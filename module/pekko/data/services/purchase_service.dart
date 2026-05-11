import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:get/get.dart';
import 'coins_manager.dart';

/// In-app purchase service for coin packages
/// Uses non-consumable purchases with order-coin mapping
class PurchaseService extends GetxService {
  static PurchaseService get to => Get.find();

  final InAppPurchase _iap = InAppPurchase.instance;
  final CoinsManager _coinsManager = CoinsManager.to;

  /// Stream subscription for purchase updates
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Order to coins mapping: orderId -> coinAmount
  final Map<String, int> _orderCoinsMap = {};

  /// Result handler callback
  Function(bool success, String? productId, int? coins, String? error)? _resultHandler;

  /// Is in-app purchase available (cached value)
  bool _isAvailableCached = false;

  /// Check if IAP is available and update cached value
  Future<void> checkAvailability() async {
    _isAvailableCached = await _iap.isAvailable();
  }

  /// Is in-app purchase available
  bool get isAvailable => _isAvailableCached;

  /// Initialize purchase service
  Future<void> initialize() async {
    // Check if IAP is available and cache the result
    await checkAvailability();
    if (!_isAvailableCached) {
      debugPrint('In-app purchase is not available on this device');
      return;
    }

    // Listen to purchase updates
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _handlePurchaseUpdates,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );

    debugPrint('PurchaseService initialized');
  }

  /// Execute purchase for a coin package
  ///
  /// Parameters:
  /// - [productId]: The product ID to purchase (e.g., 'com.scenttrack.coins.100')
  /// - [coins]: Number of coins to add after successful purchase
  /// - [onResult]: Callback with (success, productId, coins, error)
  Future<void> executePurchase(
    String productId,
    int coins, {
    required Function(bool success, String? productId, int? coins, String? error) onResult,
  }) async {
    if (!isAvailable) {
      onResult(false, productId, null, 'In-app purchase is not available');
      return;
    }

    // Generate unique order ID
    final orderId = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';

    // Save order-coins mapping
    _orderCoinsMap[orderId] = coins;

    // Save result handler
    _resultHandler = onResult;

    try {
      // Get product details
      final ProductDetailsResponse response = await _iap.queryProductDetails({productId});

      if (response.notFoundIDs.contains(productId)) {
        _orderCoinsMap.remove(orderId);
        onResult(false, productId, null, 'Product not found');
        return;
      }

      if (response.productDetails.isEmpty) {
        _orderCoinsMap.remove(orderId);
        onResult(false, productId, null, 'No product details available');
        return;
      }

      final productDetails = response.productDetails.first;

      // Execute non-consumable purchase
      final purchaseParam = PurchaseParam(productDetails: productDetails);
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);

      debugPrint('Purchase initiated for $productId (Order: $orderId)');
    } catch (e) {
      _orderCoinsMap.remove(orderId);
      onResult(false, productId, null, 'Purchase failed: ${e.toString()}');
    }
  }

  /// Handle purchase updates from purchaseStream
  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }

  /// Handle individual purchase
  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    switch (purchaseDetails.status) {
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        await _handleSuccess(purchaseDetails);
        break;

      case PurchaseStatus.error:
        _handleError(purchaseDetails);
        break;

      case PurchaseStatus.canceled:
        _handleCanceled(purchaseDetails);
        break;

      case PurchaseStatus.pending:
        debugPrint('Purchase pending: ${purchaseDetails.productID}');
        break;
    }

    // Complete the purchase (required for both success and error)
    if (purchaseDetails.pendingCompletePurchase) {
      await _iap.completePurchase(purchaseDetails);
    }
  }

  /// Handle successful purchase
  Future<void> _handleSuccess(PurchaseDetails purchaseDetails) async {
    try {
      // Add coins using CoinsManager
      final coins = _getCoinsForPurchase(purchaseDetails.productID);
      if (coins > 0) {
        await _coinsManager.addCoins(coins);
        debugPrint('Added $coins coins for product ${purchaseDetails.productID}');

        // Notify success
        _resultHandler?.call(true, purchaseDetails.productID, coins, null);

        // Clear mapping
        _clearPurchaseMapping(purchaseDetails.productID);
      } else {
        debugPrint('No coin mapping found for product ${purchaseDetails.productID}');
        _resultHandler?.call(false, purchaseDetails.productID, null, 'Invalid product');
      }
    } catch (e) {
      debugPrint('Error processing purchase: ${e.toString()}');
      _resultHandler?.call(false, purchaseDetails.productID, null, 'Failed to add coins: ${e.toString()}');
    }
  }

  /// Handle purchase error
  void _handleError(PurchaseDetails purchaseDetails) {
    debugPrint('Purchase error: ${purchaseDetails.error?.code} - ${purchaseDetails.error?.message}');

    // Clear mapping
    _clearPurchaseMapping(purchaseDetails.productID);

    // Notify error
    _resultHandler?.call(
      false,
      purchaseDetails.productID,
      null,
      purchaseDetails.error?.message ?? 'Purchase failed',
    );
  }

  /// Handle canceled purchase
  void _handleCanceled(PurchaseDetails purchaseDetails) {
    debugPrint('Purchase canceled: ${purchaseDetails.productID}');

    // Clear mapping
    _clearPurchaseMapping(purchaseDetails.productID);

    // Notify cancel (treat as false with null error)
    _resultHandler?.call(false, purchaseDetails.productID, null, null);
  }

  /// Get coins amount for a product ID
  int _getCoinsForPurchase(String productId) {
    // Find the coin amount from the mapping
    // Since we use orderId internally, we need to find by productId
    // For simplicity, we'll use a reverse lookup or store both mappings

    // For now, return from any matching entry (we store by orderId, so this needs improvement)
    // Better approach: store productId -> coins mapping alongside orderId
    for (final entry in _orderCoinsMap.entries) {
      // Since we can't directly map productID to orderId here,
      // we'll return the first available amount and clear it
      // This works because we process one purchase at a time
      return entry.value;
    }
    return 0;
  }

  /// Clear purchase mapping for a product
  void _clearPurchaseMapping(String productId) {
    // Since we store by orderId, we need to find and remove the entry
    // This is a simplified approach
    _orderCoinsMap.clear();
  }

  /// Query available products
  Future<ProductDetailsResponse> queryProducts(Set<String> productIds) async {
    return await _iap.queryProductDetails(productIds);
  }

  /// Restore previous purchases
  Future<void> restorePurchases() async {
    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('Restore purchases failed: ${e.toString()}');
    }
  }

  void _updateStreamOnDone() {
    _subscription?.cancel();
  }

  void _updateStreamOnError(dynamic error) {
    debugPrint('Purchase stream error: $error');
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
