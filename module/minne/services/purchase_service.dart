import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Purchase Service - Handles in-app purchases
/// Uses buyNonConsumable for coin packages with order-to-coins mapping
class PurchaseService {
  PurchaseService._();

  static PurchaseService? _instance;
  factory PurchaseService() => _instance ??= PurchaseService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // Order-to-coins mapping for tracking pending purchases
  final Map<String, int> _orderCoinsMap = {};

  // Result callback for purchase completion
  Function(bool success, String? productId, int? coins, String? error)? _resultHandler;

  // Product details cache
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _isInitialized = false;

  /// Get available status
  bool get isAvailable => _isAvailable;

  /// Get initialized status
  bool get isInitialized => _isInitialized;

  /// Get available products
  List<ProductDetails> get products => List.unmodifiable(_products);

  /// Initialize the purchase service
  Future<bool> initialize({
    Set<String>? productIds,
  }) async {
    if (_isInitialized) return true;

    try {
      // Check if in-app purchase is available
      _isAvailable = await _iap.isAvailable();

      if (!_isAvailable) {
        debugPrint('PurchaseService: In-app purchase not available');
        return false;
      }

      // Listen to purchase updates
      final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
      _subscription = purchaseUpdated.listen(
        _onPurchaseUpdate,
        onDone: _updateStreamOnDone,
        onError: _updateStreamOnError,
      );

      // Load products
      await loadProducts(productIds: productIds);

      // Clean up any pending purchases from previous sessions
      await _restorePendingPurchases();

      _isInitialized = true;
      debugPrint('PurchaseService: Initialized successfully');
      return true;
    } catch (e) {
      debugPrint('PurchaseService: Initialization failed - $e');
      return false;
    }
  }

