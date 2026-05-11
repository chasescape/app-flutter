import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../features/coins/contact_coins.dart';

class PurchaseService extends GetxService {
  static PurchaseService get to => Get.find();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  final Map<String, int> _orderCoinsMap = {};
  void Function(bool success, String? message)? _resultHandler;
  Future<void> Function(int coins)? _addCoinsCallback;
  bool _purchaseInProgress = false;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  final Map<String, ProductDetails> _products = {};
  Map<String, ProductDetails> get products => _products;

  static final Map<String, int> productCoinMap = {
    for (final product in Privatised236CoinProductData.allProducts)
      product.code: product.exchangeCoin,
  };

  @override
  void onInit() {
    super.onInit();
    _initIAP();
  }

  Future<void> _initIAP() async {
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) return;

    _subscription = _iap.purchaseStream.listen(_handlePurchaseUpdates);
    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    final response = await _iap.queryProductDetails(productCoinMap.keys.toSet());
    for (final product in response.productDetails) {
      _products[product.id] = product;
    }
  }

  void setAddCoinsCallback(Future<void> Function(int coins) callback) {
    _addCoinsCallback = callback;
  }

  Future<void> executePurchase({
    required String productId,
    required int coins,
    required void Function(bool success, String? message) onResult,
  }) async {
    if (_purchaseInProgress) {
      onResult(false, 'A purchase is already in progress');
      return;
    }

    if (!_isAvailable) {
      onResult(false, 'In-app purchase is not available');
      return;
    }

    final product = _products[productId];
    if (product == null) {
      onResult(false, 'Product not found');
      return;
    }

    final orderId = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';
    debugPrint('PurchaseService: $orderId -> product=$productId, coins=$coins');

    _orderCoinsMap[productId] = coins;
    _resultHandler = onResult;
    _purchaseInProgress = true;

    final param = PurchaseParam(productDetails: product);
    try {
      final initiated = await _iap.buyConsumable(
        purchaseParam: param,
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
      onResult(false, 'Failed to start purchase');
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> details) {
    for (final detail in details) {
      _processDetail(detail);
    }
  }

  Future<void> _processDetail(PurchaseDetails detail) async {
    switch (detail.status) {
      case PurchaseStatus.purchased:
        final coins = _orderCoinsMap.remove(detail.productID);
        if (coins != null && _addCoinsCallback != null) {
          await _addCoinsCallback!(coins);
        }
        _resultHandler?.call(true, null);
        _resultHandler = null;
        _purchaseInProgress = false;
        break;
      case PurchaseStatus.error:
        _orderCoinsMap.remove(detail.productID);
        _resultHandler?.call(false, detail.error?.message ?? 'Purchase failed');
        _resultHandler = null;
        _purchaseInProgress = false;
        break;
      case PurchaseStatus.canceled:
        _orderCoinsMap.remove(detail.productID);
        _resultHandler?.call(false, 'Purchase canceled');
        _resultHandler = null;
        _purchaseInProgress = false;
        break;
      case PurchaseStatus.restored:
        _purchaseInProgress = false;
        break;
      default:
        break;
    }

    if (detail.pendingCompletePurchase) {
      await _iap.completePurchase(detail);
    }
  }

  Future<void> restorePurchases() async {
    if (!_isAvailable) return;
    await _iap.restorePurchases();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
