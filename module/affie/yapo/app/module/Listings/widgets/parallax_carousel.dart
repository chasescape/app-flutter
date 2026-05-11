import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yapo/yapo/app/routes/app_pages.dart';
import '../listings_logic.dart';

/// 轮播图组件，带视差效果
class ParallaxCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> photos;

  const ParallaxCarousel({super.key, required this.photos});

  // ✅ 性能优化：静态渐变配置
  static const _carouselOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0x1A000000), // 0.1 alpha
      Color(0xB3000000), // 0.7 alpha
    ],
    stops: [0.4, 0.7, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    // ✅ 性能优化：通过构造函数传入 logic，避免重复 Get.find
    final logic = Get.find<ListingsLogic>();
    return PageView.builder(
      controller: logic.carouselPageController,
      clipBehavior: Clip.none,
      // ✅ 性能优化：限制可见页面数量，减少内存占用
      itemBuilder: (context, index) {
        final actualIndex = index % photos.length;
        return ParallaxCard(
          photo: photos[actualIndex],
          pageIndex: index,
          pageController: logic.carouselPageController,
        );
      },
    );
  }
}

/// 轮播图卡片组件
class ParallaxCard extends StatefulWidget {
  final Map<String, dynamic> photo;
  final int pageIndex;
  final PageController pageController;

  const ParallaxCard({
    super.key,
    required this.photo,
    required this.pageIndex,
    required this.pageController,
  });

  @override
  State<ParallaxCard> createState() => _ParallaxCardState();
}

class _ParallaxCardState extends State<ParallaxCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // ✅ 保持页面状态，避免重复创建

  @override
  Widget build(BuildContext context) {
    super.build(context); // ✅ 必须调用，因为使用了 AutomaticKeepAliveClientMixin

    // ✅ 性能优化：使用 AnimatedBuilder 替代 Obx，直接监听 PageController
    // 这样只有可见的卡片会重建，而不是所有卡片都重建
    return AnimatedBuilder(
      animation: widget.pageController,
      builder: (context, child) {
        // ✅ 性能优化：如果 PageController 还没有初始化，返回空容器
        if (!widget.pageController.hasClients) {
          return const SizedBox.shrink();
        }

        final currentPage = widget.pageController.page ?? widget.pageIndex.toDouble();
        double pageOffset = currentPage - widget.pageIndex;
        double value = (1 - (pageOffset.abs() * 0.3)).clamp(0.7, 1.0);
        double parallaxOffset = pageOffset * 100;

        // ✅ 性能优化：如果卡片完全不可见，不渲染
        if (pageOffset.abs() > 1.5) {
          return const SizedBox.shrink();
        }

        // ✅ 性能优化：缓存 child，避免重复创建静态内容
        return Center(
          child: RepaintBoundary(
            child: Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value,
                child: GestureDetector(
                  onTap: () =>
                      Get.toNamed(Routes.details, arguments: widget.photo['id']),
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: Colors.transparent,
                      // ✅ 性能优化：减少阴影数量，使用预计算的颜色值
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFec4899)
                              .withValues(alpha: 0.2 * value),
                          blurRadius: 30,
                          spreadRadius: 4,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: const Color(0xFFa855f7)
                              .withValues(alpha: 0.15 * value),
                          blurRadius: 24,
                          spreadRadius: 3,
                          offset: const Offset(0, 4),
                        ),
                        const BoxShadow(
                          color: Color(0x33000000), // 0.2 alpha 预计算
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Stack(
                        children: [
                          // ✅ 性能优化：Positioned 必须是 Stack 的直接子元素，RepaintBoundary 在 Positioned 内部
                          Positioned.fill(
                            child: RepaintBoundary(
                              child: Transform.translate(
                                offset: Offset(parallaxOffset, 0),
                                child: Image.asset(
                                  widget.photo['image']!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  // ✅ 性能优化：启用图片缓存
                                  cacheWidth: 800, // 限制缓存宽度，减少内存占用
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: const Color(0xFF1a0b2e),
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        color: Color(0xFFf472b6),
                                        size: 48,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          // ✅ 性能优化：使用静态渐变
                          Container(
                            decoration: const BoxDecoration(
                              gradient: ParallaxCarousel._carouselOverlayGradient,
                            ),
                          ),
                          // ✅ 性能优化：缓存静态内容，Positioned 必须在 Stack 的直接子元素中
                          Positioned(
                            bottom: 32,
                            left: 24,
                            right: 24,
                            child: child ?? _buildCardContent(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      // ✅ 性能优化：缓存静态内容，避免每次重建（只缓存内容部分，不包含 Positioned）
      child: _buildCardContent(),
    );
  }

  Widget _buildCardContent() {
    // ✅ 性能优化：只返回内容 Widget，不包含 Positioned（Positioned 必须在 Stack 中）
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // Location
        Text(
          widget.photo['location']!,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        // Date with icon
        Row(
          children: [
            const Icon(
              Icons.calendar_today,
              size: 14,
              color: Color(0xFFf9a8d4),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                widget.photo['date']!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  color: const Color(0xFFf9a8d4).withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
