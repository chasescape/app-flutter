import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

/// Purchase Service - Handles in-app purchases for coins
/// Key features:
/// - buyNonConsumable for coin packages
/// - Order-to-coin mapping mechanism
/// - Decoupled callback design
class PurchaseService {
  // Singleton pattern
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  // Core dependencies
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isAvailable = false;
  bool _isInitialized = false;

  // Order management
  final Map<String, int> _orderCoinsMap = {}; // productId -> coins mapping
  String? _currentOrderId;

  // Callback decoupling
  Function(String orderId, int coins)? _resultHandler;

  // Add coins callback (injected by CoinsManager)
  Function(int coins)? _addCoinsCallback;

  /// Initialize purchase service
  /// [addCoinsCallback] - Called when purchase succeeds to add coins
  Future<bool> initialize({Function(int coins)? addCoinsCallback}) async {
    _addCoinsCallback = addCoinsCallback;

    if (_isInitialized) {
      return _isAvailable;
    }

    // Check if in-app purchase is available
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) {
      debugPrint('PurchaseService: In-app purchase not available');
      return false;
    }

    // Configure platform-specific settings
    _configurePlatform();

    // Listen to purchase updates
    final Stream<List<PurchaseDetails>> purchaseStream = _iap.purchaseStream;
    _subscription = purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );
    _isInitialized = true;

    debugPrint('PurchaseService: Initialized successfully');
    return true;
  }

  /// Configure platform-specific settings
  void _configurePlatform() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _iap.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(PaymentQueueDelegate());
    }
  }

  /// Execute purchase with decoupled callback
  /// [productId] - Product ID from App Store/Google Play
  /// [coins] - Number of coins to add after successful purchase
  /// [onResult] - Callback with orderId and coins (success) or null (failed/canceled)
  Future<void> executePurchase(
    String productId,
    int coins, {
    required Function(String orderId, int coins)? onResult,
  }) async {
    if (!_isAvailable) {
      onResult?.call('', 0);
      debugPrint('PurchaseService: executePurchase skipped because IAP is unavailable');
      return;
    }

    // Generate unique order ID
    final orderId = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';
    _currentOrderId = orderId;

    // Save mapping: productId -> coins
    _orderCoinsMap[productId] = coins;

    // Save callback
    _resultHandler = onResult;

    debugPrint('PurchaseService: Starting purchase - Order: $orderId, Product: $productId, Coins: $coins');

    try {
      // Query product details
      final ProductDetailsResponse response = await _iap.queryProductDetails({productId});

      if (response.notFoundIDs.isNotEmpty || response.productDetails.isEmpty) {
        debugPrint('PurchaseService: Product not found - $productId');
        _resultHandler?.call('', 0);
        _removeMapping(productId);
        return;
      }

      if (response.error != null) {
        debugPrint('PurchaseService: Query error - ${response.error}');
        _resultHandler?.call('', 0);
        _removeMapping(productId);
        return;
      }

      final ProductDetails productDetails = response.productDetails.first;

      // Coin top-ups should behave like consumables so the same SKU can be
      // purchased repeatedly without StoreKit keeping ownership semantics.
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
      final bool success = await _iap.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );

      if (!success) {
        debugPrint('PurchaseService: Purchase failed to start');
        _removeMapping(productId);
      }
    } catch (e) {
      debugPrint('PurchaseService: Purchase error - $e');
      _resultHandler?.call('', 0);
      _removeMapping(productId);
    }
  }

  /// Handle purchase updates
  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      await _handlePurchase(purchaseDetails);
    }
  }

  /// Handle individual purchase
  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    final productId = purchaseDetails.productID;
    final coins = _orderCoinsMap[productId];

    debugPrint('PurchaseService: Purchase status - ${purchaseDetails.status}, Product: $productId');

    switch (purchaseDetails.status) {
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        // Successful purchase - add coins
        if (coins != null && _addCoinsCallback != null) {
          debugPrint('PurchaseService: Adding $coins coins for product $productId');
          _addCoinsCallback!(coins);
        }

        // Notify success via callback
        _resultHandler?.call(_currentOrderId ?? '', coins ?? 0);

        // Complete the purchase (REQUIRED)
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
          debugPrint('PurchaseService: Purchase completed');
        }

        // Clean up mapping
        _removeMapping(productId);
        break;

      case PurchaseStatus.error:
        debugPrint('PurchaseService: Purchase error - ${purchaseDetails.error}');
        // Notify failure
        _resultHandler?.call('', 0);
        // Complete anyway to clean up
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
        _removeMapping(productId);
        break;

      case PurchaseStatus.canceled:
        debugPrint('PurchaseService: Purchase canceled by user');
        // Notify cancellation
        _resultHandler?.call('', 0);
        // Clean up mapping
        _removeMapping(productId);
        break;

      case PurchaseStatus.pending:
        debugPrint('PurchaseService: Purchase pending');
        break;
    }

    if (purchaseDetails.pendingCompletePurchase) {
      await _iap.completePurchase(purchaseDetails);
      debugPrint('PurchaseService: Completed pending transaction cleanup');
    }
  }

  /// Remove product from mapping
  void _removeMapping(String productId) {
    _orderCoinsMap.remove(productId);
  }

  /// Stream done callback
  void _updateStreamOnDone() {
    _subscription?.cancel();
    _isInitialized = false;
    debugPrint('PurchaseService: Purchase stream closed');
  }

  /// Stream error callback
  void _updateStreamOnError(dynamic error) {
    debugPrint('PurchaseService: Purchase stream error - $error');
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _orderCoinsMap.clear();
    _resultHandler = null;
    _addCoinsCallback = null;
    _isInitialized = false;
    _isAvailable = false;
  }
}

/// iOS Payment Queue Delegate
class PaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
