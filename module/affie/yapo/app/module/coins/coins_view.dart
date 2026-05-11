import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:yapo/gen_a/A.dart';
import 'coins_logic.dart';

class CoinsPage extends StatelessWidget {
  const CoinsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<CoinsLogic>(tag: 'coins_page');

    return Scaffold(
      backgroundColor: const Color(0xFF1a0b2e),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: const Color(0xFF1a0b2e).withValues(alpha: 0.8),
                leadingWidth: 72,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: ClipOval(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Get.back(),
                        child: Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                const Color(0xFF1a0b2e).withValues(alpha: 0.7),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                            // ✅ 添加阴影增强视觉层次
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFFf9a8d4),
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF7c2d9e).withValues(alpha: 0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                title: const Text(
                  'Coins',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFf472b6),
                  ),
                ),
                centerTitle: true,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBalanceCard(logic),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Recharge Packages'),
                      const SizedBox(height: 16),
                      _buildPackages(logic),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Obx(() {
            final isPurchasing = logic.isPurchasing.value;
            if (!isPurchasing) {
              return const SizedBox.shrink();
            }
            return Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.4),
                child: Center(
                  child: Lottie.asset(
                    A.assets_loading_loading,
                    width: 140,
                    height: 140,
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(CoinsLogic logic) {
    const double cardRadius = 28;
    const double borderWidth = 2;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFfbbf24).withValues(alpha: 0.35),
            blurRadius: 28,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFFf97316).withValues(alpha: 0.2),
            blurRadius: 48,
            spreadRadius: -6,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(cardRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFfbbf24).withValues(alpha: 0.5),
              const Color(0xFFf97316).withValues(alpha: 0.4),
              const Color(0xFFfbbf24).withValues(alpha: 0.35),
            ],
          ),
        ),
        padding: const EdgeInsets.all(borderWidth),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24 - borderWidth),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(cardRadius - borderWidth),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFfbbf24).withValues(alpha: 0.15),
                const Color(0xFFf97316).withValues(alpha: 0.12),
                const Color(0xFF1a0b2e).withValues(alpha: 0.85),
                const Color(0xFFfbbf24).withValues(alpha: 0.05),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(
                Icons.monetization_on,
                color: Color(0xFFfbbf24),
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'Current Balance',
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFFfde68a).withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 4),
              Obx(() =>
                  Text(
                    '${logic.userCoins.value}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFfde68a),
                    ),
                  )),
              const SizedBox(height: 4),
              Text(
                'coins',
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFFfde68a).withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFFf9a8d4), // 使用渐变的主色调
      ),
    );
  }

  Widget _buildPackages(CoinsLogic logic) {
    return Obx(() {
      final isLoading = logic.isLoading.value;
      final isLoadingCoins = logic.isLoadingCoins.value;
      final packages = logic.packages;

      // ✅ 如果正在加载金币或商品列表且没有数据，显示骨架屏
      if ((isLoadingCoins || isLoading) && packages.isEmpty) {
        return _buildSkeletonCards();
      }

      // 如果有数据，显示卡片并添加动画
      return GetBuilder<CoinsLogic>(
        id: 'packages_list',
        tag: 'coins_page',
        builder: (logic) {
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: packages
                .asMap()
                .entries
                .map((entry) {
              final index = entry.key;
              final p = entry.value;
              final coins = p['coins'] as int;
              final price = p['price'] as String;
              final originalPrice = p['originalPrice'] as String;
              final discount = p['discount'] as String;
              final goodsCode = p['goodsCode'] as String? ?? 'coin_$coins';
              final hasDiscount = discount.isNotEmpty;

              return TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + (index * 50)),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Obx(() {
                  final isPurchasing = logic.isPurchasing.value;
                  final isAnyPurchasing = isPurchasing; // 检查是否有任何购买正在进行

                  return SizedBox(
                    width: (MediaQuery
                        .of(Get.context!)
                        .size
                        .width - 48 - 16) / 2,
                    child: InkWell(
                      onTap: isAnyPurchasing ? null : () =>
                          logic.onRecharge(coins, goodsCode),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0x14ec4899),
                              Color(0x0Fa855f7),
                            ],
                          ),
                          border: Border.all(
                            color: const Color(0x40ec4899),
                            width: 1.5,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // 购买加载遮罩（由全屏 Lottie 负责 loading 动画，这里只保留半透明遮罩）
                            if (isAnyPurchasing)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.black.withValues(alpha: 0.3),
                                  ),
                                ),
                              ),
                            if (hasDiscount)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFef4444),
                                        Color(0xFFdc2626)
                                      ],
                                    ),
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(18),
                                      bottomLeft: Radius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    discount,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0x66fbbf24),
                                          Color(0x4Df97316),
                                        ],
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.monetization_on_rounded,
                                      color: Color(0xFFfbbf24),
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '$coins',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFfbbf24),
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'coins',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0x99fde68a),
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  if (hasDiscount) ...[
                                    Text(
                                      originalPrice,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0x80d8b4fe),
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor: Color(0x80d8b4fe),
                                        height: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                  ],
                                  Text(
                                    price,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFfbbf24),
                                      height: 1,
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
                }),
              );
            }).toList(),
          );
        },
      );
    });
  }

  /// 构建骨架屏卡片
  Widget _buildSkeletonCards() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: List.generate(6, (index) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 200 + (index * 50)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: child,
            );
          },
          child: SizedBox(
            width: (MediaQuery
                .of(Get.context!)
                .size
                .width - 48 - 16) / 2,
            child: Container(
              height: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0x14ec4899).withValues(alpha: 0.3),
                    const Color(0x0Fa855f7).withValues(alpha: 0.3),
                  ],
                ),
                border: Border.all(
                  color: const Color(0x40ec4899).withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 骨架图标
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 骨架文本
                    Container(
                      width: 60,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 40,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 50,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const Spacer(),
                    // 骨架按钮
                    Container(
                      width: double.infinity,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.1),
                            Colors.white.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
