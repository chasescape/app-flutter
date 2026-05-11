import 'dart:async';

import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:vesper/vesper/app/data/coins_data.dart';
import 'package:vesper/vesper/app/data/coins_wallet_store.dart';

class CoinsLogic extends GetxController {
  final InAppPurchase _iap = InAppPurchase.instance;
  final RxBool storeAvailable = false.obs;
  final RxBool isLoading = true.obs;
  final RxBool isPurchasing = false.obs;
  final RxMap<String, ProductDetails> productDetails =
      <String, ProductDetails>{}.obs;
  final RxInt balance = 0.obs;

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  late final CoinsWalletStore _wallet;

  @override
  void onInit() {
    _wallet = Get.isRegistered<CoinsWalletStore>()
        ? Get.find<CoinsWalletStore>()
        : Get.put(CoinsWalletStore(), permanent: true);
    balance.value = _wallet.balance;
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

    final ids = CoinsData.all().map((p) => p.code).toSet();
    final response = await _iap.queryProductDetails(ids);
    if (response.error != null) {
      // Get.snackbar('Store Error', response.error!.message);
    }
    for (final detail in response.productDetails) {
      productDetails[detail.id] = detail;
    }
    isLoading.value = false;
  }

  ProductDetails? findProduct(String code) => productDetails[code];

  Future<void> buy(CoinsProduct product) async {
    final detail = findProduct(product.code);
    if (detail == null) {
      // Get.snackbar('Product Unavailable', 'Store product not found.');
      return;
    }
    final purchaseParam = PurchaseParam(productDetails: detail);
    await _iap.buyConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) {
        isPurchasing.value = true;
      }

      if (purchase.status == PurchaseStatus.error) {
        isPurchasing.value = false;
        // Get.snackbar(
        //   'Purchase Error',
        //   purchase.error?.message ?? 'Unknown error',
        // );
      }

      if (purchase.status == PurchaseStatus.purchased) {
        _applyPurchase(purchase.productID);
        isPurchasing.value = false;
      }

      if (purchase.status == PurchaseStatus.restored) {
        _applyPurchase(purchase.productID);
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

  void _applyPurchase(String productId) {
    final product =
        CoinsData.all().firstWhereOrNull((p) => p.code == productId);
    if (product == null) return;
    _wallet.add(product.coins);
    balance.value = _wallet.balance;
  }
}
