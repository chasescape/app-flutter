import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/velise_ui.dart';
import '../../../services/coins/coins_manager.dart';
import '../contact_coins.dart';
import '../controllers/coin_store_controller.dart';

class CoinStorePage extends GetView<CoinStoreController> {
  const CoinStorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return VeliseScaffold(
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
              ),
            );
          }

          final isPurchasing = controller.purchasingProductId.value != null;

          return Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildHeroBanner(),
                    const SizedBox(height: 20),
                    _buildPackageGrid(),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
              if (isPurchasing) _buildPurchaseLoadingOverlay(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: VeliseActionButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: Get.back,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 96),
              child: Text(
                'top up',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.h3Style.copyWith(
                  fontWeight: AppTextStyles.semibold,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ValueListenableBuilder<int>(
              valueListenable: CoinsManager.instance,
              builder: (context, balance, child) {
                return VelisePill(
                  label: '$balance coins',
                  icon: Icons.auto_awesome_rounded,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const crossAxisCount = 2;
        const crossAxisSpacing = 14.0;
        const mainAxisSpacing = 16.0;
        final cardWidth =
            (constraints.maxWidth - crossAxisSpacing) / crossAxisCount;
        final cardHeight = _adaptiveCardHeight(cardWidth);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.coinPackages.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            mainAxisExtent: cardHeight,
          ),
          itemBuilder: (context, index) {
            return _buildPackageCard(controller.coinPackages[index]);
          },
        );
      },
    );
  }

  double _adaptiveCardHeight(double cardWidth) {
    return (cardWidth * 1.18).clamp(178.0, 208.0);
  }

  Widget _buildHeroBanner() {
    return VeliseSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const VeliseSectionHeading(
            title: 'Flexible coin packs',
            subtitle:
                'Use them for image analysis and publishing without cluttering the rest of the UI.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              const VelisePill(
                label: 'Fast checkout',
                icon: Icons.flash_on_rounded,
                compact: true,
              ),
              VelisePill(
                label: controller.isPurchaseAvailable.value
                    ? 'Store connected'
                    : 'Demo pricing',
                icon: controller.isPurchaseAvailable.value
                    ? Icons.verified_outlined
                    : Icons.info_outline_rounded,
                compact: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(Contact575CoinProduct package) {
    final price = package.formattedPrice;
    final originalPrice = package.formattedOriginalPrice;
    final bannerLabel = package.discountPercentage > 0
        ? 'Save ${package.discountPercentage}%'
        : 'Limited';
    final isPurchasingThis =
        controller.purchasingProductId.value == package.goodsId;
    final isAnyPurchaseInProgress =
        controller.purchasingProductId.value != null;

    return VeliseSurfaceCard(
      light: true,
      onTap: isAnyPurchaseInProgress
          ? null
          : () => controller.purchasePackage(package),
      padding: const EdgeInsets.all(14),
      child: Stack(
        children: [
          if (package.isPromotion)
            Positioned(
              top: 0,
              right: 0,
              child: VelisePill(
                label: bannerLabel,
                icon: Icons.local_fire_department_outlined,
                light: true,
                compact: true,
                textColor: AppColors.primaryDark,
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  gradient: AppColors.lavenderGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const Spacer(),
              Text(
                '${package.exchangeCoin}',
                style: AppTextStyles.surfaceTitleStyle.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 12),
              Text(
                price.toString(),
                style: AppTextStyles.surfaceTitleStyle.copyWith(fontSize: 22),
              ),
              if (originalPrice != null) ...[
                const SizedBox(height: 4),
                Text(
                  originalPrice,
                  style: AppTextStyles.surfaceMetaStyle.copyWith(
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
          if (isPurchasingThis)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.6,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryMain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPurchaseLoadingOverlay() {
    return Positioned.fill(
      child: AbsorbPointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.18),
          ),
          child: Center(
            child: VeliseSurfaceCard(
              light: true,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 34,
                    height: 34,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryMain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Processing purchase',
                    style: AppTextStyles.surfaceTitleStyle.copyWith(
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please wait while the payment sheet opens.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.surfaceBodyStyle.copyWith(
                      color: AppColors.textOnSurfaceSoft,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
