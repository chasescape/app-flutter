import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pliro/pliro/core/managers/coins_manager.dart';
import 'package:pliro/pliro/core/theme/app_colors.dart';
import 'package:pliro/pliro/core/theme/app_text_styles.dart';
import 'package:pliro/pliro/core/theme/app_theme.dart';
import 'package:pliro/pliro/features/coins/presentation/controllers/coin_store_controller.dart';
import 'package:pliro/pliro/features/coins/presentation/pages/contact_coins.dart';
import 'package:pliro/pliro/shared/widgets/common_card.dart';

/// Coin store page - IAP for coin packages.
class CoinStorePage extends StatefulWidget {
  const CoinStorePage({super.key});

  @override
  State<CoinStorePage> createState() => _CoinStorePageState();
}

class _CoinStorePageState extends State<CoinStorePage> {
  final CoinStoreController _controller = Get.put(CoinStoreController());
  final CoinsManager _coinsManager = CoinsManager.instance;

  @override
  Widget build(BuildContext context) {
    return DreamScaffold(
      appBar: AppBar(title: const Text('Coin Store')),
      body: GetBuilder<CoinStoreController>(
        init: _controller,
        builder: (ctrl) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spacingMD,
                  AppTheme.spacingSM,
                  AppTheme.spacingMD,
                  AppTheme.spacingXXL,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(),
                    const SizedBox(height: AppTheme.spacingXL),
                    Text('Coin packages', style: AppTextStyles.h3),
                    const SizedBox(height: AppTheme.spacingMD),
                    ...ctrl.packages.map((package) {
                      return _buildPackageCard(package, ctrl);
                    }),
                  ],
                ),
              ),
              if (ctrl.isPurchasing) _buildLoadingOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard() {
    return ValueListenableBuilder<int>(
      valueListenable: _coinsManager.coinsNotifier,
      builder: (context, coinBalance, child) {
        return NeonCard(
          padding: const EdgeInsets.all(AppTheme.spacingLG),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
                child: const Icon(
                  Icons.toll_outlined,
                  color: AppColors.textInverse,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Available coins', style: AppTextStyles.caption),
                    Text('$coinBalance', style: AppTextStyles.h1),
                  ],
                ),
              ),
              DreamChip(label: 'Balance', color: AppColors.mint),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPackageCard(
    Contact575CoinProduct package,
    CoinStoreController ctrl,
  ) {
    final highlight = package.isPromotion;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMD),
      child: NeonCard(
        onTap: () => ctrl.purchasePackage(package),
        padding: const EdgeInsets.all(AppTheme.spacingLG),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: (highlight ? AppColors.blushMist : AppColors.surfaceMint)
                    .withOpacity(0.78),
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
              child: const Icon(
                Icons.toll_outlined,
                color: AppColors.roseDeep,
                size: 30,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${package.exchangeCoin} Coins',
                          style: AppTextStyles.bodySemiBold,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (package.isPromotion) ...[
                        const SizedBox(width: AppTheme.spacingSM),
                        DreamChip(
                          label: 'Offer',
                          selected: true,
                          color: AppColors.successGreen,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppTheme.spacingSM),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${package.price.toStringAsFixed(2)}',
                  style: AppTextStyles.bodySemiBold,
                ),
                if (package.originalPrice != null)
                  Text(
                    '\$${package.originalPrice!.toStringAsFixed(2)}',
                    style: AppTextStyles.small.copyWith(
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: AppColors.dreamCream.withOpacity(0.72),
      child: const Center(
        child: NeonCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(strokeWidth: 2.4),
              SizedBox(height: AppTheme.spacingMD),
              Text('Processing purchase...'),
            ],
          ),
        ),
      ),
    );
  }
}
