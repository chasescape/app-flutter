import 'package:flutter/material.dart';
import 'package:cliss/cliss/app/theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Gradient? gradient;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.gradient,
    this.borderRadius,
    this.boxShadow,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: gradient == null ? backgroundColor ?? AppColors.surfaceGlass : null,
        gradient: gradient ?? AppGradients.softCard,
        borderRadius: borderRadius ?? AppBorderRadius.allLarge,
        border: border ?? Border.all(color: AppColors.borderSoft),
        boxShadow: boxShadow ?? AppShadows.sm,
      ),
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? AppBorderRadius.allLarge,
        child: content,
      ),
    );
  }
}
