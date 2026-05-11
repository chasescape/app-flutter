import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yapo/yapo/app/routes/app_pages.dart';
import 'history_logic.dart';
import 'widgets/glass_history_card.dart';

// ✅ 性能优化：使用 GetView 替代 StatelessWidget + Get.put，避免重复创建 Controller
class HistoryPage extends GetView<HistoryLogic> {
  const HistoryPage({super.key});

  // ✅ 性能优化：静态渐变配置，避免每次 build 重新创建 Shader
  static const _pinkPurpleGradient = LinearGradient(
    colors: [Color(0xFFf472b6), Color(0xFFa855f7)],
  );
  static const _pinkPurpleLightGradient = LinearGradient(
    colors: [Color(0xFFf9a8d4), Color(0xFFd8b4fe)],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a0b2e),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0x801a0b2e), // 0.5 alpha 预计算
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x807c2d9e), // 0.5 alpha 预计算
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              title: RepaintBoundary(
                child: ShaderMask(
                  shaderCallback: (bounds) =>
                      _pinkPurpleGradient.createShader(bounds),
                  child: const Text(
                    'History',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ✅ 性能优化：RepaintBoundary 隔离 ShaderMask 重绘
                  RepaintBoundary(
                    child: ShaderMask(
                      shaderCallback: (bounds) =>
                          _pinkPurpleLightGradient.createShader(bounds),
                      child: const Text(
                        'Recent',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // ✅ 性能优化：缩小 Obx 范围，只监听列表长度变化
                  Obx(() => controller.historyPhotos.isNotEmpty
                      ? InkWell(
                          onTap: () => _showClearAllDialog(),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: const Color(0x26ef4444), // 0.15 alpha 预计算
                              border: Border.all(
                                color: const Color(0x4Def4444), // 0.3 alpha 预计算
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.delete_sweep_rounded,
                                  size: 16,
                                  color: Color(0xFFef4444),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Clear',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFef4444),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink()),
                ],
              ),
            ),
          ),
          Obx(() => _buildHistoryPreviewSliver(controller.historyPhotos)),
          Obx(() => controller.historyPhotos.isEmpty
              ? const SliverToBoxAdapter(child: GlassHistoryCard())
              : const SliverToBoxAdapter(child: SizedBox(height: 24))),
        ],
      ),
    );
  }

  Widget _buildHistoryPreviewSliver(List<Map<String, dynamic>> photos) {
    if (photos.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => RepaintBoundary(
            child: _buildHistoryThumb(photos[index]),
          ),
          childCount: photos.length,
        ),
      ),
    );
  }

  Widget _buildHistoryThumb(Map<String, dynamic> photo) {
    final image = photo['image'] as String?;
    final title = photo['title'] as String? ?? '';
    final location = photo['location'] as String? ?? '';
    final isAsset = image != null && !image.startsWith('http');
    final isGenerated = photo['isGenerated'] == true;

    const overlayGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        Color(0xB3000000), // 0.7 alpha 预计算
      ],
    );
    const aiBadgeShadowColor = Color(0x66f472b6); // 0.4 alpha 预计算
    const cardShadowColor = Color(0x26f472b6); // 0.15 alpha 预计算

    return GestureDetector(
      onTap: () => Get.toNamed(Routes.details, arguments: photo['id']),
      onLongPress: () {
        // 长按删除生成的照片
        if (isGenerated) {
          _showDeleteDialog(photo);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: cardShadowColor,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (image != null)
                RepaintBoundary(
                  child: isAsset
                      ? Image.asset(
                          image,
                          fit: BoxFit.cover,
                          cacheWidth: 600, // 限制缓存宽度，减少内存占用
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
                        )
                      : Image.file(
                          File(image),
                          fit: BoxFit.cover,
                          cacheWidth: 600, // 限制缓存宽度，减少内存占用
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
              Container(
                decoration: const BoxDecoration(
                  gradient: overlayGradient,
                ),
              ),
              // AI 生成标记
              if (isGenerated)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFf472b6), Color(0xFFa855f7)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: aiBadgeShadowColor,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, size: 12, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'AI',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      location,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xD9FFFFFF), // 0.85 alpha 预计算
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> photo) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1a0b2e),
                Color(0xFF2d1b4e),
              ],
            ),
            border: Border.all(
              color: const Color(0x4Dec4899), // 0.3 alpha 预计算
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFef4444), Color(0xFFdc2626)],
                  ),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Delete Photo?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This will permanently delete "${photo['title']}" from your history.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xCCd8b4fe), // 0.8 alpha 预计算
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color:
                              const Color(0xFFec4899).withValues(alpha: 0.15),
                          border: Border.all(
                            color:
                                const Color(0xFFec4899).withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        controller.deletePhoto(photo['id']);
                        Get.back();
                        Get.snackbar(
                          'Deleted',
                          'Photo has been removed from history',
                          backgroundColor: const Color(0xFFef4444),
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFef4444), Color(0xFFdc2626)],
                          ),
                        ),
                        child: const Text(
                          'Delete',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
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

  void _showClearAllDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1a0b2e),
                Color(0xFF2d1b4e),
              ],
            ),
            border: Border.all(
              color: const Color(0x66ef4444), // 0.4 alpha 预计算
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFef4444), Color(0xFFdc2626)],
                  ),
                ),
                child: const Icon(
                  Icons.delete_sweep_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Clear All History?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Obx(() => Text(
                    'This will permanently delete all ${controller.historyPhotos.length} photos from your history.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xCCd8b4fe), // 0.8 alpha 预计算
                      height: 1.5,
                    ),
                  )),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color:
                              const Color(0xFFec4899).withValues(alpha: 0.15),
                          border: Border.all(
                            color:
                                const Color(0xFFec4899).withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        controller.clearAllHistory();
                        Get.back();
                        Get.snackbar(
                          'Cleared',
                          'All history has been removed',
                          backgroundColor: const Color(0xFFef4444),
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFef4444), Color(0xFFdc2626)],
                          ),
                        ),
                        child: const Text(
                          'Clear All',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
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
}
