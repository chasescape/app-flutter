import 'dart:async';

import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:riko/riko/app/modules/coins/data/coins_data.dart';
import 'package:riko/riko/app/services/coin_store.dart';

class CoinsLogic extends GetxController {
  final InAppPurchase _iap = InAppPurchase.instance;

  final RxBool storeReady = false.obs;
  final RxBool isLoading = true.obs;
  final RxBool isPurchasing = false.obs;
  final RxnString errorMessage = RxnString();
  final RxMap<String, ProductDetails> products =
      <String, ProductDetails>{}.obs;

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _subscription = _iap.purchaseStream.listen(_handlePurchaseUpdates);
    _loadStore();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  Future<void> _loadStore() async {
    isLoading.value = true;
    errorMessage.value = null;

    final available = await _iap.isAvailable();
    storeReady.value = available;
    if (!available) {
      isLoading.value = false;
      return;
    }

    final ids = coinsData.map((p) => p.code).toSet();
    final response = await _iap.queryProductDetails(ids);
    if (response.error != null) {
      errorMessage.value = response.error?.message;
    }

    products.clear();
    for (final detail in response.productDetails) {
      products[detail.id] = detail;
    }

    isLoading.value = false;
  }

  ProductDetails? productFor(String code) => products[code];

  Future<void> buy(CoinProductData product) async {
    final detail = productFor(product.code);
    if (detail == null) {
      errorMessage.value = 'Product not available.';
      return;
    }
    final param = PurchaseParam(productDetails: detail);
    await _iap.buyConsumable(purchaseParam: param);
  }

  Future<void> restore() async {
    await _iap.restorePurchases();
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) {
        isPurchasing.value = true;
      }

      if (purchase.status == PurchaseStatus.error) {
        isPurchasing.value = false;
        errorMessage.value = purchase.error?.message ?? 'Purchase failed.';
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
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
        coinsData.firstWhereOrNull((p) => p.code == productId);
    if (product == null) return;
    final next = CoinStore.balance.value + product.coins;
    CoinStore.setBalance(next);
  }
}
