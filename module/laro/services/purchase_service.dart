import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef PurchaseResultCallback = void Function(bool success, String? message);

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  final Map<String, int> _orderCoinsMap = {};
  PurchaseResultCallback? _resultHandler;
  late final SharedPreferences prefs;

  bool _isAvailable = false;
  bool _isInitialized = false;
  bool get isAvailable => _isAvailable;

  Function(int)? _addCoinsCallback;

  Future<void> initialize({Function(int)? onCoinsAdded}) async {
    _addCoinsCallback = onCoinsAdded;

    if (_isInitialized) {
      return;
    }

    prefs = await SharedPreferences.getInstance();

    final isAvailable = await _iap.isAvailable();
    _isAvailable = isAvailable;

    if (!isAvailable) {
      debugPrint('In-app purchase not available');
      return;
    }

    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );
    _isInitialized = true;
  }

  Future<void> executePurchase(
    String productId,
    int coins,
    PurchaseResultCallback onResult,
  ) async {
    if (!_isAvailable) {
      onResult(false, 'In-app purchase not available');
      return;
    }

    _orderCoinsMap[productId] = coins;
    _resultHandler = onResult;

    try {
      final ProductDetailsResponse response =
          await _iap.queryProductDetails({productId});
      if (response.notFoundIDs.isNotEmpty) {
        _resultHandler?.call(false, 'Product not found');
        _orderCoinsMap.remove(productId);
        return;
      }

      if (response.productDetails.isEmpty) {
        _resultHandler?.call(false, 'No product details available');
        _orderCoinsMap.remove(productId);
        return;
      }

      final ProductDetails productDetails = response.productDetails.first;
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: productDetails);

      await _iap.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );
    } catch (e) {
      _resultHandler?.call(false, 'Purchase failed: $e');
      _orderCoinsMap.remove(productId);
    }
  }

  Future<void> _onPurchaseUpdate(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    switch (purchaseDetails.status) {
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        await _deliverProduct(purchaseDetails);
        break;
      case PurchaseStatus.error:
        _handleError(purchaseDetails.error!);
        break;
      case PurchaseStatus.canceled:
        _handleCancel(purchaseDetails);
        break;
      case PurchaseStatus.pending:
        debugPrint('Purchase pending: ${purchaseDetails.productID}');
        break;
    }

    if (purchaseDetails.pendingCompletePurchase) {
      await _iap.completePurchase(purchaseDetails);
    }
  }

  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    final coins = _orderCoinsMap.remove(purchaseDetails.productID);
    if (coins != null) {
      _addCoinsCallback?.call(coins);
      _resultHandler?.call(true, 'Successfully purchased $coins coins');
    } else {
      _resultHandler?.call(false, 'Purchase completed but no coins mapped');
    }
  }

  void _handleError(IAPError error) {
    _orderCoinsMap.clear();
    _resultHandler?.call(false, 'Purchase failed: ${error.message}');
  }

  void _handleCancel(PurchaseDetails purchaseDetails) {
    _orderCoinsMap.remove(purchaseDetails.productID);
    _resultHandler?.call(false, 'Purchase canceled');
  }

  void _updateStreamOnDone() {
    _subscription?.cancel();
    _isInitialized = false;
  }

  void _updateStreamOnError(dynamic error) {
    debugPrint('Purchase stream error: $error');
  }

  void dispose() {
    _subscription?.cancel();
    _orderCoinsMap.clear();
    _resultHandler = null;
    _addCoinsCallback = null;
    _isInitialized = false;
  }
}
