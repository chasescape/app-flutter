import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:zeria/zeria/services/coins_manager.dart';

/// Purchase callback result
enum PurchaseResult {
  success,
  failed,
  canceled,
  pending,
}

/// Purchase Service - In-app purchase management
/// Uses buyNonConsumable with order-coin mapping and callback decoupling
class PurchaseService {
  PurchaseService._privateConstructor();

  static final PurchaseService _instance =
      PurchaseService._privateConstructor();

  static PurchaseService get instance => _instance;

  static PurchaseService get I => instance;

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Order-coin mapping for purchase completion
  final Map<String, int> _orderCoinsMap = {};

  /// Result callback handler
  Function(PurchaseResult result, int coins, String? error)? _resultHandler;

  /// Is in-app purchase available
  Future<bool> isAvailable() => _inAppPurchase.isAvailable();

  /// Initialize purchase service
  Future<bool> init() async {
    if (!(await isAvailable())) {
      debugPrint('In-app purchase not available on this device');
      return false;
    }

    // Listen to purchase updates
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );

    return true;
  }

  /// Execute purchase with order-coin mapping
  /// [productId] - Product ID from App Store Connect / Google Play Console
  /// [coins] - Coin amount to add after successful purchase
  /// [onResult] - Callback for purchase result
  Future<void> executePurchase({
    required String productId,
    required int coins,
    Function(PurchaseResult result, int coins, String? error)? onResult,
  }) async {
    if (!(await isAvailable())) {
      onResult?.call(
          PurchaseResult.failed, coins, 'In-app purchase not available');
      return;
    }

    // Generate order ID
    final orderId = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';

    // Save order-coin mapping
    _orderCoinsMap[productId] = coins;

    // Save callback handler
    _resultHandler = onResult;

    try {
      // Get product details
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails({productId});

      if (response.notFoundIDs.isNotEmpty) {
        _resultHandler?.call(
            PurchaseResult.failed, coins, 'Product not found: $productId');
        _orderCoinsMap.remove(productId);
        return;
      }

      if (response.error != null) {
        _resultHandler?.call(
            PurchaseResult.failed, coins, response.error?.message);
        _orderCoinsMap.remove(productId);
        return;
      }

      if (response.productDetails.isEmpty) {
        _resultHandler?.call(
            PurchaseResult.failed, coins, 'No product details found');
        _orderCoinsMap.remove(productId);
        return;
      }

      // Execute purchase using buyNonConsumable
      final ProductDetails productDetails = response.productDetails.first;
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: productDetails);

      final bool success =
          await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);

      if (!success) {
        _resultHandler?.call(
            PurchaseResult.failed, coins, 'Purchase initiation failed');
        _orderCoinsMap.remove(productId);
      }
    } catch (e) {
      _resultHandler?.call(PurchaseResult.failed, coins, 'Purchase error: $e');
      _orderCoinsMap.remove(productId);
    }
  }

  /// Handle purchase updates from store
  Future<void> _onPurchaseUpdate(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }

  /// Handle individual purchase
  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    final productId = purchaseDetails.productID;
    final coins = _orderCoinsMap[productId] ?? 0;

    switch (purchaseDetails.status) {
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        await _handleSuccess(purchaseDetails, coins);
        break;

      case PurchaseStatus.error:
        _handleError(purchaseDetails, coins);
        break;

      case PurchaseStatus.canceled:
        _handleCanceled(purchaseDetails, coins);
        break;

      case PurchaseStatus.pending:
        _resultHandler?.call(PurchaseResult.pending, coins, 'Purchase pending');
        break;
    }
  }

  /// Handle successful purchase
  Future<void> _handleSuccess(
      PurchaseDetails purchaseDetails, int coins) async {
    try {
      // Complete the purchase to acknowledge to store
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }

      // Add coins through CoinsManager
      await CoinsManager.instance.addCoins(coins);

      // Notify success
      _resultHandler?.call(PurchaseResult.success, coins, null);

      // Clean up mapping
      _orderCoinsMap.remove(purchaseDetails.productID);
    } catch (e) {
      _resultHandler?.call(
          PurchaseResult.failed, coins, 'Error completing purchase: $e');
    }
  }

  /// Handle purchase error
  void _handleError(PurchaseDetails purchaseDetails, int coins) {
    final error = purchaseDetails.error?.message ?? 'Unknown purchase error';

    // Try to complete the purchase anyway
    if (purchaseDetails.pendingCompletePurchase) {
      _inAppPurchase.completePurchase(purchaseDetails);
    }

    _resultHandler?.call(PurchaseResult.failed, coins, error);
    _orderCoinsMap.remove(purchaseDetails.productID);
  }

  /// Handle canceled purchase
  void _handleCanceled(PurchaseDetails purchaseDetails, int coins) {
    // Complete the purchase
    if (purchaseDetails.pendingCompletePurchase) {
      _inAppPurchase.completePurchase(purchaseDetails);
    }

    _resultHandler?.call(PurchaseResult.canceled, coins, null);
    _orderCoinsMap.remove(purchaseDetails.productID);
  }

  /// Query product details
  Future<ProductDetailsResponse> queryProducts(Set<String> productIds) {
    return _inAppPurchase.queryProductDetails(productIds);
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
    }
  }

  void _updateStreamOnDone() {
    _subscription?.cancel();
  }

  void _updateStreamOnError(dynamic error) {
    debugPrint('Purchase stream error: $error');
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _orderCoinsMap.clear();
    _resultHandler = null;
  }
}
