import 'package:flutter/material.dart';
import 'dart:ui';
import '../constants/app_colors.dart';
import '../constants/app_shadows.dart';
import '../constants/app_border_radius.dart';

class NeonBorderContainer extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final double? borderWidth;
  final bool isGlowing;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final BoxConstraints? constraints;

  const NeonBorderContainer({
    super.key,
    required this.child,
    this.borderColor,
    this.borderWidth,
    this.isGlowing = true,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.onTap,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? AppColors.secondaryMain;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(AppBorderRadius.lg);

    final container = ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: width,
          height: height,
          margin: margin,
          constraints: constraints,
          padding: padding ?? const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: AppGradients.surface,
            borderRadius: effectiveBorderRadius,
            border: Border.all(
              color: effectiveBorderColor.withValues(alpha: borderWidth != null ? 0.65 : 0.42),
              width: borderWidth ?? 1.2,
            ),
            boxShadow: isGlowing
                ? [
                    ...AppShadows.neonGlowStrong(effectiveBorderColor),
                    ...AppShadows.cardElevation,
                  ]
                : AppShadows.cardElevation,
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveBorderRadius,
          child: container,
        ),
      );
    }

    return container;
  }
}

class NeonCard extends StatelessWidget {
  final Widget child;
  final Color? glowColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool elevated;

  const NeonCard({
    super.key,
    required this.child,
    this.glowColor,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.elevated = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppGradients.surfaceWarm,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(
          color: (glowColor ?? AppColors.secondaryMain).withValues(alpha: 0.24),
          width: 1.2,
        ),
        boxShadow: elevated
            ? [
                ...AppShadows.neon((glowColor ?? AppColors.secondaryMain)),
                ...AppShadows.cardElevation,
              ]
            : null,
      ),
      child: child,
    );
  }
}
