import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tanie/tanie/theme/app_border_radius.dart';
import 'package:tanie/tanie/theme/app_colors.dart';
import 'package:tanie/tanie/theme/app_text_styles.dart';
import 'package:tanie/tanie/widgets/app_button.dart';
import 'package:tanie/tanie/widgets/app_ui.dart';

class AppLoading extends StatelessWidget {
  final String? message;
  final bool isFullScreen;

  const AppLoading({
    super.key,
    this.message,
    this.isFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppBorderRadius.huge),
            border: Border.all(color: AppColors.cardBorder),
          ),
          alignment: Alignment.center,
          child: const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.secondaryMain),
            ),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(message!, style: AppTextStyles.bodyMedium),
        ],
      ],
    );

    if (!isFullScreen) {
      return Center(child: content);
    }

    return Scaffold(
      body: AppBackdrop(
        child: Center(child: content),
      ),
    );
  }
}

class AppLottieLoading extends StatelessWidget {
  final String? message;
  final bool isFullScreen;

  const AppLottieLoading({
    super.key,
    this.message,
    this.isFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Lottie.asset(
            'assets/lottie/loading.json',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const AppLoading();
            },
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 12),
          Text(message!, style: AppTextStyles.bodyMedium),
        ],
      ],
    );

    if (!isFullScreen) {
      return Center(child: content);
    }

    return Scaffold(
      body: AppBackdrop(
        child: Center(child: content),
      ),
    );
  }
}

class AppLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const AppLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: AbsorbPointer(
              child: Container(
                color: AppColors.white.withValues(alpha: 0.84),
                alignment: Alignment.center,
                child: AppLoading(message: message),
              ),
            ),
          ),
      ],
    );
  }
}

class AppEmptyState extends StatelessWidget {
  final String message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(30),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon ?? Icons.photo_library_outlined,
                size: 40,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.h3,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              SizedBox(
                width: 220,
                child: AppPrimaryButton(
                  text: actionLabel!,
                  onPressed: onAction,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      message: message,
      icon: Icons.error_outline,
      actionLabel: onRetry == null ? null : 'Retry',
      onAction: onRetry,
    );
  }
}
