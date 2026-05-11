import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../core/providers/app_providers.dart';
import '../../core/services/purchase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import 'contact_coins.dart';

class CoinStorePage extends ConsumerStatefulWidget {
  const CoinStorePage({super.key});

  @override
  ConsumerState<CoinStorePage> createState() => _CoinStorePageState();
}

class _CoinStorePageState extends ConsumerState<CoinStorePage> {
  bool _isInitializing = true;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _initializePurchaseService();
  }

  Future<void> _initializePurchaseService() async {
    await PurchaseService.instance.initialize(
      onCoinsAdded: (coins) async {
        await ref.read(userDataProvider.notifier).addCoins(coins);
      },
      onError: _showErrorDialog,
      onCanceled: _showCanceledDialog,
    );
    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userDataProvider);
    final packages = Privatised236CoinProductData.allProductsGrouped;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          AppBackground(
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      children: [
                        _ActionCircleButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: Get.back,
                        ),
                        const Spacer(),
                        const Text('Coins', style: AppTextStyles.h3),
                        const Spacer(),
                        const SizedBox(width: 44),
                      ],
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final availableGridWidth = constraints.maxWidth - 40;
                        final cardWidth = (availableGridWidth - 16) / 2;
                        final cardHeight = (cardWidth * 1.24).clamp(
                          176.0,
                          214.0,
                        );

                        return _isInitializing
                            ? const Center(child: CircularProgressIndicator())
                            : CustomScrollView(
                                physics: const BouncingScrollPhysics(),
                                slivers: [
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        20,
                                        20,
                                        20,
                                        0,
                                      ),
                                      child: AppCard(
                                        margin: EdgeInsets.zero,
                                        padding: const EdgeInsets.all(22),
                                        child: Column(
                                          children: [
                                            Text(
                                              '${userData.coins}',
                                              style: AppTextStyles.h1.copyWith(
                                                fontSize: 48,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: AppSpacing.xs,
                                            ),
                                            const Text(
                                              'Current balance',
                                              style: AppTextStyles.caption,
                                            ),
                                            const SizedBox(
                                              height: AppSpacing.lg,
                                            ),
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(18),
                                              decoration: BoxDecoration(
                                                gradient: AppGradients.hero,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  AppBorderRadius.large,
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    'Unlock more product looks and ingredient summaries.',
                                                    style: AppTextStyles.caption
                                                        .copyWith(
                                                      color:
                                                          AppColors.textPrimary,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SliverToBoxAdapter(
                                    child: SizedBox(height: AppSpacing.xl),
                                  ),
                                  SliverPadding(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      0,
                                      20,
                                      24,
                                    ),
                                    sliver: SliverGrid(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                          return _buildPackageCard(
                                            packages[index],
                                          );
                                        },
                                        childCount: packages.length,
                                      ),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                        mainAxisExtent: cardHeight,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isPurchasing)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.18),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(Contact575CoinProduct package) {
    final isDiscounted = package.isPromotion;
    final isBestValue = package.coinsPerDollar >= 500;

    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      onTap: () => _purchasePackage(package),
      color: isDiscounted
          ? AppColors.surface.withValues(alpha: 0.94)
          : AppColors.surface.withValues(alpha: 0.88),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient:
                      isDiscounted ? AppGradients.accent : AppGradients.hero,
                  borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                ),
                child: Icon(
                  Icons.diamond_rounded,
                  color: isDiscounted ? Colors.white : AppColors.textPrimary,
                  size: 28,
                ),
              ),
              const Spacer(),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${package.exchangeCoin}',
                      style: AppTextStyles.h2.copyWith(
                        fontSize: 30,
                      ),
                    ),
                    TextSpan(
                      text: ' coins',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                package.formattedPrice,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (package.isPromotion && package.formattedOriginalPrice != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    package.formattedOriginalPrice!,
                    style: AppTextStyles.small.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          if (isBestValue)
            const Positioned(
              top: 0,
              right: 0,
              child: AppStatPill(
                icon: Icons.local_fire_department_rounded,
                label: 'Popular',
                dark: true,
              ),
            ),
          if (package.isPromotion)
            Positioned(
              top: isBestValue ? 40 : 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppBorderRadius.full),
                ),
                child: Text(
                  '${package.discountPercentage}% OFF',
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.accentDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _purchasePackage(Contact575CoinProduct package) {
    if (_isPurchasing || _isInitializing) {
      return;
    }
    _executePurchase(package);
  }

  Future<void> _executePurchase(Contact575CoinProduct package) async {
    setState(() {
      _isPurchasing = true;
    });

    try {
      await PurchaseService.instance.executePurchase(
        package.code,
        package.exchangeCoin,
        onResult: (orderId) {
          _finishPurchaseFlow(
            onCompleted: () => _showSuccessDialog(package.exchangeCoin),
          );
        },
      );
    } catch (_) {
      _finishPurchaseFlow();
    }
  }

  void _showSuccessDialog(int coins) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: AppCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(24),
          borderRadius: BorderRadius.circular(AppBorderRadius.xlarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  gradient: AppGradients.hero,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.textPrimary,
                  size: 34,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'You got $coins coins!',
                style: AppTextStyles.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Your balance has been updated successfully.',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: 'OK',
                  onPressed: Get.back,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String error) => _finishPurchaseFlow();

  void _showCanceledDialog() => _finishPurchaseFlow();

  void _finishPurchaseFlow({VoidCallback? onCompleted}) {
    if (mounted) {
      setState(() {
        _isPurchasing = false;
      });
    }
    onCompleted?.call();
  }
}

class _ActionCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.82),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
