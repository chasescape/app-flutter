import 'package:flira/flira/app/data/coins_data.dart';
import 'package:flira/flira/app/modules/coins/coins_logic.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CoinsPage extends StatelessWidget {
  CoinsPage({Key? key}) : super(key: key);

  final CoinsLogic logic = Get.put(CoinsLogic());

  List<CoinPackageData> get _packages => logic.packages;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: Stack(
          children: <Widget>[
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[Color(0xFFFFF0F5), Color(0xFFF2F5FF)],
                ),
              ),
              child: SafeArea(
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
                        child: Row(
                          children: <Widget>[
                            _RoundBackButton(onTap: () => Get.back()),
                            const Expanded(
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.only(right: 44),
                                  child: Text(
                                    'Coin Top Up',
                                    style: TextStyle(
                                      fontSize: 32 / 1.4,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF272737),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[Color(0xFFFFA5C0), Color(0xFFF07FB0)],
                            ),
                            boxShadow: const <BoxShadow>[
                              BoxShadow(
                                color: Color(0x33F08BAD),
                                blurRadius: 22,
                                offset: Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                'Current balance',
                                style: TextStyle(
                                  color: Color(0xFFFFEFF5),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: <Widget>[
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFFE7F0),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.monetization_on_rounded,
                                      color: Color(0xFFE26690),
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '${logic.balance.value}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 56 / 1.4,
                                      fontWeight: FontWeight.w800,
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Unlock more premium content',
                                style: TextStyle(
                                  color: Color(0xFFFFECF3),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(18, 16, 18, 10),
                        child: Text(
                          'Choose a package',
                          style: TextStyle(
                            fontSize: 36 / 1.4,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF252637),
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(18, 4, 18, 22),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            final item = _packages[index];
                            final displayPrice = '\$${item.price.toStringAsFixed(2)}';

                            return _PackageCard(
                              item: item,
                              displayPrice: displayPrice,
                              onTap: () async {
                                await logic.buy(item);
                                if (!context.mounted) return;
                                Get.snackbar(
                                  'Purchase Requested',
                                  '${item.coins} coins package selected',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: const Color(0xFFFFF3F8),
                                  colorText: const Color(0xFF5C4B58),
                                  margin: const EdgeInsets.all(12),
                                  borderRadius: 14,
                                  duration: const Duration(milliseconds: 1200),
                                );
                              },
                            );
                          },
                          childCount: _packages.length,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (logic.isPurchasing.value || logic.isLoading.value)
              Positioned.fill(
                child: AbsorbPointer(
                  absorbing: true,
                  child: Container(
                    color: const Color(0x66000000),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          CircularProgressIndicator(),
                          SizedBox(height: 12),
                          Text(
                            'Processing payment...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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

class _RoundBackButton extends StatelessWidget {
  const _RoundBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF303244)),
        ),
      ),
    );
  }
}

class _PackageCard extends StatefulWidget {
  const _PackageCard({required this.item, required this.displayPrice, required this.onTap});

  final CoinPackageData item;
  final String displayPrice;
  final VoidCallback onTap;

  @override
  State<_PackageCard> createState() => _PackageCardState();
}

class _PackageCardState extends State<_PackageCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(22),
          splashColor: const Color(0x1AF090B2),
          highlightColor: const Color(0x12F090B2),
          onHighlightChanged: (bool pressed) {
            if (!mounted) return;
            setState(() => _isPressed = pressed);
          },
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFF3E1EA)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[Color(0xFFFFE7F0), Color(0xFFFFD6E6)],
                        ),
                      ),
                      child: const Icon(Icons.star_rounded, size: 18, color: Color(0xFFE07398)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.displayPrice,
                        style: const TextStyle(
                          fontSize: 24 / 1.4,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF262739),
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.item.isPromo)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: <Widget>[
                        if (widget.item.gpTemplatePrice != null)
                          Text(
                            '\$${widget.item.gpTemplatePrice!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFAD93A0),
                              decoration: TextDecoration.lineThrough,
                              decorationThickness: 2,
                            ),
                          ),
                        if (widget.item.gpTemplatePrice != null) const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE9EF),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0xFFFFB5C8)),
                          ),
                          child: const Text(
                            'SPECIAL',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFE85A82),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                Text(
                  '${widget.item.coins} coins',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF7C7E90),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
