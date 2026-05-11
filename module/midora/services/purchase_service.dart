import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Purchase Service - In-app purchase management
/// Handles non-consumable purchases with coin mapping
class PurchaseService {
  PurchaseService._();

  static PurchaseService? _instance;
  static PurchaseService get I => _instance ??= PurchaseService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // Purchase availability
  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  // Order to coins mapping (for callback decoupling)
  final Map<String, int> _orderCoinsMap = {};

  // Product ID to coins mapping
  final Map<String, int> _productCoinsMap = {
    'coin_100': 100,
    'coin_500': 500,
    'coin_1000': 1000,
    'coin_2000': 2000,
  };

  // Result callback (for decoupling)
  Function(bool success, int coins, String? error)? _resultHandler;

  // Add coins callback (set by UI layer)
  Function(int coins)? _addCoinsCallback;

  /// Initialize purchase service
  Future<bool> initialize() async {
    // Check availability
    _isAvailable = await _iap.isAvailable();

    if (!_isAvailable) {
      debugPrint('PurchaseService: In-app purchase not available');
      return false;
    }

    // Listen to purchase updates
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );

    debugPrint('PurchaseService: Initialized successfully');
    return true;
  }

  /// Set add coins callback (called from UI layer)
  void setAddCoinsCallback(Function(int coins) callback) {
    _addCoinsCallback = callback;
  }

  /// Execute purchase
  /// [productId] - Product ID from App Store Connect
  /// [coins] - Amount of coins to add after successful purchase
  /// [onResult] - Callback for purchase result
  Future<void> executePurchase({
    required String productId,
    required int coins,
    required Function(bool success, int coins, String? error) onResult,
  }) async {
    if (!_isAvailable) {
      onResult(false, 0, 'In-app purchase not available');
      return;
    }

    // Generate order ID
    final orderId = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';

    // Save mappings
    _orderCoinsMap[orderId] = coins;
    _productCoinsMap[productId] = coins;
    _resultHandler = onResult;

    debugPrint('PurchaseService: Starting purchase - Product: $productId, Order: $orderId, Coins: $coins');

    // Get product and purchase
    try {
      final ProductDetailsResponse response = await _iap.queryProductDetails({productId});

      if (response.notFoundIDs.isNotEmpty) {
        final error = 'Product $productId not found';
        debugPrint('PurchaseService: $error');
        _resultHandler?.call(false, 0, error);
        _cleanup();
        return;
      }

      if (response.productDetails.isEmpty) {
        final error = 'No product details available';
        debugPrint('PurchaseService: $error');
        _resultHandler?.call(false, 0, error);
        _cleanup();
        return;
      }

      final ProductDetails productDetails = response.productDetails.first;
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);

      // Execute non-consumable purchase
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('PurchaseService: Purchase failed with error: $e');
      _resultHandler?.call(false, 0, e.toString());
      _cleanup();
    }
  }

  /// Handle purchase updates
  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }

  /// Handle individual purchase
  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    debugPrint('PurchaseService: Purchase update - Status: ${purchaseDetails.status}, Product: ${purchaseDetails.productID}');

    switch (purchaseDetails.status) {
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        await _handleSuccess(purchaseDetails);
        break;

      case PurchaseStatus.error:
        _handleError(purchaseDetails);
        break;

      case PurchaseStatus.canceled:
        _handleCanceled(purchaseDetails);
        break;

      case PurchaseStatus.pending:
        debugPrint('PurchaseService: Purchase pending - ${purchaseDetails.productID}');
        break;
    }

    // Complete the purchase
    if (purchaseDetails.pendingCompletePurchase) {
      try {
        await _iap.completePurchase(purchaseDetails);
        debugPrint('PurchaseService: Purchase completed - ${purchaseDetails.productID}');
      } catch (e) {
        debugPrint('PurchaseService: Failed to complete purchase - $e');
      }
    }
  }

  /// Handle successful purchase
  Future<void> _handleSuccess(PurchaseDetails purchaseDetails) async {
    final coins = _productCoinsMap[purchaseDetails.productID] ?? 0;

    debugPrint('PurchaseService: Purchase successful - Product: ${purchaseDetails.productID}, Coins: $coins');

    // Add coins via callback
    if (_addCoinsCallback != null) {
      try {
        _addCoinsCallback!(coins);
        debugPrint('PurchaseService: Added $coins coins via callback');
      } catch (e) {
        debugPrint('PurchaseService: Failed to add coins - $e');
      }
    }

    // Notify success
    _resultHandler?.call(true, coins, null);
    _cleanup();
  }

  /// Handle purchase error
  void _handleError(PurchaseDetails purchaseDetails) {
    final error = purchaseDetails.error ?? 'Unknown error';
    if (error is IAPError) {
      debugPrint('PurchaseService: Purchase error - ${error.code}: ${error.message}');
      _resultHandler?.call(false, 0, error.message);
    } else {
      debugPrint('PurchaseService: Purchase error - $error');
      _resultHandler?.call(false, 0, error.toString());
    }
    _cleanup();
  }

  /// Handle canceled purchase
  void _handleCanceled(PurchaseDetails purchaseDetails) {
    debugPrint('PurchaseService: Purchase canceled - ${purchaseDetails.productID}');

    // Remove mapping
    _orderCoinsMap.removeWhere((key, value) => key.contains(purchaseDetails.productID));

    _resultHandler?.call(false, 0, 'Purchase canceled');
    _cleanup();
  }

  /// Cleanup after purchase
  void _cleanup() {
    _resultHandler = null;
  }

  /// Query product details
  Future<ProductDetailsResponse> queryProducts(Set<String> productIds) async {
    if (!_isAvailable) {
      return ProductDetailsResponse(
        productDetails: [],
        notFoundIDs: productIds.toList(),
      );
    }

    return await _iap.queryProductDetails(productIds);
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    if (!_isAvailable) {
      debugPrint('PurchaseService: Cannot restore - service not available');
      return;
    }

    try {
      await _iap.restorePurchases();
      debugPrint('PurchaseService: Restore purchases initiated');
    } catch (e) {
      debugPrint('PurchaseService: Restore failed - $e');
    }
  }

  /// Update stream done callback
  void _updateStreamOnDone() {
    _subscription?.cancel();
    debugPrint('PurchaseService: Purchase stream closed');
  }

  /// Update stream error callback
  void _updateStreamOnError(dynamic error) {
    debugPrint('PurchaseService: Purchase stream error - $error');
  }

  /// Dispose
  void dispose() {
    _subscription?.cancel();
    _orderCoinsMap.clear();
    _resultHandler = null;
    _addCoinsCallback = null;
  }
}


/// Coin Package Model
class CoinPackage {
  final String id;
  final String productId;
  final int coins;
  final double price;
  final String? bonusLabel;
  final bool? isBestValue;
  final bool? isPopular;

  CoinPackage({
    required this.id,
    required this.productId,
    required this.coins,
    required this.price,
    this.bonusLabel,
    this.isBestValue,
    this.isPopular,
  });

  CoinPackage copyWith({
    String? id,
    String? productId,
    int? coins,
    double? price,
    String? bonusLabel,
    bool? isBestValue,
    bool? isPopular,
  }) {
    return CoinPackage(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      coins: coins ?? this.coins,
      price: price ?? this.price,
      bonusLabel: bonusLabel ?? this.bonusLabel,
      isBestValue: isBestValue ?? this.isBestValue,
      isPopular: isPopular ?? this.isPopular,
    );
  }
}
