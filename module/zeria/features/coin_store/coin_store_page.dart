import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeria/zeria/constants/app_colors.dart';
import 'package:zeria/zeria/constants/app_text_styles.dart';
import 'package:zeria/zeria/services/coins_manager.dart';
import 'package:zeria/zeria/services/purchase_service.dart';
import 'package:zeria/zeria/widgets/zeria_ui.dart';
import 'contact_coins.dart';

class CoinStorePage extends StatefulWidget {
  const CoinStorePage({super.key});

  @override
  State<CoinStorePage> createState() => _CoinStorePageState();
}

class _CoinStorePageState extends State<CoinStorePage> {
  bool _isInitializing = true;
  bool _isPurchasing = false;
  bool _isIapAvailable = false;

  @override
  void initState() {
    super.initState();
    _initializePurchaseService();
  }

  Future<void> _initializePurchaseService() async {
    final available = await PurchaseService.instance.init();
    if (!mounted) return;
    setState(() {
      _isIapAvailable = available;
      _isInitializing = false;
    });
  }

  Future<void> _executePurchase(Contact575CoinProduct product) async {
    if (_isPurchasing) return;

    setState(() {
      _isPurchasing = true;
    });

    await PurchaseService.instance.executePurchase(
      productId: product.goodsId,
      coins: product.exchangeCoin,
      onResult: (result, coins, error) {
        if (!mounted) return;

        final shouldDismissLoading = result != PurchaseResult.pending;

        if (shouldDismissLoading) {
          setState(() {
            _isPurchasing = false;
          });
        }

        switch (result) {
          case PurchaseResult.success:
            Get.snackbar(
              'Purchase successful',
              'You received $coins coins.',
              snackPosition: SnackPosition.BOTTOM,
            );
            break;
          case PurchaseResult.failed:
            Get.snackbar(
              'Purchase failed',
              error ?? 'Failed to complete purchase.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.error,
              colorText: Colors.white,
            );
            break;
          case PurchaseResult.canceled:
            Get.snackbar(
              'Purchase canceled',
              'The purchase was canceled.',
              snackPosition: SnackPosition.BOTTOM,
            );
            break;
          case PurchaseResult.pending:
            Get.snackbar(
              'Purchase pending',
              'The purchase is being processed.',
              snackPosition: SnackPosition.BOTTOM,
            );
            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ZeriaScreen(
      child: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: ZeriaHeader(
                    title: 'Coin Store',
                    subtitle: 'TOP UP YOUR CREATIVE FLOW',
                    leading: ZeriaIconButton(
                      icon: Icons.arrow_back_rounded,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildBody(),
                ),
              ],
            ),
          ),
          if (_isPurchasing) _buildPurchaseLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (!_isIapAvailable) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 120),
        child: ZeriaEmptyState(
          title: 'In-app purchase unavailable',
          description: 'Purchases are not available on this device right now.',
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
      children: [
        ValueListenableBuilder<int>(
          valueListenable: CoinsManager.instance.coinsNotifier,
          builder: (context, coins, child) {
            return _buildBalanceCard(coins);
          },
        ),
        const SizedBox(height: 22),
        const ZeriaSectionTitle(
          title: 'Choose a pack',
          subtitle: 'SOFT PICK, FAST TOP-UP',
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: 246,
          ),
          itemCount: Privatised236CoinProductData.allProductsGrouped.length,
          itemBuilder: (context, index) {
            final product =
                Privatised236CoinProductData.allProductsGrouped[index];
            return _buildCoinPackageCard(product, _isPurchasing);
          },
        ),
      ],
    );
  }

  Widget _buildPurchaseLoadingOverlay() {
    return Positioned.fill(
      child: AbsorbPointer(
        child: ColoredBox(
          color: AppColors.bgOverlay,
          child: Center(
            child: ZeriaSurfaceCard(
              radius: 28,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
              color: Colors.white.withValues(alpha: 0.9),
              borderColor: Colors.white.withValues(alpha: 0.58),
              boxShadow: const [],
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.brandHotPink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Processing payment...',
                    style: AppTextStyles.bodyBold.copyWith(
                      color: AppColors.brandInk,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Please wait while we confirm your purchase.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
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

  Widget _buildBalanceCard(int coins) {
    return ZeriaSurfaceCard(
      radius: 34,
      gradient: AppColors.accentGradient,
      borderColor: Colors.white.withValues(alpha: 0.28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current balance',
                      style: AppTextStyles.bodyInverse.copyWith(
                        color: Colors.white.withValues(alpha: 0.94),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Keep a few coins ready for your next concept.',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: Text(
                  'Instant top-up',
                  style: AppTextStyles.small.copyWith(
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.monetization_on_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _formatCoinAmount(coins),
                    style:
                        AppTextStyles.h1Inverse.copyWith(color: Colors.white),
                  ),
                ),
                Text(
                  'coins',
                  style: AppTextStyles.bodyInverse.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinPackageCard(
    Contact575CoinProduct product,
    bool isPurchasing,
  ) {
    final accent = _packageAccent(product);
    final originalPrice = product.formattedOriginalPrice;
    final showOriginalPrice = product.isPromotion && originalPrice != null;
    final cardTint = (product.isPromotion ? AppColors.surfaceTint : AppColors.brandBlush)
        .withValues(alpha: 0.92);
    final cardGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: 0.92),
        cardTint,
      ],
    );

    return ZeriaSurfaceCard(
      onTap: isPurchasing ? null : () => _executePurchase(product),
      radius: 30,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      gradient: cardGradient,
      borderColor: Colors.white.withValues(alpha: 0.35),
      child: Stack(
        children: [
          Positioned(
            top: -28,
            right: -34,
            child: IgnorePointer(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accent.withValues(alpha: 0.18),
                      accent.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -48,
            left: -44,
            child: IgnorePointer(
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.22),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ZeriaPill(
                    label: _packageTag(product),
                    backgroundColor: Colors.white.withValues(alpha: 0.72),
                    foregroundColor: accent,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatCoinAmount(product.exchangeCoin),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.visible,
                          style: AppTextStyles.h1.copyWith(
                            fontSize: 30,
                            color: AppColors.brandInk,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'coins',
                          maxLines: 1,
                          softWrap: false,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.62),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.34),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            product.formattedPrice,
                            style: AppTextStyles.bodyBold.copyWith(
                              color: AppColors.brandInk,
                            ),
                          ),
                          if (showOriginalPrice) ...[
                            const SizedBox(height: 2),
                            Text(
                              originalPrice,
                              style: AppTextStyles.small.copyWith(
                                color: AppColors.textSecondary,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCoinAmount(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => ',',
        );
  }

  String _packageTag(Contact575CoinProduct product) {
    if (!product.isPromotion) return 'Regular';
    final discount = product.discountPercentage;
    if (discount <= 0) return 'Offer';
    return 'Offer -$discount%';
  }

  Color _packageAccent(Contact575CoinProduct product) {
    if (product.isPromotion) return AppColors.brandHotPink;
    return AppColors.brandOrange;
  }
}
