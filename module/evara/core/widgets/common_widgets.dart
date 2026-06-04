import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'evara_scaffold.dart';

/// Common app widgets for Evara.
class AppWidgets {
  static Widget card({
    required Widget child,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
    Color? backgroundColor,
  }) {
    return EvaraGlassCard(
      onTap: onTap,
      color: backgroundColor,
      padding: padding,
      child: child,
    );
  }

  static Widget gradientButton({
    required String text,
    required VoidCallback? onPressed,
    Gradient? gradient,
    double? width,
    double? height,
    Color? textColor,
    BorderRadius? borderRadius,
  }) {
    final radius =
        borderRadius ?? BorderRadius.circular(AppTheme.radiusFull);
    return Container(
      width: width,
      height: height ?? 54,
      decoration: BoxDecoration(
        gradient: gradient ?? AppTheme.primaryGradient,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryMain.withValues(alpha: 0.32),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: textColor ?? AppTheme.textInverse,
                fontSize: AppTheme.body,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget emptyState({
    required String message,
    String? icon,
    VoidCallback? onAction,
    String? actionText,
  }) {
    return SizedBox(
      width: double.infinity,
      child: EvaraGlassCard(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Text(icon, style: const TextStyle(fontSize: 46)),
              const SizedBox(height: AppTheme.spacingMd),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: AppTheme.body,
                height: 1.5,
              ),
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: AppTheme.spacingLg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAction,
                  child: Text(actionText),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget loading({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppTheme.primaryLight,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: AppTheme.caption,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget error({
    required String message,
    VoidCallback? onRetry,
  }) {
    return EvaraGlassCard(
      padding: const EdgeInsets.all(AppTheme.spacingXl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 52,
            color: AppTheme.error,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: AppTheme.body,
              height: 1.5,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppTheme.spacingLg),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }

  static Widget tag(String text, {Color? color, Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color ?? Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? AppTheme.textPrimary,
          fontSize: AppTheme.caption,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static Widget sectionHeader(
    String title, {
    String? action,
    VoidCallback? onAction,
    Widget? leading,
  }) {
    return Row(
      children: [
        if (leading != null) ...[
          leading,
          const SizedBox(width: AppTheme.spacingSm),
        ],
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: AppTheme.h3,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (action != null && onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(action),
          ),
      ],
    );
  }
}

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusMd),
      ),
    );
  }
}

class AppDivider extends StatelessWidget {
  final double? height;
  final double? indent;
  final double? endIndent;

  const AppDivider({
    super.key,
    this.height,
    this.indent,
    this.endIndent,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height ?? 1,
      indent: indent,
      endIndent: endIndent,
      color: Colors.white.withValues(alpha: 0.08),
    );
  }
}
