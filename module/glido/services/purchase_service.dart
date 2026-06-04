import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../managers/coins_manager.dart';

typedef PurchaseResultHandler = void Function(
  String productId,
  int coins,
  bool success,
  String? message,
);

class PurchaseService {
  static const String _keyDeliveredPurchases = 'delivered_purchases';

  static PurchaseService? _instance;

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final Map<String, ProductDetails> _productsById = {};
  final Map<String, int> _coinsByProductId = {};
  final Map<String, PurchaseResultHandler> _handlersByProductId = {};
  final Set<String> _deliveredPurchaseKeys = {};

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  bool _initialized = false;
  bool _isStoreAvailable = false;
  String? _lastQueryErrorMessage;

  factory PurchaseService() {
    _instance ??= PurchaseService._internal();
    return _instance!;
  }

  PurchaseService._internal();

  Future<void> initialize({Iterable<String> productIds = const []}) async {
    if (_initialized) {
      if (productIds.isNotEmpty) {
        await loadProducts(productIds);
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    _deliveredPurchaseKeys
      ..clear()
      ..addAll(prefs.getStringList(_keyDeliveredPurchases) ?? const []);

    _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
    );

    _isStoreAvailable = await _inAppPurchase.isAvailable();
    _initialized = true;

    if (_isStoreAvailable && productIds.isNotEmpty) {
      await loadProducts(productIds);
    }
  }

  Future<bool> isAvailable({Iterable<String> productIds = const []}) async {
    await initialize(productIds: productIds);
    return _isStoreAvailable;
  }

  Future<void> loadProducts(Iterable<String> productIds) async {
    await initialize();
    if (!_isStoreAvailable) {
      _lastQueryErrorMessage =
          'In-app purchases are unavailable on this device.';
      return;
    }

    final ids = productIds.toSet();
    if (ids.isEmpty) return;

    _lastQueryErrorMessage = null;

    try {
      final response = await _inAppPurchase.queryProductDetails(ids);

      if (response.error != null) {
        _lastQueryErrorMessage = await _buildStoreUnavailableMessage(
          fallback: response.error!.message,
        );
        debugPrint(
          'PurchaseService queryProductDetails error: ${response.error!.message}',
        );
      }

      for (final product in response.productDetails) {
        _productsById[product.id] = product;
      }

      if (response.notFoundIDs.isNotEmpty) {
        if (response.productDetails.isEmpty) {
          _lastQueryErrorMessage = await _buildStoreUnavailableMessage(
            fallback: 'App Store products are unavailable for this build.',
          );
        }
        debugPrint(
          'PurchaseService missing product IDs: ${response.notFoundIDs.join(', ')}',
        );
      }
    } catch (error) {
      _lastQueryErrorMessage = await _buildStoreUnavailableMessage(
        fallback: 'Unable to load App Store products right now.',
      );
      debugPrint('PurchaseService queryProductDetails error: $error');
    }
  }

  ProductDetails? productDetailsFor(String productId) =>
      _productsById[productId];

  Set<String> get loadedProductIds => _productsById.keys.toSet();

  String? get lastQueryErrorMessage => _lastQueryErrorMessage;

  Future<void> purchase(
    String productId,
    int coins, {
    PurchaseResultHandler? onResult,
  }) async {
    await loadProducts([productId]);

    if (!_isStoreAvailable) {
      onResult?.call(
          productId, coins, false, 'In-app purchases are unavailable.');
      return;
    }

    final productDetails = _productsById[productId];
    if (productDetails == null) {
      onResult?.call(
        productId,
        coins,
        false,
        _lastQueryErrorMessage ?? 'This item is currently unavailable.',
      );
      return;
    }

    _coinsByProductId[productId] = coins;
    if (onResult != null) {
      _handlersByProductId[productId] = onResult;
    }

    try {
      final requested = await _inAppPurchase.buyConsumable(
        purchaseParam: PurchaseParam(productDetails: productDetails),
        autoConsume: true,
      );

      if (!requested) {
        _emitFailure(productId, coins, 'Unable to start purchase.');
      }
    } catch (error) {
      final text = error.toString();
      if (_isCanceled(text)) {
        _emitSilent(productId, coins);
        return;
      }
      _emitFailure(productId, coins, 'Unable to start purchase: $error');
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      unawaited(_handlePurchase(purchase));
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    final productId = purchase.productID;
    final coins = _coinsByProductId[productId] ?? 0;

    switch (purchase.status) {
      case PurchaseStatus.pending:
        return;
      case PurchaseStatus.canceled:
        _emitSilent(productId, coins);
        break;
      case PurchaseStatus.error:
        final message = purchase.error?.message ?? 'Purchase failed.';
        if (_isCanceled(message)) {
          _emitSilent(productId, coins);
        } else {
          _emitFailure(productId, coins, message);
        }
        break;
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        final delivered = await _deliverCoins(purchase, coins);
        if (delivered) {
          _emitSuccess(productId, coins);
        } else {
          _emitFailure(productId, coins, 'Unable to deliver purchase.');
        }
        break;
    }

    if (purchase.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchase);
    }
  }

  Future<bool> _deliverCoins(PurchaseDetails purchase, int coins) async {
    if (coins <= 0) return false;

    final deliveryKey = purchase.purchaseID ??
        '${purchase.productID}:${purchase.transactionDate ?? 'unknown'}';

    if (_deliveredPurchaseKeys.contains(deliveryKey)) {
      return true;
    }

    await CoinsManager().addCoins(coins);
    _deliveredPurchaseKeys.add(deliveryKey);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _keyDeliveredPurchases,
      _deliveredPurchaseKeys.toList(),
    );

    return true;
  }

  void _emitSuccess(String productId, int coins) {
    final handler = _handlersByProductId.remove(productId);
    handler?.call(productId, coins, true, null);
    _coinsByProductId.remove(productId);
  }

  void _emitFailure(String productId, int coins, String message) {
    final handler = _handlersByProductId.remove(productId);
    handler?.call(productId, coins, false, message);
    _coinsByProductId.remove(productId);
  }

  void _emitSilent(String productId, int coins) {
    final handler = _handlersByProductId.remove(productId);
    handler?.call(productId, coins, false, null);
    _coinsByProductId.remove(productId);
  }

  bool _isCanceled(String text) {
    return text.contains('storekit2_purchase_canceled') ||
        text.contains('Purchase canceled') ||
        text.contains('cancelled by the user') ||
        text.contains('canceled by the user');
  }

  Future<String> _buildStoreUnavailableMessage({
    required String fallback,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return fallback;
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return 'App Store products are unavailable for this build (${packageInfo.packageName}).';
    } catch (_) {
      return fallback;
    }
  }

  Future<void> dispose() async {
    await _purchaseSubscription?.cancel();
    _purchaseSubscription = null;
    _initialized = false;
  }
}
