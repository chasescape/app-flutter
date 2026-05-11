import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vesper/vesper/app/data/coins_data.dart';
import 'package:vesper/vesper/app/data/coins_wallet_store.dart';
import 'package:vesper/vesper/app/widgets/app_background.dart';

import 'coins_logic.dart';

class CoinsPage extends StatelessWidget {
  CoinsPage({super.key});

  final CoinsLogic logic = Get.put(CoinsLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Coins Wallet',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2B1A2B),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2B1A2B)),
      ),
      extendBodyBehindAppBar: true,
      body: AppBackground(
        useImageBackground: true,
        safeArea: false,
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            Positioned(
              top: 140,
              left: -40,
              child: _blurBlob(
                color: const Color(0xFFFF8AC4).withOpacity(0.35),
                size: 180,
              ),
            ),
            Positioned(
              bottom: 200,
              right: -30,
              child: _blurBlob(
                color: const Color(0xFFFFC247).withOpacity(0.25),
                size: 200,
              ),
            ),
            SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 130, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GetBuilder<CoinsWalletStore>(
                      init: Get.isRegistered<CoinsWalletStore>()
                          ? Get.find<CoinsWalletStore>()
                          : Get.put(CoinsWalletStore(), permanent: true),
                      builder: (wallet) {
                        return _coinsWalletCard(wallet.balance);
                      },
                    ),
                    Transform.translate(
                      offset: const Offset(0, -86),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.6,
                        ),
                        itemCount: CoinsData.all().length,
                      itemBuilder: (context, index) {
                        final product = CoinsData.all()[index];
                        return _packageGridCard(
                          product: product,
                          logic: logic,
                        );
                      },
                    ),
                    ),
                  ],
                ),
              ),
            ),

            // Loading 遮罩层
            Obx(() {
              if (!logic.isPurchasing.value) return const SizedBox.shrink();

              return Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _coinsWalletCard(int balance) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFD56A),
            Color(0xFFFFA800),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Coins Wallet',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2B1A2B),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _coinStack(),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    balance.toString(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2B1A2B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Available coins',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6E5B6F),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.35),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Tap to recharge',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2B1A2B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _coinStack() {
    return SizedBox(
      width: 68,
      height: 68,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFFFC247),
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            left: 6,
            bottom: 6,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFFFB21E),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD56A),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Icon(
            Icons.stars_rounded,
            size: 22,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _packageGridCard({
    required CoinsProduct product,
    required CoinsLogic logic,
  }) {
    return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => logic.buy(product),
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFFFD6EA).withOpacity(0.7),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF1F7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: Color(0xFFFF5BAA),
                        size: 18,
                      ),
                    ),
                    const Spacer(),
                    if (product.isPromotion)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE3F0),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Promo',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2B1A2B),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${product.coins} coins',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2B1A2B),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    if (product.isPromotion)
                      Text(
                        '\$${product.originalPrice!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6E5B6F),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    if (product.isPromotion) const SizedBox(width: 6),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2B1A2B),
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

  Widget _blurBlob({required Color color, required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
