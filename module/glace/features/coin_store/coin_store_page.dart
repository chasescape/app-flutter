import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../core/theme/app_theme.dart';
import '../../services/coins_manager.dart';
import '../../services/purchase_service.dart';
import '../../widgets/glace_ui.dart';
import '../../widgets/scent_loading_dialog.dart';
import 'contact_coins.dart';

class CoinStorePage extends StatefulWidget {
  const CoinStorePage({super.key});

  @override
  State<CoinStorePage> createState() => _CoinStorePageState();
}

class _CoinStorePageState extends State<CoinStorePage> {
  final Map<String, ProductDetails> _storeProducts = {};
  bool _storeReady = false;
  bool _isLoadingProducts = true;
  String? _purchasingProductId;

  @override
  void initState() {
    super.initState();
    CoinsManager.instance.init();
    _initStore();
  }

  Future<void> _initStore() async {
    await PurchaseService.instance.init();
    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoadingProducts = true);

    final ids = Privatised236CoinProductData.allProductsGrouped
        .map((e) => e.goodsId)
        .toSet();

    if (!PurchaseService.instance.isAvailable) {
      setState(() {
        _storeReady = false;
        _isLoadingProducts = false;
      });
      return;
    }

    final response = await PurchaseService.instance.queryProducts(ids);

    final detailsMap = <String, ProductDetails>{};
    for (final detail in response.productDetails) {
      detailsMap[detail.id] = detail;
    }

    if (!mounted) return;
    setState(() {
      _storeProducts
        ..clear()
        ..addAll(detailsMap);
      _storeReady = true;
      _isLoadingProducts = false;
    });
  }

  Future<void> _purchase(Contact575CoinProduct pack) async {
    if (_purchasingProductId != null) return;

    final product = _storeProducts[pack.goodsId];
    if (product == null) {
      SmartDialog.showToast('This product is not available right now.');
      return;
    }

    setState(() => _purchasingProductId = pack.goodsId);
    ScentLoadingDialog.show(showMessage: false);

    await PurchaseService.instance.buyConsumable(
      product: product,
      coins: pack.exchangeCoin,
      onResult: (success, error) {
        ScentLoadingDialog.dismiss();
        if (!mounted) return;
        setState(() => _purchasingProductId = null);
        if (success) {
          CoinsManager.instance.addCoins(pack.exchangeCoin);
          SmartDialog.showToast('${pack.exchangeCoin} coins added');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GlaceScaffold(
          appBar: AppBar(
            title: const Text(
              'Coin store',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            foregroundColor: AppColors.textPrimary,
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
          ),
          safeArea: false,
          child: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _StoreHero(),
                  const SizedBox(height: 14),
                  GlaceGlassCard(
                    padding: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(26),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.86),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: AppColors.primary,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Current balance',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ValueListenableBuilder<int>(
                                valueListenable:
                                    CoinsManager.instance.balanceNotifier,
                                builder: (_, balance, __) {
                                  return Text(
                                    '$balance coins',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_storeReady)
                    _CoinGrid(
                      products: Privatised236CoinProductData.allProductsGrouped,
                      storeProducts: _storeProducts,
                      purchasingProductId: _purchasingProductId,
                      onBuy: _purchase,
                    )
                  else
                    GlaceSurfaceCard(
                      color: Colors.white.withValues(alpha: 0.82),
                      child: const Text(
                        'App Store products are not available right now. Please check your iOS in-app purchase configuration.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (_isLoadingProducts)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.16),
              child: const Center(
                child: SizedBox(
                  width: 38,
                  height: 38,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _StoreHero extends StatelessWidget {
  const _StoreHero();

  @override
  Widget build(BuildContext context) {
    return GlaceGlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(30),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF6AEFF), Color(0xFF8BA9FF)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.diamond_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unlock more scent moments',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Use coins for more journal extras and future premium content.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
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

class _CoinGrid extends StatelessWidget {
  final List<Contact575CoinProduct> products;
  final Map<String, ProductDetails> storeProducts;
  final String? purchasingProductId;
  final ValueChanged<Contact575CoinProduct> onBuy;

  const _CoinGrid({
    required this.products,
    required this.storeProducts,
    required this.purchasingProductId,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    for (var i = 0; i < products.length; i += 2) {
      final left = products[i];
      final right = i + 1 < products.length ? products[i + 1] : null;

      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _CoinCard(
                pack: left,
                displayPrice: left.formattedPrice,
                isPurchasing: purchasingProductId == left.goodsId,
                onTap: () => onBuy(left),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: right == null
                  ? const SizedBox.shrink()
                  : _CoinCard(
                      pack: right,
                      displayPrice: right.formattedPrice,
                      isPurchasing: purchasingProductId == right.goodsId,
                      onTap: () => onBuy(right),
                    ),
            ),
          ],
        ),
      );

      if (i + 2 < products.length) {
        rows.add(const SizedBox(height: 14));
      }
    }

    return Column(children: rows);
  }
}

class _CoinCard extends StatelessWidget {
  final Contact575CoinProduct pack;
  final String displayPrice;
  final bool isPurchasing;
  final VoidCallback onTap;

  const _CoinCard({
    required this.pack,
    required this.displayPrice,
    required this.isPurchasing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlaceSurfaceCard(
      onTap: isPurchasing ? null : onTap,
      color: Colors.white.withValues(alpha: 0.84),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (pack.isPromotion) const SizedBox(height: 12),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF6AEFF), Color(0xFF8BA9FF)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: isPurchasing
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.diamond_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
              ),
              const SizedBox(height: 16),
              Text(
                '${pack.exchangeCoin}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'coins',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  displayPrice,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (pack.isPromotion && pack.formattedOriginalPrice != null) ...[
                const SizedBox(height: 8),
                Text(
                  pack.formattedOriginalPrice!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
          if (pack.isPromotion)
            Positioned(
              top: -6,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    '${pack.discountPercentage}% OFF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
