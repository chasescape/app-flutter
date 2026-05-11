import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rova/gen_a/A.dart';

/// Full-screen background using [A.assets_rova_bg] with a "diffuse" blur layer.
class RovaBackground extends StatelessWidget {
  const RovaBackground({
    super.key,
    this.assetPath,
    this.child,
    this.blurSigma = 18,
    this.overlayColor = const Color(0x66000000),
    this.gradient,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  final String? assetPath;
  final Widget? child;
  final double blurSigma;
  final Color overlayColor;
  final Gradient? gradient;
  final BoxFit fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          assetPath ?? A.assets_rova_bg,
          fit: fit,
          alignment: alignment,
        ),
        Positioned.fill(
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: blurSigma,
                sigmaY: blurSigma,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: overlayColor,
                  gradient: gradient ??
                      const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x33000000),
                          Color(0x66000000),
                        ],
                      ),
                ),
              ),
            ),
          ),
        ),
        if (child != null) child!,
      ],
    );
  }
}
