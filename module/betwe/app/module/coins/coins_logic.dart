import 'dart:async';

import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../data/coins_data.dart';
import '../../service/coins_service.dart';

class CoinsLogic extends GetxController {
  final InAppPurchase _iap = InAppPurchase.instance;
  final RxBool storeAvailable = false.obs;
  final RxBool isLoading = true.obs;
  final RxBool isPurchasing = false.obs;
  final RxMap<String, ProductDetails> productDetails =
      <String, ProductDetails>{}.obs;

  late final CoinsService _coinsService;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  RxInt get balance => _coinsService.coins;

  @override
  void onInit() {
    if (!Get.isRegistered<CoinsService>()) {
      Get.put(CoinsService(), permanent: true);
    }
    _coinsService = Get.find<CoinsService>();
    _subscription = _iap.purchaseStream.listen(_onPurchaseUpdated);
    _initializeStore();
    super.onInit();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  Future<void> _initializeStore() async {
    final available = await _iap.isAvailable();
    storeAvailable.value = available;
    if (!available) {
      isLoading.value = false;
      return;
    }

    final response = await _iap.queryProductDetails(CoinsData.productIds);
    if (response.error != null) {
      // Get.snackbar('Store Error', response.error!.message);
    }
    for (final detail in response.productDetails) {
      productDetails[detail.id] = detail;
    }
    isLoading.value = false;
  }

  ProductDetails? findProduct(String code) => productDetails[code];

  Future<void> buy(CoinPackageData package) async {
    if (!storeAvailable.value) {
      // Get.snackbar('Store Unavailable', 'In-app purchase is not available.');
      return;
    }
    final detail = findProduct(package.code.toString());
    if (detail == null) {
      // Get.snackbar('Product Unavailable', 'Store product not found.');
      return;
    }
    final purchaseParam = PurchaseParam(productDetails: detail);
    await _iap.buyConsumable(purchaseParam: purchaseParam);
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) {
        isPurchasing.value = true;
      }

      if (purchase.status == PurchaseStatus.error) {
        isPurchasing.value = false;
        // Get.snackbar('Purchase Error', purchase.error?.message ?? 'Unknown error');
      }

      if (purchase.status == PurchaseStatus.purchased) {
        CoinPackageData? package;
        for (final item in CoinsData.packages) {
          if (item.code.toString() == purchase.productID) {
            package = item;
            break;
          }
        }
        if (package != null) {
          _applyPurchase(package);
        }
        isPurchasing.value = false;
      }

      if (purchase.status == PurchaseStatus.canceled) {
        isPurchasing.value = false;
      }

      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _applyPurchase(CoinPackageData package) async {
    await _coinsService.add(package.coins);
  }
}
