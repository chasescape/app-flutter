import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:crushi/crushi/core/theme/app_theme.dart';

class DiffuseBackground extends StatelessWidget {
  const DiffuseBackground({
    super.key,
    this.base = const Color(0xFF070B16),
    this.bottom = const Color(0xFF070B16),
    this.blurSigma = 40,
    this.child,
  });

  final Color base;
  final Color bottom;
  final double blurSigma;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            base,
            const Color(0xFF0A1226),
            bottom,
          ],
        ),
      ),
      child: ClipRect(
        child: Stack(
          children: [
            Positioned(
              left: -80,
              top: -40,
              child: _GlowBlob(
                size: 240,
                color: AppColors.primaryMain.withOpacity(0.45),
              ),
            ),
            Positioned(
              right: -110,
              top: 120,
              child: _GlowBlob(
                size: 280,
                color: AppColors.accentMain.withOpacity(0.32),
              ),
            ),
            Positioned(
              left: -60,
              bottom: 120,
              child: _GlowBlob(
                size: 260,
                color: AppColors.secondaryMain.withOpacity(0.28),
              ),
            ),
            Positioned(
              right: -90,
              bottom: -70,
              child: _GlowBlob(
                size: 260,
                color: AppColors.primaryMain.withOpacity(0.22),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: const SizedBox.expand(),
            ),
            Positioned.fill(
              child: ColoredBox(
                color: base.withOpacity(0.40),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      base.withOpacity(0.18),
                      Colors.transparent,
                      Colors.black.withOpacity(0.12),
                    ],
                  ),
                ),
              ),
            ),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withOpacity(0.0),
            ],
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}
