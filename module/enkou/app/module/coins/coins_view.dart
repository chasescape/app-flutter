import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:enkou/enkou/app/widget/app_toast.dart';

import 'coins_logic.dart';

/// Lunar Whisper（雾感渐变）配色：与首页/Profile 保持一致
const Color _lunarPink = Color(0xFFEED0F2);
const Color _lunarLavender = Color(0xFF9EBAEB);
const Color _lunarSky = Color(0xFF96DFF5);
const LinearGradient _pageBgGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [_lunarPink, _lunarLavender, _lunarSky],
);

const Color _surface = Color(0xFFFDFBFF); // 柔和卡片底色
const Color _titleColor = Color(0xFF242129);
const Color _mutedColor = Color(0xFF7C7785);
const Color _accent = Color(0xFF8F6AD8);
const Color _accentDeep = Color(0xFF6F4AD0);
const Color _separator = Color(0xFFE6E0EF);

class CoinsPage extends StatelessWidget {
  const CoinsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = MediaQuery.of(context).padding;
    final logic = Get.find<CoinsLogic>();

    return Container(
      decoration: const BoxDecoration(gradient: _pageBgGradient),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            SizedBox(height: padding.top + 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _BackButton(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Coin Top Up',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _titleColor,
                          ) ??
                          const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _titleColor,
                          ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BalanceCard(logic: logic),
                    const SizedBox(height: 24),
                    Text(
                      'Choose a package',
                      style: theme.textTheme.titleSmall?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _titleColor,
                          ) ??
                          const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _titleColor,
                          ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -40),
                      child: _PackageGrid(logic: logic),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.back<void>(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: _separator, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: _titleColor,
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.logic});

  final CoinsLogic logic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: 160,
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_accentDeep, _accent],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current balance',
            style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ) ??
                const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.92),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.45),
                    width: 1,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.monetization_on_rounded,
                    size: 24,
                    color: _accentDeep,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Obx(() {
                return Text(
                  '${logic.balance.value}',
                  style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ) ??
                      const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                );
              }),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Unlock more premium content',
            textAlign: TextAlign.left,
            style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.9),
                ) ??
                const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                ),
          ),
        ],
      ),
    );
  }
}

class _PackageGrid extends StatelessWidget {
  const _PackageGrid({required this.logic});

  final CoinsLogic logic;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = logic.packages;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
        ),
        itemBuilder: (context, index) {
          final item = list[index];
          return _CoinPackageCard(
            package: item,
            onTap: () async {
              if (logic.isProcessing.value) {
                return;
              }
              try {
                await logic.startPurchase(item);
              } catch (_) {
                // 发生异常时不再额外弹出失败提示，交由业务逻辑内部处理
              }
            },
          );
        },
      );
    });
  }
}

class _CoinPackageCard extends StatelessWidget {
  const _CoinPackageCard({
    required this.package,
    required this.onTap,
  });

  final CoinPackageVM package;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: _accent.withOpacity(0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: _separator, width: 1),
        ),
        padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 主体内容
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (package.hasDiscount) const SizedBox(height: 4),
                // 中间：图标和价格
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFEED0F2), Color(0xFF9EBAEB)],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.star_rounded,
                          size: 20,
                          color: Color(0xFF4A2741),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 促销时显示原价删除线 + 现价
                          if (package.originalPrice != null &&
                              package.originalPrice!.isNotEmpty) ...[
                            Text(
                              package.originalPrice!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: _mutedColor,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: _mutedColor,
                                  ) ??
                                  const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: _mutedColor,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: _mutedColor,
                                  ),
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            package.priceLabel,
                            style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: _titleColor,
                                ) ??
                                const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: _titleColor,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 底部：金币数量
                Text(
                  '${package.coins} coins',
                  style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _mutedColor,
                      ) ??
                      const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _mutedColor,
                      ),
                ),
              ],
            ),
            // 顶部：折扣标签（如果有），挂在白色卡片右上角且不遮挡文字
            if (package.hasDiscount)
              Positioned(
                top: -14,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9A8B), Color(0xFFFF6A88)],
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    package.discountLabel!,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            if (package.showSaleBadge)
              Positioned(
                top: -14,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9A8B), Color(0xFFFF6A88)],
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'SALE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      decoration: TextDecoration.none,
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
