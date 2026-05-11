import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paech/gen_a/B.dart';
import 'package:rive/rive.dart' show RiveAnimation;

import 'deposit_logic.dart';
import '../generate/generate_logic.dart';

class DepositPage extends StatefulWidget {
  DepositPage({super.key});

  @override
  State<DepositPage> createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> with SingleTickerProviderStateMixin {
  late final DepositLogic logic;
  late final AnimationController _animationController;
  late final Animation<double> _headerBalanceFade;
  late final Animation<Offset> _headerBalanceSlide;
  late final Animation<double> _packGridFade;
  late final Animation<Offset> _packGridSlide;

  @override
  void initState() {
    super.initState();
    logic = Get.put(DepositLogic());
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 850),
      vsync: this,
    );
    _headerBalanceFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _headerBalanceSlide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _packGridFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );
    _packGridSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1EA),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FadeTransition(
                  opacity: _headerBalanceFade,
                  child: SlideTransition(
                    position: _headerBalanceSlide,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                          child: Row(
                            children: [
                              Obx(() => InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: logic.isPurchasing.value ? null : () => Get.back(),
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: logic.isPurchasing.value
                                        ? const Color(0xFF2D2A26).withValues(alpha: 0.4)
                                        : const Color(0xFF2D2A26),
                                  ),
                                ),
                              )),
                              const SizedBox(width: 8),
                              Text(
                                'Coin Store',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2D2A26),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFE8E0D7)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: AbsorbPointer(
                    absorbing: logic.isPurchasing.value,
                    child: Opacity(
                      opacity: logic.isPurchasing.value ? 0.6 : 1.0,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FadeTransition(
                              opacity: _headerBalanceFade,
                              child: SlideTransition(
                                position: _headerBalanceSlide,
                                child: _BalanceCard(theme: theme),
                              ),
                            ),
                            const SizedBox(height: 18),
                            FadeTransition(
                              opacity: _packGridFade,
                              child: SlideTransition(
                                position: _packGridSlide,
                                child: _PackGrid(theme: theme, logic: logic),
                              ),
                            ),
                            const SizedBox(height: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Obx(() => logic.isPurchasing.value
                ? _PaymentOverlay(theme: theme)
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}

/// 支付遮罩：淡入 + 中间白卡缩放 0.9→1
class _PaymentOverlay extends StatefulWidget {
  const _PaymentOverlay({required this.theme});

  final ThemeData theme;

  @override
  State<_PaymentOverlay> createState() => _PaymentOverlayState();
}

class _PaymentOverlayState extends State<_PaymentOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _overlayOpacity;
  late final Animation<double> _cardScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 220),
      vsync: this,
    );
    _overlayOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _cardScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return FadeTransition(
      opacity: _overlayOpacity,
      child: Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: Center(
          child: ScaleTransition(
            scale: _cardScale,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFC8A57E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Processing Payment...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D2A26),
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
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFD8B792),
            Color(0xFFC8A57E),
          ],
        ),
      ),
      child: Stack(
        children: [
          // 装饰性半透明圆形
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Rive 甜甜圈动画装饰
          Positioned(
            top: 22,
            left: 15,
            child: SizedBox(
              width: 100,
              height: 100,
              child: RepaintBoundary(
                child: RiveAnimation.asset(
                  B.assets_rive_donuts,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Current Credits',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(() {
                  String creditsText = '0 Coins';
                  if (Get.isRegistered<GenerateLogic>()) {
                    try {
                      final generateLogic = Get.find<GenerateLogic>();
                      creditsText = '${generateLogic.credits.value} Coins';
                    } catch (_) {
                      creditsText = '0 Coins';
                    }
                  }
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOut,
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.25),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          )),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      creditsText,
                      key: ValueKey<String>(creditsText),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontSize: 26,
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 14),
                Text(
                  'Top up to continue generating AI suggestions.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PackGrid extends StatelessWidget {
  const _PackGrid({required this.theme, required this.logic});

  final ThemeData theme;
  final DepositLogic logic;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Choose a pack',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: const Color(0xFF4A3C2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ScrollablePackList(
            theme: theme,
            packs: logic.packs,
            onSelect: logic.buyPack,
          ),
        ],
      ),
    );
  }
}

