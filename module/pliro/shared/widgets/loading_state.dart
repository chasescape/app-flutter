import 'package:flutter/material.dart';
import 'package:pliro/pliro/core/theme/app_colors.dart';
import 'package:pliro/pliro/core/theme/app_text_styles.dart';
import 'package:pliro/pliro/core/theme/app_theme.dart';
import 'package:pliro/pliro/shared/widgets/common_card.dart';

/// Loading indicator widget.
class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: NeonCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingLG,
          vertical: AppTheme.spacingMD,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
            if (message != null) ...[
              const SizedBox(height: AppTheme.spacingMD),
              Text(
                message!,
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state widget.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  final double? width;
  final EdgeInsetsGeometry? margin;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.width,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: margin ?? const EdgeInsets.all(AppTheme.spacingLG),
        child: NeonCard(
          width: width,
          padding: const EdgeInsets.all(AppTheme.spacingXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.blushMist.withOpacity(0.76),
                ),
                child: Icon(
                  icon,
                  size: 36,
                  color: AppColors.roseDeep,
                ),
              ),
              const SizedBox(height: AppTheme.spacingLG),
              Text(
                title,
                style: AppTextStyles.h3,
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppTheme.spacingSM),
                Text(
                  subtitle!,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (action != null) ...[
                const SizedBox(height: AppTheme.spacingLG),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Error state widget.
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLG),
        child: NeonCard(
          padding: const EdgeInsets.all(AppTheme.spacingXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 56,
                color: AppColors.errorRed,
              ),
              const SizedBox(height: AppTheme.spacingLG),
              Text(
                message,
                style: AppTextStyles.h3,
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: AppTheme.spacingLG),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
