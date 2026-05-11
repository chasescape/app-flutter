import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../storage/local_storage.dart';

/// Purchase Service
/// Manages in-app purchase related functionality
class PurchaseService extends GetxService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late LocalStorage _storage;

  // Purchase status
  final _isPremium = false.obs;
  bool get isPremium => _isPremium.value;

  // Available products
  final _products = <ProductDetails>[].obs;
  List<ProductDetails> get products => _products;

  @override
  void onInit() {
    super.onInit();
    _storage = Get.find<LocalStorage>();
    _initPurchase();
  }

  /// Initialize purchase functionality
  Future<void> _initPurchase() async {
    // Check if purchase functionality is available
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      print('In-app purchase not available');
      return;
    }

    // Load local purchase status
    _loadPurchaseStatus();

    // Load available products
    await _loadProducts();

    // Listen to purchase status changes
    _inAppPurchase.purchaseStream.listen(_onPurchaseUpdate);
  }

  /// Load purchase status from local storage
  void _loadPurchaseStatus() {
    _isPremium.value = _storage.getBool('is_premium', defaultValue: false);
  }

  /// Load available products
  Future<void> _loadProducts() async {
    const Set<String> productIds = {
      'premium_monthly',
      'premium_yearly',
    };

    final ProductDetailsResponse response = 
        await _inAppPurchase.queryProductDetails(productIds);

    if (response.notFoundIDs.isNotEmpty) {
      print('Products not found: ${response.notFoundIDs}');
    }

    _products.value = response.productDetails;
  }

  /// Purchase product
  Future<bool> purchaseProduct(ProductDetails product) async {
    try {
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );

      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      return success;
    } catch (e) {
      print('Purchase failed: $e');
      return false;
    }
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      print('Restore purchases failed: $e');
    }
  }

  /// Handle purchase status updates
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased) {
        // Purchase successful
        _handleSuccessfulPurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // Purchase failed
        _handleFailedPurchase(purchaseDetails);
      }

      // Complete purchase process
      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  /// Handle successful purchase
  void _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) {
    // Update local status
    _isPremium.value = true;
    _storage.setBool('is_premium', true);

    // Can verify purchase here (send to server for verification)
    // _verifyPurchaseWithServer(purchaseDetails);

    Get.snackbar('Purchase Successful', 'Thank you for your support!');
  }

  /// Handle failed purchase
  void _handleFailedPurchase(PurchaseDetails purchaseDetails) {
    Get.snackbar('Purchase Failed', purchaseDetails.error?.message ?? 'Unknown error');
  }

  /// Check if user is premium
  bool checkPremiumFeature() {
    if (!_isPremium.value) {
      Get.snackbar('Notice', 'This feature requires upgrade to premium version');
      return false;
    }
    return true;
  }

  /// Clear purchase status (for account logout)
  void clearPurchaseStatus() {
    _isPremium.value = false;
    _storage.remove('is_premium');
  }
}