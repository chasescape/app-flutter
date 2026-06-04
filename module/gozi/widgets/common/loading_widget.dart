import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:achievenote/gozi/theme/app_theme.dart';

/// Loading Widget
class AppLoading extends StatelessWidget {
  final String? message;
  final double? size;

  const AppLoading({
    super.key,
    this.message,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 48,
            height: size ?? 48,
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentRed),
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppTheme.md),
            Text(
              message!,
              style: AppTheme.caption.copyWith(
                color: AppTheme.textInverse,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Full Screen Loading Overlay
class AppLoadingOverlay extends StatelessWidget {
  final String? message;

  const AppLoadingOverlay({
    super.key,
    this.message,
  });

  static void show(
    BuildContext context, {
    String? message,
  }) {
    Get.dialog(
      AppLoadingOverlay(message: message),
      barrierDismissible: false,
    );
  }

  static void hide(BuildContext context) {
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(AppTheme.xl),
          decoration: BoxDecoration(
            gradient: AppTheme.softSurfaceGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            border: Border.all(
                color: AppTheme.primaryWhite.withValues(alpha: 0.72)),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.accentRed,
                  ),
                  strokeWidth: 3,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: AppTheme.md),
                Text(
                  message!,
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.textInverse,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
