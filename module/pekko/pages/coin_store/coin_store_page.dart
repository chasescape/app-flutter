import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../data/services/coins_manager.dart';
import 'contact_coins.dart';

/// Coin store page
class CoinStorePage extends StatelessWidget {
  const CoinStorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    final coinsManager = CoinsManager.to;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coin Store'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance card
            ValueListenableBuilder<int>(
              valueListenable: coinsManager.coinsNotifier,
              builder: (context, coins, child) {
                final balanceNumberStyle = AppTextStyles.h1.copyWith(
                  color: AppColors.textInverse,
                  fontWeight: FontWeight.w300,
                  height: 1,
                  fontFeatures: const [
                    FontFeature.liningFigures(),
                    FontFeature.tabularFigures(),
                  ],
                );
                final balanceUnitStyle = AppTextStyles.h1.copyWith(
                  color: AppColors.textInverse,
                  fontWeight: FontWeight.w300,
                  height: 1,
                );

                return Container(
                  width: double.infinity,
                  padding: AppSpacing.paddingLG,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.sunsetGradient,
                    ),
                    borderRadius: AppBorderRadius.allLarge,
                    boxShadow: AppShadows.md,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.account_balance_wallet,
                            color: AppColors.textInverse,
                            size: 32,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            'Current Balance',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textInverse.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Transform.translate(
                            offset: const Offset(0, -2),
                            child: Text(
                              '$coins',
                              style: balanceNumberStyle,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Coins',
                            style: balanceUnitStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Coin packages
            LayoutBuilder(
              builder: (context, constraints) {
                const crossAxisCount = 2;
                final itemWidth =
                    (constraints.maxWidth -
                        (AppSpacing.md * (crossAxisCount - 1))) /
                    crossAxisCount;

                return Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    for (final package in controller.coinPackages)
                      SizedBox(
                        width: itemWidth,
                        child: _CoinPackageCard(
                          package: package,
                          onTap: () => controller.purchaseCoins(package),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _CoinPackageCard extends StatelessWidget {
  final Contact575CoinProduct package;
  final VoidCallback onTap;

  const _CoinPackageCard({
    required this.package,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = package.isPromotion;
    final originalPrice = package.formattedOriginalPrice;

    return InkWell(
      onTap: onTap,
      borderRadius: AppBorderRadius.allMedium,
      child: Container(
        padding: AppSpacing.paddingMD,
        decoration: BoxDecoration(
          color: hasDiscount
              ? AppColors.primary.withOpacity(0.05)
              : AppColors.backgroundPrimary,
          borderRadius: AppBorderRadius.allMedium,
          border: Border.all(
            color:
                hasDiscount ? AppColors.primary : AppColors.backgroundTertiary,
            width: hasDiscount ? 2 : 1,
          ),
          boxShadow: AppShadows.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: hasDiscount
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: AppBorderRadius.allSmall,
                      ),
                      child: Text(
                        '${package.discountPercentage}% OFF',
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.textInverse,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : const SizedBox(height: 20),
            ),
            const SizedBox(height: AppSpacing.xs),
            Icon(
              Icons.monetization_on,
              size: 44,
              color: hasDiscount ? AppColors.primary : AppColors.textDisabled,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              package.formattedCoins,
              textAlign: TextAlign.center,
              style: AppTextStyles.h3.copyWith(
                color: hasDiscount ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (originalPrice != null) ...[
              Text(
                originalPrice,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
            ] else
              const SizedBox(height: 22),
            Text(
              package.formattedPrice,
              textAlign: TextAlign.center,
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 36),
                backgroundColor: hasDiscount ? AppColors.primary : null,
              ),
              child: const Text('Buy'),
            ),
          ],
        ),
      ),
    );
  }
}
