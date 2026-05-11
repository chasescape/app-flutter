import 'package:affie/affie/app/data/coins_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'coins_logic.dart';
import '../../theme/app_colors.dart';

class CoinsPage extends StatelessWidget {
  CoinsPage({super.key});

  final CoinsLogic logic = Get.put(CoinsLogic());

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Coin Top Up',
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildCoinBalance(context),
            const SizedBox(height: 30),
            _buildCoinPackages(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinBalance(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerGradient = isDark
        ? [
            Color.lerp(AppColors.primaryDark, Colors.black, 0.15)!,
            Color.lerp(AppColors.secondaryDark, Colors.black, 0.35)!,
          ]
        : AppColors.gradientPink;

    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 18 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: headerGradient,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(isDark ? 0.18 : 0.35),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _CoinPatternPainter()),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current balance',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.75),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Row(
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              color: Colors.white,
                              size: 40,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${logic.coinBalance.value}',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )),
                    const Spacer(),
                    Text(
                      'Unlock more premium content',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoinPackages(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose a package',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () {
            final selectedCoins = logic.selectedPackageCoins.value;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: CoinsData.orderedPackages.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.25,
              ),
              itemBuilder: (context, index) {
                final package = CoinsData.orderedPackages[index];
                return TweenAnimationBuilder(
                  duration: Duration(milliseconds: 320 + (index * 90)),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Transform.translate(
                      offset: Offset(0, 18 * (1 - value)),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: _buildPackageTile(
                    context,
                    package,
                    index,
                    isSelected: selectedCoins == package.coins,
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildPackageTile(
    BuildContext context,
    CoinPackage package,
    int index,
    {required bool isSelected,}
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardGradient = isDark
        ? [
            AppColors.darkCard.withOpacity(0.85),
            AppColors.darkCard.withOpacity(0.65),
          ]
        : [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ];

    return _PressableScale(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        if (logic.isProcessing.value) return;
        logic.selectedPackageCoins.value = package.coins;
        logic.purchasePackage(package);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(color: AppColors.primary.withOpacity(0.95), width: 2)
              : Border.all(color: Colors.white.withOpacity(isDark ? 0.10 : 0.25)),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withOpacity(isDark ? 0.20 : 0.28)
                  : Colors.black.withOpacity(isDark ? 0.25 : 0.08),
              blurRadius: isSelected ? 22 : 14,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: cardGradient),
              ),
              child: Stack(
                children: [
                  if (package.type == CoinPackageType.promotion && package.discountPercent > 0)
                    Positioned(
                      top: 0,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent1.withOpacity(0.95),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          '${package.discountPercent}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? [
                                          AppColors.primary.withOpacity(0.85),
                                          AppColors.secondary.withOpacity(0.75),
                                        ]
                                      : AppColors.gradientPink,
                                ),
                              ),
                              child: const Icon(
                                Icons.stars,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const Spacer(),
                            if (package.type == CoinPackageType.promotion &&
                                package.discountPercent > 0) ...[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    package.price,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.primaryDark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatOriginalPrice(package.coins),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.textSecondary,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ),
                            ] else
                              Text(
                                package.price,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.primaryDark,
                                ),
                              ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${package.coins} coins',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatOriginalPrice(int coins) {
    final price = coins / 100.0;
    return '\$${price.toStringAsFixed(2)}';
  }


  Widget _buildBonusItem(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoinPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 20; i++) {
      final x = (i * 30.0) % size.width;
      final y = (i * 20.0) % size.height;
      canvas.drawCircle(Offset(x, y), 15, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PressableScale extends StatefulWidget {
  const _PressableScale({
    required this.child,
    required this.onTap,
    required this.borderRadius,
  });

  final Widget child;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  var _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: widget.borderRadius,
          splashColor: AppColors.primary.withOpacity(0.18),
          highlightColor: AppColors.primary.withOpacity(0.08),
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapCancel: () => setState(() => _isPressed = false),
          onTapUp: (_) => setState(() => _isPressed = false),
          child: widget.child,
        ),
      ),
    );
  }
}
