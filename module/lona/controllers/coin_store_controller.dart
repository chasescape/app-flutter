import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../services/coins_manager.dart';
import '../features/coin_store/contact_coins.dart';
import '../services/purchase_service.dart';

class CoinStoreController extends GetxController {
  final CoinsManager _coinsManager = CoinsManager.to;
  final PurchaseService _purchaseService = PurchaseService.to;

  final RxBool isPurchasing = false.obs;
  final RxBool isLoadingProducts = false.obs;
  final RxString purchasingPackageId = ''.obs;

  final List<Contact575CoinProduct> packages =
      Privatised236CoinProductData.allProductsGrouped;

  @override
  void onInit() {
    super.onInit();
    _coinsManager.refresh();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    isLoadingProducts.value = true;
    try {
      final productIds = packages.map((p) => p.goodsId).toSet();
      await _purchaseService.loadProducts(productIds);
    } finally {
      isLoadingProducts.value = false;
    }
  }

  ValueNotifier<int> get coinsNotifier => _coinsManager.coinsNotifier;

  Future<void> purchasePackage(Contact575CoinProduct package) async {
    if (isPurchasing.value) return;

    isPurchasing.value = true;
    purchasingPackageId.value = package.goodsId;

    await _purchaseService.executePurchase(
      productId: package.goodsId,
      coins: package.exchangeCoin,
      onResult: ({required success, required int coins, String? errorMessage}) {
        isPurchasing.value = false;
        purchasingPackageId.value = '';

        if (success) {
          _coinsManager.addCoins(coins);
          Get.snackbar(
            'Success',
            'Purchased $coins coins!',
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          debugPrint(
            '[CoinStoreController] Purchase error suppressed: '
            '${errorMessage ?? 'Purchase failed'}',
          );
        }
      },
    );
  }

  Future<void> restorePurchases() async {
    await _purchaseService.restorePurchases();
  }

  @override
  void refresh() {
    _coinsManager.refresh();
    super.refresh();
  }
}
