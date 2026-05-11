import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/coin_product.dart';
import '../../routes/app_routes.dart';
import '../../services/coins_manager.dart';
import '../../services/iap_service.dart';
import '../../services/purchase_service.dart';
import '../../theme/app_border.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../ui/dreamy_ui.dart';

class CoinStorePage extends StatefulWidget {
  const CoinStorePage({super.key});

  @override
  State<CoinStorePage> createState() => _CoinStorePageState();
}

class _CoinStorePageState extends State<CoinStorePage> {
  final PurchaseService _purchaseService = PurchaseService.to;
  final CoinsManager _coinsManager = CoinsManager.to;
  final IapService _iapService = IapService.to;
  bool _isPurchasing = false;
  bool _isLoadingProducts = false;

  @override
  void initState() {
    super.initState();
    _purchaseService.setResultHandler((orderId, coins, success, error) {});
    _ensureProductsLoaded();
  }

  Future<void> _ensureProductsLoaded() async {
    if (_isLoadingProducts) return;
    if (_purchaseService.products.isNotEmpty) return;

    setState(() => _isLoadingProducts = true);
    try {
      await _purchaseService.loadProducts();
    } finally {
      if (mounted) {
        setState(() => _isLoadingProducts = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<CoinProduct> products = IapService.getCoinProducts();

    return DreamyPageScaffold(
      showFloor: false,
      child: Stack(
        children: [
          CustomScrollView(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const DreamyCenteredHeader(
                        title: 'Coin store',
                        onBack: AppRoutes.goBack,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ValueListenableBuilder(
                        valueListenable: _coinsManager.coinBalanceNotifier,
                        builder: (context, balance, child) {
                          return _CoinBalanceHero(balance: balance);
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const DreamySectionLabel(
                        title: 'Choose a pack',
                        subtitle:
                            'All purchasable packs are listed below with their ID codes.',
                      ),
                      if (_purchaseService.products.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.md),
                          child: Text(
                            'Loading store products...',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textGrey,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    120,
                  ),
                  child: _CompactPackGrid(
                    products: products,
                    onBuy: _handleBuy,
                  ),
                ),
              ),
            ],
          ),
          if (_isPurchasing || _isLoadingProducts)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: AppColors.white.withValues(alpha: 0.55),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleBuy(CoinProduct product) async {
    if (_isPurchasing) return;

    // First launch can arrive before IAP product details have finished loading.
    // Ensure products are loaded so the purchase sheet can open reliably.
    if (_purchaseService.getProductDetails(product.id) == null) {
      await _ensureProductsLoaded();
    }
    if (_purchaseService.getProductDetails(product.id) == null) {
      // Get.snackbar(
      //   'Store not ready',
      //   'Please try again in a moment.',
      //   snackPosition: SnackPosition.BOTTOM,
      //   duration: const Duration(seconds: 2),
      // );
      return;
    }

    setState(() => _isPurchasing = true);
    try {
      await _iapService.purchaseCoins(product, showLoading: false);
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }
}

class _CoinBalanceHero extends StatelessWidget {
  const _CoinBalanceHero({
    required this.balance,
  });

  final int balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFE0EF),
            Color(0xFFFFF1D0),
            Color(0xFFE8F7FF),
          ],
        ),
        borderRadius: BorderRadius.circular(AppBorder.radiusXLarge),
        border: Border.all(color: AppColors.cardStroke),
        boxShadow: AppShadows.shadowLG,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppBorder.radiusXLarge),
        child: Stack(
          children: [
            Positioned(
              right: -18,
              top: -20,
              child: _GlowBubble(
                size: 96,
                color: AppColors.white.withValues(alpha: 0.28),
              ),
            ),
            Positioned(
              left: -14,
              bottom: -24,
              child: _GlowBubble(
                size: 86,
                color: AppColors.primaryLight.withValues(alpha: 0.18),
              ),
            ),
            Padding(
              padding: AppSpacing.allLG,
              child: Row(
                children: [
                  Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.84),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.75),
                      ),
                    ),
                    child: const Icon(
                      Icons.monetization_on_rounded,
                      color: AppColors.primaryMain,
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.72),
                            borderRadius: AppBorder.borderRadiusFull,
                          ),
                          child: Text(
                            'Available now',
                            style: AppTypography.small.copyWith(
                              color: AppColors.textGrey,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '$balance coins',
                          style: AppTypography.h1.copyWith(
                            color: AppColors.textDark,
                            fontSize: 30,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Use coins to create more AI hairstyle previews.',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactPackGrid extends StatelessWidget {
  const _CompactPackGrid({
    required this.products,
    required this.onBuy,
  });

  final List<CoinProduct> products;
  final ValueChanged<CoinProduct> onBuy;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double gap = AppSpacing.md;
        final bool useTwoColumns = constraints.maxWidth > 340;
        final double itemWidth = useTwoColumns
            ? (constraints.maxWidth - gap) / 2
            : constraints.maxWidth;

        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md),
          child: Wrap(
            spacing: gap,
            runSpacing: gap,
            children: products.map((product) {
              return SizedBox(
                width: itemWidth,
                child: _CompactPackCard(
                  product: product,
                  onBuy: () => onBuy(product),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _CompactPackCard extends StatelessWidget {
  const _CompactPackCard({
    required this.product,
    required this.onBuy,
  });

  final CoinProduct product;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final _PackPalette palette = _PackPalette.fromProduct(product);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onBuy,
        borderRadius: BorderRadius.circular(AppBorder.radiusXLarge),
        child: Ink(
          decoration: BoxDecoration(
            gradient: palette.cardGradient,
            borderRadius: BorderRadius.circular(AppBorder.radiusXLarge),
            border: Border.all(color: AppColors.cardStroke),
            boxShadow: AppShadows.shadowMD,
          ),
          child: Padding(
            padding: AppSpacing.allMD,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: palette.accent,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    if (product.isPromotion)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.7),
                          borderRadius: AppBorder.borderRadiusFull,
                        ),
                        child: Text(
                          product.discountPercentage != null
                              ? '${product.discountPercentage!.toStringAsFixed(0)}% off'
                              : 'Promo',
                          style: AppTypography.small.copyWith(
                            color: AppColors.accentMain,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  '${product.coinAmount} coins',
                  style: AppTypography.h3.copyWith(color: AppColors.textDark),
                ),
                if (product.originalPriceText != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    product.originalPriceText!,
                    style: AppTypography.small.copyWith(
                      color: AppColors.textGrey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                Text(
                  product.displayPrice,
                  style: AppTypography.h3.copyWith(
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PackPalette {
  const _PackPalette({
    required this.cardGradient,
    required this.accent,
  });

  final LinearGradient cardGradient;
  final Color accent;

  factory _PackPalette.fromProduct(CoinProduct product) {
    if (product.coinAmount >= 1000) {
      return const _PackPalette(
        cardGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE7F5FF),
            Color(0xFFFFE8F3),
            Color(0xFFFFF2D4),
          ],
        ),
        accent: Color(0xFF6EA8F5),
      );
    }

    if (product.coinAmount >= 500) {
      return const _PackPalette(
        cardGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFE6F2),
            Color(0xFFFFF1CF),
            Color(0xFFF4EEFF),
          ],
        ),
        accent: AppColors.primaryMain,
      );
    }

    return const _PackPalette(
      cardGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFF0D7),
          Color(0xFFFFE7F2),
          Color(0xFFF6F3FF),
        ],
      ),
      accent: AppColors.secondaryDark,
    );
  }
}

class _GlowBubble extends StatelessWidget {
  const _GlowBubble({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
