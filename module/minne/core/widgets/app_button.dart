import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_border_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text_styles.dart';

/// App Button - Custom button with gradient support
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isSecondary;
  final bool isExpanded;
  final Widget? icon;
  final double? width;
  final double? height;
  final List<Color>? gradientColors;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isSecondary = false,
    this.isExpanded = false,
    this.icon,
    this.width,
    this.height,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    Widget child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(AppColors.textInverse),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                AppSpacing.gapSM,
              ],
              Text(text),
            ],
          );

    if (isOutlined) {
      return OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          minimumSize: Size(width ?? (isExpanded ? double.infinity : 120), height ?? 48),
          shape: AppBorderRadius.stadiumBorder,
        ),
        child: child,
      );
    }

    if (isSecondary) {
      return ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryMain,
          minimumSize: Size(width ?? (isExpanded ? double.infinity : 120), height ?? 48),
          shape: AppBorderRadius.stadiumBorder,
        ),
        child: child,
      );
    }

    return Container(
      width: width ?? (isExpanded ? double.infinity : null),
      height: height ?? 48,
      decoration: BoxDecoration(
        gradient: enabled
            ? LinearGradient(colors: gradientColors ?? AppColors.primaryGradient)
            : null,
        color: enabled ? null : AppColors.buttonDisabled,
        borderRadius: AppBorderRadius.borderRadiusFull,
        boxShadow: enabled ? AppShadows.buttonShadow : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: AppBorderRadius.borderRadiusFull,
          child: Center(
            child: DefaultTextStyle(
              style: AppTextStyles.buttonStyle,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Icon Button - Circular icon button
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.bgSecondary,
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(size / 2),
          child: Icon(
            icon,
            color: iconColor ?? AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
