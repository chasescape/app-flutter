import 'package:flutter/material.dart';
import '../../app/theme/theme.dart';
import '../../widgets/animations/bounce_in_animation.dart';
import '../../widgets/visuals/sunny_visuals.dart';
import '../../services/purchase_service.dart';
import '../../services/coins_manager.dart';

/// Coin Store Page
/// IAP integration for purchasing coin packs
class CoinStorePage extends StatefulWidget {
  const CoinStorePage({super.key});

  @override
  State<CoinStorePage> createState() => _CoinStorePageState();
}

class _CoinStorePageState extends State<CoinStorePage> {
  bool _isPurchasing = false;
  bool _isServiceReady = false;

  // Coin products
  final List<CoinProduct> _products = const [
    CoinProduct(
      id: 'cheria00',
      name: 'Cheria Point0',
      description: '100 coins - Normal Edition',
      coins: 100,
      price: 0.99,
      isPromotion: false,
      parentProductCode: '100009902',
    ),
    CoinProduct(
      id: 'cheria01',
      name: 'Cheria Point1',
      description: '600 coins - Normal Edition',
      coins: 600,
      price: 5.99,
      isPromotion: false,
      parentProductCode: '100059902',
    ),
    CoinProduct(
      id: 'cheria02',
      name: 'Cheria Point2',
      description: '999 coins - Normal Edition',
      coins: 999,
      price: 9.99,
      isPromotion: false,
      parentProductCode: '100099903',
    ),
    CoinProduct(
      id: 'cheria03',
      name: 'Cheria Point3',
      description: '2400 coins - Normal Edition',
      coins: 2400,
      price: 19.99,
      isPromotion: false,
      parentProductCode: '100199905',
    ),
    CoinProduct(
      id: 'cheria04',
      name: 'Cheria Point4',
      description: '7000 coins - Normal Edition',
      coins: 7000,
      price: 49.99,
      isPromotion: false,
      parentProductCode: '100499907',
    ),
    CoinProduct(
      id: 'cheria05',
      name: 'Cheria Point5',
      description: '15000 coins - Normal Edition',
      coins: 15000,
      price: 99.99,
      isPromotion: false,
      parentProductCode: '100999910',
    ),
    CoinProduct(
      id: 'cheria06',
      name: 'Cheria Point6',
      description: 'Limited Promotion: 298 coins',
      coins: 298,
      price: 0.99,
      originalPrice: 2.99,
      isPromotion: true,
      parentProductCode: '100009906',
    ),
    CoinProduct(
      id: 'cheria07',
      name: 'Cheria Point7',
      description: 'Limited Promotion: 498 coins',
      coins: 498,
      price: 1.99,
      originalPrice: 4.99,
      isPromotion: true,
      parentProductCode: '100019900',
    ),
    CoinProduct(
      id: 'cheria08',
      name: 'Cheria Point8',
      description: 'Limited Promotion: 1199 coins',
      coins: 1199,
      price: 4.99,
      originalPrice: 9.99,
      isPromotion: true,
      parentProductCode: '100049904',
    ),
    CoinProduct(
      id: 'cheria09',
      name: 'Cheria Point9',
      description: 'Limited Promotion: 2500 coins',
      coins: 2500,
      price: 11.99,
      originalPrice: 19.99,
      isPromotion: true,
      parentProductCode: '100119905',
    ),
    CoinProduct(
      id: 'cheria10',
      name: 'Cheria Point10',
      description: 'Limited Promotion: 10000 coins',
      coins: 10000,
      price: 49.99,
      originalPrice: 69.99,
      isPromotion: true,
      parentProductCode: '100499904',
    ),
    CoinProduct(
      id: 'cheria11',
      name: 'Cheria Point11',
      description: 'Limited Promotion: 17999 coins',
      coins: 17999,
      price: 99.99,
      originalPrice: 119.99,
      isPromotion: true,
      parentProductCode: '100999906',
    ),
    CoinProduct(
      id: 'cheria12',
      name: 'Cheria Point12',
      description: 'Normal Edition',
      coins: 500,
      price: 4.99,
      isPromotion: false,
      parentProductCode: '270012',
    ),
    CoinProduct(
      id: 'cheria13',
      name: 'Cheria Point13',
      description: 'Normal Edition',
      coins: 700,
      price: 6.99,
      isPromotion: false,
      parentProductCode: '270013',
    ),
  ];

