import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mische/gen_a/A.dart';

import '../../data/coins_data.dart';
import '../../widgets/mische_background.dart';
import 'coins_logic.dart';

class CoinsPage extends StatelessWidget {
  CoinsPage({Key? key}) : super(key: key);

  final CoinsLogic logic = Get.put(CoinsLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E12),
      body: Stack(
        children: [
          MischeBackground(
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBalanceCard(),
                          const SizedBox(height: 24),
                          const Text(
                            'Choose a package',
                            style: TextStyle(
                              color: Color(0xFFE1E1E6),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildProductGrid(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Obx(
            () => logic.isLoading.value
                ? Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.45),
                      child: Center(
                        child: Lottie.asset(
                          A.assets_loading_coins,
                          width: 220,
                          height: 220,
                          fit: BoxFit.contain,
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

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A22),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2A2A33)),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const Expanded(
            child: Text(
              'Coin Top Up',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8F3CF0), Color(0xFFE94AA8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8F3CF0).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current balance',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.monetization_on,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${logic.currentBalance.value}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Unlock more premium content',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    final regularProducts = CoinsData.regularProducts;
    final promotionProducts = CoinsData.promotionProducts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.02,
          ),
          itemCount: regularProducts.length,
          itemBuilder: (context, index) {
            return _buildProductCard(regularProducts[index]);
          },
        ),
        if (promotionProducts.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text(
            'Limited Time Offers',
            style: TextStyle(
              color: Color(0xFFE1E1E6),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: promotionProducts.length,
            itemBuilder: (context, index) {
              return _buildProductCard(promotionProducts[index]);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildProductCard(CoinProduct product) {
    final isPromotion = product.type == CoinProductType.promotion;

    return Obx(
      () => GestureDetector(
        onTap: logic.isLoading.value ? null : () => logic.buyProduct(product),
        child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPromotion
                ? [const Color(0xFF1F1F2A), const Color(0xFF2A1F2A)]
                : [const Color(0xFF1A1A22), const Color(0xFF14141C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isPromotion
                ? const Color(0xFFFF7A4B).withOpacity(0.5)
                : const Color(0xFF2A2A33),
            width: isPromotion ? 2 : 1,
          ),
          boxShadow: isPromotion
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF7A4B).withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isPromotion
                          ? [const Color(0xFFFF7A4B), const Color(0xFFFF5B5B)]
                          : [const Color(0xFF8F3CF0), const Color(0xFFE94AA8)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPromotion ? Icons.local_fire_department : Icons.stars,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                if (isPromotion)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF7A4B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'HOT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isPromotion && product.originalPrice != null)
                  Text(
                    '\$${product.originalPrice!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF6D6677),
                      fontSize: 14,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: Color(0xFF6D6677),
                    ),
                  ),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isPromotion ? 28 : 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.coins} coins',
                  style: TextStyle(
                    color: isPromotion
                        ? const Color(0xFFFFB088)
                        : const Color(0xFFB0B0B6),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}
