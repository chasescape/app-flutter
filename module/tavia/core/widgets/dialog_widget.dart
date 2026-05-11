import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../shared/constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'tavia_ui.dart';

/// Common dialog helpers.
class AppDialog {
  AppDialog._();

  static Future<T?> showGlassDialog<T>(
    BuildContext context, {
    required Widget child,
    bool barrierDismissible = true,
    EdgeInsets insetPadding =
        const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: AppColors.black.withValues(alpha: 0.18),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: insetPadding,
        child: _GlassSurface(
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }

  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) {
    return showGlassDialog<bool>(
      context,
      child: _DialogContent(
        icon: Icons.help_outline_rounded,
        iconColor: AppColors.primaryMain,
        title: title,
        message: content,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          SizedBox(
            width: 120,
            child: TaviaPrimaryButton(
              label: confirmText,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showGlassDialog<void>(
      context,
      child: _DialogContent(
        icon: Icons.error_outline_rounded,
        iconColor: AppColors.semanticError,
        title: title,
        message: message,
        actions: [
          SizedBox(
            width: 120,
            child: TaviaPrimaryButton(
              label: 'OK',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> showSuccessDialog(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onConfirm,
  }) {
    return showGlassDialog<void>(
      context,
      child: _DialogContent(
        icon: Icons.check_circle_outline_rounded,
        iconColor: AppColors.semanticSuccess,
        title: title,
        message: message,
        actions: [
          SizedBox(
            width: 120,
            child: TaviaPrimaryButton(
              label: 'OK',
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm?.call();
              },
            ),
          ),
        ],
      ),
    );
  }

  static OverlayEntry? _loadingEntry;
  static OverlayEntry? _toastEntry;
  static Timer? _toastTimer;

  static void showLoadingDialog(
    BuildContext context, {
    String message = 'Loading...',
  }) {
    if (_loadingEntry != null) {
      return;
    }

    _loadingEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: AppColors.black.withValues(alpha: 0.08),
                ),
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260),
                child: _GlassSurface(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingLg,
                    vertical: AppConstants.spacingLg,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: AppConstants.spacingMd),
                      Text(
                        message,
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_loadingEntry!);
  }

  static void hideLoadingDialog() {
    _loadingEntry?.remove();
    _loadingEntry = null;
  }

  static void showToast(
    BuildContext context, {
    required String message,
    IconData icon = Icons.check_circle_outline_rounded,
    Duration duration = const Duration(seconds: 2),
  }) {
    _toastTimer?.cancel();
    _toastEntry?.remove();

    final overlay = Overlay.of(context, rootOverlay: true);

    _toastEntry = OverlayEntry(
      builder: (overlayContext) {
        final bottomInset = MediaQuery.of(overlayContext).padding.bottom;
        return IgnorePointer(
          child: Material(
            color: Colors.transparent,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppConstants.spacingLg,
                  0,
                  AppConstants.spacingLg,
                  AppConstants.spacingLg + bottomInset,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 28, end: 0),
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    builder: (context, offsetY, child) {
                      final progress = 1 - (offsetY / 28).clamp(0.0, 1.0);
                      return Transform.translate(
                        offset: Offset(0, offsetY),
                        child: Opacity(
                          opacity: progress,
                          child: child,
                        ),
                      );
                    },
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: _GlassSurface(
                        borderRadius: BorderRadius.circular(22),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingMd,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: AppColors.primaryMain.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                icon,
                                size: 18,
                                color: AppColors.primaryMain,
                              ),
                            ),
                            const SizedBox(width: AppConstants.spacingSm),
                            Expanded(
                              child: Text(
                                message,
                                style: AppTextStyles.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_toastEntry!);
    _toastTimer = Timer(duration, () {
      _toastEntry?.remove();
      _toastEntry = null;
      _toastTimer = null;
    });
  }

  static Future<T?> showBottomSheet<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: builder,
    );
  }
}

class _GlassSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  const _GlassSurface({
    required this.child,
    required this.padding,
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.78),
            borderRadius: borderRadius,
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.72),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor(AppColors.black, opacity: 0.14),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DialogContent extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final List<Widget> actions;

  const _DialogContent({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.h3,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Text(
          message,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppConstants.spacingLg),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: actions,
        ),
      ],
    );
  }
}
