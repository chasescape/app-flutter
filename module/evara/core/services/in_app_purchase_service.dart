import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:signals/signals_flutter.dart';
import '../singletons/user_service.dart';

/// In-App Purchase Service
class InAppPurchaseService extends GetxController {
  final InAppPurchase _iap = InAppPurchase.instance;
  final UserService _userService = UserService.instance;

  final available = signal<bool>(false);
  final products = signal<List<ProductDetails>>([]);
  final isPurchasing = signal<bool>(false);

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    final isAvailable = await _iap.isAvailable();
    available.value = isAvailable;

    if (isAvailable) {
      // Listen to purchase updates
      final purchaseStream = _iap.purchaseStream;
      purchaseStream.listen((purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      }, onDone: () {}, onError: (error) {});

      // Load products
      await loadProducts();
    }
  }

  Future<void> loadProducts() async {
    // This would load real product IDs from the store
    // For now, we'll use mock products
    products.value = [];
  }

  Future<bool> purchaseCoins(int coinAmount) async {
    if (!available.value) {
      Get.snackbar('Error', 'In-app purchases not available');
      return false;
    }

    isPurchasing.value = true;

    try {
      // Simulate purchase
      await Future.delayed(const Duration(seconds: 2));

      // Add coins
      await _userService.addCoins(coinAmount);

      isPurchasing.value = false;
      return true;
    } catch (e) {
      isPurchasing.value = false;
      Get.snackbar('Error', 'Purchase failed: $e');
      return false;
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      // Handle purchase
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        // Deliver coins
        // Complete purchase
        if (purchaseDetails.pendingCompletePurchase) {
          _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }
}
