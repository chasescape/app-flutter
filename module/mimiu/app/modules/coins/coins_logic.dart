import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

import '../../data/coin_products_data.dart';
import '../../services/coin_wallet.dart';

class CoinsLogic extends GetxController {
  final InAppPurchase _iap = InAppPurchase.instance;
  final CoinWallet _wallet = CoinWallet();

  final RxBool storeAvailable = false.obs;
  final RxBool isLoading = true.obs;
  final RxBool purchaseInProgress = false.obs;
  final RxString purchaseOverlayText = 'Processing...'.obs;
  final RxInt balance = 0.obs;

  final RxList<CoinProductData> products = <CoinProductData>[].obs;
  final RxMap<String, ProductDetails> storeDetails =
      <String, ProductDetails>{}.obs;

  StreamSubscription<List<PurchaseDetails>>? _sub;
  final Map<String, PurchaseDetails> _latestByProductId = <String, PurchaseDetails>{};
  Timer? _purchaseTimeout;

  @override
  void onInit() {
    super.onInit();
    products.assignAll(kCoinProducts);
    unawaited(_loadBalance());
    unawaited(_initStore());
  }

  Future<void> _loadBalance() async {
    balance.value = await _wallet.getBalance();
  }

  Future<void> _initStore() async {
    isLoading.value = true;
    storeAvailable.value = await _iap.isAvailable();

    _sub ??= _iap.purchaseStream.listen(
      _onPurchasesUpdated,
      onDone: () => _sub = null,
      onError: (_) => purchaseInProgress.value = false,
    );

    if (!storeAvailable.value) {
      isLoading.value = false;
      return;
    }

    // User preference: don't get stuck on pending StoreKit transactions.
    // Clear any lingering transactions in the payment queue (sandbox + hot
    // restart can easily leave them around).
    unawaited(_finishAllIosTransactions());

    // Kick off a background restore to help clear any pending StoreKit
    // transactions (common in sandbox + hot restart). Don't block UI on this.
    // The purchaseStream will deliver updates if anything is pending.
    unawaited(_safeRestorePurchases());

    final ids = products.map((e) => e.code.toString()).toSet();
    final resp = await _iap.queryProductDetails(ids);
    for (final p in resp.productDetails) {
      storeDetails[p.id] = p;
    }

    isLoading.value = false;
  }

  Future<void> _safeRestorePurchases() async {
    try {
      await _iap.restorePurchases();
    } catch (_) {}
  }

  Future<void> buy(CoinProductData product) async {
    if (purchaseInProgress.value) return;
    if (isLoading.value) return;
    if (!storeAvailable.value) return;

    final productId = product.code.toString();
    final details = storeDetails[productId];
    if (details == null) return;

    purchaseOverlayText.value = 'Opening payment...';
    purchaseInProgress.value = true;
    _purchaseTimeout?.cancel();
    _purchaseTimeout = Timer(const Duration(seconds: 20), () {
      if (!purchaseInProgress.value) return;
      purchaseInProgress.value = false;
    });
    final param = PurchaseParam(productDetails: details);
    try {
      final ok = await _iap.buyConsumable(purchaseParam: param);
      if (!ok) purchaseInProgress.value = false;
    } on PlatformException catch (e) {
      // Common in sandbox/hot restart: a previous transaction is still pending.
      if (e.code == 'storekit_duplicate_product_object') {
        // Force-finish the stale transaction so user can try again immediately.
        await _finishIosTransactions(productId);
        // Best-effort retry once (no UI noise).
        try {
          final ok = await _iap.buyConsumable(purchaseParam: param);
          if (!ok) purchaseInProgress.value = false;
          return;
        } catch (_) {}
      }
      purchaseInProgress.value = false;
      _purchaseTimeout?.cancel();
    } catch (_) {
      purchaseInProgress.value = false;
      _purchaseTimeout?.cancel();
    }
  }

  Future<void> _finishAllIosTransactions() async {
    if (!Platform.isIOS) return;
    try {
      final queue = SKPaymentQueueWrapper();
      final txs = await queue.transactions();
      for (final tx in txs) {
        try {
          await queue.finishTransaction(tx);
        } catch (_) {}
      }
    } catch (_) {}
  }

