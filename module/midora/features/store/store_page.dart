import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/midora_design.dart';
import '../../core/widgets/midora_open_background.dart';
import '../../services/coins_manager.dart';
import '../../services/purchase_service.dart';
import 'contact_coins.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  late final CoinStoreController _controller;
  bool _isPurchasing = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await CoinsManager.I.initialize();
    await PurchaseService.I.initialize();
    PurchaseService.I.setAddCoinsCallback((coins) {
      CoinsManager.I.addCoins(coins);
      AppController.I.addCoins(coins);
    });

    if (!Get.isRegistered<CoinStoreController>()) {
      Get.put(CoinStoreController());
    }
    _controller = CoinStoreController.I;

    if (mounted) {
      setState(() => _isInitializing = false);
    }
  }

  Future<void> _purchaseCoins(Contact575CoinProduct package) async {
    setState(() => _isPurchasing = true);

    try {
      await _controller.purchaseCoins(
        package,
        onSuccess: () {
          if (mounted) {
            Get.snackbar(
              'Success',
              'You received ${package.exchangeCoin} coins!',
              backgroundColor: AppColors.success,
              colorText: AppColors.primaryDark,
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },
        onError: (error) {
          final message = (error ?? '').trim();
          final isCanceled = message.toLowerCase().contains('canceled');
          if (mounted && !isCanceled && message.isNotEmpty) {
            // Get.snackbar(
            //   'Purchase Failed',
            //   message,
            //   backgroundColor: AppColors.error,
            //   colorText: AppColors.textInverse,
            //   snackPosition: SnackPosition.BOTTOM,
            // );
          }
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  _StorePackageColumns _buildPackageColumns(
    List<Contact575CoinProduct> packages,
  ) {
    final left = <Contact575CoinProduct>[];
    final right = <Contact575CoinProduct>[];
    var leftHeight = 0.0;
    var rightHeight = 0.0;

    for (final package in packages) {
      final estimatedHeight = package.isPromotion ? 252.0 : 216.0;

      if (leftHeight <= rightHeight) {
        left.add(package);
        leftHeight += estimatedHeight;
      } else {
        right.add(package);
        rightHeight += estimatedHeight;
      }
    }

    return _StorePackageColumns(left: left, right: right);
  }

  @override
  Widget build(BuildContext context) {
    final packageColumns =
        _isInitializing ? null : _buildPackageColumns(_controller.packages);

    return PopScope(
      canPop: !_isPurchasing,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            const MidoraOpenBackground(overlayOpacity: 0.24),
            SafeArea(
              child: _isInitializing
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryLight),
                    )
                  : CustomScrollView(
                      slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            AppSpacing.md,
                            AppSpacing.md,
                            AppSpacing.lg,
                          ),
                          child: Column(
                            children: [
                              MidoraTopBar(
                                title: 'Coin Store',
                                subtitle:
                                    'Unlock more analysis and save more dreamy moments.',
                                leading: MidoraCircleButton(
                                  icon: Icons.arrow_back_ios_new_rounded,
                                  onTap: () => Navigator.of(context).pop(),
                                ),
                                trailing: [
                                  MidoraGlassCard(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: AppSpacing.sm,
                                    ),
                                    borderRadius:
                                        AppBorderRadius.borderRadiusFull,
                                    blur: 10,
                                    shadow: const [],
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.monetization_on_rounded,
                                          color: AppColors.secondaryLight,
                                        ),
                                        const SizedBox(width: 6),
                                        CoinsBuilder(
                                          builder: (coins) => Text(
                                            '$coins',
                                            style:
                                                AppTextStyles.bodyBold.copyWith(
                                              color: AppColors.textInverse,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.lg),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          0,
                          AppSpacing.md,
                          AppSpacing.xxl,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    for (var i = 0;
                                        i < packageColumns!.left.length;
                                        i++) ...[
                                      _CoinPackageCard(
                                        package: packageColumns.left[i],
                                        isPurchasing: _isPurchasing,
                                        onTap: () => _purchaseCoins(
                                          packageColumns.left[i],
                                        ),
                                      ),
                                      if (i != packageColumns.left.length - 1)
                                        const SizedBox(height: AppSpacing.md),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  children: [
                                    for (var i = 0;
                                        i < packageColumns.right.length;
                                        i++) ...[
                                      _CoinPackageCard(
                                        package: packageColumns.right[i],
                                        isPurchasing: _isPurchasing,
                                        onTap: () => _purchaseCoins(
                                          packageColumns.right[i],
                                        ),
                                      ),
                                      if (i != packageColumns.right.length - 1)
                                        const SizedBox(height: AppSpacing.md),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
            ),
            _PurchaseLoadingOverlay(visible: _isPurchasing),
          ],
        ),
      ),
    );
  }
}

class _PurchaseLoadingOverlay extends StatelessWidget {
  const _PurchaseLoadingOverlay({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 160),
        child: !visible
            ? const SizedBox.shrink()
            : Stack(
                fit: StackFit.expand,
                children: [
                  ModalBarrier(
                    dismissible: false,
                    color: Colors.black.withValues(alpha: 0.45),
                  ),
                  Center(
                    child: MidoraGlassCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      borderRadius: AppBorderRadius.borderRadiusLg,
                      blur: 12,
                      shadow: const [],
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: AppColors.primaryLight,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Processing…',
                            style: AppTextStyles.bodyBold.copyWith(
                              color: AppColors.textInverse,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _CoinPackageCard extends StatelessWidget {
  const _CoinPackageCard({
    required this.package,
    required this.isPurchasing,
    required this.onTap,
  });

  final Contact575CoinProduct package;
  final bool isPurchasing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPromotion = package.isPromotion;

    return GestureDetector(
      onTap: isPurchasing ? null : onTap,
      child: MidoraGlassCard(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          12,
        ),
        borderColor:
            isPromotion ? AppColors.warning : AppColors.glassBorderStrong,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPromotion
              ? [
                  AppColors.warning.withValues(alpha: 0.16),
                  Colors.white.withValues(alpha: 0.14),
                  AppColors.primaryMain.withValues(alpha: 0.10),
                ]
              : [
                  Colors.white.withValues(alpha: 0.16),
                  AppColors.accentMain.withValues(alpha: 0.08),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPromotion) ...[
              MidoraPill(
                label: '${package.discountPercentage}% OFF',
                foregroundColor: AppColors.warning,
                backgroundColor: AppColors.warning.withValues(alpha: 0.22),
                borderColor: AppColors.warning.withValues(alpha: 0.35),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isPromotion
                      ? AppColors.primaryGradient
                      : AppColors.secondaryGradient,
                  boxShadow: AppColors.shadowMd,
                ),
                child: const Icon(
                  Icons.monetization_on_rounded,
                  color: AppColors.textInverse,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                '${package.exchangeCoin}',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.textInverse,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Center(
              child: Text(
                'coins',
                style:
                    AppTextStyles.caption.copyWith(color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (package.formattedOriginalPrice != null) ...[
              SizedBox(
                width: double.infinity,
                child: Text(
                  package.formattedOriginalPrice!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textMuted,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: isPurchasing ? null : onTap,
              borderRadius: AppBorderRadius.borderRadiusFull,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: const BoxDecoration(
                  gradient: AppColors.buttonGradient,
                  borderRadius: AppBorderRadius.borderRadiusFull,
                ),
                child: Text(
                  package.formattedPrice,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.buttonSmall.copyWith(
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StorePackageColumns {
  const _StorePackageColumns({
    required this.left,
    required this.right,
  });

  final List<Contact575CoinProduct> left;
  final List<Contact575CoinProduct> right;
}
