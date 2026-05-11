import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  final Map<String, int> _orderCoinsMap = {};
  final Map<String, ProductDetails> _productDetailsMap = {};

  Function(int coins, String orderId)? _resultHandler;
  Function(String error)? _errorHandler;
  Function()? _cancelHandler;

  Future<void> initialize() async {
    final bool isAvailable = await _iap.isAvailable();
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
  }

  Future<void> loadProducts(List<String> productIds) async {
    if (!_isAvailable) {
      debugPrint('Cannot load products: IAP not available');
      return;
    }

    final ProductDetailsResponse response = await _iap.queryProductDetails(productIds.toSet());

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Products not found: ${response.notFoundIDs}');
    }

    if (response.error != null) {
      debugPrint('Error loading products: ${response.error}');
      return;
    }

    for (var product in response.productDetails) {
      _productDetailsMap[product.id] = product;
    }

    debugPrint('Loaded ${response.productDetails.length} products');
  }

  Future<void> executePurchase({
    required String productId,
    required int coins,
    required Function(int coins, String orderId) onResult,
    Function(String error)? onError,
    Function()? onCancel,
  }) async {
    if (!_isAvailable) {
      onError?.call('In-app purchase not available');
      return;
    }

    final productDetails = _productDetailsMap[productId];
    if (productDetails == null) {
      onError?.call('Product not found: $productId');
      return;
    }

    final orderId = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';
    _orderCoinsMap[orderId] = coins;
    _resultHandler = onResult;
    _errorHandler = onError;
    _cancelHandler = onCancel;

    try {
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('Purchase error: $e');
      _orderCoinsMap.remove(orderId);
      onError?.call('Purchase failed: $e');
    }
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    switch (purchaseDetails.status) {
      case PurchaseStatus.pending:
        debugPrint('Purchase pending: ${purchaseDetails.productID}');
        break;

      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        await _deliverProduct(purchaseDetails);
        break;

      case PurchaseStatus.error:
        _handleError(purchaseDetails.error!);
        await _clearOrder(purchaseDetails);
        break;

      case PurchaseStatus.canceled:
        _handleCancel();
        await _clearOrder(purchaseDetails);
        break;
    }

    if (purchaseDetails.pendingCompletePurchase) {
      await _iap.completePurchase(purchaseDetails);
    }
  }

  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    final orderId = purchaseDetails.purchaseID ?? 'ORDER_${DateTime.now().millisecondsSinceEpoch}';

    final coins = _orderCoinsMap.values.firstOrNull ?? 0;

    if (coins > 0 && _resultHandler != null) {
      await _savePurchaseHistory(purchaseDetails.productID, coins, orderId);
      _resultHandler!(coins, orderId);
    }

    await _clearOrder(purchaseDetails);
  }

  void _handleError(IAPError error) {
    debugPrint('Purchase error: ${error.code} - ${error.message}');
    _errorHandler?.call(error.message);
  }

  void _handleCancel() {
    debugPrint('Purchase canceled');
    _cancelHandler?.call();
  }

  Future<void> _clearOrder(PurchaseDetails purchaseDetails) async {
    _orderCoinsMap.removeWhere((key, value) => key.startsWith('ORDER_'));
    _resultHandler = null;
    _errorHandler = null;
    _cancelHandler = null;

    if (purchaseDetails.pendingCompletePurchase) {
      await _iap.completePurchase(purchaseDetails);
    }
  }

  Future<void> _savePurchaseHistory(String productId, int coins, String orderId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList('purchase_history') ?? [];
    history.add('$productId|$coins|$orderId|${DateTime.now().toIso8601String()}');
    await prefs.setStringList('purchase_history', history);
  }

  Future<List<PurchaseRecord>> getPurchaseHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList('purchase_history') ?? [];

    return history.map((record) {
      final parts = record.split('|');
      return PurchaseRecord(
        productId: parts[0],
        coins: int.parse(parts[1]),
        orderId: parts[2],
        timestamp: DateTime.parse(parts[3]),
      );
    }).toList();
  }

  void _updateStreamOnDone() {
    _subscription?.cancel();
  }

  void _updateStreamOnError(dynamic error) {
    debugPrint('Purchase stream error: $error');
  }

  void dispose() {
    _subscription?.cancel();
  }
}

class PurchaseRecord {
  final String productId;
  final int coins;
  final String orderId;
  final DateTime timestamp;

  PurchaseRecord({
    required this.productId,
    required this.coins,
    required this.orderId,
    required this.timestamp,
  });
}
