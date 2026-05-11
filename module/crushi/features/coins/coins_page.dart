import 'package:flutter/material.dart';
import 'package:crushi/crushi/core/theme/app_theme.dart';
import 'package:crushi/crushi/core/router/global_router.dart';
import 'package:crushi/crushi/features/coins/contact_coins.dart';
import 'package:crushi/crushi/features/coins/coins_logic.dart';
import 'package:crushi/crushi/core/widgets/diffuse_background.dart';
import 'package:crushi/crushi/core/widgets/glass_card.dart';

class CoinsPage extends StatefulWidget {
  const CoinsPage({super.key});

  @override
  State<CoinsPage> createState() => _CoinsPageState();
}

class _CoinsPageState extends State<CoinsPage> {
  late final CoinsLogic _logic;

  static const Color _hermesOrange = AppColors.primaryMain;

  List<Contact575CoinProduct> get _packages =>
      Privatised236CoinProductData.allProductsGrouped;

  @override
  void initState() {
    super.initState();
    _logic = CoinsLogic()..addListener(_onLogicChanged);
    _logic.init();
  }

  @override
  void dispose() {
    _logic.removeListener(_onLogicChanged);
    _logic.disposeLogic();
    super.dispose();
  }

  void _onLogicChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            fit: StackFit.expand,
            children: [
              const Positioned.fill(
                child: DiffuseBackground(
                  base: Color(0xFF070B16),
                  bottom: Color(0xFF070B16),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.sm,
                        AppSpacing.lg,
                        AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          _RoundIconButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: () => GlobalRouter.I.goBack(),
                          ),
                          const Spacer(),
                          Text(
                            'Coin Top Up',
                            style: AppTypography.h3.copyWith(
                              color: AppColors.textInverse,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 44),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          AppSpacing.xl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBalanceCard(),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              'Choose a package',
                              style: AppTypography.h3.copyWith(
                                color: AppColors.textInverse,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            if (_logic.isLoading)
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: AppSpacing.xl,
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: _hermesOrange,
                                  ),
                                ),
                              ),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: AppSpacing.md,
                                mainAxisSpacing: AppSpacing.md,
                                childAspectRatio: 1.0,
                              ),
                              itemCount: _packages.length,
                              itemBuilder: (context, index) {
                                return _buildPackageCard(_packages[index]);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Loading overlay
        if (_logic.isPurchasing)
          Container(
            color: AppColors.overlay,
            child: const Center(
              child: CircularProgressIndicator(color: _hermesOrange),
            ),
          ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      tintOpacity: 0.18,
      borderOpacity: 0.22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current balance',
            style: AppTypography.small.copyWith(
              color: AppColors.textInverse.withOpacity(0.85),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: const Center(
                  child: Icon(
                    Icons.monetization_on,
                    size: 18,
                    color: _hermesOrange,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${_logic.balance}',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textInverse,
                  fontFamily: AppTypography.fontFamily,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Unlock more premium content',
            style: AppTypography.small.copyWith(
              color: AppColors.textInverse.withOpacity(0.78),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(Contact575CoinProduct pkg) {
    final isPromotion = pkg.isPromotion;
    final hasOriginal = pkg.formattedOriginalPrice != null;
    final displayPrice = pkg.formattedPrice;

    return InkWell(
      onTap: () => _logic.buy(pkg),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        borderRadius: AppRadius.lg,
        tintOpacity: 0.16,
        borderOpacity: isPromotion ? 0.42 : 0.22,
        boxShadow: AppShadows.sm,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                right: isPromotion ? 76 : 0,
                top: isPromotion ? 2 : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: _hermesOrange.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.star_rounded,
                            color: AppColors.textInverse,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      displayPrice,
                      style: AppTypography.h3.copyWith(
                        color: AppColors.textInverse,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (hasOriginal)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        pkg.formattedOriginalPrice!,
                        style: AppTypography.small.copyWith(
                          color: AppColors.textInverse.withOpacity(0.7),
                          decoration: TextDecoration.lineThrough,
                          decorationThickness: 2,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xs),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${pkg.exchangeCoin} coins',
                      style: AppTypography.small.copyWith(
                        color: AppColors.textInverse.withOpacity(0.78),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isPromotion)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _hermesOrange.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: _hermesOrange.withOpacity(0.35)),
                  ),
                  child: Text(
                    pkg.discountPercentage > 0
                        ? '${pkg.discountPercentage}% OFF'
                        : 'SALE',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textInverse,
                      fontFamily: AppTypography.fontFamily,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppRadius.full),
          boxShadow: AppShadows.sm,
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 18,
            color: AppColors.textInverse,
          ),
        ),
      ),
    );
  }
}
