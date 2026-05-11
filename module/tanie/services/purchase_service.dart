import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// PurchaseService - In-App Purchase service
/// Handles non-consumable purchases with product-coin mapping
class PurchaseService {
  PurchaseService._();
  static final PurchaseService _instance = PurchaseService._();
  factory PurchaseService() => _instance;

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Pending purchase mapping: productId -> coins amount
  final Map<String, int> _orderCoinsMap = {};

  /// Result handler callback
  Function(bool success, String? message, int? coins)? _resultHandler;

  /// Product details cache: productId -> ProductDetails
  final Map<String, ProductDetails> _products = {};

  /// Add coins callback (decoupled design)
  Function(int coins)? _addCoinsCallback;

  /// Initialize the service
  Future<bool> initialize() async {
    // Check if in-app purchase is available
    final isAvailable = await _iap.isAvailable();
    if (!isAvailable) {
      debugPrint('PurchaseService: In-app purchase not available');
      return false;
    }

    // Listen to purchase updates
    final purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );

    debugPrint('PurchaseService: Initialized successfully');
    return true;
  }

  /// Set the add coins callback (decoupled design)
  void setAddCoinsCallback(Function(int coins) callback) {
    _addCoinsCallback = callback;
  }

  /// Query products by product IDs
  Future<bool> queryProducts(Set<String> productIds) async {
    final response = await _iap.queryProductDetails(productIds);
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint(
          'PurchaseService: Products not found: ${response.notFoundIDs}');
    }

    if (response.productDetails.isEmpty) {
      debugPrint('PurchaseService: No products found');
      return false;
    }

    // Cache product details
    for (final product in response.productDetails) {
      _products[product.id] = product;
    }

    debugPrint(
        'PurchaseService: Queried ${response.productDetails.length} products');
    return true;
  }

  /// Execute purchase with product-coin mapping
  Future<void> executePurchase({
    required String productId,
    required int coins,
    required Function(bool success, String? message, int? coins) onResult,
  }) async {
    final product = _products[productId];
    if (product == null) {
      onResult(false, 'Product not found: $productId', null);
      return;
    }

    // Save the product being purchased so updates can credit the correct coins.
    _orderCoinsMap[productId] = coins;

    // Save result handler
    _resultHandler = onResult;

    // Execute non-consumable purchase
    try {
      final purchaseParam = PurchaseParam(productDetails: product);
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      // Remove mapping on error
      _orderCoinsMap.remove(productId);
      _resultHandler?.call(false, 'Purchase failed: $e', null);
      _resultHandler = null;
    }
  }

  /// Handle purchase updates
  Future<void> _onPurchaseUpdate(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }

  /// Handle individual purchase
  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    switch (purchaseDetails.status) {
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        await _handlePurchased(purchaseDetails);
        break;

      case PurchaseStatus.error:
        _handleError(purchaseDetails);
        break;

      case PurchaseStatus.canceled:
        _handleCanceled(purchaseDetails);
        break;

      case PurchaseStatus.pending:
        debugPrint('PurchaseService: Purchase pending');
        break;
    }

    // Complete the purchase
    if (purchaseDetails.pendingCompletePurchase) {
      await _iap.completePurchase(purchaseDetails);
    }
  }

  /// Handle successful purchase
  Future<void> _handlePurchased(PurchaseDetails purchaseDetails) async {
    // Find coins amount from the pending product mapping
    int? coins;

    // Match the completed purchase back to the requested product.
    for (final entry in _orderCoinsMap.entries) {
      if (purchaseDetails.productID == entry.key) {
        coins = entry.value;
        _orderCoinsMap.remove(entry.key);
        break;
      }
    }

    if (coins != null && coins > 0) {
      // Call add coins callback (decoupled design)
      if (_addCoinsCallback != null) {
        await _addCoinsCallback!(coins);
      }

      _resultHandler?.call(true, 'Purchase successful', coins);
      debugPrint('PurchaseService: Added $coins coins');
    } else {
      // No coins mapping found, might be a restore
      _resultHandler?.call(true, 'Purchase restored', null);
      debugPrint('PurchaseService: Purchase restored without coins mapping');
    }

    _resultHandler = null;
  }

  /// Handle purchase error
  void _handleError(PurchaseDetails purchaseDetails) {
    final error = purchaseDetails.error;
    if (error != null) {
      debugPrint(
          'PurchaseService: Purchase error - ${error.code} - ${error.message}');
      _resultHandler?.call(false, error.message, null);
    } else {
      _resultHandler?.call(false, 'Purchase failed', null);
    }
    _resultHandler = null;
  }

  /// Handle purchase canceled
  void _handleCanceled(PurchaseDetails purchaseDetails) {
    debugPrint('PurchaseService: Purchase canceled');

    // Remove mapping for this purchase
    _orderCoinsMap
        .removeWhere((key, value) => purchaseDetails.productID == key);

    _resultHandler?.call(false, 'Purchase canceled', null);
    _resultHandler = null;
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    try {
      await _iap.restorePurchases();
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

  /// Dispose the service
  void dispose() {
    _subscription?.cancel();
    _orderCoinsMap.clear();
    _products.clear();
    _addCoinsCallback = null;
    _resultHandler = null;
  }

  /// Get cached product by ID
  ProductDetails? getProduct(String productId) {
    return _products[productId];
  }

  /// Get all cached products
  Map<String, ProductDetails> get products => Map.unmodifiable(_products);

  /// Check if product is available
  bool isProductAvailable(String productId) {
    return _products.containsKey(productId);
  }
}

/// Global instance
final purchaseService = PurchaseService();
