import 'package:flutter/material.dart';
import 'package:tanie/tanie/theme/app_border_radius.dart';
import 'package:tanie/tanie/theme/app_colors.dart';
import 'package:tanie/tanie/theme/app_shadows.dart';
import 'package:tanie/tanie/theme/app_spacing.dart';
import 'package:tanie/tanie/theme/app_text_styles.dart';

class AppPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;

  const AppPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = isEnabled && !isLoading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: isActive ? AppColors.buttonPrimary : AppColors.buttonDisabled,
        borderRadius: BorderRadius.circular(AppBorderRadius.full),
        border: Border.all(
          color: isActive ? AppColors.secondaryMain : AppColors.cardBorder,
          width: 2,
        ),
        boxShadow: isActive ? AppShadows.button : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isActive ? onPressed : null,
          borderRadius: BorderRadius.circular(AppBorderRadius.full),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  )
                : Text(
                    text,
                    style: AppTextStyles.buttonPrimary,
                  ),
          ),
        ),
      ),
    );
  }
}

class AppSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AppSecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(AppBorderRadius.full),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppBorderRadius.full),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryMain,
                      ),
                    ),
                  )
                : Text(text, style: AppTextStyles.buttonSecondary),
          ),
        ),
      ),
    );
  }
}

class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? textColor;

  const AppTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor ?? AppColors.textPrimary,
        padding: AppSpacing.buttonPadding,
      ),
      child: Text(
        text,
        style: AppTextStyles.buttonSecondary.copyWith(
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
    );
  }
}

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
    this.size = 46,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.white,
        shape: BoxShape.circle,
        boxShadow: AppShadows.soft,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Icon(
            icon,
            color: iconColor ?? AppColors.textPrimary,
            size: size * 0.46,
          ),
        ),
      ),
    );
  }
}
