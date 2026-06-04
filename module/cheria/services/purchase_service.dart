import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'coins_manager.dart';

/// Purchase Service - IAP service for non-consumable coin purchases
/// Handles purchase flow with order-to-coin mapping and decoupled callbacks
class PurchaseService {
  PurchaseService._internal();

  static final PurchaseService _instance = PurchaseService._internal();

  /// Singleton instance
  static PurchaseService get instance => _instance;

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Order to coins mapping: productId or orderId -> coins
  final Map<String, int> _orderCoinsMap = {};

  /// Current purchase result callback
  Function(bool success, int coins, String? error)? _resultHandler;

  /// Currently processing purchase ID (productId or orderId)
  String? _currentPurchaseId;

  /// Pending coins for in-progress purchase (for pending->purchased)
  int? _pendingCoins;

  /// Coins addition callback
  Function(int coins)? _addCoinsCallback;

  /// Is service initialized
  bool _isInitialized = false;

  /// Get initialization status
  bool get isInitialized => _isInitialized;

  /// Initialize service and check IAP availability
  Future<bool> initialize({
    Function(int coins)? onAddCoins,
  }) async {
    if (_isInitialized) return true;

    _addCoinsCallback = onAddCoins;

    // Check if IAP is available
    final bool isAvailable = await _iap.isAvailable();
    if (!isAvailable) {
      debugPrint('PurchaseService: IAP not available on this device');
      return false;
    }

    // Listen to purchase updates
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (error) {
        debugPrint('PurchaseService: purchaseStream error - $error');
      },
    );