  /// Load available products
  Future<void> loadProducts({
    Set<String>? productIds,
  }) async {
    if (!_isAvailable) return;

    try {
      final Set<String> ids = productIds ?? {
        'com.funny.temp.preview.coins100',
        'com.funny.temp.preview.coins500',
        'com.funny.temp.preview.coins1000',
        'com.funny.temp.preview.coins2500',
        'com.funny.temp.preview.coins5000',
        'com.funny.temp.preview.coins10000',
      };

      final ProductDetailsResponse response = await _iap.queryProductDetails(ids);

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('PurchaseService: Products not found - ${response.notFoundIDs}');
      }

      if (response.productDetails.isEmpty) {
        debugPrint('PurchaseService: No products available');
      }

      _products = response.productDetails;
      debugPrint('PurchaseService: Loaded ${_products.length} products');
    } catch (e) {
      debugPrint('PurchaseService: Failed to load products - $e');
    }
  }

  /// Execute purchase for a product
  /// [productId] - Product ID from App Store Connect
  /// [coins] - Number of coins to add after successful purchase
  /// [onResult] - Callback with (success, productId, coins, errorMessage)
  Future<void> executePurchase({
    required String productId,
    required int coins,
    required Function(bool success, String? productId, int? coins, String? error) onResult,
  }) async {
    if (!_isAvailable) {
      onResult(false, productId, null, 'In-app purchase not available');
      return;
    }

    if (_products.isEmpty) {
      onResult(false, productId, null, 'No products available');
      return;
    }

    // Find the product
    final ProductDetails? product = _findProduct(productId);
    if (product == null) {
      onResult(false, productId, null, 'Product not found');
      return;
    }

    // Save the mapping and callback
    final orderKey = _generateOrderKey();
    _orderCoinsMap[orderKey] = coins;
    _resultHandler = onResult;

    // Save to persistent storage for app restart scenario
    await _saveOrderMapping(orderKey, productId, coins);

    try {
      // Execute purchase using buyNonConsumable
      final bool success = await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );

      if (!success) {
        // Clean up on immediate failure
        await _removeOrderMapping(orderKey);
        onResult(false, productId, null, 'Purchase initialization failed');
      }
    } catch (e) {
      // Clean up on error
      await _removeOrderMapping(orderKey);
      _orderCoinsMap.remove(orderKey);
      onResult(false, productId, null, 'Purchase error: ${e.toString()}');
    }
  }

  /// Handle purchase updates from the purchase stream
  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }

  /// Handle individual purchase
  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    switch (purchaseDetails.status) {
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        await _handleSuccessfulPurchase(purchaseDetails);
        break;

      case PurchaseStatus.error:
        await _handleErrorPurchase(purchaseDetails);
        break;

      case PurchaseStatus.canceled:
        await _handleCanceledPurchase(purchaseDetails);
        break;

      case PurchaseStatus.pending:
        debugPrint('PurchaseService: Purchase pending - ${purchaseDetails.productID}');
        break;
    }
  }

  /// Handle successful purchase
  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
    try {
      // Get coins from mapping (try persistent storage first)
      final int? coins = await _getCoinsForOrder(purchaseDetails.productID);

      if (coins != null && coins > 0) {
        // Add coins via callback
        _resultHandler?.call(true, purchaseDetails.productID, coins, null);
      } else {
        // Fallback: try in-memory mapping
        final int? inMemoryCoins = _orderCoinsMap[purchaseDetails.productID];
        if (inMemoryCoins != null) {
          _resultHandler?.call(true, purchaseDetails.productID, inMemoryCoins, null);
        } else {
          _resultHandler?.call(false, purchaseDetails.productID, null, 'Purchase completed but coins mapping not found');
        }
      }

      // Clean up mapping
      await _removeOrderMapping(purchaseDetails.productID);
      _orderCoinsMap.remove(purchaseDetails.productID);

      // Complete the purchase
      if (purchaseDetails.pendingCompletePurchase) {
        await _iap.completePurchase(purchaseDetails);
      }
    } catch (e) {
      debugPrint('PurchaseService: Error handling successful purchase - $e');
    }
  }

  /// Handle error purchase
  Future<void> _handleErrorPurchase(PurchaseDetails purchaseDetails) async {
    final String error = purchaseDetails.error?.message ?? 'Unknown purchase error';

    // Notify error
    _resultHandler?.call(false, purchaseDetails.productID, null, error);

    // Clean up
    await _removeOrderMapping(purchaseDetails.productID);
    _orderCoinsMap.remove(purchaseDetails.productID);

    // Still complete to clear from queue
    if (purchaseDetails.pendingCompletePurchase) {
      await _iap.completePurchase(purchaseDetails);
    }

    debugPrint('PurchaseService: Purchase error - $error');
  }

  /// Handle canceled purchase
  Future<void> _handleCanceledPurchase(PurchaseDetails purchaseDetails) async {
    // Notify cancellation
    _resultHandler?.call(false, purchaseDetails.productID, null, 'Purchase canceled');

    // Clean up
    await _removeOrderMapping(purchaseDetails.productID);
    _orderCoinsMap.remove(purchaseDetails.productID);

    // Complete the purchase
    if (purchaseDetails.pendingCompletePurchase) {
      await _iap.completePurchase(purchaseDetails);
    }

    debugPrint('PurchaseService: Purchase canceled by user');
  }

  /// Restore pending purchases from previous session
  Future<void> _restorePendingPurchases() async {
    try {
      // Check for any stored order mappings
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('order_map_'));

      for (final key in keys) {
        final data = prefs.getString(key);
        if (data != null) {
          final parts = data.split('|');
          if (parts.length == 2) {
            final productId = parts[0];
            final coins = int.tryParse(parts[1]);
            if (productId.isNotEmpty && coins != null) {
              _orderCoinsMap[productId] = coins;
            }
          }
        }
      }

      // Try to restore purchases
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('PurchaseService: Restore purchases failed - $e');
    }
  }

  /// Find product by ID
  ProductDetails? _findProduct(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// Generate unique order key
  String _generateOrderKey() {
    return 'ORDER_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Save order mapping to persistent storage
  Future<void> _saveOrderMapping(String orderKey, String productId, int coins) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('order_map_$productId', '$productId|$coins');
    } catch (e) {
      debugPrint('PurchaseService: Failed to save order mapping - $e');
    }
  }

  /// Remove order mapping from persistent storage
  Future<void> _removeOrderMapping(String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('order_map_$productId');
    } catch (e) {
      debugPrint('PurchaseService: Failed to remove order mapping - $e');
    }
  }

  /// Get coins for an order from persistent storage
  Future<int?> _getCoinsForOrder(String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('order_map_$productId');
      if (data != null) {
        final parts = data.split('|');
        if (parts.length == 2) {
          return int.tryParse(parts[1]);
        }
      }
      return null;
    } catch (e) {
      debugPrint('PurchaseService: Failed to get coins for order - $e');
      return null;
    }
  }

  /// Handle stream done
  void _updateStreamOnDone() {
    _subscription?.cancel();
    debugPrint('PurchaseService: Purchase stream closed');
  }

  /// Handle stream error
  void _updateStreamOnError(dynamic error) {
    debugPrint('PurchaseService: Purchase stream error - $error');
  }

  /// Dispose the service
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _orderCoinsMap.clear();
    _resultHandler = null;
    _isInitialized = false;
  }
}