  Future<void> _finishIosTransactions(String productId) async {
    if (!Platform.isIOS) return;
    try {
      final queue = SKPaymentQueueWrapper();
      final txs = await queue.transactions();
      for (final tx in txs) {
        final id = tx.payment.productIdentifier;
        if (id == productId) {
          try {
            await queue.finishTransaction(tx);
          } catch (_) {}
        }
      }
    } catch (_) {}
  }

  Future<void> restore() async {
    if (!storeAvailable.value) return;
    await _iap.restorePurchases();
    // Get.snackbar(
    //   'Restore',
    //   'Restore request sent.',
    //   backgroundColor: const Color(0xFF0B0B0B).withValues(alpha: 0.80),
    //   colorText: const Color(0xFFFDE68A),
    //   snackPosition: SnackPosition.BOTTOM,
    //   margin: const EdgeInsets.all(16),
    // );
  }

  void _onPurchasesUpdated(List<PurchaseDetails> purchases) {
    for (final p in purchases) {
      _latestByProductId[p.productID] = p;
      switch (p.status) {
        case PurchaseStatus.pending:
          purchaseOverlayText.value = 'Waiting for confirmation...';
          purchaseInProgress.value = true;
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _purchaseTimeout?.cancel();
          unawaited(_deliver(p));
          break;
        case PurchaseStatus.canceled:
          purchaseInProgress.value = false;
          _purchaseTimeout?.cancel();
          break;
        case PurchaseStatus.error:
          purchaseInProgress.value = false;
          _purchaseTimeout?.cancel();
          break;
      }
    }
  }

  Future<void> _deliver(PurchaseDetails purchase) async {
    purchaseOverlayText.value = 'Finalizing...';
    try {
      final code = int.tryParse(purchase.productID);
      final product = products.firstWhereOrNull((e) => e.code == code);
      if (product != null) {
        await _wallet.add(product.coins);
        balance.value = await _wallet.getBalance();
      }
    } finally {
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
      purchaseInProgress.value = false;
      _purchaseTimeout?.cancel();
    }
  }

  String displayPrice(CoinProductData p) {
    // Always show the USD value from seed data (no localized currency display).
    return '\$${p.priceUsd.toStringAsFixed(2)}';
  }

  String? displayOriginalPrice(CoinProductData p) {
    if (p.type != CoinProductType.promo) return null;

    // Estimate a "regular" price for this coin amount using the regular curve.
    final regular = products.where((e) => e.type == CoinProductType.regular).toList()
      ..sort((a, b) => a.coins.compareTo(b.coins));
    if (regular.length < 2) return null;

    double estimate;
    final target = p.coins;

    CoinProductData? left;
    CoinProductData? right;
    for (var i = 0; i < regular.length; i++) {
      final r = regular[i];
      if (r.coins == target) {
        estimate = r.priceUsd;
        // Only show strike-through if it's actually higher.
        if (estimate <= p.priceUsd + 0.01) return null;
        return '\$${estimate.toStringAsFixed(2)}';
      }
      if (r.coins < target) left = r;
      if (r.coins > target) {
        right = r;
        break;
      }
    }

    if (left == null) {
      // Below smallest: scale by per-coin price of smallest.
      final r0 = regular.first;
      estimate = (target / r0.coins) * r0.priceUsd;
    } else if (right == null) {
      // Above largest: extrapolate with last segment.
      final a = regular[regular.length - 2];
      final b = regular.last;
      final t = (target - a.coins) / (b.coins - a.coins);
      estimate = a.priceUsd + (b.priceUsd - a.priceUsd) * t;
    } else {
      final t = (target - left.coins) / (right.coins - left.coins);
      estimate = left.priceUsd + (right.priceUsd - left.priceUsd) * t;
    }

    // Keep it visibly higher than promo and avoid tiny differences.
    estimate = estimate.clamp(0.0, 9999.0);
    if (estimate <= p.priceUsd + 0.20) {
      estimate = p.priceUsd + 0.50;
    }
    return '\$${estimate.toStringAsFixed(2)}';
  }

  @override
  void onClose() {
    _sub?.cancel();
    _sub = null;
    _purchaseTimeout?.cancel();
    _purchaseTimeout = null;
    super.onClose();
  }
}
