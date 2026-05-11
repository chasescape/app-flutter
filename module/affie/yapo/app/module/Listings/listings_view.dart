import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yapo/yapo/app/routes/app_pages.dart';
import 'listings_logic.dart';
import 'widgets/parallax_carousel.dart';
import 'widgets/glass_upload_card.dart';

// ✅ 性能优化：使用 GetView 替代 StatelessWidget + Get.put，避免重复创建 Controller
class ListingsPage extends GetView<ListingsLogic> {
  const ListingsPage({super.key});

  // ✅ 性能优化：静态渐变配置，避免每次 build 重新创建 Shader
  static const _pinkPurpleGradient = LinearGradient(
    colors: [Color(0xFFf472b6), Color(0xFFa855f7)],
  );
  static const _pinkPurpleLightGradient = LinearGradient(
    colors: [Color(0xFFf9a8d4), Color(0xFFd8b4fe)],
  );
  static const _pinkPurpleTripleGradient = LinearGradient(
    colors: [
      Color(0xFFf9a8d4),
      Color(0xFFd8b4fe),
      Color(0xFFf9a8d4),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a0b2e),
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            pinned: true,
            expandedHeight: 100,
            backgroundColor: const Color(0xFF1a0b2e).withValues(alpha: 0.5),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF7c2d9e).withValues(alpha: 0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RepaintBoundary(
                    child: ShaderMask(
                      shaderCallback: (bounds) =>
                          _pinkPurpleGradient.createShader(bounds),
                      child: const Text(
                        'Travel Memories',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'Your AI-powered photo album',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFFf472b6).withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildUploadCard(),
                _buildFeaturedSection(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: RepaintBoundary(
                      child: ShaderMask(
                        shaderCallback: (bounds) =>
                            _pinkPurpleLightGradient.createShader(bounds),
                        child: const Text(
                          'All Memories',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: _buildPhotoGrid(),
                ),
                Transform.translate(
                  offset: const Offset(0, -100),
                  child: _buildEditorsPick(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard() {
    return const GlassUploadCard();
  }

  Widget _buildFeaturedSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ✅ 性能优化：RepaintBoundary 隔离重绘
              RepaintBoundary(
                child: ShaderMask(
                  shaderCallback: (bounds) =>
                      _pinkPurpleLightGradient.createShader(bounds),
                  child: const Text(
                    'Featured Moments',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 40),
          child: SizedBox(
            height: 360,
            child: ParallaxCarousel(
              photos: controller.featuredPhotos,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoGrid() {
    // ✅ 性能优化：移除 Obx，因为 mockPhotos 是静态数据，不会变化
    // 如果将来需要动态更新，可以使用 GetBuilder 或只监听特定字段
    final photos = controller.mockPhotos;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: photos.length,
        // ✅ 性能优化：使用 RepaintBoundary 隔离每个卡片的重绘
        itemBuilder: (context, index) {
          final photo = photos[index];
          return RepaintBoundary(
            child: _buildPhotoCard(photo),
          );
        },
      ),
    );
  }

  Widget _buildPhotoCard(Map<String, dynamic> photo) {
    // ✅ 性能优化：静态渐变配置，避免每次 build 重新创建
    const _overlayGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        Color(0xB3000000), // 0.7 alpha 预计算
      ],
    );

    return GestureDetector(
      onTap: () => Get.toNamed(Routes.details, arguments: photo['id']),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // ✅ 性能优化：使用 Image.asset 替代 Container + DecorationImage，更好的缓存
            Image.asset(
              photo['image']!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              // ✅ 性能优化：启用图片缓存和错误处理
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF1a0b2e),
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Color(0xFFf472b6),
                    size: 32,
                  ),
                );
              },
            ),

            // ✅ 性能优化：使用静态渐变
            Container(
              decoration: const BoxDecoration(
                gradient: _overlayGradient,
              ),
            ),

            // Content
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    photo['location']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    photo['date']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFFf9a8d4).withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorsPick() {
    const spotlightOverlayGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        Color(0x4D000000), // 0.3 alpha
        Color(0xE6000000), // 0.9 alpha
      ],
    );

    final spotlight = controller.spotlightPhoto;
    return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // ✅ 性能优化：RepaintBoundary 隔离重绘
                RepaintBoundary(
                  child: ShaderMask(
                    shaderCallback: (bounds) =>
                        _pinkPurpleLightGradient.createShader(bounds),
                    child: const Text(
                      "Editor's Pick",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('✨', style: TextStyle(fontSize: 20)),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () =>
                  Get.toNamed(Routes.details, arguments: spotlight['id']),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(
                  aspectRatio: 0.75,
                  child: Stack(
                    children: [
                      Image.asset(
                        spotlight['image']!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
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

                      Container(
                        decoration: const BoxDecoration(
                          gradient: spotlightOverlayGradient,
                        ),
                      ),

                      // Content
                      Positioned(
                        bottom: 32,
                        left: 32,
                        right: 32,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              spotlight['title']!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              spotlight['story']!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: const Color(0xFFfce7f3)
                                    .withValues(alpha: 0.9),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Text('📍',
                                    style: TextStyle(fontSize: 14)),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    spotlight['location']!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: const Color(0xFFf9a8d4)
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Text('📅',
                                    style: TextStyle(fontSize: 14)),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    spotlight['date']!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: const Color(0xFFf9a8d4)
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      );
  }
}
