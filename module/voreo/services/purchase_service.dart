import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:get/get.dart';

import '../pages/coin_store/contact_coins.dart';

class PurchaseService extends GetxService {
  static PurchaseService get to => Get.find();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // Order to coins mapping for callback
  final Map<String, int> _orderCoinsMap = {};

  // Product ID to coins mapping for query
  final Map<String, int> _productCoinsMap = {};

  // Result callback handler
  Function(String orderId, int coins, bool success, String? error)? _resultHandler;

  // Available products
  List<ProductDetails> _products = [];

  Future<bool> get isAvailable async => await _iap.isAvailable();

  Future<PurchaseService> init() async {
    // Check if IAP is available
    if (!await isAvailable) {
      debugPrint('In-App Purchase not available');
      return this;
    }

    // Listen to purchase updates
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );

    // Load products
    await loadProducts();

    return this;
  }

  Future<void> loadProducts() async {
    final Set<String> productIds = Privatised236CoinProductData
        .allProductsGrouped
        .map((product) => product.goodsId)
        .toSet();

    final ProductDetailsResponse response = await _iap.queryProductDetails(productIds);

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Products not found: ${response.notFoundIDs}');
    }

    if (response.error != null) {
      debugPrint('IAP Query Error: ${response.error}');
      return;
    }

    if (response.productDetails.isNotEmpty) {
      _products = response.productDetails;
      debugPrint('Products loaded successfully: ${_products.length}');
      for (var product in _products) {
        debugPrint('  - ${product.id}: ${product.title}');
      }
    }
  }

  List<ProductDetails> get products => _products;

  ProductDetails? getProductDetails(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  void setResultHandler(Function(String orderId, int coins, bool success, String? error) handler) {
    _resultHandler = handler;
  }

  Future<void> executePurchase({
    required String productId,
    required int coins,
    required Function(String orderId, int coins, bool success, String? error) onResult,
  }) async {
    if (!await isAvailable) {
      onResult('', 0, false, 'In-App Purchase is not available');
      return;
    }

    final productDetails = getProductDetails(productId);
    if (productDetails == null) {
      onResult('', 0, false, 'Product not found: $productId');
      return;
    }

    // Generate unique order ID
    final orderId = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';

    // Save order-coins mapping
    _orderCoinsMap[orderId] = coins;
    _productCoinsMap[productId] = coins;

    // Save result handler
    _resultHandler = onResult;

    debugPrint('Starting purchase: $orderId for product $productId ($coins coins)');

    // Execute purchase using buyNonConsumable
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);

    try {
      final bool success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      if (!success) {
        _orderCoinsMap.remove(orderId);
        _productCoinsMap.remove(productId);
        onResult(orderId, coins, false, 'Purchase initialization failed');
      }
    } catch (e) {
      _orderCoinsMap.remove(orderId);
      _productCoinsMap.remove(productId);
      onResult(orderId, coins, false, 'Purchase error: $e');
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    final productId = purchaseDetails.productID;
    final coins = _productCoinsMap[productId] ?? 0;
    final orderId = 'ORDER_${purchaseDetails.purchaseID}';

    debugPrint('Purchase status: ${purchaseDetails.status} for $productId');

    switch (purchaseDetails.status) {
      case PurchaseStatus.pending:
        debugPrint('Purchase pending for $productId');
        break;

      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        // Verify purchase on server side in production
        // For MVP, we'll deliver directly

        // Call success callback
        if (_resultHandler != null) {
          _resultHandler!(orderId, coins, true, null);
        }

        // Complete the purchase
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }

        // Clean up mappings
        _orderCoinsMap.remove(orderId);
        _productCoinsMap.remove(productId);

        debugPrint('Purchase completed: $orderId, added $coins coins');
        break;

      case PurchaseStatus.error:
        final error = purchaseDetails.error?.message ?? 'Unknown error';

        // Call error callback
        if (_resultHandler != null) {
          _resultHandler!(orderId, coins, false, error);
        }

        // Clean up mappings
        _orderCoinsMap.remove(orderId);
        _productCoinsMap.remove(productId);

        // Complete purchase even on error to clear it
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }

        debugPrint('Purchase error: $error');
        break;

      case PurchaseStatus.canceled:
        // Call canceled callback
        if (_resultHandler != null) {
          _resultHandler!(orderId, coins, false, 'Purchase canceled');
        }

        // Clean up mappings
        _orderCoinsMap.remove(orderId);
        _productCoinsMap.remove(productId);

        // Complete purchase to clear it
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }

        debugPrint('Purchase canceled by user');
        break;
    }
  }

  void _updateStreamOnDone() {
    _subscription?.cancel();
  }

  void _updateStreamOnError(dynamic error) {
    debugPrint('Purchase stream error: $error');
  }

  Future<void> restorePurchases() async {
    if (!await isAvailable) {
      debugPrint('In-App Purchase is not available');
      return;
    }

    try {
      await _iap.restorePurchases();
      debugPrint('Restore purchases initiated');
    } catch (e) {
      debugPrint('Restore purchases error: $e');
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