  final CoinsManager _coinsManager = CoinsManager.instance;
  final PurchaseService _purchaseService = PurchaseService.instance;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  @override
  void dispose() {
    // Don't dispose services as they are singletons
    super.dispose();
  }

  /// Initialize purchase service and coins manager
  Future<void> _initializeServices() async {
    // Initialize coins manager
    await _coinsManager.initialize();

    // Initialize purchase service with coins callback
    final success = await _purchaseService.initialize(
      onAddCoins: (coins) {
        _coinsManager.addCoins(coins);
      },
    );

    if (mounted) {
      setState(() {
        _isServiceReady = success;
      });
    }

    if (!success) {
      // SmartDialog.showToast('In-app purchase not available on this device');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coin Store'),
      ),
      body: SunnyPage(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  // Balance Card with AnimatedBuilder
                  AnimatedBuilder(
                    animation: _coinsManager,
                    builder: (context, child) {
                      return _BalanceCard(balance: _coinsManager.coins);
                    },
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Products Grid
                  _ProductsGrid(
                    products: _products,
                    isServiceReady: _isServiceReady,
                    onPurchase: _handlePurchase,
                  ),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),

            // Loading Overlay
            if (_isPurchasing)
              Container(
                color: const Color(AppColors.backgroundOverlay),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(AppColors.primaryMain),
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        'Processing purchase...',
                        style: TextStyle(
                          color: Color(AppColors.textPrimary),
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

  Future<void> _handlePurchase(CoinProduct product) async {
    if (!_isServiceReady) {
      // SmartDialog.showToast('Purchase service not ready');
      return;
    }

    setState(() {
      _isPurchasing = true;
    });

    try {
      await _purchaseService.executePurchase(
        product.id,
        product.coins,
        onResult: (success, coins, error) {
          if (mounted) {
            setState(() {
              _isPurchasing = false;
            });

            if (!success) {
              // SmartDialog.showToast(error ?? 'Purchase failed');
            }
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
        // SmartDialog.showToast('Purchase failed: $e');
      }
    }
  }
}

class _BalanceCard extends StatelessWidget {
  final int balance;

  const _BalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    return BounceInAnimation(
      delay: const Duration(milliseconds: 100),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(AppColors.backgroundSecondary),
              Color(AppColors.secondaryMain),
              Color(AppColors.primaryMain)
            ],
          ),
          borderRadius: AppBorderRadius.allLG,
          border: Border.all(
            color: const Color(AppColors.cardElevated),
            width: 3,
          ),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          children: [
            const Icon(
              Icons.monetization_on,
              size: 48,
              color: Color(AppColors.textInverse),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your Balance',
              style: AppTypography.getCaptionTextStyle(
                const Color(AppColors.textInverse),
              ).copyWith(
                color: const Color(AppColors.textInverse).withOpacity(0.82),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '$balance',
              style: AppTypography.getH1TextStyle(
                const Color(AppColors.textInverse),
              ).copyWith(
                fontWeight: AppTypography.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'coins',
              style: AppTypography.getCaptionTextStyle(
                const Color(AppColors.textInverse),
              ).copyWith(
                color: const Color(AppColors.textInverse).withOpacity(0.82),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductsGrid extends StatelessWidget {
  final List<CoinProduct> products;
  final bool isServiceReady;
  final ValueChanged<CoinProduct> onPurchase;

  const _ProductsGrid({
    required this.products,
    required this.isServiceReady,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fallbackWidth =
            MediaQuery.sizeOf(context).width - (AppSpacing.md * 2);
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : fallbackWidth;
        final columnCount = availableWidth >= 640
            ? 3
            : availableWidth >= 300
                ? 2
                : 1;
        final itemWidth =
            (availableWidth - AppSpacing.md * (columnCount - 1)) / columnCount;

        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: List.generate(products.length, (index) {
            final product = products[index];

            return SizedBox(
              width: itemWidth,
              child: _CoinProductCard(
                product: product,
                index: index,
                isServiceReady: isServiceReady,
                onPurchase: () => onPurchase(product),
              ),
            );
          }),
        );
      },
    );
  }
}

class _CoinProductCard extends StatelessWidget {
  final CoinProduct product;
  final int index;
  final bool isServiceReady;
  final VoidCallback onPurchase;

  const _CoinProductCard({
    required this.product,
    required this.index,
    required this.isServiceReady,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return BounceInAnimation(
      delay: Duration(milliseconds: 100 + (index * 50)),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(AppColors.cardElevated),
          borderRadius: AppBorderRadius.allMD,
          boxShadow: AppShadows.card,
          border: Border.all(
            color: product.isPromotion
                ? const Color(AppColors.primaryMain)
                : const Color(AppColors.cardElevated),
            width: product.isPromotion ? 2 : 3,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Popular Badge
            if (product.isPromotion)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: const BoxDecoration(
                  color: Color(AppColors.primaryMain),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppBorderRadius.sm),
                    topRight: Radius.circular(AppBorderRadius.sm),
                  ),
                ),
                child: Text(
                  'LIMITED',
                  style: AppTypography.getSmallTextStyle(
                    const Color(AppColors.textInverse),
                  ).copyWith(
                    fontWeight: AppTypography.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Coin Icon
                  Icon(
                    Icons.monetization_on,
                    size: 42,
                    color: product.isPromotion
                        ? const Color(AppColors.primaryMain)
                        : const Color(AppColors.accentMain),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Coin Amount
                  Text(
                    product.coins.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.getH2TextStyle(
                      const Color(AppColors.textPrimary),
                    ).copyWith(
                      fontWeight: AppTypography.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // Label
                  Text(
                    'coins',
                    style: AppTypography.getSmallTextStyle(
                      const Color(AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),

            // Price Section
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: const Color(AppColors.backgroundTertiary),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppBorderRadius.md),
                  bottomRight: Radius.circular(AppBorderRadius.md),
                ),
              ),
              child: Column(
                children: [
                  // Original Price with discount
                  if (product.hasDiscount) ...[
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        Text(
                          product.formattedOriginalPrice!,
                          style: AppTypography.getSmallTextStyle(
                            const Color(AppColors.textDisabled),
                          ).copyWith(
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(AppColors.error),
                            borderRadius: AppBorderRadius.allSM,
                          ),
                          child: Text(
                            '-${product.discount}%',
                            style: AppTypography.getSmallTextStyle(
                              const Color(AppColors.textInverse),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                  ],

                  // Current Price
                  Text(
                    product.formattedPrice,
                    style: AppTypography.getH3TextStyle(
                      const Color(AppColors.textPrimary),
                    ).copyWith(
                      fontWeight: AppTypography.bold,
                      color: product.isPromotion
                          ? const Color(AppColors.primaryMain)
                          : const Color(AppColors.textPrimary),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Buy Button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: isServiceReady ? onPurchase : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: product.isPromotion
                            ? const Color(AppColors.primaryMain)
                            : const Color(AppColors.buttonPrimary),
                        foregroundColor: product.isPromotion
                            ? const Color(AppColors.textInverse)
                            : const Color(AppColors.textInverse),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppBorderRadius.allSM,
                        ),
                      ),
                      child: const Text('BUY'),
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

class CoinProduct {
  final String id;
  final String name;
  final String description;
  final int coins;
  final double price;
  final double? originalPrice;
  final bool isPromotion;
  final String parentProductCode;

  const CoinProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.coins,
    required this.price,
    this.originalPrice,
    required this.isPromotion,
    required this.parentProductCode,
  });

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  int get discount {
    if (!hasDiscount) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String? get formattedOriginalPrice {
    final value = originalPrice;
    if (value == null) return null;
    return '\$${value.toStringAsFixed(2)}';
  }
}
