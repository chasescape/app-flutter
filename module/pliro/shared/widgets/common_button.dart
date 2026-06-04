import 'package:flutter/material.dart';
import 'package:pliro/pliro/core/theme/app_colors.dart';
import 'package:pliro/pliro/core/theme/app_text_styles.dart';
import 'package:pliro/pliro/core/theme/app_theme.dart';

/// Primary button with the app's pastel glow treatment.
class NeonButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final IconData? icon;

  const NeonButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      height: height ?? 52,
      decoration: BoxDecoration(
        gradient: enabled ? AppColors.primaryGradient : null,
        color: enabled ? null : AppColors.inkMuted.withOpacity(0.20),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: enabled ? AppTheme.glowShadow : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.textInverse),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          color: AppColors.textInverse,
                          size: 20,
                        ),
                        const SizedBox(width: AppTheme.spacingSM),
                      ],
                      Text(
                        text,
                        style: AppTextStyles.button,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Secondary outlined button.
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width,
    this.height,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height ?? 52,
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.70),
        border: Border.all(
          color: AppColors.rose.withOpacity(0.42),
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: AppColors.roseDeep,
                    size: 20,
                  ),
                  const SizedBox(width: AppTheme.spacingSM),
                ],
                Text(
                  text,
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.roseDeep,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
