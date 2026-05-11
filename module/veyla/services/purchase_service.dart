import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../core/mixin/singleton_mixin.dart';
import 'coins_manager.dart';

class PurchaseResult {
  final bool success;
  final String? message;
  final int? coinsAdded;

  const PurchaseResult({
    required this.success,
    this.message,
    this.coinsAdded,
  });

  factory PurchaseResult.success(int coins) {
    return PurchaseResult(
      success: true,
      message: 'Successfully added $coins coins!',
      coinsAdded: coins,
    );
  }

  factory PurchaseResult.error(String message) {
    return PurchaseResult(
      success: false,
      message: message,
    );
  }

  factory PurchaseResult.canceled() {
    return const PurchaseResult(
      success: false,
      message: 'Purchase canceled',
    );
  }
}

typedef PurchaseResultCallback = void Function(PurchaseResult result);

class PurchaseService with SingletonMixin<PurchaseService> {
  PurchaseService._();

  static PurchaseService get instance =>
      SingletonMixin.getInstance(() => PurchaseService._());

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  final Map<String, int> _pendingProductCoinsMap = {};
  final Map<String, ProductDetails> _productDetailsMap = {};
  PurchaseResultCallback? _resultHandler;
  void Function(int)? _addCoinsCallback;

  CoinsManager get _coinsManager => CoinsManager.instance;

  Future<bool> isAvailable() => _iap.isAvailable();

  Future<bool> initialize({void Function(int)? onAddCoins}) async {
    _addCoinsCallback = onAddCoins;

    final bool isAvailable = await _iap.isAvailable();
    if (!isAvailable) {
      debugPrint('In-app purchase not available');
      return false;
    }

    _subscription ??= _iap.purchaseStream.listen(
          _handlePurchaseUpdates,
          onError: (error) {
            debugPrint('Purchase stream error: $error');
            _notifyResult(PurchaseResult.error('Purchase stream error: $error'));
          },
        );

    return true;
  }

  Future<void> loadProducts(List<String> productIds) async {
    final ProductDetailsResponse response = await _iap.queryProductDetails(productIds.toSet());

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Products not found: ${response.notFoundIDs}');
    }

    if (response.error != null) {
      debugPrint('Product query error: ${response.error}');
      return;
    }

    for (final product in response.productDetails) {
      _productDetailsMap[product.id] = product;
    }

    debugPrint('Loaded ${response.productDetails.length} products');
  }

  Future<void> executePurchase(
    String productId,
    int coins, {
    required PurchaseResultCallback onResult,
  }) async {
    final productDetails = _productDetailsMap[productId];
    if (productDetails == null) {
      onResult(PurchaseResult.error('Product not found: $productId'));
      return;
    }

    _pendingProductCoinsMap[productId] = coins;
    _resultHandler = onResult;

    debugPrint('Starting purchase: $productId -> $coins coins');

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: productDetails,
    );

    try {
      final bool success = await _iap.buyConsumable(purchaseParam: purchaseParam);
      if (!success) {
        _pendingProductCoinsMap.remove(productId);
        _notifyResult(PurchaseResult.error('Purchase failed to start'));
      }
    } catch (e) {
      _pendingProductCoinsMap.remove(productId);
      _notifyResult(PurchaseResult.error('Purchase error: $e'));
    }
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    final productId = purchaseDetails.productID;

    switch (purchaseDetails.status) {
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        await _deliverProduct(purchaseDetails);
        break;

      case PurchaseStatus.error:
        _handleError(purchaseDetails.error!);
        _pendingProductCoinsMap.remove(productId);
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
        break;

      case PurchaseStatus.canceled:
        debugPrint('Purchase canceled: $productId');
        _pendingProductCoinsMap.remove(productId);
        _notifyResult(PurchaseResult.canceled());
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
        break;

      case PurchaseStatus.pending:
        debugPrint('Purchase pending: ${purchaseDetails.productID}');
        break;
    }
  }

  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    final orderId = purchaseDetails.purchaseID ?? 'unknown';
    final productId = purchaseDetails.productID;
    final coins = _pendingProductCoinsMap.remove(productId);

    if (coins == null) {
      debugPrint('No coins mapping found for order: $orderId, product: $productId');
      if (purchaseDetails.pendingCompletePurchase) {
        await _iap.completePurchase(purchaseDetails);
      }
      _notifyResult(
        PurchaseResult.error('Purchase completed, but the coin package could not be matched.'),
      );
      return;
    }

    await _coinsManager.addCoins(coins);

    if (_addCoinsCallback != null) {
      _addCoinsCallback!(coins);
    }

    if (purchaseDetails.pendingCompletePurchase) {
      await _iap.completePurchase(purchaseDetails);
    }

    _notifyResult(PurchaseResult.success(coins));
  }

  void _handleError(IAPError error) {
    debugPrint('Purchase error: ${error.code} - ${error.message}');
    String message = error.message;

    switch (error.code) {
      case 'storekit_purchase_pending':
        message = 'Payment is pending, please complete it in your payment settings';
        break;
      case 'storekit_product_not_available':
        message = 'Product not available';
        break;
      case 'storekit_payment_invalid':
        message = 'Payment was invalid';
        break;
      case 'storekit_payment_not_allowed':
        message = 'Payments are not allowed on this device';
        break;
    }

    _notifyResult(PurchaseResult.error(message));
  }

  void _notifyResult(PurchaseResult result) {
    if (_resultHandler != null) {
      _resultHandler!(result);
      _resultHandler = null;
    }
  }

  ProductDetails? getProductDetails(String productId) {
    return _productDetailsMap[productId];
  }

  List<ProductDetails> get allProducts => _productDetailsMap.values.toList();

  Future<void> restorePurchases() async {
    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('Restore purchases error: $e');
    }
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _pendingProductCoinsMap.clear();
    _productDetailsMap.clear();
    _resultHandler = null;
    _addCoinsCallback = null;
  }
}
