import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../services/purchase_service.dart';
import '../../services/coins_manager.dart';
import '../../widgets/common/pastel_ui.dart';
import 'contact_coins.dart';

class CoinShopPage extends StatefulWidget {
  const CoinShopPage({super.key});

  @override
  State<CoinShopPage> createState() => _CoinShopPageState();
}

class _CoinShopPageState extends State<CoinShopPage> {
  final List<Contact575CoinProduct> _products =
      Privatised236CoinProductData.allProductsGrouped;
  final PurchaseService _purchaseService = PurchaseService.instance;
  final CoinsManager _coinsManager = CoinsManager.instance;

  bool _isInitializing = true;
  bool _isLoadingPurchase = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePurchaseService();
  }

  Future<void> _initializePurchaseService() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    final available = await _purchaseService.initialize(
      onAddCoins: (coins) {
        debugPrint('Coins added via purchase: $coins');
      },
    );

    if (!available) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _errorMessage = 'In-app purchase is not available on this device';
      });
      return;
    }

    await _purchaseService.loadProducts(_products.map((p) => p.goodsId).toList());
    await _coinsManager.initialize();

    if (!mounted) return;
    setState(() {
      _isInitializing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PastelScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        title: const Text('Coin Shop'),
      ),
      child: _isInitializing
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: GlassCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 56, color: AppColors.error),
                          const SizedBox(height: AppSpacing.md),
                          Text(_errorMessage!, style: AppTextStyles.body, textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildPackagesGrid(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F0E7),
              Color(0xFFEDE3FA),
            ],
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF352B4F),
                Color(0xFF21192F),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF21192F).withValues(alpha: 0.18),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -20,
                right: -10,
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                left: 18,
                bottom: 18,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: ValueListenableBuilder<int>(
                  valueListenable: _coinsManager.coinsNotifier,
                  builder: (context, coins, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2BC73),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet_rounded,
                                size: 28,
                                color: Color(0xFF2A1F3D),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.10),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 15,
                                    color: Color(0xFFFFDFA8),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'No subscription',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Current balance',
                          style: TextStyle(
                            color: Color(0xFFCDBFE0),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$coins coins',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Pick a one-time pack whenever you need more daily check-ins.',
                          style: TextStyle(
                            color: Color(0xFFB8ABCE),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.08),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.lock_rounded,
                                      size: 16,
                                      color: Color(0xFFFFDFA8),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'One-time purchase only',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackagesGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - AppSpacing.md) / 2;

        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: _products
              .map(
                (product) => SizedBox(
                  width: itemWidth,
                  child: _buildPackageCard(product),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildPackageCard(Contact575CoinProduct product) {
    final isBestValue = product.discountPercentage > 0;
    final isDisabled = _isLoadingPurchase;

    return Opacity(
      opacity: isDisabled ? 0.72 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
          onTap: isDisabled ? null : () => _handlePurchase(product),
          child: GlassCard(
            radius: AppBorderRadius.large,
            padding: EdgeInsets.zero,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppBorderRadius.large),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFF9F5FF),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isBestValue
                                  ? const [Color(0xFFFFE1AE), Color(0xFFF5B85C)]
                                  : const [Color(0xFFEDE7FF), Color(0xFFD9E8FF)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isBestValue
                                        ? const Color(0xFFF0BA69)
                                        : AppColors.accentLight)
                                    .withValues(alpha: 0.45),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            isBestValue
                                ? Icons.workspace_premium_rounded
                                : Icons.diamond_outlined,
                            size: 22,
                            color: isBestValue
                                ? const Color(0xFF7A4E08)
                                : AppColors.accentDark,
                          ),
                        ),
                        const Spacer(),
                        if (isDisabled)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.accentDark,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '${product.exchangeCoin} coins',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.accentDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          product.formattedPrice,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        if (product.formattedOriginalPrice != null) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              product.formattedOriginalPrice!,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.small.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: AppColors.textDisabled,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (product.discountPercentage > 0) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF2D8),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Save ${product.discountPercentage}%',
                          style: AppTextStyles.small.copyWith(
                            color: const Color(0xFF8A5A00),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handlePurchase(Contact575CoinProduct product) async {
    if (_isLoadingPurchase) return;

    setState(() {
      _isLoadingPurchase = true;
    });

    await _purchaseService.executePurchase(
      product.goodsId,
      product.exchangeCoin,
      onResult: (result) {
        if (!mounted) return;

        setState(() {
          _isLoadingPurchase = false;
        });

        if (result.success) {
          Get.snackbar(
            'Purchase successful',
            result.message ?? 'Coins added to your balance',
            backgroundColor: AppColors.success,
            colorText: AppColors.textInverse,
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          // Intentionally keep failure and cancellation silent.
        }
      },
    );
  }
}
