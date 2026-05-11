import 'dart:async';

import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../data/coins_products.dart';
import '../../data/coin_store.dart';
import '../profile/profile_logic.dart';

class CoinsLogic extends GetxController {
  final InAppPurchase _iap = InAppPurchase.instance;
  final RxBool storeAvailable = false.obs;
  final RxBool isLoading = true.obs;
  final RxBool isPurchasing = false.obs;
  final RxMap<String, ProductDetails> productDetails =
      <String, ProductDetails>{}.obs;
  final RxInt balance = 0.obs;

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  @override
  void onInit() {
    _subscription = _iap.purchaseStream.listen(_onPurchaseUpdated);
    _initializeStore();
    _loadBalance();
    super.onInit();
  }

  Future<void> _loadBalance() async {
    final int stored = await CoinStore.loadBalance();
    balance.value = stored;
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

    final response = await _iap.queryProductDetails(CoinProductsData.productIds);
    if (response.error != null) {
      Get.snackbar('Store Error', response.error!.message);
    }
    for (final detail in response.productDetails) {
      productDetails[detail.id] = detail;
    }
    isLoading.value = false;
  }

  ProductDetails? findProduct(String code) => productDetails[code];

  Future<void> buy(CoinProduct product) async {
    final detail = findProduct(product.code);
    if (detail == null) {
      Get.snackbar('Product Unavailable', 'Store product not found.');
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
        Get.snackbar('Purchase Error', purchase.error?.message ?? 'Unknown error');
      }

      if (purchase.status == PurchaseStatus.purchased) {
        final product = CoinProductsData.allProducts
            .firstWhereOrNull((p) => p.code == purchase.productID);
        if (product != null) {
          _applyPurchase(product);
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

  Future<void> _applyPurchase(CoinProduct product) async {
    final int next = await CoinStore.addCoins(product.coins);
    balance.value = next;
    
    // 同步更新 ProfileLogic 的余额
    try {
      final profileLogic = Get.find<ProfileLogic>();
      profileLogic.balance.value = next;
    } catch (_) {
      // ProfileLogic 可能还未初始化，忽略
    }
  }

}
