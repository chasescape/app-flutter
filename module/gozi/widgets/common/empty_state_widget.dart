import 'package:flutter/material.dart';
import 'package:achievenote/gozi/theme/app_theme.dart';
import 'app_button.dart';

/// Empty State Widget - Enhanced with animation and better visual design
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onAction,
    this.iconColor,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon container
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.5 + (0.5 * value),
                child: Opacity(
                  opacity: value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          (iconBackgroundColor ??
                              AppTheme.accentRed.withValues(alpha: 0.1)),
                          (iconBackgroundColor ??
                              AppTheme.accentRed.withValues(alpha: 0.08)),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 64,
                      color: iconColor ?? AppTheme.accentRed,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppTheme.lg),

          // Title with fade-in animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Text(
                  title,
                  style: AppTheme.h3.copyWith(
                    color: AppTheme.textInverse,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
          const SizedBox(height: AppTheme.sm),

          // Subtitle with fade-in animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Text(
                  subtitle,
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),

          // Action button (optional)
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: AppTheme.xl),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: AppButton(
                      text: actionText!,
                      onPressed: onAction,
                      width: 200,
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// Lightweight empty state for inline use
class InlineEmptyState extends StatelessWidget {
  final String message;
  final IconData? icon;

  const InlineEmptyState({
    super.key,
    required this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 48,
                color: AppTheme.textDisabled,
              ),
              const SizedBox(height: AppTheme.md),
            ],
            Text(
              message,
              style: AppTheme.caption.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
