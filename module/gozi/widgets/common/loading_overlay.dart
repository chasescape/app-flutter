import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:achievenote/gozi/theme/app_theme.dart';

/// Loading Overlay - Shows a loading overlay on top of the screen
class AppLoadingOverlay {
  static bool _isVisible = false;

  /// Show loading overlay
  static void show(BuildContext context) {
    if (_isVisible) return;
    _isVisible = true;

    Get.dialog(
      const _LoadingDialog(),
      barrierDismissible: false,
    );
  }

  /// Hide loading overlay
  static void hide(BuildContext context) {
    if (!_isVisible) return;
    _isVisible = false;
    Get.back();
  }
}

class _LoadingDialog extends StatelessWidget {
  const _LoadingDialog();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.xl),
        decoration: BoxDecoration(
          gradient: AppTheme.softSurfaceGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border:
              Border.all(color: AppTheme.primaryWhite.withValues(alpha: 0.72)),
          boxShadow: AppTheme.cardShadow,
        ),
        child: const CircularProgressIndicator(),
      ),
    );
  }
}
