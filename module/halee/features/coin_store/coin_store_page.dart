import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/widgets/glass_card.dart';
import '../../app/widgets/bounce_in_animation.dart';
import '../../services/coins_manager.dart';
import '../../services/purchase_service.dart';
import 'contact_coins.dart';

class CoinStorePage extends StatefulWidget {
  const CoinStorePage({super.key});

  @override
  State<CoinStorePage> createState() => _CoinStorePageState();
}

class _CoinStorePageState extends State<CoinStorePage> {
  final PurchaseService _purchaseService = PurchaseService.instance;
  final CoinsManager _coinsManager = CoinsManager.instance;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _purchaseService.initialize();
  }

  @override
  void dispose() {
    _purchaseService.dispose();
    super.dispose();
  }

  Future<void> _onBuyPressed(Contact575CoinProduct product) async {
    if (_isPurchasing) return;
    setState(() => _isPurchasing = true);

    await _purchaseService.executePurchase(
      productId: product.goodsId,
      coins: product.exchangeCoin,
      onResult: (result) {
        if (!mounted) return;
        setState(() => _isPurchasing = false);

        switch (result.result) {
          case IAPResult.success:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Added ${result.coins} coins!'),
                backgroundColor: AppColors.success,
              ),
            );
            break;
          case IAPResult.canceled:
          case IAPResult.error:
            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final coinProducts = Privatised236CoinProductData.allProductsGrouped;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A0A2E), Color(0xFF2D1B69)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // AppBar
                GlassAppBar(title: 'Coin Store'),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        // Balance card
                        BounceInAnimation(
                          delay: const Duration(milliseconds: 100),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              gradient: AppColors.coinCardGradient,
                              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusXl),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.secondaryMain.withOpacity(0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'My Coins',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    ValueListenableBuilder<int>(
                                      valueListenable: _coinsManager.coinsNotifier,
                                      builder: (context, value, _) {
                                        return Text(
                                          _coinsManager.formatCoins(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 42,
                                            fontWeight: FontWeight.w900,
                                            fontFamily: 'Inter',
                                            letterSpacing: -1,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.3),
                                        blurRadius: 12,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.diamond, color: Colors.white, size: 28),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Product grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: AppSpacing.md,
                            mainAxisSpacing: AppSpacing.md,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: coinProducts.length,
                          itemBuilder: (context, index) {
                            final product = coinProducts[index];
                            return BounceInAnimation(
                              delay: Duration(milliseconds: 200 + index * 80),
                              duration: const Duration(milliseconds: 400),
                              child: _CoinProductCard(
                                product: product,
                                isPurchasing: _isPurchasing,
                                onBuy: () => _onBuyPressed(product),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoinProductCard extends StatelessWidget {
  final Contact575CoinProduct product;
  final bool isPurchasing;
  final VoidCallback onBuy;

  const _CoinProductCard({
    required this.product,
    required this.isPurchasing,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final isPromo = product.isPromotion && product.originalPrice != null;

    return Container(
      decoration: BoxDecoration(
        color: isPromo
            ? AppColors.secondaryMain.withOpacity(0.15)
            : const Color(0xFF3D2A5C),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusXl),
        border: isPromo
            ? Border.all(color: const Color(0xFFEB45ED), width: 1.5)
            : Border.all(color: AppColors.cardBorder, width: 0.5),
        boxShadow: isPromo
            ? [
                BoxShadow(
                  color: const Color(0xFFEB45ED).withOpacity(0.3),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // Discount badge
          if (isPromo)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department, size: 12, color: Colors.black),
                    const SizedBox(width: 2),
                    Text(
                      '-${product.discountPercentage}%',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.diamond_outlined, color: AppColors.accentMain, size: 32),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${product.exchangeCoin} Coins',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
                if (isPromo) ...[
                  const SizedBox(height: 6),
                  Text(
                    product.formattedOriginalPrice ?? '',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                      decoration: TextDecoration.lineThrough,
                      decorationThickness: 2,
                    ),
                  ),
                ],
                const Spacer(),
                // Buy button
                GestureDetector(
                  onTap: isPurchasing ? null : onBuy,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isPromo ? AppColors.buttonGradient : null,
                      color: isPromo ? null : Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
                    ),
                    child: Center(
                      child: isPurchasing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              product.formattedPrice,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
