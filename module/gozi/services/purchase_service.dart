import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Purchase Result Type
enum PurchaseResultType {
  success,
  failed,
  canceled,
  pending,
}

/// Purchase Result Callback
typedef PurchaseResultCallback = void Function(
  PurchaseResultType type,
  String? message,
  int? coinsAdded,
);

/// Purchase Service - Handles in-app purchases with buyNonConsumable pattern
///
/// Key Features:
/// - Non-consumable purchase pattern with order-coin mapping
/// - Auto cleanup of unfinished orders before new purchase
/// - Decoupled callback design
/// - Support for continuous purchases
class PurchaseService {
  PurchaseService._();

  static PurchaseService? _instance;
  static PurchaseService get instance {
    _instance ??= PurchaseService._();
    return _instance!;
  }

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Order ID to coins mapping
  final Map<String, int> _orderCoinsMap = {};

  /// Product ID to coins mapping (for restore purchases)
  final Map<String, int> _productCoinsMap = {};

  /// Current purchase result callback
  PurchaseResultCallback? _resultHandler;

  /// Current pending purchase order ID
  String? _currentOrderId;

  /// Is service initialized
  bool _isInitialized = false;

  /// Is purchase in progress
  bool _isPurchasing = false;

  /// Get initialization status
  bool get isInitialized => _isInitialized;

  /// Get purchasing status
  bool get isPurchasing => _isPurchasing;

  /// Initialize service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Check if in-app purchase is available
      final bool isAvailable = await _iap.isAvailable();
      if (!isAvailable) {
        debugPrint('PurchaseService: In-app purchase not available');
        return false;
      }

      // Listen to purchase updates
      _subscription = _iap.purchaseStream.listen(
        _handlePurchaseUpdates,
        onError: (error) {
          debugPrint('PurchaseService: Purchase stream error - $error');
          _handlePurchaseError(error);
        },
      );

