import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

typedef PurchaseResultCallback = void Function({
  required bool success,
  required int coins,
  String? errorMessage,
});

class PurchaseService extends GetxService {
  static PurchaseService get to => Get.find();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  Future<void>? _initializeFuture;

  final Map<String, int> _orderCoinsMap = {};
  PurchaseResultCallback? _resultHandler;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  @override
  void onInit() {
    super.onInit();
    _initializeFuture = _initialize();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  Future<void> _initialize() async {
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

    debugPrint('PurchaseService initialized');
  }

  Future<void> loadProducts(Set<String> productIds) async {
    await _ensureInitialized();

    if (!_isAvailable) {
      debugPrint('Cannot load products: IAP not available');
      return;
    }

    final ProductDetailsResponse response =
        await _iap.queryProductDetails(productIds);

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Products not found: ${response.notFoundIDs}');
    }

    if (response.error != null) {
      debugPrint('Product query error: ${response.error}');
      return;
    }

    _products = response.productDetails;
    debugPrint('Loaded ${_products.length} products');
  }

  ProductDetails? getProductById(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  Future<void> executePurchase({
    required String productId,
    required int coins,
    required PurchaseResultCallback onResult,
  }) async {
    await _ensureInitialized();

    if (!_isAvailable) {
      onResult(
        success: false,
        coins: coins,
        errorMessage: 'In-app purchase not available',
      );
      return;
    }

    ProductDetails? product = getProductById(productId);
    if (product == null) {
      await loadProducts({productId});
      product = getProductById(productId);
    }

    if (product == null) {
      onResult(
        success: false,
        coins: coins,
        errorMessage: 'Product not found in the store: $productId',
      );
      return;
    }

    _orderCoinsMap[productId] = coins;
    _resultHandler = onResult;

    debugPrint('Starting purchase: $productId -> $coins coins');

    try {
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: product);
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('Purchase error: $e');
      _orderCoinsMap.remove(productId);
      _resultHandler = null;
      onResult(
        success: false,
        coins: coins,
        errorMessage: 'Purchase failed: ${e.toString()}',
      );
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    debugPrint(
        'Purchase status: ${purchaseDetails.status} for ${purchaseDetails.productID}');

    switch (purchaseDetails.status) {
      case PurchaseStatus.pending:
        debugPrint('Purchase pending: ${purchaseDetails.productID}');
        break;

      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        await _deliverProduct(purchaseDetails);
        break;

      case PurchaseStatus.error:
        _handleError(purchaseDetails);
        break;

      case PurchaseStatus.canceled:
        _handleCanceled(purchaseDetails);
        break;
    }

    if (purchaseDetails.pendingCompletePurchase) {
      await _completePurchase(purchaseDetails);
    }
  }

  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    debugPrint('Delivering product: ${purchaseDetails.productID}');

    final int coins = _orderCoinsMap.remove(purchaseDetails.productID) ?? 0;

    if (_resultHandler != null) {
      _resultHandler!(
        success: true,
        coins: coins,
      );
      _resultHandler = null;
    }

    debugPrint('Product delivered: $coins coins');
  }

  void _handleError(PurchaseDetails purchaseDetails) {
    debugPrint('Purchase error: ${purchaseDetails.error}');

    final int coins = _orderCoinsMap.remove(purchaseDetails.productID) ?? 0;

    if (_resultHandler != null) {
      _resultHandler!(
        success: false,
        coins: coins,
        errorMessage: purchaseDetails.error?.message ?? 'Purchase failed',
      );
      _resultHandler = null;
    }
  }

  void _handleCanceled(PurchaseDetails purchaseDetails) {
    debugPrint('Purchase canceled: ${purchaseDetails.productID}');

    _orderCoinsMap.remove(purchaseDetails.productID);

    if (_resultHandler != null) {
      _resultHandler!(
        success: false,
        coins: 0,
        errorMessage: 'Purchase canceled',
      );
      _resultHandler = null;
    }
  }

  Future<void> _completePurchase(PurchaseDetails purchaseDetails) async {
    try {
      await _iap.completePurchase(purchaseDetails);
      debugPrint('Purchase completed: ${purchaseDetails.productID}');
    } catch (e) {
      debugPrint('Failed to complete purchase: $e');
    }
  }

  void _updateStreamOnDone() {
    _subscription?.cancel();
    debugPrint('Purchase stream closed');
  }

  void _updateStreamOnError(dynamic error) {
    debugPrint('Purchase stream error: $error');
  }

  Future<void> restorePurchases() async {
    await _ensureInitialized();

    if (!_isAvailable) return;

    try {
      await _iap.restorePurchases();
      debugPrint('Restore purchases triggered');
    } catch (e) {
      debugPrint('Restore purchases error: $e');
    }
  }

  Future<void> _ensureInitialized() async {
    _initializeFuture ??= _initialize();
    await _initializeFuture;
  }
}
