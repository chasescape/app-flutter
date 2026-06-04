import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pliro/pliro/core/managers/coins_manager.dart';

/// Purchase result callback
typedef PurchaseResultCallback = void Function(
    bool success, bool canceled, String? message);

/// Purchase service - handles in-app purchase for coin packages
class PurchaseService {
  PurchaseService._internal();

  static PurchaseService? _instance;

  static PurchaseService get instance {
    _instance ??= PurchaseService._internal();
    return _instance!;
  }

  final InAppPurchase _iap = InAppPurchase.instance;
  final CoinsManager _coinsManager = CoinsManager.instance;
  static const MethodChannel _nativeIapChannel =
      MethodChannel('pliro/native_iap');

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Order ID to coins mapping
  final Map<String, int> _orderCoinsMap = {};

  /// Product ID to coins mapping (for restored purchases)
  final Map<String, int> _productCoinsMap = {};

  /// Current purchase result handler
  PurchaseResultCallback? _resultHandler;

  /// Pending purchases that need completion
  final Set<String> _pendingCompletions = {};

  /// Is service ready
  bool _isReady = false;

  /// Get is ready
  bool get isReady => _isReady;

  /// Initialize purchase service
  Future<bool> initialize() async {
    if (_isReady) return true;

    if (Platform.isIOS) {
      _isReady = true;
      return true;
    }

    // Check if in-app purchase is available
    final isAvailable = await _iap.isAvailable();
    if (!isAvailable) {
      debugPrint('In-app purchase not available on this device');
      return false;
    }
    debugPrint('In-app purchase available');

    // Listen to purchase updates
    final purchaseStream = _iap.purchaseStream;
    _subscription = purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );

    // Check and clean any unfinished purchases
    await _checkAndCleanPendingPurchases();

