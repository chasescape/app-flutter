import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimiu/mimiu/app/data/coin_products_data.dart';
import 'package:mimiu/mimiu/app/widgets/page_header.dart';
import 'package:mimiu/mimiu/app/widgets/symmetric_gradient_background.dart';

import 'coins_logic.dart';

class CoinsPage extends GetView<CoinsLogic> {
  const CoinsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(child: SymmetricGradientBackground()),
          SafeArea(
            child: Column(
              children: [
                const PageHeader(
                  title: 'Coins',
                  titleSize: 22,
                  titleWeight: FontWeight.w800,
                  useGradientTitle: false,
                  showBack: true,
                  centerTitle: true,
                  padding: EdgeInsets.fromLTRB(16, 6, 16, 10),
                ),
                Expanded(
                  child: Obx(() {
                    final items = controller.products.toList();
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 26),
                      children: [
                        _BalanceCard(balance: controller.balance.value),
                        const SizedBox(height: 14),
                        GridView.builder(
                          itemCount: items.length,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 1.42,
                          ),
                          itemBuilder: (context, index) {
                            final p = items[index];
                            final highlight = p.type == CoinProductType.promo;
                            return _ProductTile(
                              price: controller.displayPrice(p),
                              originalPrice: controller.displayOriginalPrice(p),
                              coins: p.coins,
                              highlight: highlight,
                              promo: p.type == CoinProductType.promo,
                              disabled: controller.purchaseInProgress.value,
                              onTap: () => controller.buy(p),
                            );
                          },
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
          Obx(() {
            if (!controller.purchaseInProgress.value) {
              return const SizedBox.shrink();
            }
            return Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.55),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 46,
                      height: 46,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      controller.purchaseOverlayText.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ProductTile extends StatefulWidget {
  const _ProductTile({
    required this.price,
    required this.originalPrice,
    required this.coins,
    required this.onTap,
    required this.disabled,
    required this.promo,
    this.highlight = false,
  });

  final String price;
  final String? originalPrice;
  final int coins;
  final VoidCallback onTap;
  final bool disabled;
  final bool promo;
  final bool highlight;

  @override
  State<_ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<_ProductTile> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final border = widget.highlight
        ? const Color(0xFFFBBF24).withValues(alpha: 0.45)
        : const Color(0xFF92400E).withValues(alpha: 0.35);
    final interactive = !widget.disabled;
    return GestureDetector(
      onTap: interactive ? widget.onTap : null,
      behavior: HitTestBehavior.opaque,
      onTapDown: interactive ? (_) => _setPressed(true) : null,
      onTapUp: interactive ? (_) => _setPressed(false) : null,
      onTapCancel: interactive ? () => _setPressed(false) : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 140),
        opacity: widget.disabled ? 0.55 : 1,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          scale: _pressed ? 0.98 : 1,
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: _pressed
                        ? const Color(0xFFFBBF24).withValues(alpha: 0.65)
                        : border,
                    width: 2,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey.shade900.withValues(alpha: 0.86),
                      Colors.black.withValues(alpha: 0.92),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF78350F).withValues(
                        alpha: _pressed ? 0.40 : 0.28,
                      ),
                      blurRadius: _pressed ? 44 : 34,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.black.withValues(alpha: 0.18),
                            border: Border.all(
                              color: const Color(0xFF92400E)
                                  .withValues(alpha: 0.40),
                            ),
                          ),
                          child: const Icon(
                            Icons.monetization_on_rounded,
                            color: Color(0xFFFBBF24),
                            size: 20,
                          ),
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (widget.originalPrice != null)
                              Text(
                                widget.originalPrice!,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFFDE68A)
                                      .withValues(alpha: 0.60),
                                  decoration: TextDecoration.lineThrough,
                                  decorationThickness: 2,
                                  height: 1.0,
                                ),
                              ),
                            if (widget.originalPrice != null)
                              const SizedBox(height: 3),
                            Text(
                              widget.price,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFBBF24),
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B)
                                .withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: const Color(0xFFF59E0B)
                                  .withValues(alpha: 0.26),
                            ),
                          ),
                          child: Text(
                            '${widget.coins} coins',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFFDE68A),
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                        if (widget.promo) ...[
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C2D12)
                                  .withValues(alpha: 0.80),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: const Color(0xFFFBBF24)
                                    .withValues(alpha: 0.40),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFBBF24)
                                      .withValues(alpha: 0.20),
                                  blurRadius: 16,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Text(
                              'SALE',
                              style: TextStyle(
                                color: Color(0xFFFFF7ED),
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                                letterSpacing: 0.3,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (_pressed)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        color: const Color(0xFFFBBF24).withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});

  final int balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFFBBF24).withValues(alpha: 0.26),
          width: 2,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade900.withValues(alpha: 0.78),
            Colors.black.withValues(alpha: 0.92),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF78350F).withValues(alpha: 0.28),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFF422006).withValues(alpha: 0.50),
              border: Border.all(
                color: const Color(0xFFFBBF24).withValues(alpha: 0.22),
              ),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Color(0xFFFBBF24),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Balance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Coins available on this device',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$balance',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFFFBBF24),
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
