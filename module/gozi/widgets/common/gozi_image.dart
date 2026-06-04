import 'dart:io';

import 'package:flutter/material.dart';
import 'package:achievenote/gozi/theme/app_theme.dart';

class GoziImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? errorChild;

  const GoziImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorChild,
  });

  @override
  Widget build(BuildContext context) {
    final child = _isFilePath(imagePath)
        ? Image.file(
            File(imagePath),
            width: width,
            height: height,
            fit: fit,
            errorBuilder: _errorBuilder,
          )
        : Image.asset(
            imagePath,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: _errorBuilder,
          );

    if (borderRadius == null) {
      return child;
    }

    return ClipRRect(
      borderRadius: borderRadius!,
      child: child,
    );
  }

  bool _isFilePath(String path) {
    return path.startsWith('/') || path.startsWith('file://');
  }

  Widget _errorBuilder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return errorChild ??
        Container(
          width: width,
          height: height,
          decoration: const BoxDecoration(
            gradient: AppTheme.softSurfaceGradient,
          ),
          child: const Icon(
            Icons.image_not_supported_outlined,
            size: 42,
            color: AppTheme.textDisabled,
          ),
        );
  }
}
