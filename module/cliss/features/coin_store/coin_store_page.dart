import 'package:flutter/material.dart';
import 'package:cliss/cliss/app/services/purchase_service.dart';
import 'package:cliss/cliss/app/services/user_service.dart';
import 'package:cliss/cliss/app/theme/app_theme.dart';
import 'package:cliss/cliss/app/widgets/app_card.dart';
import 'package:cliss/cliss/app/widgets/app_scaffold.dart';
import 'package:cliss/cliss/features/coin_store/contact_coins.dart';

class CoinStorePage extends StatefulWidget {
  const CoinStorePage({super.key});

  @override
  State<CoinStorePage> createState() => _CoinStorePageState();
}

class _CoinStorePageState extends State<CoinStorePage> {
  bool _isInitializing = true;
  bool _isPurchasing = false;
  String? _purchasingProductId;
  DateTime? _purchaseStartedAt;
  late List<Contact575CoinProduct> _packages;

  @override
  void initState() {
    super.initState();
    _packages = Privatised236CoinProductData.allProductsGrouped;
    _initializePurchaseService();
  }

  Future<void> _initializePurchaseService() async {
    await PurchaseService.instance.init();
    await PurchaseService.instance.loadProducts(_packages.map((p) => p.goodsId).toList());
    _packages = _packages
        .where((package) => PurchaseService.instance.hasProduct(package.goodsId))
        .toList();
    if (!mounted) return;
    setState(() => _isInitializing = false);
  }

  Future<void> _handlePurchase(Contact575CoinProduct package) async {
    if (_isPurchasing) return;
    setState(() {
      _isPurchasing = true;
      _purchasingProductId = package.goodsId;
    });

    try {
      final started = await PurchaseService.instance.executePurchase(
        package.goodsId,
        package.exchangeCoin,
        (coins) {
          if (!mounted) return;
          setState(() {
            _isPurchasing = false;
            _purchasingProductId = null;
            _purchaseStartedAt = null;
          });
        },
      );
      if (!started && mounted) {
        setState(() {
          _isPurchasing = false;
          _purchasingProductId = null;
          _purchaseStartedAt = null;
        });
        return;
      }
      _purchaseStartedAt = DateTime.now();
      Future<void>.delayed(const Duration(seconds: 20), () {
        if (!mounted || !_isPurchasing) return;
        final startedAt = _purchaseStartedAt;
        if (startedAt == null) return;
        if (DateTime.now().difference(startedAt) >= const Duration(seconds: 20)) {
          setState(() {
            _isPurchasing = false;
            _purchasingProductId = null;
            _purchaseStartedAt = null;
          });
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isPurchasing = false;
        _purchasingProductId = null;
        _purchaseStartedAt = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Coin Store')),
      safeBottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          120,
        ),
        children: [
          ValueListenableBuilder(
            valueListenable: UserService.instance.coinsV,
            builder: (context, coins, child) {
              return AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceMint,
                        borderRadius: AppBorderRadius.allLarge,
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        size: 28,
                        color: AppColors.primaryMain,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Current balance', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                          const SizedBox(height: AppSpacing.xs),
                          Text('$coins coins', style: AppTextStyles.h2),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_isInitializing)
            const Center(child: CircularProgressIndicator())
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = (constraints.maxWidth - AppSpacing.md) / 2;
                return Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: _packages.map((package) {
                    final isPurchasing =
                        _isPurchasing && _purchasingProductId == package.goodsId;
                    return SizedBox(
                      width: itemWidth,
                      child: _CoinPackageWidget(
                        package: package,
                        isPurchasing: isPurchasing,
                        onTap: () => _handlePurchase(package),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _CoinPackageWidget extends StatelessWidget {
  final Contact575CoinProduct package;
  final bool isPurchasing;
  final VoidCallback onTap;

  const _CoinPackageWidget({
    required this.package,
    required this.isPurchasing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: isPurchasing ? null : onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (package.isPromotion)
                _PackFlag(
                  text: package.discountPercentage > 0
                      ? '-${package.discountPercentage}%'
                      : 'SALE',
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.surfaceMint,
              borderRadius: AppBorderRadius.allLarge,
            ),
            child: isPurchasing
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.primaryMain,
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('${package.exchangeCoin} coins', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.xs),
          Text(
            package.formattedPrice,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          if (package.formattedOriginalPrice != null) ...[
            const SizedBox(height: 4),
            Text(
              package.formattedOriginalPrice!,
              style: AppTextStyles.small.copyWith(
                color: AppColors.textSecondary,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PackFlag extends StatelessWidget {
  final String text;

  const _PackFlag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primaryMain,
        borderRadius: AppBorderRadius.allSmall,
      ),
      child: Text(
        text,
        style: AppTextStyles.small.copyWith(
          color: AppColors.textInverse,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
