import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

import '../storage/storage_service.dart';

/// Purchase Service - In-App Purchase Management
/// Handles non-consumable purchases with coin rewards
class PurchaseService {
  static PurchaseService? _instance;

  static PurchaseService get instance {
    _instance ??= PurchaseService._internal();
    return _instance!;
  }

  PurchaseService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Order to coins mapping
  final Map<String, int> _orderCoinsMap = {};

  /// Product ID to coins mapping
  final Map<String, int> _productCoinsMap = {};

  /// Product catalog fallback for recovering stale transactions.
  final Map<String, int> _catalogCoinsMap = {};

  /// Current purchase result handler
  Function(String orderId, int coins, bool success, String? error)?
      _resultHandler;

  /// Add coins callback
  Future<void> Function(int coins)? _addCoinsCallback;

  /// Available products
  List<ProductDetails> _products = [];

  final StorageService _storage = StorageService.instance;

  /// Is purchase available
  bool get isAvailable => _isAvailable;
  bool _isAvailable = false;

  /// Initialize purchase service
  Future<bool> initialize({required Map<String, int> productCoinsById}) async {
    _catalogCoinsMap
      ..clear()
      ..addAll(productCoinsById);

    // Check if in-app purchase is available
    _isAvailable = await _iap.isAvailable();

    if (!_isAvailable) {
      debugPrint('In-App Purchase not available on this device');
      return false;
    }

    if (Platform.isIOS) {
      await _reconcilePendingIosTransactions();
    }

    // Listen to purchase updates
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    await _subscription?.cancel();
    _subscription = purchaseUpdated.listen(
      _handlePurchaseUpdates,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );

    // Load products
    await loadProducts(productCoinsById.keys.toSet());

    return true;
  }

  /// Load available products
  Future<void> loadProducts(Set<String> productIds) async {
    if (!_isAvailable || productIds.isEmpty) {
      _products = [];
      return;
    }

    final ProductDetailsResponse response =
        await _iap.queryProductDetails(productIds);

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Products not found: ${response.notFoundIDs}');
    }

    if (response.productDetails.isEmpty) {
      debugPrint('No products found');
      _products = [];
    } else {
      _products = response.productDetails;
      debugPrint('Loaded ${_products.length} products');
    }

