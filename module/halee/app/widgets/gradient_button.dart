import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final LinearGradient? gradient;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: onPressed != null
              ? (gradient ?? AppColors.buttonGradient)
              : LinearGradient(colors: [Colors.grey.shade700, Colors.grey.shade600]),
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
          boxShadow: onPressed != null
              ? [
                  BoxShadow(
                    color: AppColors.accentMain.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      text,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class NeonIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double? size;
  final Color? iconColor;
  final Color? glowColor;

  const NeonIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size,
    this.iconColor,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.accentMain;
    final glow = glowColor ?? AppColors.neonGlow;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: glow.withOpacity(0.4), blurRadius: 12),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: size ?? 24),
        onPressed: onPressed,
        color: color,
      ),
    );
  }
}