      _isInitialized = true;
      debugPrint('PurchaseService: Initialized successfully');
      return true;
    } catch (e) {
      debugPrint('PurchaseService: Initialization failed - $e');
      return false;
    }
  }

  /// Handle purchase updates from purchaseStream
  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      debugPrint(
          'PurchaseService: Received update - ${purchaseDetails.status} for ${purchaseDetails.productID}');

      switch (purchaseDetails.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _handlePurchaseSuccess(purchaseDetails);
          break;

        case PurchaseStatus.error:
          _handlePurchaseError(purchaseDetails.error!);
          break;

        case PurchaseStatus.canceled:
          _handlePurchaseCanceled(purchaseDetails);
          break;

        case PurchaseStatus.pending:
          _handlePurchasePending(purchaseDetails);
          break;
      }

      // Always complete the purchase to clear the queue
      if (purchaseDetails.pendingCompletePurchase) {
        debugPrint(
            'PurchaseService: Completing purchase for ${purchaseDetails.productID}');
        _iap.completePurchase(purchaseDetails);
      }
    }
  }

  /// Handle successful purchase
  void _handlePurchaseSuccess(PurchaseDetails purchaseDetails) {
    debugPrint(
        'PurchaseService: Purchase successful - ${purchaseDetails.productID}');

    // Get coins from mapping (try product ID first, then order ID)
    int coins = 0;
    if (_productCoinsMap.containsKey(purchaseDetails.productID)) {
      coins = _productCoinsMap[purchaseDetails.productID]!;
    } else if (_currentOrderId != null &&
        _orderCoinsMap.containsKey(_currentOrderId!)) {
      coins = _orderCoinsMap[_currentOrderId!]!;
    }

    // Add coins via callback
    if (coins > 0 && _addCoinsCallback != null) {
      _addCoinsCallback!(coins);
      debugPrint('PurchaseService: Added $coins coins');
    }

    // Clean up mappings
    _cleanupMappings();

    // Notify success
    _notifyResult(PurchaseResultType.success, 'Purchase successful!', coins);
  }

  /// Handle purchase error
  void _handlePurchaseError(dynamic error) {
    debugPrint('PurchaseService: Purchase error - $error');

    // Clean up mappings
    _cleanupMappings();

    // Notify error
    final errorMessage = error is IAPError ? error.message : 'Purchase failed';
    _notifyResult(PurchaseResultType.failed, errorMessage, null);
  }

  /// Handle purchase canceled
  void _handlePurchaseCanceled(PurchaseDetails purchaseDetails) {
    debugPrint(
        'PurchaseService: Purchase canceled - ${purchaseDetails.productID}');

    // Clean up mappings
    _cleanupMappings();

    // Notify canceled
    _notifyResult(PurchaseResultType.canceled, 'Purchase canceled', null);
  }

  /// Handle purchase pending
  void _handlePurchasePending(PurchaseDetails purchaseDetails) {
    debugPrint(
        'PurchaseService: Purchase pending - ${purchaseDetails.productID}');

    // Notify pending - don't clean up mappings yet
    _notifyResult(
        PurchaseResultType.pending, 'Purchase is processing...', null);
  }

  /// Notify purchase result via callback
  void _notifyResult(
      PurchaseResultType type, String? message, int? coinsAdded) {
    if (_resultHandler != null) {
      _resultHandler!(type, message, coinsAdded);
      // Clear callback after notification
      _resultHandler = null;
    }
    _isPurchasing = false;
  }

  /// Clean up mappings and current state
  void _cleanupMappings() {
    _orderCoinsMap.clear();
    _productCoinsMap.clear();
    _currentOrderId = null;
  }

  /// Add coins callback - set by CoinsManager
  void Function(int coins)? _addCoinsCallback;

  /// Set add coins callback
  void setAddCoinsCallback(void Function(int coins) callback) {
    _addCoinsCallback = callback;
  }

  /// Check and clean unfinished orders before new purchase
  Future<void> _checkAndCleanUnfinishedOrders() async {
    try {
      debugPrint('PurchaseService: Checking for unfinished orders...');

      // Try to restore purchases to find any unfinished orders
      await _iap.restorePurchases();

      // Wait a bit for purchaseStream to process
      await Future.delayed(const Duration(milliseconds: 500));

      debugPrint('PurchaseService: Unfinished orders check completed');
    } catch (e) {
      debugPrint('PurchaseService: Error checking unfinished orders - $e');
    }
  }

  /// Execute purchase with product ID and coins amount
  ///
  /// Parameters:
  /// - productId: Product ID for in-app purchase
  /// - coins: Coins to add after successful purchase
  /// - onResult: Callback for purchase result
  Future<void> executePurchase({
    required String productId,
    required int coins,
    required PurchaseResultCallback onResult,
  }) async {
    // Check initialization
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        onResult(
            PurchaseResultType.failed, 'In-app purchase not available', null);
        return;
      }
    }

    // Check if already purchasing
    if (_isPurchasing) {
      onResult(
          PurchaseResultType.failed, 'Purchase in progress, please wait', null);
      return;
    }

    try {
      _isPurchasing = true;
      _resultHandler = onResult;

      // Step 1: Check and clean unfinished orders
      await _checkAndCleanUnfinishedOrders();

      // Step 2: Create unique order ID
      final orderId = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';
      _currentOrderId = orderId;

      // Step 3: Save order-coin mapping
      _orderCoinsMap[orderId] = coins;
      _productCoinsMap[productId] = coins;

      debugPrint(
          'PurchaseService: Initiating purchase - Product: $productId, Order: $orderId, Coins: $coins');

      // Step 4: Query product details
      final ProductDetailsResponse response =
          await _iap.queryProductDetails({productId});
      if (response.notFoundIDs.contains(productId)) {
        throw Exception('Product not found: $productId');
      }
      final products = response.productDetails;

      final ProductDetails productDetails = products.first;

      // Step 5: Execute purchase using buyNonConsumable
      final bool purchaseResult = await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(
          productDetails: productDetails,
        ),
      );

      if (!purchaseResult) {
        throw Exception('Failed to initiate purchase');
      }

      debugPrint('PurchaseService: Purchase initiated successfully');
    } catch (e) {
      debugPrint('PurchaseService: Purchase failed - $e');

      // Clean up on error
      _cleanupMappings();
      _isPurchasing = false;

      onResult(PurchaseResultType.failed, 'Purchase failed: $e', null);
    }
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    try {
      debugPrint('PurchaseService: Restoring purchases...');
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('PurchaseService: Restore failed - $e');
    }
  }

  /// Dispose service
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _cleanupMappings();
    _isInitialized = false;
    debugPrint('PurchaseService: Disposed');
  }
}
