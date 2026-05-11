import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../features/coin_store/contact_coins.dart';

class PurchaseService {
  static PurchaseService? _instance;

  static PurchaseService get instance {
    _instance ??= PurchaseService._internal();
    return _instance!;
  }

  PurchaseService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isInitializing = false;
  bool _hasInitialized = false;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  final Map<String, int> _orderCoinsMap = {};
  final Map<String, ProductDetails> _productDetailsMap = {};

  Function(int coins)? _addCoinsCallback;
  Function(String error)? _onError;
  Function()? _onCanceled;

  Future<void> initialize({
    Function(int coins)? onCoinsAdded,
    Function(String error)? onError,
    Function()? onCanceled,
  }) async {
    _addCoinsCallback = onCoinsAdded;
    _onError = onError;
    _onCanceled = onCanceled;

    if (_isInitializing) {
      return;
    }

    if (_hasInitialized) {
      if (_productDetailsMap.isEmpty && _isAvailable) {
        await _loadProductDetails();
      }
      return;
    }

    _isInitializing = true;

    try {
      final isAvailable = await _iap.isAvailable();
      _isAvailable = isAvailable;

      if (!isAvailable) {
        debugPrint('In-app purchase not available');
        return;
      }

      if (_subscription == null) {
        final purchaseStream = _iap.purchaseStream;
        _subscription = purchaseStream.listen(
          _onPurchaseUpdate,
          onDone: _updateStreamOnDone,
          onError: _updateStreamOnError,
        );
      }

      await _loadProductDetails();
      _hasInitialized = true;
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _loadProductDetails() async {
    final productIds = Privatised236CoinProductData.allProductsGrouped
        .map((product) => product.code)
        .toSet();

    final ProductDetailsResponse response =
        await _iap.queryProductDetails(productIds);

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Products not found: ${response.notFoundIDs}');
    }

    if (response.error != null) {
      debugPrint('Error loading products: ${response.error}');
      return;
    }

    _productDetailsMap.clear();

    for (final product in response.productDetails) {
      _productDetailsMap[product.id] = product;
    }
  }

  Future<void> executePurchase(
    String productId,
    int coins, {
    Function(String orderId)? onResult,
  }) async {
    if (!_isAvailable) {
      _onError?.call('In-app purchase not available');
      return;
    }

    final product = _productDetailsMap[productId];
    if (product == null) {
      _onError?.call('Product not found: $productId');
      return;
    }

    _orderCoinsMap[productId] = coins;
    _resultHandler = onResult;

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);

    try {
      await _iap.buyConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('Purchase error: $e');
      _orderCoinsMap.remove(productId);
      _resultHandler = null;
      _onError?.call('Purchase failed: $e');
    }
  }

  Function(String orderId)? _resultHandler;

  Future<void> _onPurchaseUpdate(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);

      if (purchaseDetails.pendingCompletePurchase) {
        await _iap.completePurchase(purchaseDetails);
      }
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
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
        debugPrint('Purchase pending: ${purchaseDetails.productID}');
        break;
    }
  }

  Future<void> _handleSuccess(PurchaseDetails purchaseDetails) async {
    final productId = purchaseDetails.productID;
    final purchaseId = purchaseDetails.purchaseID ?? productId;

    if (_orderCoinsMap.containsKey(productId)) {
      final coins = _orderCoinsMap[productId]!;
      _orderCoinsMap.remove(productId);

      _addCoinsCallback?.call(coins);
      _resultHandler?.call(purchaseId);
      _resultHandler = null;
      debugPrint('Purchase successful: $purchaseId, coins added: $coins');
    } else {
      _resultHandler = null;
      debugPrint('Purchase successful but order not found: $purchaseId');
    }
  }

  void _handleError(PurchaseDetails purchaseDetails) {
    final error = purchaseDetails.error;
    _orderCoinsMap.remove(purchaseDetails.productID);
    _resultHandler = null;
    if (error != null) {
      _onError?.call(error.message);
      debugPrint('Purchase error: ${error.message} (${error.code})');
    }
  }

  void _handleCanceled(PurchaseDetails purchaseDetails) {
    _orderCoinsMap.remove(purchaseDetails.productID);
    _resultHandler = null;
    _onCanceled?.call();
    debugPrint('Purchase canceled: ${purchaseDetails.productID}');
  }

  void _updateStreamOnDone() {
    _subscription?.cancel();
  }

  void _updateStreamOnError(dynamic error) {
    debugPrint('Purchase stream error: $error');
  }

  ProductDetails? getProductDetails(String productId) {
    return _productDetailsMap[productId];
  }

  List<ProductDetails> getAllProducts() {
    return _productDetailsMap.values.toList();
  }

  void dispose() {
    _subscription?.cancel();
  }
}
