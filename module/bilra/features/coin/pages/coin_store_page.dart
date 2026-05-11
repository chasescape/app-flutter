import 'package:flutter/material.dart';
import 'package:bilra/bilra/routes/app_router.dart';
import 'package:bilra/bilra/services/coins_manager.dart';
import 'package:bilra/bilra/services/purchase_service.dart';
import 'package:bilra/bilra/theme/app_theme.dart';
import 'package:bilra/bilra/widgets/bilra_ui.dart';

import 'contact_coins.dart';

class CoinStorePage extends StatefulWidget {
  const CoinStorePage({
    super.key,
    this.returnTab,
  });

  final int? returnTab;

  @override
  State<CoinStorePage> createState() => _CoinStorePageState();
}

class _CoinStorePageState extends State<CoinStorePage> {
  final PurchaseService _purchaseService = PurchaseService();
  final CoinsManager _coinsManager = CoinsManager();
  bool _isPurchasing = false;

  List<Contact575CoinProduct> get _products =>
      Privatised236CoinProductData.allProductsGrouped;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _purchaseService.initialize();
    await _purchaseService.loadProducts(
      Privatised236CoinProductData.allProducts.map((e) => e.code).toList(),
    );
    await _coinsManager.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _purchaseService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BilraBackdrop(
        child: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.xl,
                ),
                children: [
                  BilraTopBar(
                    title: 'Coin store',
                    subtitle: 'Unlock more image analyses',
                    leading: BilraIconChipButton(
                      icon: Icons.arrow_back_rounded,
                      onTap:
                          _isPurchasing ? null : () => AppRoutes.pop(context),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ValueListenableBuilder<int>(
                    valueListenable: _coinsManager.coinsNotifier,
                    builder: (context, coins, child) {
                      return BilraGlassCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        radius: 32,
                        child: Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.primaryMain,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                color: AppColors.textInverse,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Available balance',
                                      style: AppTextStyles.small),
                                  const SizedBox(height: 2),
                                  Text('$coins coins', style: AppTextStyles.h2),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Use coins for instant AI makeup direction on new uploads.',
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final itemWidth =
                          (constraints.maxWidth - AppSpacing.md) / 2;
                      return Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.md,
                        children: _products.map((product) {
                          return SizedBox(
                            width: itemWidth,
                            child: _StoreCard(
                              product: product,
                              onTap: () => _executePurchase(product),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
            if (_isPurchasing)
              Positioned.fill(
                child: AbsorbPointer(
                  child: Container(
                    color: AppColors.primaryMain.withValues(alpha: 0.12),
                    child: Center(
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.96),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: AppShadows.md,
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.accentMain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _executePurchase(Contact575CoinProduct product) async {
    if (_isPurchasing) return;

    setState(() {
      _isPurchasing = true;
    });

    await _purchaseService.executePurchase(
      productId: product.code,
      coins: product.exchangeCoin,
      onResult: (coins, orderId) async {
        await _coinsManager.addCoins(coins);
        _stopPurchaseLoading();
        _showMessage(
          'Purchase successful',
          '+$coins coins added to your balance.',
          backgroundColor: AppColors.primaryMain,
        );
      },
      onError: (error) {
        _stopPurchaseLoading();
        // _showMessage(
        //   'Purchase failed',
        //   error,
        //   backgroundColor: AppColors.semanticError,
        // );
      },
      onCancel: () {
        _stopPurchaseLoading();
        // _showMessage(
        //   'Canceled',
        //   'Purchase was canceled.',
        //   backgroundColor: AppColors.primaryMain,
        // );
      },
    );
  }

  void _stopPurchaseLoading() {
    if (!mounted || !_isPurchasing) return;

    setState(() {
      _isPurchasing = false;
    });
  }

  void _showMessage(
    String title,
    String message, {
    required Color backgroundColor,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$title\n$message'),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({
    required this.product,
    required this.onTap,
  });

  final Contact575CoinProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: BilraGlassCard(
        color: product.isPromotion
            ? AppColors.surfaceTertiary.withValues(alpha: 0.94)
            : AppColors.backgroundOverlay,
        radius: 28,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (product.isPromotion)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: BilraPill(
                  label: '${product.discountPercentage}% OFF',
                  color: AppColors.primaryMain,
                  foregroundColor: AppColors.textInverse,
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: BilraPill(
                  label: 'Regular',
                  color: AppColors.surfaceSecondary,
                ),
              ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryMain,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.stars_rounded,
                color: AppColors.textInverse,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '${product.exchangeCoin}',
              textAlign: TextAlign.center,
              style: AppTextStyles.h3.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              product.formattedPrice,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                fontSize: 15,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (product.isPromotion && product.formattedOriginalPrice != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  product.formattedOriginalPrice!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.small.copyWith(
                    fontSize: 11,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
