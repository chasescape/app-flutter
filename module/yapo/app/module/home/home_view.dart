import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:yapo/yapo/app/routes/app_pages.dart';
import 'home_logic.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<HomeLogic>();

    return Scaffold(
      backgroundColor: const Color(0xFF1a0b2e),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0x337c2d9e), // 0.2 alpha
                  Color(0xFF1a0b2e),
                  Color(0xFF0f172a),
                ],
              ),
            ),
          ),

          // Main content with SliverAppBar
          CustomScrollView(
            slivers: [
              // Animated header
              SliverAppBar(
                pinned: true,
                expandedHeight: 80,
                backgroundColor: const Color(0x801a0b2e), // 0.5 alpha
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x807c2d9e), // 0.5 alpha
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // ✅ 移除 ShaderMask，使用简单颜色
                  title: const Text(
                    'My Travels',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFf472b6),
                    ),
                  ),
                  centerTitle: true,
                ),
              ),

              // Content
              Obx(() => SliverToBoxAdapter(
                    child: logic.expandedIndex.value == null
                        ? _buildStackedCards(logic)
                        : _buildExpandedCard(logic, context),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStackedCards(HomeLogic logic) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: logic.cards.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => logic.expandCard(index),
          child: Container(
            height: 240,
            margin: const EdgeInsets.only(bottom: 20),
            child: _buildCard(logic.cards[index], index),
          ).animate().fadeIn(duration: 400.ms, delay: (index * 80).ms).slideY(
              begin: 0.3,
              end: 0,
              duration: 500.ms,
              delay: (index * 80).ms,
              curve: Curves.easeOutCubic),
        );
      },
    );
  }

  Widget _buildCard(CardData card, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: card.gradient,
        boxShadow: [
          BoxShadow(
            color: (card.gradient.colors.first)
                .withValues(alpha: 0.4),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          const BoxShadow(
            color: Color(0x33000000), // 0.2 alpha
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: _buildCardImage(card.image),
            ),

            // Gradient overlay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x1A000000), // 0.1 alpha
                    Color(0x4D000000), // 0.3 alpha
                    Color(0xCC000000), // 0.8 alpha
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),

            // Decorative circles
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x1AFFFFFF), // 0.1 alpha
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -60,
              child: Container(
                width: 250,
                height: 250,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x14FFFFFF), // 0.08 alpha
                ),
              ),
            ),

            // Content
            Positioned(
              left: 28,
              right: 28,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    card.title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    card.subtitle,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xD9FFFFFF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Top right icon
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0x33FFFFFF), // 0.2 alpha
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0x4DFFFFFF), // 0.3 alpha
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.more_horiz,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedCard(HomeLogic logic, BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 100,
      child: PageView.builder(
        controller: logic.pageController,
        itemCount: logic.cards.length,
        onPageChanged: logic.onPageChanged,
        itemBuilder: (context, index) {
          final card = logic.cards[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Expanded(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onVerticalDragEnd: (details) {
                          if (details.primaryVelocity != null &&
                              details.primaryVelocity! < -280) {
                            logic.hideSwipeHint();
                            Get.toNamed(Routes.details,
                                arguments: card.id ?? card.title);
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 80),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            gradient: card.gradient,
                            boxShadow: [
                              BoxShadow(
                                color: (card.gradient.colors.first)
                                    .withValues(alpha: 0.5),
                                blurRadius: 40,
                                spreadRadius: 5,
                                offset: const Offset(0, 12),
                              ),
                              const BoxShadow(
                                color: Color(0x4D000000), // 0.3 alpha
                                blurRadius: 30,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Stack(
                              children: [
                                // Background image
                                Positioned.fill(
                                  child: _buildCardImage(card.image),
                                ),

                                // Gradient overlay
                                Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0x33000000), // 0.2 alpha
                                        Color(0x66000000), // 0.4 alpha
                                        Color(0xD9000000), // 0.85 alpha
                                      ],
                                      stops: [0.0, 0.6, 1.0],
                                    ),
                                  ),
                                ),

                                // Decorative elements
                                Positioned(
                                  top: -100,
                                  right: -100,
                                  child: Container(
                                    width: 300,
                                    height: 300,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0x14FFFFFF), // 0.08 alpha
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: -120,
                                  left: -80,
                                  child: Container(
                                    width: 350,
                                    height: 350,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0x0FFFFFFF), // 0.06 alpha
                                    ),
                                  ),
                                ),

                                // Content
                                Positioned(
                                  left: 32,
                                  right: 32,
                                  bottom: 40,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        card.title,
                                        style: const TextStyle(
                                          fontSize: 42,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          height: 1.1,
                                          letterSpacing: -1,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        card.subtitle,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Color(0xE6FFFFFF), // 0.9 alpha
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 24,
                                  left: 24,
                                  child: GestureDetector(
                                    onTap: logic.collapseCard,
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                            0x4D000000), // 0.3 alpha
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(
                                              0x33FFFFFF), // 0.2 alpha
                                          width: 1,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_back,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ),
                                // 向上滑动提示 - 显示在卡片底部
                                Obx(() => logic.showSwipeHint.value
                                    ? Positioned(
                                        left: 0,
                                        right: 0,
                                        bottom: 20,
                                        child: IgnorePointer(
                                          child: Center(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 12),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                    0x80000000), // 0.5 alpha
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                                border: Border.all(
                                                  color: const Color(
                                                      0x66f9a8d4), // 0.4 alpha
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.arrow_upward,
                                                    size: 18,
                                                    color: Color(
                                                        0xE6f9a8d4), // 0.9 alpha
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    'Swipe up for details',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Color(
                                                          0xE6f9a8d4), // 0.9 alpha
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                            .animate(
                                                onPlay: (controller) =>
                                                    controller.repeat())
                                            .fadeIn(duration: 1000.ms)
                                            .then()
                                            .fadeOut(duration: 1000.ms),
                                      )
                                    : const SizedBox.shrink()),
                              ],
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .scale(duration: 400.ms, curve: Curves.easeOutCubic)
                          .fadeIn(duration: 300.ms),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardImage(String image) {
    if (image.startsWith('http')) {
      return Image.network(image, fit: BoxFit.cover);
    }
    return Image.asset(image, fit: BoxFit.cover);
  }
}
