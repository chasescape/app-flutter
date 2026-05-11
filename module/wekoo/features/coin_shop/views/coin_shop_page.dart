import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'contact_coins.dart';
import '../../../services/coins_manager.dart';
import '../../../services/purchase_service.dart';
import '../../../theme/app_theme.dart';

class CoinShopPage extends StatefulWidget {
  const CoinShopPage({super.key});

  @override
  State<CoinShopPage> createState() => _CoinShopPageState();
}

class _CoinShopPageState extends State<CoinShopPage> {
  final CoinsManager _coinsManager = CoinsManager.instance;
  final PurchaseService _purchaseService = PurchaseService.instance;
  bool _isInitializing = true;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _initPurchaseService();
  }

  Future<void> _initPurchaseService() async {
    await _purchaseService.init(
      addCoinsCallback: (coins) async {
        await _coinsManager.addCoins(coins);
      },
    );
    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppTheme.appBackgroundGradient,
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Get Coins'),
            backgroundColor: Colors.transparent,
          ),
          body: Stack(
            children: [
              _isInitializing
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Column(
                      children: [
                        _buildBalanceCard(),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                              AppTheme.spacingMd,
                              0,
                              AppTheme.spacingMd,
                              AppTheme.spacingMd,
                            ),
                            itemCount: Privatised236CoinProductData
                                .allProductsGrouped.length,
                            itemBuilder: (context, index) {
                              final product = Privatised236CoinProductData
                                  .allProductsGrouped[index];
                              return _buildPackageCard(product);
                            },
                          ),
                        ),
                      ],
                    ),
              if (_isPurchasing)
                Positioned.fill(
                  child: AbsorbPointer(
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.62),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return ValueListenableBuilder<int>(
      valueListenable: _coinsManager.coinsNotifier,
      builder: (context, coins, child) {
        return Container(
          margin: const EdgeInsets.all(AppTheme.spacingLg),
          padding: const EdgeInsets.all(AppTheme.spacingXl),
          decoration: BoxDecoration(
            gradient: AppTheme.aquaPrimaryGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: AppTheme.shadowsElevated,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Balance',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.86),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$coins',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.monetization_on,
                size: 48,
                color: Colors.white,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPackageCard(Contact575CoinProduct product) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.shadows,
        border: Border.all(
          color: product.isPromotion ? AppTheme.primaryMain : AppTheme.secondaryLight,
          width: product.isPromotion ? 1.8 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.primaryMain.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Icon(
              Icons.diamond,
              color: AppTheme.primaryMain,
              size: 32,
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
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Coins',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (product.isPromotion) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${product.discountPercentage}% off',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.semanticSuccess,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      product.formattedPrice,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.primaryMain,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (product.isPromotion && product.formattedOriginalPrice != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        product.formattedOriginalPrice!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _isPurchasing
                ? null
                : () => _purchasePackage(product.goodsId, product.exchangeCoin),
            child: const Text('Buy'),
          ),
        ],
      ),
    );
  }

  void _purchasePackage(String productId, int coins) {
    setState(() {
      _isPurchasing = true;
    });

    _purchaseService.executePurchase(
      productId,
      coins,
      onResult: (success, error) {
        if (mounted) {
          setState(() {
            _isPurchasing = false;
          });
        }

        if (success) {
          Get.snackbar(
            'Success',
            'Purchase successful!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.semanticSuccess.withValues(alpha: 0.9),
            colorText: Colors.white,
          );
        } else {
          debugPrint('Purchase skipped snackbar: ${error ?? 'Unknown error'}');
        }
      },
    );
  }
}
