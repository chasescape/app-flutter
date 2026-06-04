import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cliss/cliss/app/services/coins_manager.dart';

class PurchaseService {
  PurchaseService._();

  static late final PurchaseService _instance = PurchaseService._internal();
  static PurchaseService get instance => _instance;

  PurchaseService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isAvailable = false;
  bool _isInitialized = false;
  bool get isAvailable => _isAvailable;

  static const String _pendingCoinsKey = 'pending_purchase_coins';
  static const String _processedPurchaseIdsKey = 'processed_purchase_ids';

  final Map<String, int> _pendingCoinsByProductId = {};
  final Map<String, ProductDetails> _productDetailsMap = {};
  final Map<String, void Function(int coins)> _resultHandlersByProductId = {};
  final Set<String> _processedPurchaseIds = <String>{};

  Future<void> init() async {
    if (_isInitialized) return;

    final isAvailable = await _iap.isAvailable();
    _isAvailable = isAvailable;

    if (!isAvailable) {
      debugPrint('In-app purchase not available');
      return;
    }

    await _loadPersistedState();

    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );
    _isInitialized = true;
  }

  Future<void> _loadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingCoins =
        prefs.getStringList(_pendingCoinsKey) ?? const <String>[];
    for (final item in pendingCoins) {
      final parts = item.split(':');
      if (parts.length != 2) continue;
      final coins = int.tryParse(parts[1]);
      if (coins == null) continue;
      _pendingCoinsByProductId[parts[0]] = coins;
    }
    _processedPurchaseIds
      ..clear()
      ..addAll(prefs.getStringList(_processedPurchaseIdsKey) ?? const <String>[]);
  }

  Future<void> _persistPendingCoins() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _pendingCoinsByProductId.entries
        .map((entry) => '${entry.key}:${entry.value}')
        .toList();
    await prefs.setStringList(_pendingCoinsKey, data);
  }

  Future<void> _persistProcessedPurchaseIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _processedPurchaseIdsKey,
      _processedPurchaseIds.toList(),
    );
  }

  Future<void> loadProducts(List<String> productIds) async {
    if (!_isAvailable) return;

    final ProductDetailsResponse response = await _iap.queryProductDetails(productIds.toSet());
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Products not found: ${response.notFoundIDs}');
    }
    if (response.error != null) {
      debugPrint('Product query error: ${response.error}');
    }

    for (final product in response.productDetails) {
      _productDetailsMap[product.id] = product;
    }
  }

  bool hasProduct(String productId) => _productDetailsMap.containsKey(productId);

  Future<bool> executePurchase(
    String productId,
    int coins,
    void Function(int coins) onResult,
  ) async {
    if (!_isAvailable) {
      onResult(0);
      return false;
    }

    final ProductDetails? productDetails = _productDetailsMap[productId];
    if (productDetails == null) {
      debugPrint('Product not found: $productId');
      onResult(0);
      return false;
    }

    _pendingCoinsByProductId[productId] = coins;
    _resultHandlersByProductId[productId] = onResult;
    await _persistPendingCoins();

    try {
      final purchaseParam = PurchaseParam(productDetails: productDetails);
      return await _iap.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );
    } catch (e) {
      debugPrint('Purchase error: $e');
      _pendingCoinsByProductId.remove(productId);
      await _persistPendingCoins();
      _resultHandlersByProductId.remove(productId)?.call(0);
      return false;
    }
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      await _handlePurchase(purchaseDetails);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    final productId = purchaseDetails.productID;
    final purchaseId = purchaseDetails.purchaseID;

    switch (purchaseDetails.status) {
      case PurchaseStatus.purchased:
        final coins = _pendingCoinsByProductId.remove(productId);
        final resultHandler = _resultHandlersByProductId.remove(productId);
        await _persistPendingCoins();

        if (coins != null &&
            purchaseId != null &&
            !_processedPurchaseIds.contains(purchaseId)) {
          await CoinsManager.instance.addCoins(coins);
          _processedPurchaseIds.add(purchaseId);
          await _persistProcessedPurchaseIds();
          resultHandler?.call(coins);
        } else {
          resultHandler?.call(0);
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
        break;

      case PurchaseStatus.restored:
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
        break;

      case PurchaseStatus.error:
        debugPrint('Purchase error: ${purchaseDetails.error}');
        _pendingCoinsByProductId.remove(productId);
        await _persistPendingCoins();
        _resultHandlersByProductId.remove(productId)?.call(0);
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
        break;

      case PurchaseStatus.canceled:
        _pendingCoinsByProductId.remove(productId);
        await _persistPendingCoins();
        _resultHandlersByProductId.remove(productId)?.call(0);
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
        break;

      default:
        break;
    }
  }

  void _updateStreamOnDone() {
    _subscription?.cancel();
    _subscription = null;
    _isInitialized = false;
  }

  void _updateStreamOnError(dynamic error) {
    debugPrint('Purchase stream error: $error');
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _isInitialized = false;
  }
}
