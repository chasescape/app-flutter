import 'package:flutter/material.dart';
import 'package:achievenote/gozi/services/purchase_service.dart';
import 'package:achievenote/gozi/services/coins_manager.dart';
import 'package:achievenote/gozi/widgets/common/app_card.dart';
import 'package:achievenote/gozi/widgets/common/app_scaffold.dart';
import 'package:achievenote/gozi/widgets/common/loading_widget.dart';
import 'package:achievenote/gozi/theme/app_theme.dart';
import 'contact_coins.dart';

/// Store Page - Purchase coin packages with real in-app purchase
class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  final List<Contact575CoinProduct> _packages =
      Privatised236CoinProductData.allProductsGrouped;

  final PurchaseService _purchaseService = PurchaseService.instance;
  final CoinsManager _coinsManager = CoinsManager.instance;

  bool _isInitialized = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _coinsManager.initialize();

    final initialized = await _purchaseService.initialize();
    if (!initialized) {
      if (mounted) {
        _showErrorSnackBar('In-app purchase not available on this device');
      }
      return;
    }

    _purchaseService.setAddCoinsCallback((int coins) {
      _coinsManager.addCoins(coins);
    });

    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _purchasePackage(Contact575CoinProduct package) async {
    if (!_isInitialized) {
      _showErrorSnackBar('Purchase service not ready');
      return;
    }

    if (!mounted) return;

    setState(() => _isLoading = true);
    AppLoadingOverlay.show(context);

    await _purchaseService.executePurchase(
      productId: package.code,
      coins: package.exchangeCoin,
      onResult: (type, message, coinsAdded) {
        if (mounted) {
          AppLoadingOverlay.hide(context);
          setState(() => _isLoading = false);
        }

        switch (type) {
          case PurchaseResultType.success:
            _showSuccessSnackBar('Added $coinsAdded coins to your balance!');
            break;
          case PurchaseResultType.failed:
            _showErrorSnackBar(message ?? 'Purchase failed');
            break;
          case PurchaseResultType.canceled:
            _showInfoSnackBar('Purchase canceled');
            break;
          case PurchaseResultType.pending:
            _showInfoSnackBar(message ?? 'Purchase is processing...');
            break;
        }
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(message),
    //     backgroundColor: AppTheme.success,
    //     duration: const Duration(seconds: 3),
    //   ),
    // );
  }

  void _showErrorSnackBar(String message) {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(message),
    //     backgroundColor: AppTheme.error,
    //     duration: const Duration(seconds: 3),
    //   ),
    // );
  }

  void _showInfoSnackBar(String message) {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(message),
    //     backgroundColor: AppTheme.info,
    //     duration: const Duration(seconds: 3),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Get Coins'),
      ),
      body: Column(
        children: [
          _BalanceHeader(coinsManager: _coinsManager),
          const SizedBox(height: AppTheme.lg),
          Expanded(
            child: _isInitialized
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      final availableWidth =
                          constraints.maxWidth - AppTheme.md * 2;
                      final itemWidth = availableWidth >= 320
                          ? (availableWidth - AppTheme.md) / 2
                          : availableWidth;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          AppTheme.md,
                          0,
                          AppTheme.md,
                          AppTheme.xl,
                        ),
                        child: Wrap(
                          spacing: AppTheme.md,
                          runSpacing: AppTheme.md,
                          children: [
                            for (final package in _packages)
                              SizedBox(
                                width: itemWidth,
                                child: _PackageCard(
                                  package: package,
                                  onTap: () => _purchasePackage(package),
                                  isLoading: _isLoading,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  )
                : const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.accentRed,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _BalanceHeader extends StatelessWidget {
  final CoinsManager coinsManager;

  const _BalanceHeader({required this.coinsManager});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.md,
        vertical: AppTheme.sm,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.lg,
        vertical: AppTheme.md,
      ),
      decoration: BoxDecoration(
        gradient: AppTheme.softSurfaceGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border:
            Border.all(color: AppTheme.primaryWhite.withValues(alpha: 0.74)),
        boxShadow: AppTheme.buttonShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryButtonGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.monetization_on,
              color: AppTheme.primaryWhite,
              size: 28,
            ),
          ),
          const SizedBox(width: AppTheme.lg),
          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: coinsManager.balanceNotifier,
              builder: (context, balance, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Balance',
                      style: AppTheme.small.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$balance coins',
                      style: AppTheme.h2.copyWith(
                        color: AppTheme.textInverse,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const Icon(
            Icons.info_outline,
            color: AppTheme.accentRed,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final Contact575CoinProduct package;
  final VoidCallback onTap;
  final bool isLoading;

  const _PackageCard({
    required this.package,
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      onTap: isLoading ? null : onTap,
      borderRadius: AppTheme.radiusXl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (package.isPromotion)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.sm,
                vertical: AppTheme.xs,
              ),
              decoration: const BoxDecoration(
                color: AppTheme.accentRed,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusXl),
                  bottomRight: Radius.circular(AppTheme.radiusLg),
                ),
              ),
              child: Text(
                '-${package.discountPercentage}%',
                style: AppTheme.small.copyWith(
                  color: AppTheme.primaryWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.md,
              AppTheme.md,
              AppTheme.md,
              AppTheme.sm,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.monetization_on,
                    size: 40,
                    color: AppTheme.accentRed.withValues(alpha: 0.84),
                  ),
                  const SizedBox(height: AppTheme.xs),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${package.exchangeCoin}',
                      style: AppTheme.h2.copyWith(
                        color: AppTheme.textInverse,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    'Coins',
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.md,
              AppTheme.xs,
              AppTheme.md,
              AppTheme.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppTheme.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      package.formattedPrice,
                      style: AppTheme.h3.copyWith(
                        color: AppTheme.accentRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (package.isPromotion &&
                        package.formattedOriginalPrice != null)
                      Text(
                        package.formattedOriginalPrice!,
                        style: AppTheme.small.copyWith(
                          color: AppTheme.textDisabled,
                          decoration: TextDecoration.lineThrough,
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
