import 'package:flutter/material.dart';

import '../../shared/constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'tavia_ui.dart';

/// Empty state widget
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXl),
        child: TaviaPanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 56,
                color: AppColors.primaryMain,
              ),
              const SizedBox(height: AppConstants.spacingLg),
              Text(
                title,
                style: AppTextStyles.h3,
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppConstants.spacingSm),
                Text(
                  subtitle!,
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
              ],
              if (actionText != null && onAction != null) ...[
                const SizedBox(height: AppConstants.spacingLg),
                TaviaPrimaryButton(
                  label: actionText!,
                  onPressed: onAction,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Error state widget
class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String? message;
  final VoidCallback? onRetry;

  const ErrorStateWidget({
    super.key,
    required this.title,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXl),
        child: TaviaPanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 56,
                color: AppColors.semanticError,
              ),
              const SizedBox(height: AppConstants.spacingLg),
              Text(
                title,
                style: AppTextStyles.h3,
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                const SizedBox(height: AppConstants.spacingSm),
                Text(
                  message!,
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
              ],
              if (onRetry != null) ...[
                const SizedBox(height: AppConstants.spacingLg),
                OutlinedButton(
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

/// Loading card widget
class LoadingCardWidget extends StatelessWidget {
  final double? width;
  final double? height;

  const LoadingCardWidget({
    super.key,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return TaviaPanel(
      child: SizedBox(
        width: width,
        height: height ?? 200,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

/// Shimmer loading widget
class ShimmerLoadingWidget extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerLoadingWidget({
    super.key,
    required this.child,
    this.baseColor = AppColors.textDisabled,
    this.highlightColor = AppColors.textSecondary,
  });

  @override
  State<ShimmerLoadingWidget> createState() => _ShimmerLoadingWidgetState();
}

class _ShimmerLoadingWidgetState extends State<ShimmerLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor.withValues(alpha: 0.5),
                widget.baseColor,
              ],
              stops: [
                _animation.value - 1,
                _animation.value,
                _animation.value + 1,
              ],
              tileMode: TileMode.mirror,
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}
