import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lenbo/lenbo/app/widgets/ripple_tap_effect.dart';
import 'package:lenbo/lenbo/core/services/coins_manager.dart';
import 'package:lenbo/lenbo/core/services/purchase_service.dart';
import 'package:lenbo/lenbo/core/theme/app_colors.dart';
import 'package:lenbo/lenbo/core/theme/app_spacing.dart';
import 'package:lenbo/lenbo/core/theme/app_theme.dart';
import 'package:lenbo/lenbo/features/coin_store/contact_coins.dart';

class CoinStorePage extends StatefulWidget {
  const CoinStorePage({super.key});

  @override
  State<CoinStorePage> createState() => _CoinStorePageState();
}

class _CoinStorePageState extends State<CoinStorePage> {
  bool _isPurchasing = false;
  String? _purchasingProductId;

  @override
  void initState() {
    super.initState();
    PurchaseService().initialize();
  }

  Future<void> _handlePurchase(String productId, int coins) async {
    if (_isPurchasing) return;
    setState(() {
      _isPurchasing = true;
      _purchasingProductId = productId;
    });

    await PurchaseService().executePurchase(
      productId: productId,
      coins: coins,
      onResult: (result, message) {
        if (mounted) {
          setState(() {
            _isPurchasing = false;
            _purchasingProductId = null;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: const Text(
          'Coin Store',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Balance card
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: AppTheme.pinkGradientDecoration,
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.monetization_on, color: AppColors.textInverse, size: 32),
                      SizedBox(width: 10),
                      Text(
                        'Current Balance',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textInverse,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<int>(
                    valueListenable: CoinsManager.coinsNotifier,
                    builder: (context, value, _) {
                      return Text(
                        '$value',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textInverse,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'coins',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textInverse.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ...Privatised236CoinProductData.allProductsGrouped.map(
              (product) => _CoinPackage(
                product: product,
                isLoading: _isPurchasing && _purchasingProductId == product.goodsId,
                onTap: () => _handlePurchase(product.goodsId, product.exchangeCoin),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _CoinPackage extends StatelessWidget {
  final Contact575CoinProduct product;
  final bool isLoading;
  final VoidCallback? onTap;

  const _CoinPackage({
    required this.product,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RippleTapEffect(
        onTap: isLoading ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.bgPrimary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: product.isPromotion ? AppColors.secondaryMain : AppColors.cardBorderLight,
              width: product.isPromotion ? 1.5 : 0.5,
            ),
            boxShadow: product.isPromotion
                ? [
                    BoxShadow(
                      color: AppColors.neonPinkGlow,
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : AppSpacing.shadowSm,
          ),
          child: Row(
            children: [
              // Coin icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.accentMain.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: const Icon(
                  Icons.monetization_on,
                  color: AppColors.secondaryMain,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${product.exchangeCoin} Coins',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (product.isPromotion) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryMain,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: const Text(
                              'SALE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textInverse,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Price & buy button
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (product.formattedOriginalPrice != null) ...[
                    Text(
                      product.formattedOriginalPrice!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    product.formattedPrice,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondaryMain,
                    ),
                  ),
                  if (product.discountPercentage > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Save ${product.discountPercentage}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: isLoading
                          ? AppColors.secondaryMain.withOpacity(0.5)
                          : AppColors.secondaryMain,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.textInverse),
                            ),
                          )
                        : const Text(
                            'Buy',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textInverse,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
