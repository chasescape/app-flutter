import 'dart:ui';

import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 18,
    this.blurSigma = 14,
    this.backgroundColor = const Color(0x99FFFFFF),
    this.borderColor = const Color(0x22FFFFFF),
    this.shadowColor = const Color(0x1A000000),
    this.padding = const EdgeInsets.all(16),
    this.highlight = true,
  });

  final Widget child;
  final double borderRadius;
  final double blurSigma;
  final Color backgroundColor;
  final Color borderColor;
  final Color shadowColor;
  final EdgeInsets padding;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: borderColor),
            ),
            child: Stack(
              children: [
                if (highlight)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(borderRadius),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0x66FFFFFF),
                              Color(0x00FFFFFF),
                              Color(0x22FFFFFF),
                            ],
                            stops: [0.0, 0.55, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
