import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../../core/services/purchase_service.dart';
import '../../core/singletons/coins_manager.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/evara_scaffold.dart';
import 'contact_coins.dart';

/// Coin store page with generated product data.
class CoinStorePage extends StatefulWidget {
  const CoinStorePage({super.key});

  @override
  State<CoinStorePage> createState() => _CoinStorePageState();
}

class _CoinStorePageState extends State<CoinStorePage> {
  final CoinsManager _coinsManager = CoinsManager.instance;
  final PurchaseService _purchaseService = PurchaseService();

  final List<Contact575CoinProduct> _products =
      Privatised236CoinProductData.allProducts;

  bool _isPurchasing = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePurchaseService();
  }

  Future<void> _initializePurchaseService() async {
    final initialized = await _purchaseService.initialize();
    if (mounted) {
      setState(() {
        _isInitialized = initialized;
      });
    }
  }

  Future<void> _purchase(Contact575CoinProduct product) async {
    if (_isPurchasing) {
      return;
    }

    setState(() {
      _isPurchasing = true;
    });

    await _purchaseService.executePurchase(
      product.code,
      product.exchangeCoin,
      (status, message, coinsAdded) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isPurchasing = false;
        });

        switch (status) {
          case PurchaseResultStatus.success:
            SmartDialog.showToast(
              'Successfully purchased ${coinsAdded ?? product.exchangeCoin} coins!',
            );
            break;
          case PurchaseResultStatus.pending:
            SmartDialog.showToast('Payment is processing...');
            break;
          case PurchaseResultStatus.canceled:
            SmartDialog.showToast('Purchase canceled');
            break;
          case PurchaseResultStatus.error:
            SmartDialog.showToast(
              message ?? 'Purchase failed. Please try again.',
            );
            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return EvaraScaffold(
      safeTop: false,
      appBar: AppBar(title: const Text('Coin Store')),
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingLg,
              110,
              AppTheme.spacingLg,
              AppTheme.spacingXxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder<int>(
                  valueListenable: _coinsManager.coinsNotifier,
                  builder: (context, coins, child) {
                    return EvaraGlassCard(
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: AppTheme.textInverse,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Current balance',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: AppTheme.caption,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$coins coins',
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppTheme.spacingLg),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final rows = <Widget>[];
                    for (var index = 0; index < _products.length; index += 2) {
                      final leftProduct = _products[index];
                      final hasRightProduct = index + 1 < _products.length;
                      final rightProduct = hasRightProduct
                          ? _products[index + 1]
                          : null;

                      rows.add(
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _ProductCard(
                                  product: leftProduct,
                                  onTap: () => _purchase(leftProduct),
                                  isPurchasing:
                                      _isPurchasing || !_isInitialized,
                                  isPopular:
                                      index == 1 || leftProduct.isPromotion,
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacingMd),
                              Expanded(
                                child: rightProduct == null
                                    ? const SizedBox.shrink()
                                    : _ProductCard(
                                        product: rightProduct,
                                        onTap: () => _purchase(rightProduct),
                                        isPurchasing:
                                            _isPurchasing || !_isInitialized,
                                        isPopular: index + 1 == 1 ||
                                            rightProduct.isPromotion,
                                      ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
                          rows[rowIndex],
                          if (rowIndex != rows.length - 1)
                            const SizedBox(height: AppTheme.spacingMd),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          if (_isPurchasing)
            Container(
              color: AppTheme.bgOverlay,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppTheme.accentMain),
                    SizedBox(height: AppTheme.spacingMd),
                    Text(
                      'Processing purchase...',
                      style: TextStyle(
                        color: AppTheme.textInverse,
                        fontSize: AppTheme.body,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Contact575CoinProduct product;
  final VoidCallback onTap;
  final bool isPurchasing;
  final bool isPopular;

  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.isPurchasing,
    required this.isPopular,
  });

  @override
  Widget build(BuildContext context) {
    return EvaraGlassCard(
      onTap: isPurchasing ? null : onTap,
      padding: EdgeInsets.zero,
      color: isPopular
          ? AppTheme.bgCardStrong
          : AppTheme.bgCard.withValues(alpha: 0.92),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              gradient: isPopular
                  ? AppTheme.primaryGradient
                  : AppTheme.accentGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusLg),
                topRight: Radius.circular(AppTheme.radiusLg),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: AppTheme.spacingSm),
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 40,
                  color: AppTheme.textInverse,
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  '${product.exchangeCoin}',
                  style: const TextStyle(
                    color: AppTheme.textInverse,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  'coins',
                  style: TextStyle(
                    color: AppTheme.textInverse,
                    fontSize: AppTheme.caption,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              children: [
                if (product.formattedOriginalPrice != null &&
                    product.discountPercentage > 0) ...[
                  Text(
                    product.formattedOriginalPrice!,
                    style: const TextStyle(
                      color: AppTheme.textDisabled,
                      fontSize: AppTheme.caption,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (product.discountPercentage > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-${product.discountPercentage}%',
                          style: const TextStyle(
                            color: AppTheme.error,
                            fontSize: AppTheme.small,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      product.formattedPrice,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
