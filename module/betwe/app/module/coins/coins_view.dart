import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/coins_data.dart';
import '../../widgets/app_background.dart';
import '../../widgets/app_colors.dart';
import 'coins_logic.dart';

class CoinsPage extends StatelessWidget {
  CoinsPage({super.key});

  final CoinsLogic logic = Get.put(CoinsLogic());

  final List<CoinPackageData> packages = CoinsData.packages;

  List<CoinPackageData> get normalPackages {
    final list = packages.where((p) => !p.isPromo).toList();
    list.sort((a, b) => a.price.compareTo(b.price));
    return list;
  }

  List<CoinPackageData> get promoPackages => packages.where((p) => p.isPromo).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          AppBackground(
            useImageBackground: true,
            safeArea: false,
            padding: EdgeInsets.zero,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Coins',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9AC7), Color(0xFFB67CFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF9AC7).withOpacity(0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current balance',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.attach_money, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Obx(
                                () => Text(
                                  logic.balance.value.toString(),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Unlock more premium content',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Choose a package',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: normalPackages.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.2,
                      ),
                      itemBuilder: (context, index) {
                        final package = normalPackages[index];
                        final displayPrice = '\$${package.price.toStringAsFixed(2)}';
                        return _PackageCard(
                          package: package,
                          priceText: displayPrice,
                          onTap: () => logic.buy(package),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Hot Sale',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: promoPackages.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                      ),
                      itemBuilder: (context, index) {
                        final package = promoPackages[index];
                        final displayPrice = '\$${package.price.toStringAsFixed(2)}';
                        return _PackageCard(
                          package: package,
                          priceText: displayPrice,
                          onTap: () => logic.buy(package),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Obx(
            () => logic.isPurchasing.value
                ? Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.35),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.package,
    required this.priceText,
    required this.onTap,
  });

  final CoinPackageData package;
  final String priceText;
  final VoidCallback onTap;

  double _normalPrice(CoinPackageData promo) {
    final normalPackages = CoinsData.packages.where((p) => !p.isPromo).toList();
    normalPackages.sort((a, b) => a.coins.compareTo(b.coins));

    final CoinPackageData? match = normalPackages
        .cast<CoinPackageData?>()
        .firstWhere((p) => p != null && p.coins >= promo.coins, orElse: () => null);

    if (match == null) {
      return promo.price * 2;
    }

    final double unitPrice = match.price / match.coins;
    return unitPrice * promo.coins;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: package.isPromo
                      ? const Color(0xFFFF9AC7).withOpacity(0.2)
                      : const Color(0xFFB67CFF).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  package.isPromo ? Icons.local_fire_department : Icons.star,
                  color: package.isPromo ? const Color(0xFFFF6B9D) : const Color(0xFFB67CFF),
                  size: 18,
                ),
              ),
              const Spacer(),
              if (!package.isPromo)
                Text(
                  priceText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      priceText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${_normalPrice(package).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 6),
              Text(
                '${package.coins} coins',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
