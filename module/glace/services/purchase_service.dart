import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseService {
  PurchaseService._();

  static final PurchaseService _instance = PurchaseService._();

  static PurchaseService get instance => _instance;

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isAvailable = false;
  bool _isInitialized = false;

  final Map<String, int> _coinsByProductId = {};
  final Map<String, void Function(bool success, String? error)>
      _resultHandlers = {};

  bool get isAvailable => _isAvailable;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) return;

    _subscription = _iap.purchaseStream.listen(_handlePurchases);
  }

  Future<ProductDetailsResponse> queryProducts(Set<String> productIds) {
    return _iap.queryProductDetails(productIds);
  }

  Future<void> buyConsumable({
    required ProductDetails product,
    required int coins,
    required void Function(bool success, String? error) onResult,
  }) async {
    if (!_isAvailable) {
      onResult(false, 'App Store is not available right now.');
      return;
    }

    _coinsByProductId[product.id] = coins;
    _resultHandlers[product.id] = onResult;

    final purchaseParam = PurchaseParam(productDetails: product);
    final launched = await _iap.buyConsumable(purchaseParam: purchaseParam);

    if (!launched) {
      _coinsByProductId.remove(product.id);
      _resultHandlers.remove(product.id);
      onResult(false, 'Unable to start purchase.');
    }
  }

  void _handlePurchases(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      final productId = purchase.productID;

      switch (purchase.status) {
        case PurchaseStatus.pending:
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _resultHandlers[productId]?.call(true, null);
          _cleanup(productId);
          break;
        case PurchaseStatus.error:
          _resultHandlers[productId]
              ?.call(false, purchase.error?.message ?? 'Purchase failed.');
          _cleanup(productId);
          break;
        case PurchaseStatus.canceled:
          _resultHandlers[productId]?.call(false, 'Purchase canceled.');
          _cleanup(productId);
          break;
      }

      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  void _cleanup(String productId) {
    _coinsByProductId.remove(productId);
    _resultHandlers.remove(productId);
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _isInitialized = false;
  }
}
