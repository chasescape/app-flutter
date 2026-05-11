import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../contact_coins.dart';
import '../../../services/purchase/purchase_service.dart';
import '../../../services/coins/coins_manager.dart';

/// Coin Store Controller
class CoinStoreController extends GetxController with WidgetsBindingObserver {
  final RxList<Contact575CoinProduct> coinPackages =
      <Contact575CoinProduct>[].obs;
  final RxBool isLoading = false.obs;
  final RxString currentBalance = '0'.obs;
  final RxBool isPurchaseAvailable = false.obs;
  final RxnString purchasingProductId = RxnString();

  final PurchaseService _purchaseService = PurchaseService.instance;
  final CoinsManager _coinsManager = CoinsManager.instance;
  Timer? _purchaseResumeFallbackTimer;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    loadCoinPackages();
    _initializePurchaseService();
    _setupCoinsListener();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _coinsManager.removeListener(_coinsListener);
    _purchaseResumeFallbackTimer?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (purchasingProductId.value == null) {
      return;
    }

    if (state == AppLifecycleState.resumed) {
      _purchaseResumeFallbackTimer?.cancel();
      _purchaseResumeFallbackTimer = Timer(
        const Duration(milliseconds: 500),
        _clearPurchaseState,
      );
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _purchaseResumeFallbackTimer?.cancel();
    }
  }

  /// Initialize purchase service
  Future<void> _initializePurchaseService() async {
    try {
      _purchaseService.setAddCoinsCallback((int coins) async {
        await _coinsManager.addCoins(coins);
      });

      final available = await _purchaseService.initialize(
        productCoinsById: {
          for (final product in Privatised236CoinProductData.allProducts)
            product.goodsId: product.exchangeCoin,
        },
      );
      isPurchaseAvailable.value = available;

      if (!available) {
        return;
      }
    } catch (e) {
      debugPrint('Failed to initialize purchase service: $e');
      isPurchaseAvailable.value = false;
    }
  }

  /// Setup coins listener
  void _setupCoinsListener() {
    currentBalance.value = _coinsManager.balanceString;
    _coinsManager.addListener(_coinsListener);
  }

  /// Coins value changed listener
  void _coinsListener() {
    currentBalance.value = _coinsManager.balanceString;
  }

  void loadCoinPackages() {
    isLoading.value = true;
    coinPackages.assignAll(Privatised236CoinProductData.allProductsGrouped);
    isLoading.value = false;
  }

  Future<void> purchasePackage(Contact575CoinProduct package) async {
    final productId = package.goodsId;
    final totalCoins = package.exchangeCoin;

    if (purchasingProductId.value != null) {
      return;
    }

    if (productId.isEmpty || totalCoins <= 0) {
      debugPrint('Invalid package: $productId -> $totalCoins');
      return;
    }

    purchasingProductId.value = productId;
    _purchaseResumeFallbackTimer?.cancel();

    try {
      await _purchaseService.executePurchase(
        productId,
        totalCoins,
        onResult: (orderId, purchasedCoins, success, error) {
          _clearPurchaseState();

          if (success) {
            // Get.snackbar(
            //   'Success',
            //   'You received $purchasedCoins coins!',
            //   backgroundColor: Get.theme.colorScheme.primary,
            //   colorText: Get.theme.colorScheme.onPrimary,
            //   snackPosition: SnackPosition.TOP,
            // );
            debugPrint('Purchase success: $purchasedCoins coins');
          } else {
            // if (error != null && error != 'Purchase canceled') {
            //   Get.snackbar(
            //     'Purchase interrupted',
            //     error,
            //     snackPosition: SnackPosition.TOP,
            //   );
            // }
            debugPrint(
                'Purchase finished without success: ${error ?? 'Unknown error'}');
          }
        },
      );
    } catch (e) {
      _clearPurchaseState();
      debugPrint('Purchase failed: $e');
    }
  }

  Future<void> restorePurchases() async {
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );

    await _purchaseService.restorePurchases();

    await Future.delayed(const Duration(seconds: 1));

    Get.back();

    // Get.snackbar(
    //   'Restore Complete',
    //   'Please check your coin balance',
    //   snackPosition: SnackPosition.TOP,
    // );
  }

  void _clearPurchaseState() {
    _purchaseResumeFallbackTimer?.cancel();
    purchasingProductId.value = null;
  }
}
