import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:crushi/crushi/data/coins_wallet_store.dart';
import 'package:crushi/crushi/features/coins/contact_coins.dart';

class CoinsLogic extends ChangeNotifier {
  CoinsLogic({
    InAppPurchase? iap,
    CoinsWalletStore? wallet,
  })  : _iap = iap ?? InAppPurchase.instance,
        _wallet = wallet ?? CoinsWalletStore();

  final InAppPurchase _iap;
  final CoinsWalletStore _wallet;

  bool storeAvailable = false;
  bool isLoading = true;
  bool isPurchasing = false;
  int balance = 0;
  final Map<String, ProductDetails> productDetails = {};

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  Future<void> init() async {
    await _wallet.load();
    balance = _wallet.balance;

    _subscription ??= _iap.purchaseStream.listen(_onPurchaseUpdated);
    await _initializeStore();
  }

  void disposeLogic() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _initializeStore() async {
    final available = await _iap.isAvailable();
    storeAvailable = available;
    if (!available) {
      isLoading = false;
      notifyListeners();
      return;
    }

    final ids = Privatised236CoinProductData.allProducts
        .map((p) => p.code)
        .toSet();
    final response = await _iap.queryProductDetails(ids);
    for (final detail in response.productDetails) {
      productDetails[detail.id] = detail;
    }

    isLoading = false;
    notifyListeners();
  }

  ProductDetails? findProduct(String code) => productDetails[code];

  Future<void> buy(Contact575CoinProduct product) async {
    final detail = findProduct(product.code);
    if (detail == null) return;

    isPurchasing = true;
    notifyListeners();

    try {
      final purchaseParam = PurchaseParam(productDetails: detail);
      await _iap.buyConsumable(
        purchaseParam: purchaseParam,
        // Required by `in_app_purchase_storekit`: on iOS we should always auto
        // consume; on Android this also helps ensure consumables can be re-bought.
        autoConsume: true,
      );
    } catch (_) {
      isPurchasing = false;
      notifyListeners();
      // Swallow to avoid crashing the app; callers can rely on UI state reset.
    }
  }

  Future<void> _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) {
        isPurchasing = true;
        notifyListeners();
      }

      if (purchase.status == PurchaseStatus.error ||
          purchase.status == PurchaseStatus.canceled) {
        isPurchasing = false;
        notifyListeners();
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await _applyPurchase(purchase.productID);

        isPurchasing = false;
        notifyListeners();
      }

      // Always complete the purchase if required (even for canceled/errored),
      // otherwise the store may treat it as still pending and block re-buy.
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _applyPurchase(String productId) async {
    final product = Privatised236CoinProductData.allProducts.firstWhere(
      (p) => p.code == productId,
      orElse: () => const Contact575CoinProduct(
        code: '',
        goodsId: '',
        name: '',
        description: '',
        price: 0,
        exchangeCoin: 0,
        isPromotion: false,
      ),
    );
    if (product.code.isEmpty) return;

    await _wallet.add(product.exchangeCoin);
    balance = _wallet.balance;
  }
}
