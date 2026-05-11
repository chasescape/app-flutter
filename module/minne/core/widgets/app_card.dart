import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_border_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_shadows.dart';

/// App Card - Custom card with shadow and rounded corners
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? width;
  final double? height;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: width,
      height: height,
      padding: padding ?? AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.cardBg,
        borderRadius: AppBorderRadius.borderRadiusLG,
        boxShadow: AppShadows.cardShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppBorderRadius.borderRadiusLG,
          child: Container(
            margin: margin,
            child: card,
          ),
        ),
      );
    }

    return Container(margin: margin, child: card);
  }
}

/// Gradient Card - Card with gradient background
class GradientCard extends StatelessWidget {
  final Widget child;
  final List<Color> gradientColors;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  const GradientCard({
    super.key,
    required this.child,
    required this.gradientColors,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: width,
      height: height,
      padding: padding ?? AppSpacing.paddingMD,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: AppBorderRadius.borderRadiusLG,
        boxShadow: AppShadows.shadowMD,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppBorderRadius.borderRadiusLG,
          child: Container(
            margin: margin,
            child: card,
          ),
        ),
      );
    }

    return Container(margin: margin, child: card);
  }
}
