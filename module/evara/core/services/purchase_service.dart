import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../singletons/coins_manager.dart';
import '../../pages/coin_store/contact_coins.dart';

/// Purchase Result Status
enum PurchaseResultStatus {
  success,
  pending,
  canceled,
  error,
}

/// Purchase Result Callback
typedef PurchaseResultCallback = void Function(
  PurchaseResultStatus status,
  String? message,
  int? coinsAdded,
);

/// In-App Purchase Service
/// Handles non-consumable purchases with coin mapping
class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  final CoinsManager _coinsManager = CoinsManager.instance;

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isAvailable = false;
  bool _isInitialized = false;

  List<ProductDetails> _products = [];

  // Order-Coins mapping: tracks pending purchase coin amounts
  final Map<String, int> _orderCoinsMap = {};

  // Current purchase result callback
  PurchaseResultCallback? _resultHandler;

  // Set of processed transaction IDs to prevent duplicate coin delivery
  final Set<String> _processedTransactions = {};

  // Pending purchases waiting to be completed
  final List<PurchaseDetails> _pendingPurchases = [];

  // Initialize the purchase service
  Future<bool> initialize() async {
    if (_isInitialized) return _isAvailable;

    final isAvailable = await _iap.isAvailable();
    _isAvailable = isAvailable;

    if (isAvailable) {
      _subscription = _iap.purchaseStream.listen(
        _handlePurchaseUpdates,
        onDone: _updateStreamOnDone,
        onError: _updateStreamOnError,
      );

      await _loadProducts();
    }

    _isInitialized = true;
    return _isAvailable;
  }

  void _updateStreamOnDone() {
    _subscription?.cancel();
  }

  void _updateStreamOnError(dynamic error) {
    debugPrint('Purchase stream error: $error');
  }

  // Load available products from store
  Future<void> _loadProducts() async {
    final Set<String> productIds = Privatised236CoinProductData.allProducts
        .map((product) => product.code)
        .toSet();

    final ProductDetailsResponse response = await _iap.queryProductDetails(productIds);

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Products not found: ${response.notFoundIDs}');
    }

    if (response.error != null) {
      debugPrint('Product query error: ${response.error}');
    }

    if (response.productDetails.isNotEmpty) {
      _products = response.productDetails;
    }
  }

  // Get available products
  List<ProductDetails> get products => _products;

  // Check if purchase service is available
  bool get isAvailable => _isAvailable;

  // Execute purchase with coin mapping
  Future<void> executePurchase(
    String productId,
    int coins,
    PurchaseResultCallback onResult,
  ) async {
    if (!_isAvailable) {
      onResult(PurchaseResultStatus.error, 'In-app purchases not available', null);
      return;
    }

    final product = _products.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw Exception('Product not found: $productId'),
    );

    await _cleanPendingPurchases();

    _orderCoinsMap[productId] = coins;
    _resultHandler = onResult;

    try {
      await _iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: product));
    } catch (e) {
      _orderCoinsMap.remove(productId);
      _resultHandler = null;
      onResult(PurchaseResultStatus.error, 'Purchase failed: $e', null);
    }
  }

  // Clean pending purchases before new purchase
  Future<void> _cleanPendingPurchases() async {
    try {
      await _iap.restorePurchases();
      await Future.delayed(const Duration(milliseconds: 500));

      for (final purchase in _pendingPurchases) {
        if (purchase.pendingCompletePurchase) {
          try {
            await _iap.completePurchase(purchase);
          } catch (e) {
            debugPrint('Error completing pending purchase: $e');
          }
        }
      }
      _pendingPurchases.clear();
    } catch (e) {
      debugPrint('Error cleaning pending purchases: $e');
    }
  }

  // Handle purchase updates from stream
  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      _processPurchaseUpdate(purchaseDetails);
    }
  }

  // Process individual purchase update
  Future<void> _processPurchaseUpdate(PurchaseDetails purchaseDetails) async {
    switch (purchaseDetails.status) {
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        await _handleSuccessfulPurchase(purchaseDetails);
        break;

      case PurchaseStatus.error:
        await _handleErrorPurchase(purchaseDetails);
        break;

      case PurchaseStatus.canceled:
        await _handleCanceledPurchase(purchaseDetails);
        break;

      case PurchaseStatus.pending:
        _handlePendingPurchase(purchaseDetails);
        break;
    }
  }

  // Handle successful purchase
  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
    final String productId = purchaseDetails.productID;
    final String? transactionId = purchaseDetails.purchaseID;

    if (transactionId != null && _processedTransactions.contains(transactionId)) {
      if (purchaseDetails.pendingCompletePurchase) {
        await _completePurchase(purchaseDetails);
      }
      return;
    }

    final int? coins = _orderCoinsMap.remove(productId);

    if (coins != null && coins > 0) {
      await _coinsManager.addCoins(coins);

      if (transactionId != null) {
        _processedTransactions.add(transactionId);
      }

      _resultHandler?.call(PurchaseResultStatus.success, 'Purchase successful', coins);
    } else {
      _resultHandler?.call(PurchaseResultStatus.success, 'Purchase restored', 0);
    }

    await _completePurchase(purchaseDetails);
    _clearCurrentCallback();
  }

  // Handle error purchase
  Future<void> _handleErrorPurchase(PurchaseDetails purchaseDetails) async {
    final String productId = purchaseDetails.productID;
    _orderCoinsMap.remove(productId);

    final error = purchaseDetails.error ?? Exception('Unknown error');
    _resultHandler?.call(PurchaseResultStatus.error, error.toString(), null);

    await _completePurchase(purchaseDetails);
    _clearCurrentCallback();
  }

  // Handle canceled purchase
  Future<void> _handleCanceledPurchase(PurchaseDetails purchaseDetails) async {
    final String productId = purchaseDetails.productID;
    _orderCoinsMap.remove(productId);

    _resultHandler?.call(PurchaseResultStatus.canceled, 'Purchase canceled', null);

    await _completePurchase(purchaseDetails);
    _clearCurrentCallback();
  }

  // Handle pending purchase
  void _handlePendingPurchase(PurchaseDetails purchaseDetails) {
    _pendingPurchases.add(purchaseDetails);
    _resultHandler?.call(PurchaseResultStatus.pending, 'Payment is processing', null);
  }

  // Complete purchase with the store
  Future<void> _completePurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.pendingCompletePurchase) {
      try {
        await _iap.completePurchase(purchaseDetails);
        _pendingPurchases.remove(purchaseDetails);
      } catch (e) {
        debugPrint('Error completing purchase: $e');
      }
    }
  }

  // Clear current purchase callback
  void _clearCurrentCallback() {
    _resultHandler = null;
  }

  // Restore previous purchases
  Future<void> restorePurchases() async {
    if (!_isAvailable) return;

    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('Restore purchases error: $e');
    }
  }

  // Dispose and cleanup
  void dispose() {
    _subscription?.cancel();
    _orderCoinsMap.clear();
    _resultHandler = null;
    _processedTransactions.clear();
    _pendingPurchases.clear();
  }
}
