import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../contact_coins.dart';
import '../../../core/app_routes.dart';
import '../../../core/app_theme.dart';
import '../../../core/pink_ui.dart';
import '../providers/coin_provider.dart';

class CoinStorePage extends StatefulWidget {
  const CoinStorePage({super.key});

  @override
  State<CoinStorePage> createState() => _CoinStorePageState();
}

class _CoinStorePageState extends State<CoinStorePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CoinProvider>().initializePurchaseService();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PinkPageScaffold(
      leading: const PinkBackButton(onTap: AppRoutes.back),
      title: 'Store',
      centerTitle: true,
      child: Consumer<CoinProvider>(
        builder: (context, coinProvider, child) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              PinkGlassCard(
                child: Row(
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        gradient: AppTheme.heroGradient,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.monetization_on_rounded,
                        color: AppTheme.textInverse,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${coinProvider.coins} coins',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          const SizedBox(height: AppTheme.spacingXs),
                          Text(
                            'Top up when you want more image generations.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              ...coinProvider.products.map(
                (Contact575CoinProduct product) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                  child: PinkGlassCard(
                    child: Row(
                      children: [
                        Container(
                          width: 74,
                          height: 74,
                          decoration: BoxDecoration(
                            gradient: AppTheme.heroGradient,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: Text(
                              '${product.exchangeCoin}',
                              style: const TextStyle(
                                color: AppTheme.textInverse,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${product.exchangeCoin} Coins',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: AppTheme.spacingXs),
                              Text(
                                product.formattedPrice,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: AppTheme.primaryDark,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              if (product.formattedOriginalPrice != null) ...[
                                const SizedBox(height: AppTheme.spacingXs),
                                Text(
                                  product.formattedOriginalPrice!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppTheme.textSecondary,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                ),
                              ],
                              if (product.isPromotion &&
                                  product.discountPercentage > 0) ...[
                                const SizedBox(height: AppTheme.spacingSm),
                                PinkPill(
                                  text: '${product.discountPercentage}% OFF',
                                  backgroundColor: AppTheme.accentLight,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        SizedBox(
                          width: 88,
                          child: PinkPrimaryButton(
                            label: 'Buy',
                            onPressed: () =>
                                _handlePurchase(context, product, coinProvider),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handlePurchase(BuildContext context,
      Contact575CoinProduct product, CoinProvider coinProvider) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          const Center(child: CircularProgressIndicator()),
    );

    final success = await coinProvider.purchaseCoins(product.code);

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pop();
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Purchased ${product.exchangeCoin} coins successfully.',
          ),
        ),
      );
    }
    // else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Purchase failed. Please try again.'),
    //     ),
    //   );
    // }
  }
}