    _isReady = true;
    return true;
  }

  /// Check and clean pending/unfinished purchases
  /// This must be called before any new purchase to avoid "pending purchase" errors
  Future<void> _checkAndCleanPendingPurchases() async {
    try {
      // Try to restore purchases to find any pending/unfinished transactions
      // This will trigger purchaseStream with any pending purchases
      // Note: restorePurchases() doesn't work on Android for consumables,
      // but we use non-consumables so it should work
    } catch (e) {
      debugPrint('Error checking pending purchases: $e');
    }
  }

  /// Execute purchase for a coin package
  ///
  /// Parameters:
  /// - productId: The primary App Store product ID to purchase
  /// - fallbackProductIds: Extra IDs to query if the primary ID is not found
  /// - coins: Number of coins to award after successful purchase
  /// - onResult: Callback for purchase result (success, canceled, error)
  Future<void> executePurchase({
    required String productId,
    List<String> fallbackProductIds = const [],
    required int coins,
    required PurchaseResultCallback onResult,
  }) async {
    final productIds = _buildProductIdCandidates(
      productId,
      fallbackProductIds,
    );

    if (productIds.isEmpty) {
      onResult(false, false, 'No product ID available');
      return;
    }

    if (Platform.isIOS) {
      await _executeIosNativePurchase(
        productIds: productIds,
        coins: coins,
        onResult: onResult,
      );
      return;
    }

    // Initialize if not ready
    if (!_isReady) {
      final initialized = await initialize();
      if (!initialized) {
        onResult(false, false, 'In-app purchase not available');
        return;
      }
    }

    // Clean any existing mappings and handlers
    _orderCoinsMap.clear();
    _productCoinsMap.clear();
    _resultHandler = null;

    debugPrint('Purchase requested. productIds: $productIds, coins: $coins');

    // Save the coins mapping for each possible App Store product ID.
    for (final candidateProductId in productIds) {
      _productCoinsMap[candidateProductId] = coins;
    }

    // Save the result handler
    _resultHandler = onResult;

    // Generate order ID
    final orderId = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';
    _orderCoinsMap[orderId] = coins;

    try {
      // Get product details. StoreKit only opens the payment sheet after a
      // valid ProductDetails is fetched, so query every possible configured ID.
      final ProductDetailsResponse response =
          await _iap.queryProductDetails(productIds.toSet());

      debugPrint('IAP found products: '
          '${response.productDetails.map((item) => item.id).toList()}');
      debugPrint('IAP not found products: ${response.notFoundIDs}');

      if (response.productDetails.isEmpty) {
        onResult(false, false, 'Product not found: ${productIds.join(', ')}');
        _cleanup();
        return;
      }

      if (response.error != null) {
        onResult(false, false, response.error!.message);
        _cleanup();
        return;
      }

      final productDetails = _selectProductDetails(
        response.productDetails,
        productIds,
      );
      debugPrint('Starting native purchase for product: ${productDetails.id}');

      // Execute purchase
      final purchaseParam = PurchaseParam(productDetails: productDetails);

      // Check for pending purchases before starting new one
      // If there's a pending purchase, we'll handle it in the stream
      if (_pendingCompletions.isNotEmpty) {
        debugPrint(
            'Have ${_pendingCompletions.length} pending completions, waiting...');
      }

      final purchaseStarted = await _iap.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );
      debugPrint('buyConsumable called. started: $purchaseStarted');
      if (!purchaseStarted) {
        onResult(false, false, 'Unable to start purchase');
        _cleanup();
      }
    } catch (e) {
      debugPrint('Purchase error: $e');
      onResult(false, false, e.toString());
      _cleanup();
    }
  }

  Future<void> _executeIosNativePurchase({
    required List<String> productIds,
    required int coins,
    required PurchaseResultCallback onResult,
  }) async {
    debugPrint(
      'Starting iOS native IAP. productIds: $productIds, coins: $coins',
    );

    try {
      final result = await _nativeIapChannel.invokeMapMethod<String, dynamic>(
        'purchaseConsumable',
        <String, dynamic>{'productIds': productIds},
      );
      final status = result?['status'] as String?;
      final message = result?['message'] as String?;
      final purchasedProductId = result?['productId'] as String?;

      debugPrint(
        'iOS native IAP result: status=$status, productId=$purchasedProductId, message=$message',
      );

      switch (status) {
        case 'purchased':
          await _coinsManager.addCoins(coins);
          debugPrint(
              'Added $coins coins, new balance: ${_coinsManager.currentCoins}');
          onResult(true, false, 'Successfully purchased $coins coins');
          break;
        case 'canceled':
          onResult(false, true, message ?? 'Purchase canceled');
          break;
        case 'pending':
          onResult(false, false, message ?? 'Purchase is pending');
          break;
        default:
          onResult(false, false, message ?? 'Purchase failed');
          break;
      }
    } on PlatformException catch (e) {
      debugPrint('iOS native IAP platform error: ${e.code}, ${e.message}');
      onResult(
        false,
        e.code == 'purchase_canceled',
        e.message ?? e.code,
      );
    } catch (e) {
      debugPrint('iOS native IAP error: $e');
      onResult(false, false, e.toString());
    }
  }

  List<String> _buildProductIdCandidates(
    String primaryProductId,
    List<String> fallbackProductIds,
  ) {
    final ids = <String>[];
    for (final rawId in [primaryProductId, ...fallbackProductIds]) {
      final id = rawId.trim();
      if (id.isNotEmpty && !ids.contains(id)) {
        ids.add(id);
      }
    }
    return ids;
  }

  ProductDetails _selectProductDetails(
    List<ProductDetails> products,
    List<String> preferredIds,
  ) {
    for (final preferredId in preferredIds) {
      for (final product in products) {
        if (product.id == preferredId) {
          return product;
        }
      }
    }
    return products.first;
  }

  /// Handle purchase updates from the stream
  Future<void> _handlePurchaseUpdates(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchaseDetails in purchaseDetailsList) {
      await _handlePurchaseDetails(purchaseDetails);
    }
  }

  /// Handle individual purchase details
  Future<void> _handlePurchaseDetails(PurchaseDetails purchaseDetails) async {
    debugPrint('Purchase status: ${purchaseDetails.status}');
    debugPrint('Product ID: ${purchaseDetails.productID}');

    switch (purchaseDetails.status) {
      case PurchaseStatus.pending:
        _handlePending(purchaseDetails);
        break;

      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        await _handlePurchasedOrRestored(purchaseDetails);
        break;

      case PurchaseStatus.error:
        _handleError(purchaseDetails);
        break;

      case PurchaseStatus.canceled:
        _handleCanceled(purchaseDetails);
        break;
    }

    // Complete the purchase to remove it from the queue
    // This is CRITICAL - even for canceled/error purchases we must complete
    if (purchaseDetails.pendingCompletePurchase) {
      try {
        await _iap.completePurchase(purchaseDetails);
        _pendingCompletions.remove(purchaseDetails.purchaseID);
        debugPrint('Completed purchase: ${purchaseDetails.purchaseID}');
      } catch (e) {
        debugPrint('Error completing purchase: $e');
      }
    }
  }

  /// Handle pending purchase
  void _handlePending(PurchaseDetails purchaseDetails) {
    debugPrint('Purchase pending: ${purchaseDetails.productID}');

    _resultHandler?.call(
        false, false, 'Purchase is pending payment confirmation');
  }

  /// Handle successful or restored purchase
  Future<void> _handlePurchasedOrRestored(
      PurchaseDetails purchaseDetails) async {
    debugPrint('Purchase/restored: ${purchaseDetails.productID}');

    // Get coins from product mapping (fallback to order mapping)
    final coins = _productCoinsMap[purchaseDetails.productID] ??
        _orderCoinsMap.values.firstOrNull;

    if (coins == null || coins <= 0) {
      debugPrint('No coins found for product: ${purchaseDetails.productID}');
      _resultHandler?.call(false, false, 'Invalid purchase - no coins mapped');
      _cleanup();
      return;
    }

    // Add coins to balance
    try {
      await _coinsManager.addCoins(coins);
      debugPrint(
          'Added $coins coins, new balance: ${_coinsManager.currentCoins}');

      // Notify success
      _resultHandler?.call(true, false, 'Successfully purchased $coins coins');

      // Clean up after successful purchase
      _cleanup();
    } catch (e) {
      debugPrint('Error adding coins: $e');
      _resultHandler?.call(
          false, false, 'Purchase completed but failed to add coins');
      _cleanup();
    }
  }

  /// Handle purchase error
  void _handleError(PurchaseDetails purchaseDetails) {
    debugPrint('Purchase error: ${purchaseDetails.error?.toString()}');

    // Clean up mappings and handler
    _resultHandler?.call(
        false, false, purchaseDetails.error?.message ?? 'Purchase failed');
    _cleanup();
  }

  /// Handle canceled purchase
  void _handleCanceled(PurchaseDetails purchaseDetails) {
    debugPrint('Purchase canceled by user');

    // Clean up mappings and handler
    _resultHandler?.call(false, true, 'Purchase canceled');
    _cleanup();
  }

  /// Clean up mappings and handlers after purchase completion
  void _cleanup() {
    _orderCoinsMap.clear();
    _productCoinsMap.clear();
    _resultHandler = null;
  }

  /// Restore purchases (for transferring purchases between devices)
  Future<void> restorePurchases() async {
    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
    }
  }

  /// Update stream done callback
  void _updateStreamOnDone() {
    _subscription?.cancel();
    debugPrint('Purchase stream done');
  }

  /// Update stream error callback
  void _updateStreamOnError(dynamic error) {
    debugPrint('Purchase stream error: $error');
  }

  /// Dispose the service
  Future<void> dispose() async {
    await _subscription?.cancel();
    _cleanup();
    _isReady = false;
  }
}
