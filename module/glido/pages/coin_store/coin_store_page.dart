import 'package:flutter/material.dart';

import 'contact_coins.dart';
import '../../managers/coins_manager.dart';
import '../../services/purchase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glido_ui.dart';

class CoinStorePage extends StatefulWidget {
  const CoinStorePage({super.key});

  @override
  State<CoinStorePage> createState() => _CoinStorePageState();
}

class _CoinStorePageState extends State<CoinStorePage> {
  final List<Contact575CoinProduct> _products =
      Privatised236CoinProductData.allProductsGrouped;
  final PurchaseService _purchaseService = PurchaseService();

  String? _activeProductId;

  bool get _isAnyPurchaseInProgress => _activeProductId != null;

  @override
  void initState() {
    super.initState();
    _initPurchaseService();
    _initCoinsManager();
  }

  Future<void> _initPurchaseService() async {
    final productIds = _products.map((product) => product.goodsId);
    await _purchaseService.isAvailable(productIds: productIds);
    await _purchaseService.loadProducts(productIds);

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _initCoinsManager() async {
    await CoinsManager().init();
  }

  Future<void> _purchaseProduct(Contact575CoinProduct product) async {
    if (_isAnyPurchaseInProgress) {
      return;
    }

    final productId = product.goodsId;
    setState(() => _activeProductId = productId);

    await _purchaseService.purchase(
      productId,
      product.exchangeCoin,
      onResult: (productId, coins, success, message) {
        if (!mounted) return;
        setState(() => _activeProductId = null);

        if (!success && message != null) {
          _showErrorDialog(message);
        }
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Purchase failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Coin Store'),
      ),
      body: GlidoPageBackground(
        topSafeArea: true,
        padding: const EdgeInsets.only(
          top: kToolbarHeight - AppTheme.spacingMd,
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spacingMd,
            0,
            AppTheme.spacingMd,
            120,
          ),
          children: [
            _BalanceCard(),
            const SizedBox(height: AppTheme.spacingLg),
            const GlidoSectionHeader(
              title: 'Choose a pack',
              subtitle:
                  'Bright, simple purchase cards that match the rest of the interface.',
            ),
            const SizedBox(height: AppTheme.spacingMd),
            ..._products.map((product) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                  child: _ProductCard(
                    product: product,
                    isAvailable: !_isAnyPurchaseInProgress,
                    isPurchasing: _activeProductId == product.goodsId,
                    onBuy: () => _purchaseProduct(product),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _activeProductId = null;
    super.dispose();
  }
}

class _BalanceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CoinsManager(),
      builder: (context, _) {
        return GlidoSurface(
          gradient: AppTheme.highlightGradient,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current balance',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                    child: const Icon(
                      Icons.monetization_on_rounded,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Text(
                    '${CoinsManager().balance}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Contact575CoinProduct product;
  final bool isAvailable;
  final bool isPurchasing;
  final VoidCallback onBuy;

  const _ProductCard({
    required this.product,
    required this.isAvailable,
    required this.isPurchasing,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return GlidoSurface(
      gradient: product.isPromotion ? AppTheme.blushGradient : null,
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.56),
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            ),
            child: const Icon(
              Icons.monetization_on_rounded,
              color: AppTheme.textPrimary,
              size: 34,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${product.exchangeCoin}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(width: AppTheme.spacingXs),
                    Text(
                      'coins',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Wrap(
                  spacing: AppTheme.spacingSm,
                  runSpacing: AppTheme.spacingSm,
                  children: [
                    if (product.isPromotion) const GlidoPill(label: 'Sale'),
                    if (product.discountPercentage > 0)
                      GlidoPill(
                        label: '${product.discountPercentage}% off',
                        color: Colors.white.withValues(alpha: 0.56),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                product.formattedPrice,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (product.formattedOriginalPrice != null) ...[
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  product.formattedOriginalPrice!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: AppTheme.textSecondary,
                      ),
                ),
              ],
              const SizedBox(height: AppTheme.spacingSm),
              SizedBox(
                width: 88,
                child: ElevatedButton(
                  onPressed: (isPurchasing || !isAvailable) ? null : onBuy,
                  child: isPurchasing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Buy'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
