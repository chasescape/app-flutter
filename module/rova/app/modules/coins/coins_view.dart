import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rova/rova/app/widgets/glass_card.dart';
import 'package:rova/rova/app/widgets/rova_background.dart';

import 'coins_logic.dart';

class CoinsPage extends StatelessWidget {
  const CoinsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CoinsLogic logic = Get.find<CoinsLogic>();
    const Color pink = Color(0xFFE84B7B);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RovaBackground(
        blurSigma: 4,
        overlayColor: const Color(0x22FFFFFF),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x33FFE7EF),
            Color(0x22FFFFFF),
          ],
        ),
        child: SafeArea(
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Coins Wallet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 44),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            blurRadius: 22,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Stack(
                          children: [
                            const Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFFFD45A),
                                      Color(0xFFFFB128),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const Positioned.fill(
                              child: IgnorePointer(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0x33FFFFFF),
                                        Color(0x00FFFFFF),
                                        Color(0x11FFFFFF),
                                      ],
                                      stops: [0.0, 0.55, 1.0],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.28),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.stars_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Coins Wallet',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${logic.balance.value}',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          'Available coins',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black
                                                .withValues(alpha: 0.65),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(alpha: 0.30),
                                            borderRadius:
                                                BorderRadius.circular(999),
                                          ),
                                          child: const Text(
                                            'Tap to recharge',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 14),
                  const Text(
                    'Top up',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: logic.packs.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.12,
                    ),
                    itemBuilder: (context, index) {
                      return _PackGridTile(
                        pack: logic.packs[index],
                        accentColor: pink,
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
              Obx(() {
                final blocking =
                    logic.isLoading.value || logic.isPurchasing.value;
                if (!blocking) return const SizedBox.shrink();
                return Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.08),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _PackGridTile extends StatelessWidget {
  const _PackGridTile({
    required this.pack,
    required this.accentColor,
  });

  final CoinPack pack;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final CoinsLogic logic = Get.find<CoinsLogic>();

    return GlassCard(
      borderRadius: 18,
      blurSigma: 14,
      backgroundColor: const Color(0xD9FFFFFF),
      borderColor: const Color(0x44FFFFFF),
      highlight: false,
      padding: const EdgeInsets.all(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          await logic.buy(pack);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.local_fire_department_rounded,
                    color: accentColor,
                    size: 18,
                  ),
                ),
                const Spacer(),
                if (pack.badge != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      pack.badge!,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${pack.coins} coins',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            if (pack.originalPriceLabel != null &&
                pack.originalPriceLabel != pack.priceLabel) ...[
              Text(
                pack.originalPriceLabel!,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.black.withValues(alpha: 0.45),
                  decoration: TextDecoration.lineThrough,
                  decorationThickness: 2,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              pack.priceLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// (intentionally no diffuse blob on the coins card; keep it a clean gold card)
