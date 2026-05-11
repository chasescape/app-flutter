import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/coin_store_controller.dart';
import '../../core/constants/app_border_radius.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/app_shell.dart';
import 'contact_coins.dart';

class CoinStorePage extends GetView<CoinStoreController> {
  const CoinStorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            AppBackdrop(
              child: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.xxl,
                  ),
                  children: [
                    const AppTopBar(
                      title: 'Coin store',
                      subtitle: 'UNLOCK MORE REVIEWS',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildBalanceCard(),
                    const SizedBox(height: AppSpacing.xl),
                    const AppSectionTitle(
                      title: 'Choose a package',
                      subtitle: 'Tap any card to start the in-app purchase flow.',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cardWidth =
                            (constraints.maxWidth - AppSpacing.md) / 2;

                        return Wrap(
                          spacing: AppSpacing.md,
                          runSpacing: AppSpacing.md,
                          children: controller.packages
                              .map(
                                (package) => SizedBox(
                                  width: cardWidth,
                                  child: _buildPackageCard(package),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (controller.isPurchasing.value) _buildPurchaseOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return ValueListenableBuilder<int>(
      valueListenable: controller.coinsNotifier,
      builder: (context, coins, _) => AppSurface(
        child: Column(
          children: [
            const AppTag(label: 'YOUR BALANCE'),
            const SizedBox(height: AppSpacing.md),
            Text(
              '$coins coins',
              style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text('available right now', style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard(Contact575CoinProduct package) {
    return Obx(
      () {
        final originalPriceLabel = package.formattedOriginalPrice;
        final showPromotion =
            package.isPromotion && package.discountPercentage > 0;

        return AppSurface(
          onTap: controller.isPurchasing.value
              ? null
              : () => controller.purchasePackage(package),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showPromotion) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: AppTag(label: '-${package.discountPercentage}%'),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  gradient: AppGradients.accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.textOnDark,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${package.exchangeCoin}',
                        style: AppTextStyles.h3.copyWith(
                          fontSize: 24,
                          height: 1,
                        ),
                      ),
                      const TextSpan(text: '  '),
                      const TextSpan(
                        text: 'coins',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.formattedPrice,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800),
                  ),
                  if (originalPriceLabel != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      originalPriceLabel,
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.textDisabled,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: AppColors.textDisabled,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPurchaseOverlay() {
    return Positioned.fill(
      child: AbsorbPointer(
        child: Container(
          color: Colors.black.withValues(alpha: 0.22),
          child: Center(
            child: AppSurface(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.lg,
              ),
              borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.6,
                      valueColor: AlwaysStoppedAnimation(
                        AppColors.secondaryMain,
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Processing purchase...',
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
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