class _ScrollablePackList extends StatefulWidget {
  const _ScrollablePackList({
    required this.theme,
    required this.packs,
    required this.onSelect,
  });

  final ThemeData theme;
  final List<DepositPack> packs;
  final ValueChanged<int> onSelect;

  @override
  State<_ScrollablePackList> createState() => _ScrollablePackListState();
}

class _ScrollablePackListState extends State<_ScrollablePackList> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final packs = widget.packs;

    final availableWidth = MediaQuery.of(context).size.width;
    const columns = 2;
    const horizontalPadding = 20.0;
    const containerPadding = 16.0;
    const spacing = 12.0;
    const scrollbarPaddingRight = 6.0;

    final tileWidth = (availableWidth -
            (horizontalPadding * 2) -
            (containerPadding * 2) -
            scrollbarPaddingRight -
            (spacing * (columns - 1))) /
        columns;

    return Stack(
      children: [
        Container(
          constraints: const BoxConstraints(
            minHeight: 140,
            maxHeight: 420,
          ),
          child: SingleChildScrollView(
            controller: _controller,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (var i = 0; i < packs.length; i++)
                    SizedBox(
                      width: tileWidth,
                      child: _PackTile(
                        theme: theme,
                        badge: packs[i].badge ?? 'NORMAL',
                        credits: '${packs[i].exchangeCoin}',
                        price: packs[i].formattedPrice,
                        originalPrice: packs[i].formattedOriginalPrice,
                        isPromo: packs[i].isPromotion,
                        isRecommended: packs[i].isRecommended,
                        onTap: () => widget.onSelect(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0),
                    Colors.white.withValues(alpha: 1),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 2,
          child: IgnorePointer(
            child: Center(
              child: Container(
                width: 46,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E0D7),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PackTile extends StatefulWidget {
  const _PackTile({
    required this.theme,
    required this.badge,
    required this.credits,
    required this.price,
    required this.originalPrice,
    required this.isPromo,
    required this.isRecommended,
    required this.onTap,
    this.onLongPress,
  });

  final ThemeData theme;
  final String badge;
  final String credits;
  final String price;
  final String? originalPrice;
  final bool isPromo;
  final bool isRecommended;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  State<_PackTile> createState() => _PackTileState();
}

class _PackTileState extends State<_PackTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final badge = widget.badge;
    final credits = widget.credits;
    final price = widget.price;
    final originalPrice = widget.originalPrice;
    final isPromo = widget.isPromo;
    final isRecommended = widget.isRecommended;

    final borderColor = isPromo
        ? const Color(0xFFE27D5B)
        : (isRecommended ? const Color(0xFFC8A57E) : const Color(0xFFEFE7DE));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onHighlightChanged: (isHighlighted) {
          if (_pressed == isHighlighted) return;
          setState(() {
            _pressed = isHighlighted;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          scale: _pressed ? 0.98 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 110),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: isPromo ? const Color(0xFFFFF6F2) : const Color(0xFFF7F3EF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: isPromo ? 1.6 : (isRecommended ? 1.4 : 1),
              ),
            ),
            foregroundDecoration: _pressed
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.black.withValues(alpha: 0.04),
                  )
                : null,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isPromo
                            ? const Color(0xFFE27D5B)
                            : (isRecommended
                                ? const Color(0xFFC8A57E)
                                : const Color(0xFFF2EBE3)),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badge,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isPromo || isRecommended
                              ? Colors.white
                              : const Color(0xFF8B7968),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (isRecommended && !isPromo)
                      const Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: Color(0xFFC8A57E),
                      ),
                    if (isPromo)
                      const Icon(
                        Icons.local_fire_department_rounded,
                        size: 18,
                        color: Color(0xFFE27D5B),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '$credits Coins',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2D2A26),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: theme.textTheme.bodySmall?.fontSize != null
                      ? (theme.textTheme.bodySmall!.fontSize! * 1.2)
                      : 14,
                  child: (isPromo && originalPrice != null)
                      ? Text(
                          originalPrice,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFFB8B0A6),
                            decoration: TextDecoration.lineThrough,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                Text(
                  price,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: isPromo
                        ? const Color(0xFFE27D5B)
                        : const Color(0xFF8B7968),
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
