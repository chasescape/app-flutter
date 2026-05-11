import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_border_radius.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

/// App Overlay - Toast, Dialog, and Loading using Overlay
class AppOverlay {
  AppOverlay._();

  static OverlayEntry? _toastEntry;
  static OverlayEntry? _loadingEntry;
  static int _loadingCounter = 0;

  // Toast
  static void showToast(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 2),
  }) {
    _toastEntry?.remove();
    _toastEntry = null;

    _toastEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        onDismiss: () {
          _toastEntry?.remove();
          _toastEntry = null;
        },
      ),
    );

    Overlay.of(context).insert(_toastEntry!);
    Future.delayed(duration, () {
      _toastEntry?.remove();
      _toastEntry = null;
    });
  }

  // Loading
  static void showLoading(BuildContext context) {
    if (_loadingCounter > 0) {
      _loadingCounter++;
      return;
    }

    _loadingEntry = OverlayEntry(
      builder: (context) => _LoadingWidget(
        onDismiss: () {
          _loadingEntry?.remove();
          _loadingEntry = null;
          _loadingCounter = 0;
        },
      ),
    );

    Overlay.of(context).insert(_loadingEntry!);
    _loadingCounter = 1;
  }

  static void hideLoading() {
    _loadingCounter--;
    if (_loadingCounter <= 0) {
      _loadingEntry?.remove();
      _loadingEntry = null;
      _loadingCounter = 0;
    }
  }

  // Dialog
  static Future<T?> showDialog<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
  }) async {
    T? result;

    OverlayEntry? entry;

    entry = OverlayEntry(
      builder: (context) => _DialogOverlay(
        barrierDismissible: barrierDismissible,
        child: child,
        onDismiss: () {
          entry?.remove();
        },
        onResult: (r) {
          result = r as T?;
          entry?.remove();
        },
      ),
    );

    Overlay.of(context).insert(entry);
    await Future.delayed(Duration.zero);

    return result;
  }

  // Confirm Dialog
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    bool? result;
    OverlayEntry? entry;

    entry = OverlayEntry(
      builder: (overlayContext) => _DialogOverlay(
        barrierDismissible: true,
        onDismiss: () {
          entry?.remove();
          entry = null;
        },
        onResult: (r) {
          result = r as bool?;
          entry?.remove();
          entry = null;
        },
        child: _ConfirmDialog(
          title: title,
          content: content,
          confirmText: confirmText,
          cancelText: cancelText,
          onCancel: () {
            result = false;
            entry?.remove();
            entry = null;
          },
          onConfirm: () {
            result = true;
            entry?.remove();
            entry = null;
          },
        ),
      ),
    );

    Overlay.of(context).insert(entry!);
    await Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 16));
      return entry != null;
    });
    return result;
  }

  /// Frosted glass confirm sheet that slides up from the bottom.
  /// Use this for destructive or account actions (logout/delete).
  static Future<bool?> showFrostedConfirmSheet({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) {
    return showModalBottomSheet<bool?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.30),
      builder: (sheetContext) {
        final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.78),
                      const Color(0xFFFFF1F6).withValues(alpha: 0.68),
                      const Color(0xFFFFF5DF).withValues(alpha: 0.62),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.70),
                  ),
                  boxShadow: AppShadows.shadowLG,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      AppSpacing.gapLG,
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h3Style.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      AppSpacing.gapSM,
                      Text(
                        content,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySecondaryStyle.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                      AppSpacing.gapLG,
                      Row(
                        children: [
                          Expanded(
                            child: _FrostedSheetButton(
                              text: cancelText,
                              isPrimary: false,
                              onTap: () => Navigator.of(sheetContext).pop(false),
                            ),
                          ),
                          AppSpacing.gapSM,
                          Expanded(
                            child: _FrostedSheetButton(
                              text: confirmText,
                              isPrimary: true,
                              isDestructive: isDestructive,
                              onTap: () => Navigator.of(sheetContext).pop(true),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(sheetContext).padding.bottom),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Frosted glass notice sheet that slides up from the bottom and auto-dismisses.
  static Future<void> showFrostedNoticeSheet(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 2),
  }) async {
    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: false,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.18),
      builder: (sheetContext) {
        // Auto dismiss after duration (only if still open).
        Future.delayed(duration, () {
          if (Navigator.of(sheetContext).canPop()) {
            Navigator.of(sheetContext).pop();
          }
        });

        final Color accent;
        final IconData icon;
        switch (type) {
          case ToastType.success:
            accent = AppColors.success;
            icon = Icons.check_circle;
            break;
          case ToastType.warning:
            accent = AppColors.warning;
            icon = Icons.warning;
            break;
          case ToastType.error:
            accent = AppColors.error;
            icon = Icons.error;
            break;
          case ToastType.info:
          default:
            accent = AppColors.primaryMain;
            icon = Icons.info;
            break;
        }

        return SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.80),
                        const Color(0xFFFFF1F6).withValues(alpha: 0.70),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.70),
                    ),
                    boxShadow: AppShadows.shadowLG,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 18, color: accent),
                      ),
                      AppSpacing.gapMD,
                      Expanded(
                        child: Text(
                          message,
                          style: AppTextStyles.bodyMediumStyle.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      AppSpacing.gapSM,
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        icon: Icon(
                          Icons.close,
                          size: 18,
                          color: AppColors.textSecondary.withValues(alpha: 0.70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

enum ToastType { info, success, warning, error }

class _ToastWidget extends StatelessWidget {
  final String message;
  final ToastType type;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final top = _getTopPosition(screenSize.height);

    return Positioned(
      top: top,
      left: AppSpacing.md,
      right: AppSpacing.md,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: AppSpacing.paddingMD,
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: AppBorderRadius.borderRadiusMD,
            boxShadow: AppShadows.shadowMD,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getIcon(), color: AppColors.textInverse, size: 20),
              AppSpacing.gapSM,
              Flexible(
                child: Text(
                  message,
                  style: AppTextStyles.bodyInverse,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getTopPosition(double screenHeight) {
    switch (type) {
      case ToastType.info:
      case ToastType.success:
      case ToastType.warning:
      case ToastType.error:
      default:
        return screenHeight * 0.75;
    }
  }

  Color _getBackgroundColor() {
    switch (type) {
      case ToastType.success:
        return AppColors.success;
      case ToastType.warning:
        return AppColors.warning;
      case ToastType.error:
        return AppColors.error;
      default:
        return AppColors.textPrimary;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.warning:
        return Icons.warning;
      case ToastType.error:
        return Icons.error;
      default:
        return Icons.info;
    }
  }
}

class _LoadingWidget extends StatelessWidget {
  final VoidCallback onDismiss;

  const _LoadingWidget({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgOverlay,
      child: Center(
        child: Container(
          padding: AppSpacing.paddingXL,
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: AppBorderRadius.borderRadiusLG,
            boxShadow: AppShadows.shadowLG,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.primaryMain),
              ),
              AppSpacing.gapMD,
              Text(
                'Loading...',
                style: AppTextStyles.bodyStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FrostedSheetButton extends StatelessWidget {
  final String text;
  final bool isPrimary;
  final bool isDestructive;
  final VoidCallback onTap;

  const _FrostedSheetButton({
    required this.text,
    required this.isPrimary,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isDestructive ? AppColors.error : AppColors.primaryMain;
    final fg = isPrimary ? AppColors.textInverse : AppColors.textPrimary;
    final bg = isPrimary ? primaryColor : Colors.white.withValues(alpha: 0.65);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppBorderRadius.borderRadiusFull,
        onTap: onTap,
        child: Ink(
          height: 46,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppBorderRadius.borderRadiusFull,
            border: isPrimary
                ? null
                : Border.all(color: Colors.white.withValues(alpha: 0.75)),
            boxShadow: isPrimary ? AppShadows.shadowMD : null,
          ),
          child: Center(
            child: Text(
              text,
              style: AppTextStyles.bodyMediumStyle.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogOverlay extends StatefulWidget {
  final Widget child;
  final bool barrierDismissible;
  final VoidCallback onDismiss;
  final ValueChanged<dynamic> onResult;

  const _DialogOverlay({
    required this.child,
    required this.barrierDismissible,
    required this.onDismiss,
    required this.onResult,
  });

  @override
  State<_DialogOverlay> createState() => _DialogOverlayState();
}

class _DialogOverlayState extends State<_DialogOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: widget.barrierDismissible ? _handleDismiss : null,
        child: Container(
          color: AppColors.bgOverlay,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: GestureDetector(
                  onTap: () {},
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _ConfirmDialog({
    required this.title,
    required this.content,
    required this.confirmText,
    required this.cancelText,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 304,
      padding: AppSpacing.paddingXL,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: AppBorderRadius.borderRadiusLG,
        boxShadow: AppShadows.shadowLG,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTextStyles.h3Style,
          ),
          AppSpacing.gapMD,
          Text(
            content,
            style: AppTextStyles.bodySecondaryStyle,
            textAlign: TextAlign.center,
          ),
          AppSpacing.gapLG,
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  child: Text(
                    cancelText,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ),
              AppSpacing.gapMD,
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  child: Text(
                    confirmText,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
