import 'package:flutter/material.dart';
import 'package:cliss/cliss/app/theme/app_theme.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final bool isOutlined;
  final double? width;
  final double? height;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.isOutlined = false,
    this.width,
    this.height,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = AppTextStyles.label.copyWith(
      color: isOutlined
          ? AppColors.primaryMain
          : isSecondary
              ? AppColors.primaryMain
              : AppColors.textInverse,
    );

    final row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOutlined || isSecondary
                    ? AppColors.primaryMain
                    : AppColors.textInverse,
              ),
            ),
          )
        else if (icon != null) ...[
          Icon(
            icon,
            size: 18,
            color: textStyle.color,
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(text, style: textStyle),
      ],
    );

    final child = SizedBox(
      width: width,
      height: height ?? 56,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              child: row,
            )
          : DecoratedBox(
              decoration: BoxDecoration(
                gradient: isSecondary ? null : AppGradients.buttonGradient,
                color: isSecondary ? AppColors.surfaceGlass : null,
                borderRadius: AppBorderRadius.allLarge,
                border: isSecondary ? Border.all(color: AppColors.borderSoft) : null,
                boxShadow: isSecondary ? AppShadows.sm : AppShadows.md,
              ),
              child: ElevatedButton(
                onPressed: isLoading ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.transparent,
                ),
                child: row,
              ),
            ),
    );

    return child;
  }
}

class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;

  const AppTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: color ?? AppColors.primaryMain,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