    _isInitialized = true;
    debugPrint('PurchaseService: initialized successfully');
    return true;
  }

  /// Dispose service
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _isInitialized = false;
  }

  /// Execute purchase with product ID and coins amount
  /// Returns immediately; result handled via callback
  Future<void> executePurchase(
    String productId,
    int coins, {
    required Function(bool success, int coins, String? error) onResult,
  }) async {
    if (!_isInitialized) {
      onResult(false, 0, 'Purchase service not initialized');
      return;
    }

    // Step 1: Check and clear any unfinished orders before new purchase
    await _checkAndClearUnfinishedOrders();

    // Step 2: Generate unique order ID
    final orderId = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';

    // Step 3: Save order-coins mapping
    _orderCoinsMap[productId] = coins;
    _orderCoinsMap[orderId] = coins;
    _currentPurchaseId = orderId;

    // Step 4: Save result callback
    _resultHandler = onResult;

    debugPrint('PurchaseService: Starting purchase - productId: $productId, orderId: $orderId, coins: $coins');

    try {
      // Step 5: Query product details
      final ProductDetailsResponse response = await _iap.queryProductDetails({productId});

      if (response.notFoundIDs.isNotEmpty || response.productDetails.isEmpty) {
        final error = 'Product $productId not found';
        debugPrint('PurchaseService: $error');
        _cleanupPurchase(productId, orderId);
        _resultHandler?.call(false, 0, error);
        return;
      }

      if (response.error != null) {
        final error = 'Query product failed: ${response.error}';
        debugPrint('PurchaseService: $error');
        _cleanupPurchase(productId, orderId);
        _resultHandler?.call(false, 0, error);
        return;
      }

      final productDetails = response.productDetails.first;

      // Step 6: Execute non-consumable purchase
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );

      await _iap.buyNonConsumable(purchaseParam: purchaseParam);

      debugPrint('PurchaseService: Purchase initiated for $productId');
    } catch (e) {
      final error = 'Purchase failed: $e';
      debugPrint('PurchaseService: $error');
      _cleanupPurchase(productId, orderId);
      _resultHandler?.call(false, 0, error);
    }
  }

  /// Handle purchase updates from purchaseStream
  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      _handleSinglePurchase(purchaseDetails);
    }
  }

  /// Handle single purchase update
  Future<void> _handleSinglePurchase(PurchaseDetails purchaseDetails) async {
    debugPrint('PurchaseService: Handling purchase - status: ${purchaseDetails.status}, '
        'productID: ${purchaseDetails.productID}, '
        'purchaseID: ${purchaseDetails.purchaseID}, '
        'verificationData: ${purchaseDetails.verificationData}');

    switch (purchaseDetails.status) {
      case PurchaseStatus.pending:
        await _handlePending(purchaseDetails);
        break;

      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        await _handlePurchasedOrRestored(purchaseDetails);
        break;

      case PurchaseStatus.error:
        await _handleError(purchaseDetails);
        break;

      case PurchaseStatus.canceled:
        await _handleCanceled(purchaseDetails);
        break;
    }

    // Complete the purchase if needed (iOS/macOS requirement)
    if (purchaseDetails.pendingCompletePurchase) {
      try {
        await _iap.completePurchase(purchaseDetails);
        debugPrint('PurchaseService: Completed purchase for ${purchaseDetails.productID}');
      } catch (e) {
        debugPrint('PurchaseService: Failed to complete purchase - $e');
      }
    }
  }

  /// Handle pending purchase
  Future<void> _handlePending(PurchaseDetails purchaseDetails) async {
    final productId = purchaseDetails.productID;
    final coins = _orderCoinsMap[productId] ?? _orderCoinsMap[purchaseDetails.purchaseID ?? ''];

    debugPrint('PurchaseService: Purchase pending for $productId, coins: $coins');

    // Store pending coins for later processing
    _pendingCoins = coins;

    // Notify user that purchase is pending
    _resultHandler?.call(false, 0, 'Purchase is pending, please complete payment in system settings');
  }

  /// Handle purchased or restored purchase
  Future<void> _handlePurchasedOrRestored(PurchaseDetails purchaseDetails) async {
    final productId = purchaseDetails.productID;
    final purchaseId = purchaseDetails.purchaseID ?? '';

    // Get coins from mapping
    int? coins = _orderCoinsMap[productId] ?? _orderCoinsMap[purchaseId];

    // If this is a pending purchase that completed, use stored coins
    if (coins == null && _pendingCoins != null) {
      coins = _pendingCoins;
      _pendingCoins = null;
    }

    debugPrint('PurchaseService: Purchase ${purchaseDetails.status} - productId: $productId, '
        'purchaseId: $purchaseId, coins: $coins');

    if (coins != null && coins > 0) {
      // Add coins via callback
      _addCoinsCallback?.call(coins);

      debugPrint('PurchaseService: Added $coins coins successfully');

      // Notify success
      _resultHandler?.call(true, coins, null);

      // Clean up this purchase mapping (but keep others)
      _orderCoinsMap.remove(productId);
      _orderCoinsMap.remove(purchaseId);
    } else {
      final error = 'No coins found for purchase: $productId / $purchaseId';
      debugPrint('PurchaseService: $error');
      _resultHandler?.call(false, 0, error);
    }

    // Clear current purchase ID and callback
    _currentPurchaseId = null;
    _resultHandler = null;
  }

  /// Handle purchase error
  Future<void> _handleError(PurchaseDetails purchaseDetails) async {
    final productId = purchaseDetails.productID;
    final error = purchaseDetails.error?.toString() ?? 'Unknown purchase error';

    debugPrint('PurchaseService: Purchase error for $productId - $error');

    // Remove mapping and clean up
    _cleanupPurchase(productId, purchaseDetails.purchaseID ?? '');

    // Notify failure
    _resultHandler?.call(false, 0, error);
  }

  /// Handle canceled purchase
  Future<void> _handleCanceled(PurchaseDetails purchaseDetails) async {
    final productId = purchaseDetails.productID;

    debugPrint('PurchaseService: Purchase canceled for $productId');

    // Remove mapping and clean up
    _cleanupPurchase(productId, purchaseDetails.purchaseID ?? '');

    // Notify cancellation
    _resultHandler?.call(false, 0, 'Purchase canceled');

    // Clear pending coins
    _pendingCoins = null;
  }

  /// Clean up purchase data for a specific product/order
  void _cleanupPurchase(String productId, String orderId) {
    _orderCoinsMap.remove(productId);
    _orderCoinsMap.remove(orderId);
    _currentPurchaseId = null;
    _resultHandler = null;
  }

  /// Check and clear unfinished orders before new purchase
  Future<void> _checkAndClearUnfinishedOrders() async {
    debugPrint('PurchaseService: Checking for unfinished orders...');

    try {
      // Restore purchases to find any unfinished transactions
      await _iap.restorePurchases();

      debugPrint('PurchaseService: Restore purchases called, waiting for purchaseStream updates...');
      // Note: purchaseStream will deliver any restored/unfinished purchases
      // Wait a bit for the stream to process
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint('PurchaseService: Error checking unfinished orders - $e');
    }
  }

  /// Restore previous purchases
  Future<void> restorePurchases({
    required Function(bool success, int totalCoins, String? error) onResult,
  }) async {
    if (!_isInitialized) {
      onResult(false, 0, 'Purchase service not initialized');
      return;
    }

    debugPrint('PurchaseService: Restoring purchases...');

    // Set up callback for restoration
    _resultHandler = (bool success, int coins, String? error) {
      if (success) {
        debugPrint('PurchaseService: Restored purchase with $coins coins');
        onResult(true, coins, null);
      } else if (error?.contains('canceled') == true) {
        // Ignore cancellations during restore
        debugPrint('PurchaseService: Ignoring canceled purchase during restore');
      } else {
        onResult(false, 0, error ?? 'Restore failed');
      }
    };

    try {
      await _iap.restorePurchases();

      // Wait for purchases to be delivered via purchaseStream
      await Future.delayed(const Duration(seconds: 2));

      // Clear callback after wait
      _resultHandler = null;

      onResult(true, 0, null);
    } catch (e) {
      final error = 'Restore failed: $e';
      debugPrint('PurchaseService: $error');
      _resultHandler = null;
      onResult(false, 0, error);
    }
  }
}
