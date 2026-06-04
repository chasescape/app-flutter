import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cliss/cliss/app/theme/app_theme.dart';

class AppImageFrame extends StatelessWidget {
  final String imagePath;
  final double? height;
  final double aspectRatio;
  final BorderRadius? borderRadius;
  final Widget? overlay;

  const AppImageFrame({
    super.key,
    required this.imagePath,
    this.height,
    this.aspectRatio = 4 / 5,
    this.borderRadius,
    this.overlay,
  });

  bool get _isAsset => imagePath.startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppBorderRadius.allLarge;
    final image = _isAsset
        ? Image.asset(
            imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: height,
            errorBuilder: (_, __, ___) => _fallback(),
          )
        : Image.file(
            File(imagePath),
            fit: BoxFit.cover,
            width: double.infinity,
            height: height,
            errorBuilder: (_, __, ___) => _fallback(),
          );

    final content = Stack(
      fit: StackFit.expand,
      children: [
        Container(color: AppColors.backgroundTertiary, child: image),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppGradients.imageOverlay,
          ),
        ),
        if (overlay != null) overlay!,
      ],
    );

    final sizedContent = height != null
        ? SizedBox(
            width: double.infinity,
            height: height,
            child: content,
          )
        : AspectRatio(
            aspectRatio: aspectRatio,
            child: content,
          );

    return ClipRRect(
      borderRadius: radius,
      child: sizedContent,
    );
  }

  Widget _fallback() {
    return Container(
      color: AppColors.backgroundTertiary,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_rounded,
        size: 52,
        color: AppColors.textTertiary.withValues(alpha: 0.45),
      ),
    );
  }
}
