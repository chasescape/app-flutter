import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riko/riko/app/modules/coins/data/coins_data.dart';
import 'package:riko/riko/app/modules/coins/coins_logic.dart';
import 'package:riko/riko/app/widgets/diffuse_background.dart';

class CoinsPage extends StatelessWidget {
  const CoinsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<CoinsLogic>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Credits'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: DiffuseBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: _CoinGrid(products: coinsData, logic: logic),
              ),
              Obx(
                () => logic.isPurchasing.value
                    ? Container(
                        color: Colors.black.withOpacity(0.2),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFEE7FA0),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoinGrid extends StatelessWidget {
  final List<CoinProductData> products;
  final CoinsLogic logic;

  const _CoinGrid({required this.products, required this.logic});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final item = products[index];
        final originalPrice =
            _OriginalPriceCalculator.originalPrice(item, products);
        return _CoinPack(
          name: item.name,
          description: item.description,
          price: item.price,
          coins: item.coins,
          isPromotion: item.type == '促销',
          originalPrice: originalPrice,
          onTap: () => logic.buy(item),
        );
      },
    );
  }
}

class _OriginalPriceCalculator {
  static double? originalPrice(
    CoinProductData item,
    List<CoinProductData> all,
  ) {
    if (item.type != '促销') return null;
    final regular = all.where((e) => e.type == '常规').toList();
    final exact = regular.firstWhere(
      (e) => e.coins == item.coins,
      orElse: () => CoinProductData(
        code: '',
        name: '',
        description: '',
        price: 0,
        coins: 0,
        type: '',
      ),
    );
    if (exact.coins != 0) {
      return exact.price;
    }
    if (regular.isEmpty) {
      return item.price * 1.5;
    }
    final avgRate =
        regular.map((e) => e.coins / e.price).reduce((a, b) => a + b) /
            regular.length;
    var derived = item.coins / avgRate;
    if (derived <= item.price) {
      derived = item.price * 1.5;
    }
    return double.parse(derived.toStringAsFixed(2));
  }
}

class _CoinPack extends StatelessWidget {
  final String name;
  final String description;
  final double price;
  final int coins;
  final bool isPromotion;
  final double? originalPrice;
  final VoidCallback onTap;

  const _CoinPack({
    required this.name,
    required this.description,
    required this.price,
    required this.coins,
    required this.isPromotion,
    this.originalPrice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _CoinPackIcon(),
                const Spacer(),
                if (isPromotion) const _SaleBadge(),
              ],
            ),
            const SizedBox(height: 6),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.monetization_on,
                  size: 16,
                  color: Color(0xFFEE7FA0),
                ),
                const SizedBox(width: 4),
                Text(
                  coins.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2B2B2B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (isPromotion && originalPrice != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '\$${originalPrice!.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8A8A8A),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
            Text(
              '\$${price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFFEE7FA0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaleBadge extends StatelessWidget {
  const _SaleBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6D8D), Color(0xFFFFB66F)],
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'SALE',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _CoinPackIcon extends StatelessWidget {
  const _CoinPackIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8FD3FF), Color(0xFFFFA7D6)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.monetization_on,
        size: 18,
        color: Colors.white,
      ),
    );
  }
}
