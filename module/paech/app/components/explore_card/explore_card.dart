import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExploreCard extends StatelessWidget {
  const ExploreCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.onLongPress,
    this.height = 336,
    this.imageHeight = 260,
    this.imagePath,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double height;
  final double imageHeight;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap ?? () {},
      onLongPress: onLongPress,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: imageHeight,
              child: Container(
                color: const Color(0xFFE4E0DA),
                child: imagePath != null
                    ? _buildImage(imagePath!)
                    : const Center(
                        child: Icon(
                          Icons.image_outlined,
                          color: Color(0xFFB8B0A6),
                          size: 44,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D2A26),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF8D857C),
                      height: 1.2,
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

  /// 构建图片（支持 asset 和本地文件）
  Widget _buildImage(String path) {
    // 判断是本地文件路径还是 asset 路径
    // Asset 路径通常以 "assets/" 开头
    // 本地文件路径通常是绝对路径（以 "/" 开头）或包含平台路径分隔符
    final isAssetPath = path.startsWith('assets/');
    final isLocalFile = path.startsWith('/') || 
                       (path.contains(Platform.pathSeparator) && !isAssetPath);
    
    if (isLocalFile) {
      // 本地文件路径
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading local image: $path, error: $error');
          return const Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: Color(0xFFB8B0A6),
              size: 44,
            ),
          );
        },
      );
    } else {
      // Asset 路径
      return Image.asset(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading asset image: $path, error: $error');
          return const Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: Color(0xFFB8B0A6),
              size: 44,
            ),
          );
        },
      );
    }
  }
}

class ExploreCardGrid extends StatelessWidget {
  const ExploreCardGrid({
    super.key,
    required this.items,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 12,
    this.mainAxisSpacing = 12,
    this.itemHeight = 336,
    this.onItemTap,
    this.onItemLongPress,
  });

  final List<ExploreCardItem> items;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double itemHeight;
  final Function(int)? onItemTap;
  final Function(int)? onItemLongPress;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        mainAxisExtent: itemHeight,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return ExploreCard(
          title: item.title,
          subtitle: item.subtitle,
          imagePath: item.imagePath,
          onTap: () => onItemTap?.call(index),
          onLongPress: () => onItemLongPress?.call(index),
        );
      },
    );
  }
}

class ExploreCardItem {
  const ExploreCardItem({
    required this.title,
    required this.subtitle,
    this.imagePath,
  });

  final String title;
  final String subtitle;
  final String? imagePath;
}