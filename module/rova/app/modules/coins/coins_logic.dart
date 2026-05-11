import 'dart:async';

import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/coin_packs.dart';
import '../profile/profile_logic.dart';

class CoinPack {
  const CoinPack({
    required this.productId,
    required this.coins,
    required this.priceLabel,
    required this.originalPriceLabel,
    required this.category,
    required this.title,
    this.badge,
  });

  final int productId;
  final int coins;
  final String priceLabel;
  final String? originalPriceLabel;
  final CoinPackCategory category;
  final String title;
  final String? badge;

  String get storeId => productId.toString();
}

class CoinsLogic extends GetxController {
  static const String _kBalanceKey = 'rova.coins.balance';
  static const int initialBalance = 100;

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final Set<String> _processedPurchaseIds = <String>{};

  final RxInt balance = 0.obs;
  final RxBool storeReady = false.obs;
  final RxBool isLoading = true.obs;
  final RxBool isPurchasing = false.obs;

  final RxMap<String, ProductDetails> products =
      <String, ProductDetails>{}.obs;

  late final List<CoinPack> packs;

  @override
  void onInit() {
    super.onInit();
    _subscription = _iap.purchaseStream.listen(_handlePurchaseUpdates);
    packs = kCoinPacks
        .map(
          (p) => CoinPack(
            productId: p.productId,
            title: p.title,
            coins: p.coins,
            priceLabel: p.priceLabel,
            originalPriceLabel: p.originalPriceLabel,
            category: p.category,
            badge: p.category == CoinPackCategory.promo ? 'LIMITED' : null,
          ),
        )
        .toList(growable: false);
    _load();
    _loadStore();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getInt(_kBalanceKey);
    if (stored == null) {
      balance.value = initialBalance;
      await prefs.setInt(_kBalanceKey, balance.value);
      return;
    }
    balance.value = stored;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kBalanceKey, balance.value);
  }

  Future<void> refreshBalance() async {
    await _load();
  }

  Future<void> _loadStore() async {
    isLoading.value = true;
    products.clear();

    try {
      final available = await _iap.isAvailable();
      storeReady.value = available;
      if (!available) {
        isLoading.value = false;
        return;
      }

      final ids = packs.map((p) => p.storeId).toSet();
      final response = await _iap.queryProductDetails(ids);
      if (response.productDetails.isNotEmpty) {
        for (final detail in response.productDetails) {
          products[detail.id] = detail;
        }
      }
    } catch (_) {
      // No error UI per requirement.
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> buy(CoinPack pack) async {
    final detail = products[pack.storeId];
    if (detail == null) {
      // No error UI per requirement.
      return;
    }

    try {
      final param = PurchaseParam(productDetails: detail);
      await _iap.buyConsumable(purchaseParam: param);
    } catch (_) {
      // No error UI per requirement.
    }
  }

  Future<void> clearBalance() async {
    balance.value = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kBalanceKey);
    if (Get.isRegistered<ProfileLogic>()) {
      await Get.find<ProfileLogic>().refreshCoins();
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) {
        isPurchasing.value = true;
      }

      if (purchase.status == PurchaseStatus.error ||
          purchase.status == PurchaseStatus.canceled) {
        isPurchasing.value = false;
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        _applyPurchase(purchase);
        isPurchasing.value = false;
      }

      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _applyPurchase(PurchaseDetails purchase) async {
    final pid = purchase.purchaseID ?? '${purchase.productID}-${purchase.status}';
    if (_processedPurchaseIds.contains(pid)) return;
    _processedPurchaseIds.add(pid);

    final pack = packs.firstWhereOrNull((p) => p.storeId == purchase.productID);
    if (pack == null) return;

    balance.value += pack.coins;
    await _save();
    if (Get.isRegistered<ProfileLogic>()) {
      await Get.find<ProfileLogic>().refreshCoins();
    }

    Get.snackbar(
      'Success',
      '+${pack.coins} coins',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
