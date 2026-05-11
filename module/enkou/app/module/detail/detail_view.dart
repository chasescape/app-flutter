import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:enkou/gen_a/A.dart';
import 'detail_logic.dart';

class DetailPage extends GetView<DetailLogic> {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bgImage = _pickBackgroundImage(controller.medias);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 背景图片
          _buildBackgroundImage(bgImage),

          // 顶部渐变
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 底部渐变
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 400,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.95),
                  ],
                ),
              ),
            ),
          ),

          // 顶部按钮
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTopButton(Icons.arrow_back_ios_new, () => Get.back()),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (controller.canEdit)
                          _buildTopButton(
                            Icons.edit_outlined,
                            () => controller.openEditJournal(),
                          ),
                        if (controller.canEdit) const SizedBox(width: 12),
                        _buildTopButton(Icons.share_outlined, _handleShare),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 底部信息卡片
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题
                    Text(
                      controller.subtitle.isEmpty
                          ? 'Travel Journal'
                          : controller.subtitle,
                      style: const TextStyle(
                        fontSize: 36,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 日期 + 地点信息（替换原评分）
                    Row(
                      children: [
                        Text(
                          controller.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        if (controller.subtitle.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Color(0xCCFFFFFF),
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              controller.subtitle,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xCCFFFFFF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 描述（不折叠）
                    Text(
                      controller.body.isEmpty
                          ? 'No description available.'
                          : controller.body,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Color(0xE6FFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage(String src) {
    final isAsset = src.startsWith('assets/');

    if (isAsset) {
      return Image.asset(
        src,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0xFF2C2C3E),
          child: const Center(
            child: Icon(Icons.landscape, size: 80, color: Colors.white24),
          ),
        ),
      );
    } else {
      return Image.file(
        File(src),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0xFF2C2C3E),
          child: const Center(
            child: Icon(Icons.landscape, size: 80, color: Colors.white24),
          ),
        ),
      );
    }
  }

  Widget _buildTopButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  String _pickBackgroundImage(List<Map<String, String>> medias) {
    final images = medias
        .where((m) => (m['type'] ?? '').toLowerCase() == 'image')
        .toList();
    if (images.isEmpty) return A.assets_enkou_03;
    return images.last['source'] ?? A.assets_enkou_03;
  }

  void _handleShare() {
    print('Share button clicked'); // 调试信息
    
    final title = controller.subtitle.isEmpty
        ? 'Travel Journal'
        : controller.subtitle;
    final date = controller.title;
    final location = controller.subtitle.isNotEmpty
        ? '\n📍 ${controller.subtitle}'
        : '';
    final content = controller.body.isEmpty
        ? 'No description available.'
        : controller.body;

    final shareText = '$title\n$date$location\n\n$content';
    
    print('Sharing text: $shareText'); // 调试信息

    try {
      Share.share(
        shareText,
        subject: title,
      );
    } catch (e) {
      print('Share error: $e'); // 错误信息
      Get.snackbar(
        '分享失败',
        '无法打开分享面板: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _showFullDescription(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Color(0xFF1F1F33),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.subtitle.isEmpty
                          ? 'Travel Journal'
                          : controller.subtitle,
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      controller.body,
                      style: const TextStyle(
                          fontSize: 16, height: 1.6, color: Color(0xE6FFFFFF)),
                    ),
                    const SizedBox(height: 24),
                    if (controller.medias.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.medias
                            .map((m) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8E44FF),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    '${m['type'] ?? ''}: ${m['label'] ?? ''}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                ))
                            .toList(),
                      ),
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

class _InfoColumn extends StatelessWidget {
  const _InfoColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                color: Color(0xB3FFFFFF),
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
      ],
    );
  }
}
