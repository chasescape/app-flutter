import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../services/coins_manager.dart';
import '../../services/purchase_service.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/soft_ui.dart';
import 'contact_coins.dart';

class CoinStoreController extends GetxController {
  final PurchaseService _purchaseService = PurchaseService.to;
  final CoinsManager _coinsManager = CoinsManager.to;

  final RxList<Contact575CoinProduct> packages = <Contact575CoinProduct>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isPurchasing = false.obs;

  int get currentCoins => _coinsManager.currentCoins;

  Contact575CoinProduct? get bestValuePackage {
    if (packages.isEmpty) {
      return null;
    }
    return packages.reduce(
      (current, next) =>
          current.coinsPerDollar >= next.coinsPerDollar ? current : next,
    );
  }

  @override
  void onInit() {
    super.onInit();
    _checkPurchaseAvailability();
    loadPackages();
  }

  Future<void> _checkPurchaseAvailability() async {
    if (!await _purchaseService.isAvailable()) {
      // Get.snackbar(
      //     'Notice', 'In-app purchases are not available on this device');
    }
  }

  void loadPackages() {
    isLoading.value = true;
    packages.assignAll(Privatised236CoinProductData.allProductsGrouped);
    isLoading.value = false;
  }

  void purchasePackage(Contact575CoinProduct package) {
    if (isPurchasing.value) return;
    isPurchasing.value = true;

    Get.dialog(
      const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryMain),
        ),
      ),
      barrierDismissible: false,
    );

    _purchaseService.executePurchase(
      package.goodsId,
      package.exchangeCoin,
      (int coins, bool success) async {
        isPurchasing.value = false;
        Get.back();

        if (success) {
          await _coinsManager.addCoins(coins);
          Get.snackbar('Success', 'You received $coins coins.');
        }
      },
    );
  }
}

class CoinStorePage extends GetView<CoinStoreController> {
  const CoinStorePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CoinStoreController());
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NeniaBackdrop(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                child: NeniaInlineHeader(
                  title: 'Coins',
                  subtitle: 'Top up without breaking the visual rhythm.',
                  onBack: Get.back,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildBalanceHero(),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const LoadingWidget(message: 'Loading packages');
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      const horizontalPadding = 20.0;
                      const spacing = 14.0;
                      final cardWidth = (constraints.maxWidth -
                              (horizontalPadding * 2) -
                              spacing) /
                          2;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          24,
                        ),
                        physics: const BouncingScrollPhysics(),
                        child: Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: [
                            for (final package in controller.packages)
                              SizedBox(
                                width: cardWidth,
                                child: _buildCoinCard(package),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceHero() {
    return NeniaSurface(
      radius: 32,
      gradient: AppColors.spotlightGradient,
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              gradient: AppColors.candyGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.monetization_on_rounded,
                color: AppColors.textInverse, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: CoinsManager.to.coinsNotifier,
              builder: (context, value, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Current balance', style: AppTextStyles.small),
                    const SizedBox(height: 4),
                    Text('$value coins', style: AppTextStyles.h2),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinCard(Contact575CoinProduct package) {
    final badge = package.isPromotion
        ? 'SALE'
        : controller.bestValuePackage?.code == package.code
            ? 'Best value'
            : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.purchasePackage(package),
        borderRadius: AppBorderRadius.allLg,
        child: NeniaSurface(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (badge != null) NeniaTagChip(label: badge),
              SizedBox(height: badge != null ? 10 : 2),
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  gradient: AppColors.spotlightGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.monetization_on_rounded,
                    color: AppColors.primaryMain),
              ),
              const SizedBox(height: 18),
              Text('${package.exchangeCoin}', style: AppTextStyles.h2),
              const SizedBox(height: 4),
              Text(package.formattedPrice,
                  style:
                      AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
              if (package.originalPrice != null) ...[
                const SizedBox(height: 4),
                Text(
                  package.formattedOriginalPrice!,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textDisabled,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
