import 'dart:ui';

import 'package:flutter/material.dart';

/// A symmetric vertical glow gradient background:
/// - Dark at top/bottom
/// - Warm glow around the center, mirrored vertically
class SymmetricGradientBackground extends StatelessWidget {
  const SymmetricGradientBackground({
    super.key,
    this.centerGlowColor = const Color(0xFFF59E0B),
    this.centerGlowOpacity = 0.22,
    this.vignetteOpacity = 0.55,
    this.blurSigma = 0,
  });

  final Color centerGlowColor;
  final double centerGlowOpacity;
  final double vignetteOpacity;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    Widget child = Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(color: Colors.black),
        ),
        // Center glow (symmetrically fades to top/bottom).
        Positioned.fill(
          child: Column(
            children: [
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black,
                        centerGlowColor.withValues(alpha: centerGlowOpacity),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black,
                        centerGlowColor.withValues(alpha: centerGlowOpacity),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Warm side glows (subtle).
        Positioned.fill(
          child: Row(
            children: [
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        centerGlowColor.withValues(alpha: centerGlowOpacity * 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        centerGlowColor.withValues(alpha: centerGlowOpacity * 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Vignette to match screenshot contrast.
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.15,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: vignetteOpacity),
                ],
                stops: const [0.25, 1.0],
              ),
            ),
          ),
        ),
      ],
    );

    if (blurSigma > 0) {
      child = ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: child,
      );
    }

    return SizedBox.expand(child: child);
  }
}
