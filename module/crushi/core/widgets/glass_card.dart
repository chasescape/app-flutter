import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:crushi/crushi/core/theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = AppRadius.xl,
    this.blurSigma = 18,
    this.tintColor = Colors.white,
    this.tintOpacity = 0.18,
    this.borderOpacity = 0.22,
    this.boxShadow,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurSigma;
  final Color tintColor;
  final double tintOpacity;
  final double borderOpacity;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: tintColor.withOpacity(tintOpacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: Colors.white.withOpacity(borderOpacity)),
              boxShadow: boxShadow ?? AppShadows.md,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

