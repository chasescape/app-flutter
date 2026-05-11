import 'dart:async';
import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lenbo/lenbo/core/services/coins_manager.dart';

/// Result of a purchase attempt.
enum PurchaseResult { success, error, canceled }

/// In-app purchase service for buying coins.
/// Uses non-consumable purchases with order-coin mapping.
class PurchaseService {
  static final PurchaseService _instance = PurchaseService._();
  factory PurchaseService() => _instance;
  PurchaseService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  Future<bool>? _initializeFuture;

  /// Maps productId -> coins amount for pending purchases.
  final Map<String, int> _orderCoinsMap = {};

  /// Callback for purchase result.
  void Function(PurchaseResult result, String message)? _resultHandler;

  /// Whether IAP is available on this device.
  bool _available = false;

  /// Initialize the purchase service.
  /// This only prepares StoreKit/Billing listeners and must not trigger
  /// purchase restore automatically, otherwise iOS may show the Apple ID
  /// sign-in prompt before the user taps a product.
  Future<bool> initialize() async {
    if (_subscription != null) {
      return _available;
    }
    if (_initializeFuture != null) {
      return _initializeFuture!;
    }

    _initializeFuture = _initializeInternal();
    final result = await _initializeFuture!;
    _initializeFuture = null;
    return result;
  }

  Future<bool> _initializeInternal() async {
    _available = await _iap.isAvailable();
    if (!_available) {
      print('[PurchaseService] IAP not available on this device');
      return false;
    }

    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _subscription?.cancel(),
      onError: (error) {
        print('[PurchaseService] purchaseStream error: $error');
      },
    );

    print('[PurchaseService] initialized successfully');
    return true;
  }

  /// Execute a purchase for the given product.
  /// [productId] - App Store / Google Play product ID
  /// [coins] - Number of coins to grant on success
  /// [onResult] - Callback with purchase result
  Future<void> executePurchase({
    required String productId,
    required int coins,
    void Function(PurchaseResult result, String message)? onResult,
  }) async {
    final available = _subscription != null ? _available : await initialize();
    if (!available) {
      onResult?.call(PurchaseResult.error, 'In-app purchase is not available');
      return;
    }

    final orderId = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';
    _orderCoinsMap[productId] = coins;
    _resultHandler = onResult;

    print('[PurchaseService] Starting purchase: $orderId, product: $productId, coins: $coins');

    try {
      final response = await _iap.queryProductDetails({productId});
      if (response.notFoundIDs.isNotEmpty || response.productDetails.isEmpty) {
        _orderCoinsMap.remove(productId);
        _resultHandler = null;
        onResult?.call(PurchaseResult.error, 'Product not found');
        return;
      }

      final productDetails = response.productDetails.first;
      final purchaseParam = PurchaseParam(productDetails: productDetails);

      if (Platform.isIOS) {
        await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      } else if (Platform.isAndroid) {
        // Android uses consume flag for non-consumable too
        await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      }
    } catch (e) {
      print('[PurchaseService] Purchase error: $e');
      _orderCoinsMap.remove(productId);
      _resultHandler = null;
      onResult?.call(PurchaseResult.error, 'Purchase failed: ${e.toString()}');
    }
  }

  /// Handle purchase stream updates.
  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchaseDetails in purchaseDetailsList) {
      print('[PurchaseService] Purchase status: ${purchaseDetails.status}, product: ${purchaseDetails.productID}');

      switch (purchaseDetails.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _handlePurchased(purchaseDetails);
          break;
        case PurchaseStatus.error:
          _handleError(purchaseDetails);
          break;
        case PurchaseStatus.canceled:
          _handleCanceled(purchaseDetails);
          break;
        case PurchaseStatus.pending:
          // Payment is pending (e.g. parental approval) - wait
          break;
      }

      // Complete the purchase transaction
      if (purchaseDetails.pendingCompletePurchase) {
        await _iap.completePurchase(purchaseDetails);
      }
    }
  }

  /// Handle successful purchase - add coins.
  void _handlePurchased(PurchaseDetails purchaseDetails) {
    final productId = purchaseDetails.productID;
    final coins = _orderCoinsMap.remove(productId);

    if (coins != null) {
      CoinsManager.addCoins(coins);
      print('[PurchaseService] Added $coins coins for product: $productId');
      _resultHandler?.call(PurchaseResult.success, 'Successfully purchased $coins coins!');
    } else {
      // No mapping found (e.g. restored purchase) - still complete it
      print('[PurchaseService] No coin mapping for product: $productId, skipping coin add');
      _resultHandler?.call(PurchaseResult.success, 'Purchase restored');
    }
    _resultHandler = null;
  }

  /// Handle purchase error.
  void _handleError(PurchaseDetails purchaseDetails) {
    final productId = purchaseDetails.productID;
    _orderCoinsMap.remove(productId);
    final message = purchaseDetails.error?.message ?? 'Purchase failed';
    print('[PurchaseService] Purchase error for $productId: $message');
    _resultHandler?.call(PurchaseResult.error, message);
    _resultHandler = null;
  }

  /// Handle canceled purchase.
  void _handleCanceled(PurchaseDetails purchaseDetails) {
    final productId = purchaseDetails.productID;
    _orderCoinsMap.remove(productId);
    print('[PurchaseService] Purchase canceled: $productId');
    _resultHandler?.call(PurchaseResult.canceled, 'Purchase canceled');
    _resultHandler = null;
  }

  /// Dispose resources.
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
