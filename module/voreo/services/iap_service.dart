import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/coin_product.dart';
import '../pages/coin_store/contact_coins.dart';
import 'purchase_service.dart';
import 'coins_manager.dart';

class IapService extends GetxService {
  static IapService get to => Get.find();

  final PurchaseService _purchaseService = PurchaseService.to;
  final CoinsManager _coinsManager = CoinsManager.to;

  // Fixed coin cost for image-to-image generation
  // Cost is determined at code generation time and remains constant at runtime
  static const int image2ImageCoinCost = 42;

  // Generate random coin cost for generation (50-100 as per MVP)
  // Deprecated: Use image2ImageCoinCost constant instead
  @Deprecated('Use image2ImageCoinCost constant instead')
  static int generateCoinCost() {
    final random = Random();
    return 50 + random.nextInt(51);
  }

  // Get available coin products
  static List<CoinProduct> getCoinProducts() {
    final String featuredPromotionCode =
        Privatised236CoinProductData.promotionProducts.isNotEmpty
            ? Privatised236CoinProductData.promotionProducts.last.code
            : '';

    return Privatised236CoinProductData.allProductsGrouped.map((product) {
      return CoinProduct(
        id: product.goodsId,
        code: product.code,
        name: product.name,
        coinAmount: product.exchangeCoin,
        price: product.price,
        currencyCode: 'USD',
        localizedPrice: product.formattedPrice,
        description: product.description,
        isPromotion: product.isPromotion,
        originalPriceText: product.formattedOriginalPrice,
        isBestValue: product.code == featuredPromotionCode,
        discountPercentage: product.originalPrice == null
            ? null
            : product.discountPercentage.toDouble(),
      );
    }).toList();
  }

  // Get product details loaded from IAP
  List<dynamic> getLoadedProducts() {
    return _purchaseService.products;
  }

  // Purchase coins using real IAP
  Future<bool> purchaseCoins(CoinProduct product,
      {bool showLoading = true}) async {
    final completer = Completer<bool>();
    Timer? timeout;

    void closeLoadingIfOpen() {
      if (!showLoading) return;
      // Only close the loading dialog. Do NOT pop the Coin store page route.
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    }

    // Show loading
    if (showLoading) {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );
    }

    // Safety net: if we never receive a purchase update (e.g. user cancels and
    // the platform doesn't emit a callback), don't leave the loading stuck.
    timeout = Timer(const Duration(seconds: 45), () {
      if (completer.isCompleted) return;
      closeLoadingIfOpen();
      completer.complete(false);
    });

    // Execute purchase through PurchaseService
    await _purchaseService.executePurchase(
      productId: product.id,
      coins: product.coinAmount,
      onResult: (orderId, coins, success, error) async {
        timeout?.cancel();

        // Close loading dialog
        closeLoadingIfOpen();

        if (success) {
          // Add coins through CoinsManager
          await _coinsManager.addCoins(coins);

          // Show success message
          Get.snackbar(
            'Purchase Successful',
            'You received $coins coins!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.primaryContainer,
            duration: const Duration(seconds: 3),
          );

          completer.complete(true);
        } else {
          // NOTE: As requested, suppress "payment canceled" and "payment error"
          // toasts/snackbars on the coin purchase page.
          // Get.snackbar(
          //   'Purchase Failed',
          //   error ?? 'Failed to complete purchase',
          //   snackPosition: SnackPosition.BOTTOM,
          //   backgroundColor: Get.theme.colorScheme.errorContainer,
          //   duration: const Duration(seconds: 3),
          // );

          completer.complete(false);
        }
      },
    );

    return completer.future;
  }

  // Restore previous purchases
  Future<void> restorePurchases() async {
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );

    await _purchaseService.restorePurchases();

    if (Get.isDialogOpen == true) {
      Get.back();
    }

    Get.snackbar(
      'Restore Completed',
      'Your purchases have been restored',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primaryContainer,
      duration: const Duration(seconds: 2),
    );
  }
}
