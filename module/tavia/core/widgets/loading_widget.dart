import 'package:flutter/material.dart';

import '../../shared/constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Overlay-based loading indicator.
class AppLoading {
  AppLoading._();

  static OverlayEntry? _entry;
  static int _counter = 0;

  static void show(
    BuildContext context, {
    String message = 'Loading...',
  }) {
    if (_counter > 0) {
      _counter++;
      return;
    }

    _entry = OverlayEntry(
      builder: (context) => Container(
        color: AppColors.black.withValues(alpha: 0.5),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spacingXl),
            decoration: BoxDecoration(
              color: AppColors.surfaceStrong,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              boxShadow: AppConstants.shadowLg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primaryMain),
                ),
                const SizedBox(height: AppConstants.spacingMd),
                Text(
                  message,
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_entry!);
    _counter = 1;
  }

  static void dismiss() {
    _counter--;
    if (_counter <= 0) {
      _entry?.remove();
      _entry = null;
      _counter = 0;
    }
  }
}

/// Simple loading indicator widget.
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;

  const LoadingIndicator({
    super.key,
    this.message,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryMain),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              message!,
              style: AppTextStyles.body,
            ),
          ],
        ],
      ),
    );
  }
}
