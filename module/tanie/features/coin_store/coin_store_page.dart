import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tanie/tanie/bloc/auth/auth_bloc.dart';
import 'package:tanie/tanie/bloc/auth/auth_event.dart';
import 'package:tanie/tanie/services/coins_manager.dart';
import 'package:tanie/tanie/services/purchase_service.dart';
import 'package:tanie/tanie/theme/app_colors.dart';
import 'package:tanie/tanie/theme/app_text_styles.dart';
import 'package:tanie/tanie/widgets/app_loading.dart';
import 'package:tanie/tanie/widgets/app_ui.dart';

import 'contact_coins.dart';

class CoinStorePage extends StatefulWidget {
  const CoinStorePage({super.key});

  @override
  State<CoinStorePage> createState() => _CoinStorePageState();
}

class _CoinStorePageState extends State<CoinStorePage> {
  bool _isInitialized = false;
  bool _isInitializing = false;
  bool _isPurchasing = false;

  static final Set<String> _productIds = Privatised236CoinProductData
      .allProducts
      .map((product) => product.goodsId)
      .toSet();

  @override
  void initState() {
    super.initState();
    _initializePurchaseService();
  }

  Future<void> _initializePurchaseService() async {
    if (_isInitializing || _isInitialized) return;
    setState(() => _isInitializing = true);

    try {
      final initialized = await purchaseService.initialize();
      if (!initialized) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('In-App Purchase is not available on this device'),
          ),
        );
        return;
      }

      await purchaseService.queryProducts(_productIds);
      purchaseService.setAddCoinsCallback((coins) async {
        await coinsManager.addCoins(coins);
        if (!mounted) return;
        context
            .read<AuthBloc>()
            .add(UpdateCoinsEvent(coinsManager.currentCoins));
      });

      setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint('Failed to initialize purchase service: $e');
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  void _executePurchase(Contact575CoinProduct product) {
    if (_isPurchasing) {
      return;
    }

    if (!_isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase service is not ready')),
      );
      return;
    }

    setState(() => _isPurchasing = true);

    purchaseService.executePurchase(
      productId: product.goodsId,
      coins: product.exchangeCoin,
      onResult: (success, message, coins) {
        if (mounted) {
          setState(() => _isPurchasing = false);
        }

        if (!mounted) {
          return;
        }

        if (!success) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message ?? (success ? 'Purchase successful!' : 'Purchase failed'),
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final packages = Privatised236CoinProductData.allProductsGrouped;

    return Scaffold(
      body: AppLoadingOverlay(
        isLoading: _isPurchasing,
        message: 'Processing payment...',
        child: AppBackdrop(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppIconCircle(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => context.pop(),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: AppSectionTitle(
                        title: 'Coin Store',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ValueListenableBuilder<int>(
                  valueListenable: coinsManager.coinsNotifier,
                  builder: (context, coins, child) {
                    return _CoinBalanceWalletCard(
                      coins: coins,
                      isLoading: _isInitializing,
                    );
                  },
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    const spacing = 14.0;
                    final cardWidth = (constraints.maxWidth - spacing) / 2;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        for (final product in packages)
                          SizedBox(
                            width: cardWidth,
                            child: _CoinPackageCard(
                              product: product,
                              displayPrice: product.formattedPrice,
                              onPurchase: () => _executePurchase(product),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CoinPackageCard extends StatelessWidget {
  final Contact575CoinProduct product;
  final String displayPrice;
  final VoidCallback onPurchase;

  const _CoinPackageCard({
    required this.product,
    required this.displayPrice,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      gradient: product.isPromotion
          ? AppColors.accentGradient
          : AppColors.softGradient,
      onTap: onPurchase,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (product.isPromotion)
            Align(
              alignment: Alignment.center,
              child: AppStickerChip(
                label: product.discountPercentage > 0
                    ? '${product.discountPercentage}% OFF'
                    : 'Sale',
              ),
            ),
          if (product.isPromotion) const SizedBox(height: 12),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.monetization_on_rounded,
              color: AppColors.secondaryMain,
              size: 22,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            '${product.exchangeCoin}',
            textAlign: TextAlign.center,
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: 4),
          Text(
            displayPrice,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (product.formattedOriginalPrice != null) ...[
            const SizedBox(height: 4),
            Text(
              product.formattedOriginalPrice!,
              textAlign: TextAlign.center,
              style: AppTextStyles.small.copyWith(
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CoinBalanceWalletCard extends StatelessWidget {
  final int coins;
  final bool isLoading;

  const _CoinBalanceWalletCard({
    required this.coins,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      gradient: AppColors.heroGradient,
      padding: const EdgeInsets.all(22),
      child: SizedBox(
        height: 152,
        child: Stack(
          children: [
            Positioned(
              top: -22,
              right: -18,
              child: Container(
                width: 118,
                height: 118,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.26),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -32,
              left: -12,
              child: Container(
                width: 132,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(36),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMain.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Coin Wallet',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textInverse,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentDark.withValues(alpha: 0.14),
                            blurRadius: 22,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: AppColors.secondaryMain,
                        size: 34,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Available balance',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '$coins coins',
                                  style: AppTextStyles.h1.copyWith(fontSize: 30),
                                ),
                              ),
                              if (isLoading) ...[
                                const SizedBox(width: 10),
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Use coins to unlock more reflections anytime.',
                            style: AppTextStyles.small.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
