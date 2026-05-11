import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../shared/constants/app_constants.dart';

/// Toast Widget - Overlay-based toast notification
enum ToastPosition { top, center, bottom }
enum ToastType { info, success, warning, error }

class AppToast {
  AppToast._();

  static OverlayEntry? _entry;

  /// Show toast notification
  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    ToastPosition position = ToastPosition.center,
    ToastType type = ToastType.info,
  }) {
    _entry?.remove();

    _entry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        position: position,
        type: type,
        onDismiss: () => _entry?.remove(),
      ),
    );

    Overlay.of(context).insert(_entry!);

    Future.delayed(duration, () {
      _entry?.remove();
      _entry = null;
    });
  }

  /// Dismiss toast
  static void dismiss() {
    _entry?.remove();
    _entry = null;
  }
}

class _ToastWidget extends StatelessWidget {
  final String message;
  final ToastPosition position;
  final ToastType type;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.position,
    required this.type,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _getTopPosition(context),
      left: AppConstants.screenPaddingHorizontal,
      right: AppConstants.screenPaddingHorizontal,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingLg,
            vertical: AppConstants.spacingMd,
          ),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            boxShadow: AppConstants.shadowLg,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getIcon(),
                color: AppColors.white,
                size: AppConstants.iconSizeMd,
              ),
              const SizedBox(width: AppConstants.spacingSm),
              Flexible(
                child: Text(
                  message,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getTopPosition(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    switch (position) {
      case ToastPosition.top:
        return screenHeight * 0.1;
      case ToastPosition.center:
        return screenHeight * 0.5 - 50;
      case ToastPosition.bottom:
        return screenHeight * 0.8;
    }
  }

  Color _getBackgroundColor() {
    switch (type) {
      case ToastType.info:
        return AppColors.textSecondary;
      case ToastType.success:
        return AppColors.semanticSuccess;
      case ToastType.warning:
        return AppColors.semanticWarning;
      case ToastType.error:
        return AppColors.semanticError;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case ToastType.info:
        return Icons.info;
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.warning:
        return Icons.warning;
      case ToastType.error:
        return Icons.error;
    }
  }
}
