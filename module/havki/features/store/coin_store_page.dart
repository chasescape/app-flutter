import 'package:flutter/material.dart';
import 'package:havki/havki/app/services/coins_manager.dart';
import 'package:havki/havki/app/services/purchase_service.dart';
import 'package:havki/havki/app/theme/app_theme.dart';
import 'package:havki/havki/features/store/contact_coins.dart';

class CoinStorePage extends StatefulWidget {
  const CoinStorePage({super.key});

  @override
  State<CoinStorePage> createState() => _CoinStorePageState();
}

class _CoinStorePageState extends State<CoinStorePage> {
  final CoinsManager _coinsManager = CoinsManager();
  final PurchaseService _purchaseService = PurchaseService();
  bool _isInitializing = true;
  bool _isPurchasing = false;
  String? _purchasingProductId;

  final List<_CoinPackage> _coinPackages = List<_CoinPackage>.unmodifiable(
    Privatised236CoinProductData.allProductsGrouped
        .asMap()
        .entries
        .map((entry) => _CoinPackage.fromProduct(entry.value, entry.key))
        .toList(),
  );

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await _coinsManager.initialize();
      await _purchaseService.initialize(
        addCoinsCallback: (coins) async => _coinsManager.addCoins(coins),
      );
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AppBackground(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppCircleIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Expanded(
                      child: AppSectionTitle(
                        eyebrow: '',
                        title: 'Store',
                        subtitle: '',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _buildBalanceCard(),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: _isInitializing
                      ? const SizedBox.shrink()
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            const spacing = AppSpacing.md;
                            final cardWidth = (constraints.maxWidth - spacing) / 2;
                            return SingleChildScrollView(
                              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                              child: Wrap(
                                spacing: spacing,
                                runSpacing: spacing,
                                children: _coinPackages.map((package) {
                                  return SizedBox(
                                    width: cardWidth,
                                    child: AppGlassCard(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 52,
                                            height: 52,
                                            decoration: BoxDecoration(
                                              color: AppColors.secondary,
                                              borderRadius: BorderRadius.circular(18),
                                            ),
                                            child: const Icon(Icons.monetization_on, color: AppColors.textPrimary),
                                          ),
                                          const SizedBox(height: AppSpacing.lg),
                                          Text(
                                            '${package.coins} coins',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: AppFontSizes.body,
                                              fontWeight: AppFontWeights.semibold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: AppSpacing.xs),
                                          Text(
                                            package.displayPrice,
                                            style: const TextStyle(
                                              fontSize: AppFontSizes.caption,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          if (package.originalPrice != null) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              package.originalPrice!,
                                              style: const TextStyle(
                                                fontSize: AppFontSizes.small,
                                                color: AppColors.textDisabled,
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: AppSpacing.md),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: _isPurchasing ? null : () => _purchasePackage(package),
                                              child: Text(_isPurchasing && _purchasingProductId == package.productId ? 'Buying...' : 'Buy'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          if (_isInitializing || _isPurchasing) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: AbsorbPointer(
        child: Container(
          color: Colors.white.withValues(alpha: 0.32),
          child: Center(
            child: AppGlassCard(
              radius: AppBorderRadius.xl,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      _isPurchasing ? 'Processing purchase...' : 'Loading store...',
                      style: const TextStyle(
                        fontSize: AppFontSizes.body,
                        fontWeight: AppFontWeights.medium,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return ValueListenableBuilder<int>(
      valueListenable: _coinsManager.coinsNotifier,
      builder: (context, coins, child) {
        return AppGlassCard(
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(Icons.auto_awesome, color: AppColors.textPrimary, size: 34),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your balance',
                    style: TextStyle(
                      fontSize: AppFontSizes.caption,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '$coins coins',
                    style: const TextStyle(
                      fontSize: AppFontSizes.h2,
                      fontWeight: AppFontWeights.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _purchasePackage(_CoinPackage package) async {
    setState(() {
      _isPurchasing = true;
      _purchasingProductId = package.productId;
    });

    try {
      await _purchaseService.executePurchase(
        package.productId,
        package.coins,
        onResult: (orderId, coins) {
          if (!mounted) {
            return;
          }

          if (coins > 0) {
            _showSnack('Successfully purchased $coins coins.');
          }

          setState(() {
            _isPurchasing = false;
            _purchasingProductId = null;
          });
        },
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isPurchasing = false;
        _purchasingProductId = null;
      });
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CoinPackage {
  final String productId;
  final int coins;
  final String displayPrice;
  final String? originalPrice;

  const _CoinPackage({
    required this.productId,
    required this.coins,
    required this.displayPrice,
    this.originalPrice,
  });

  factory _CoinPackage.fromProduct(Contact575CoinProduct product, int index) {
    return _CoinPackage(
      productId: product.goodsId,
      coins: product.exchangeCoin,
      displayPrice: product.formattedPrice,
      originalPrice: product.formattedOriginalPrice,
    );
  }
}
