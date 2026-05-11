import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../features/coin_shop/views/contact_coins.dart';

class PurchaseService {
  PurchaseService._();

  static PurchaseService? _instance;

  static PurchaseService get instance {
    _instance ??= PurchaseService._();
    return _instance!;
  }

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  final Map<String, int> _orderCoinsMap = {};
  Function(bool success, String? error)? _resultHandler;
  Function(int coins)? _addCoinsCallback;
  bool _purchaseInProgress = false;
  bool _isInitialized = false;
  bool _isAvailable = false;
  final Map<String, ProductDetails> _products = {};

  static final Set<String> _productIds = {
    for (final product in Privatised236CoinProductData.allProducts) product.goodsId,
  };

  Future<bool> get isAvailable async {
    if (_isInitialized) {
      return _isAvailable;
    }
    _isAvailable = await _iap.isAvailable();
    return _isAvailable;
  }

  Future<void> init({
    required Function(int coins) addCoinsCallback,
  }) async {
    _addCoinsCallback = addCoinsCallback;
    if (_isInitialized) return;

    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) {
      _isInitialized = true;
      return;
    }

    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;

    _subscription = purchaseUpdated.listen(
      _listenToPurchaseUpdated,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );

    await _loadProducts();
    _isInitialized = true;
  }

  Future<void> executePurchase(
    String productId,
    int coins, {
    required Function(bool success, String? error) onResult,
  }) async {
    if (_purchaseInProgress) {
      onResult(false, 'A purchase is already in progress');
      return;
    }

    final available = await isAvailable;
    if (!available) {
      onResult(false, 'In-app purchase not available');
      return;
    }

    if (_products.isEmpty) {
      await _loadProducts();
    }

    try {
      final ProductDetails? productDetails = _products[productId];
      if (productDetails == null) {
        onResult(false, 'Product not found');
        return;
      }

      _orderCoinsMap[productId] = coins;
      _resultHandler = onResult;
      _purchaseInProgress = true;

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );

      final bool initiated = await _iap.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );

      if (!initiated) {
        _orderCoinsMap.remove(productId);
        _resultHandler = null;
        _purchaseInProgress = false;
        onResult(false, 'Failed to initiate purchase');
      }
    } catch (e) {
      _orderCoinsMap.remove(productId);
      _resultHandler = null;
      _purchaseInProgress = false;
      onResult(false, e.toString());
    }
  }

  Future<void> _loadProducts() async {
    final ProductDetailsResponse response =
        await _iap.queryProductDetails(_productIds);

    _products
      ..clear()
      ..addEntries(
        response.productDetails.map(
          (product) => MapEntry(product.id, product),
        ),
      );

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('IAP not found IDs: ${response.notFoundIDs.join(', ')}');
    }

    if (response.error != null) {
      debugPrint('IAP query error: ${response.error!.message}');
    }
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      await _handlePurchase(purchaseDetails);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    final productId = purchaseDetails.productID;
    final coins = _orderCoinsMap[productId];

    if (coins == null) {
      await _completePurchase(purchaseDetails);
      return;
    }

    switch (purchaseDetails.status) {
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        try {
          if (_addCoinsCallback != null) {
            await _addCoinsCallback!(coins);
          }
          _resultHandler?.call(true, null);
          _orderCoinsMap.remove(productId);
          _resultHandler = null;
          _purchaseInProgress = false;
        } catch (e) {
          _resultHandler?.call(false, e.toString());
          _resultHandler = null;
          _purchaseInProgress = false;
        }
        await _completePurchase(purchaseDetails);
        break;

      case PurchaseStatus.error:
        _resultHandler?.call(
          false,
          purchaseDetails.error?.message ?? 'Purchase failed',
        );
        _orderCoinsMap.remove(productId);
        _resultHandler = null;
        _purchaseInProgress = false;
        await _completePurchase(purchaseDetails);
        break;

      case PurchaseStatus.canceled:
        _resultHandler?.call(false, 'Purchase canceled');
        _orderCoinsMap.remove(productId);
        _resultHandler = null;
        _purchaseInProgress = false;
        await _completePurchase(purchaseDetails);
        break;

      case PurchaseStatus.pending:
        break;
    }
  }

  Future<void> _completePurchase(PurchaseDetails purchaseDetails) async {
    try {
      if (purchaseDetails.pendingCompletePurchase) {
        await _iap.completePurchase(purchaseDetails);
      }
    } catch (e) {
      debugPrint('Complete purchase error: $e');
    }
  }

  void _updateStreamOnDone() {
    _subscription?.cancel();
  }

  void _updateStreamOnError(dynamic error) {
    debugPrint('Purchase stream error: $error');
  }

  Future<void> dispose() async {
    _subscription?.cancel();
  }
}