    if (response.error != null) {
      debugPrint('Error loading products: ${response.error}');
    }
  }

  /// Get loaded products
  List<ProductDetails> get products => _products;

  /// Set add coins callback
  void setAddCoinsCallback(Future<void> Function(int coins) callback) {
    _addCoinsCallback = callback;
  }

  /// Execute purchase with order-coins mapping
  Future<void> executePurchase(
    String productId,
    int coins, {
    Function(String orderId, int coins, bool success, String? error)? onResult,
  }) async {
    if (!_isAvailable) {
      onResult?.call('', coins, false, 'Purchase not available');
      return;
    }

    final ProductDetails? product =
        _products.cast<ProductDetails?>().firstWhere(
              (p) => p?.id == productId,
              orElse: () => null,
            );

    if (product == null) {
      onResult?.call('', coins, false, 'Product not available');
      return;
    }

    // Generate order ID
    final String orderId = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';

    // Save mappings
    _orderCoinsMap[orderId] = coins;
    _productCoinsMap[productId] = coins;
    _resultHandler = onResult;

    debugPrint('Starting purchase: $productId -> $orderId -> $coins coins');

    // Execute purchase
    try {
      final didStart = await _startPurchase(product);

      if (!didStart) {
        await _handlePurchaseError(
          orderId,
          coins,
          'Purchase request was not started',
        );
      }
    } catch (e) {
      debugPrint('Purchase error: $e');

      if (await _recoverDuplicateProductError(e, productId)) {
        await _handlePurchaseError(
          orderId,
          coins,
          'Recovered an unfinished purchase. Please tap again.',
        );
        return;
      }

      await _handlePurchaseError(orderId, coins, e.toString());
    }
  }

  /// Handle purchase updates
  Future<void> _handlePurchaseUpdates(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      await _handlePurchase(purchaseDetails);
    }
  }

  /// Handle individual purchase
  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    final String productId = purchaseDetails.productID;

    // Get coins from mapping
    final int coins = _resolveCoins(productId);
    final String orderId = 'ORDER_${purchaseDetails.purchaseID}';

    switch (purchaseDetails.status) {
      case PurchaseStatus.purchased:
        await _handlePurchaseSuccess(orderId, coins, purchaseDetails);
        break;

      case PurchaseStatus.restored:
        await _handleRestoredPurchase(orderId, purchaseDetails);
        break;

      case PurchaseStatus.error:
        await _handlePurchaseError(
          orderId,
          coins,
          purchaseDetails.error?.message,
          purchaseDetails: purchaseDetails,
        );
        break;

      case PurchaseStatus.canceled:
        await _handlePurchaseCanceled(
          orderId,
          coins,
          purchaseDetails,
        );
        break;

      case PurchaseStatus.pending:
        debugPrint('Purchase pending: $orderId');
        break;
    }
  }

  /// Handle successful purchase
  Future<void> _handlePurchaseSuccess(
    String orderId,
    int coins,
    PurchaseDetails purchaseDetails,
  ) async {
    debugPrint('Purchase success: $orderId -> $coins coins');

    final transactionId = purchaseDetails.purchaseID;
    final shouldGrant = !await _hasDeliveredTransaction(transactionId);

    if (shouldGrant && coins > 0) {
      await _addCoinsCallback?.call(coins);
      await _rememberDeliveredTransaction(transactionId);
    }

    // Finish the native transaction before notifying the UI.
    await _completePurchaseIfNeeded(purchaseDetails);

    // Notify success
    _resultHandler?.call(orderId, shouldGrant ? coins : 0, true, null);

    _clearPurchaseTracking();
  }

  Future<void> _handleRestoredPurchase(
    String orderId,
    PurchaseDetails purchaseDetails,
  ) async {
    debugPrint('Restored purchase detected for ${purchaseDetails.productID}');

    await _completePurchaseIfNeeded(purchaseDetails);

    _resultHandler?.call(
      orderId,
      0,
      false,
      'This product does not support restore.',
    );

    _clearPurchaseTracking();
  }

  /// Handle purchase error
  Future<void> _handlePurchaseError(
    String orderId,
    int coins,
    String? error, {
    PurchaseDetails? purchaseDetails,
  }) async {
    debugPrint('Purchase error: $orderId -> $error');

    if (purchaseDetails != null) {
      await _completePurchaseIfNeeded(purchaseDetails);
    }

    _resultHandler?.call(orderId, coins, false, error ?? 'Unknown error');

    _clearPurchaseTracking();
  }

  /// Handle canceled purchase
  Future<void> _handlePurchaseCanceled(
    String orderId,
    int coins,
    PurchaseDetails purchaseDetails,
  ) async {
    debugPrint('Purchase canceled: $orderId');

    await _completePurchaseIfNeeded(purchaseDetails);

    _resultHandler?.call(orderId, coins, false, 'Purchase canceled');

    _clearPurchaseTracking();
  }

  Future<void> _completePurchaseIfNeeded(
      PurchaseDetails purchaseDetails) async {
    if (!purchaseDetails.pendingCompletePurchase) {
      return;
    }

    debugPrint('Completing purchase: ${purchaseDetails.productID}');
    await _iap.completePurchase(purchaseDetails);
  }

  void _clearPurchaseTracking() {
    _orderCoinsMap.clear();
    _productCoinsMap.clear();
    _resultHandler = null;
  }

  int _resolveCoins(String productId) {
    return _productCoinsMap[productId] ?? _catalogCoinsMap[productId] ?? 0;
  }

  Future<bool> _startPurchase(ProductDetails product) {
    final purchaseParam = PurchaseParam(productDetails: product);
    return _iap.buyConsumable(purchaseParam: purchaseParam);
  }

  Future<bool> _recoverDuplicateProductError(
      Object error, String productId) async {
    if (!Platform.isIOS) {
      return false;
    }

    final errorText = error.toString();
    if (!errorText.contains('storekit_duplicate_product_object')) {
      return false;
    }

    final result = await _reconcilePendingIosTransactions(productId: productId);
    return result != _IosQueueRecoveryResult.none &&
        result != _IosQueueRecoveryResult.stillPending;
  }

  Future<_IosQueueRecoveryResult> _reconcilePendingIosTransactions({
    String? productId,
  }) async {
    final queue = SKPaymentQueueWrapper();
    final transactions = await queue.transactions();
    var outcome = _IosQueueRecoveryResult.none;

    for (final transaction in transactions) {
      final queuedProductId = transaction.payment.productIdentifier;
      if (productId != null && queuedProductId != productId) {
        continue;
      }

      switch (transaction.transactionState) {
        case SKPaymentTransactionStateWrapper.purchased:
          final purchaseId = transaction.transactionIdentifier;
          final shouldGrant = !await _hasDeliveredTransaction(purchaseId);
          final coins = _resolveCoins(queuedProductId);
          if (shouldGrant && coins > 0) {
            await _addCoinsCallback?.call(coins);
            await _rememberDeliveredTransaction(purchaseId);
          }
          await queue.finishTransaction(transaction);
          outcome = _IosQueueRecoveryResult.recoveredPurchase;
          break;

        case SKPaymentTransactionStateWrapper.restored:
        case SKPaymentTransactionStateWrapper.failed:
          await queue.finishTransaction(transaction);
          outcome = _IosQueueRecoveryResult.clearedStaleTransaction;
          break;

        case SKPaymentTransactionStateWrapper.purchasing:
        case SKPaymentTransactionStateWrapper.deferred:
          outcome = _IosQueueRecoveryResult.stillPending;
          break;

        case SKPaymentTransactionStateWrapper.unspecified:
          break;
      }
    }

    return outcome;
  }

  Future<List<String>> _loadDeliveredPurchaseIds() async {
    final json = await _storage.getString(StorageKeys.deliveredPurchaseIds);
    if (json == null || json.isEmpty) {
      return <String>[];
    }

    try {
      final decoded = jsonDecode(json);
      if (decoded is List) {
        return decoded.whereType<String>().toList();
      }
    } catch (e) {
      debugPrint('Failed to decode delivered purchase ids: $e');
    }

    return <String>[];
  }

  Future<bool> _hasDeliveredTransaction(String? transactionId) async {
    if (transactionId == null || transactionId.isEmpty) {
      return false;
    }

    final deliveredIds = await _loadDeliveredPurchaseIds();
    return deliveredIds.contains(transactionId);
  }

  Future<void> _rememberDeliveredTransaction(String? transactionId) async {
    if (transactionId == null || transactionId.isEmpty) {
      return;
    }

    final deliveredIds = await _loadDeliveredPurchaseIds();
    if (deliveredIds.contains(transactionId)) {
      return;
    }

    deliveredIds.add(transactionId);
    if (deliveredIds.length > 100) {
      deliveredIds.removeRange(0, deliveredIds.length - 100);
    }

    await _storage.setString(
      StorageKeys.deliveredPurchaseIds,
      jsonEncode(deliveredIds),
    );
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    if (!_isAvailable) return;

    try {
      await _iap.restorePurchases();
      debugPrint('Restore purchases initiated');
    } catch (e) {
      debugPrint('Restore purchases error: $e');
    }
  }

  /// Update stream done
  void _updateStreamOnDone() {
    _subscription?.cancel();
  }

  /// Update stream error
  void _updateStreamOnError(dynamic error) {
    debugPrint('Purchase stream error: $error');
  }

  /// Dispose
  void dispose() {
    _subscription?.cancel();
    _clearPurchaseTracking();
  }
}

enum _IosQueueRecoveryResult {
  none,
  clearedStaleTransaction,
  recoveredPurchase,
  stillPending,
}
