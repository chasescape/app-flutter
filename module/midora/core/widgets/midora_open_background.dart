import 'package:flutter/material.dart';
import '../../../gen_a/A.dart';
import '../theme/app_colors.dart';

/// Full-screen splash-style background using [A.assets_midora_MidoraOpen].
/// Uses [Image.asset] with [Image.errorBuilder] so a missing asset entry fails gracefully.
class MidoraOpenBackground extends StatelessWidget {
  const MidoraOpenBackground({
    super.key,
    this.overlayOpacity = 0.35,
  });

  /// Same meaning as `AppColors.backgroundOverlay.withOpacity(x)` on the previous layer.
  final double overlayOpacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          A.assets_midora_MidoraOpen,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: const BoxDecoration(
                gradient: AppColors.backgroundGradient,
              ),
            );
          },
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
        ),
        Positioned(
          top: -120,
          right: -40,
          child: _GlowOrb(
            size: 280,
            color: AppColors.primaryMain.withOpacity(0.30),
          ),
        ),
        Positioned(
          top: 160,
          left: -90,
          child: _GlowOrb(
            size: 220,
            color: AppColors.accentMain.withOpacity(0.18),
          ),
        ),
        Positioned(
          bottom: -140,
          left: -80,
          child: _GlowOrb(
            size: 360,
            color: AppColors.backgroundPrimary.withOpacity(0.55),
          ),
        ),
        CustomPaint(
          painter: _MidoraStarsPainter(),
          child: const SizedBox.expand(),
        ),
        Container(
          color: AppColors.backgroundOverlay
              .withOpacity(overlayOpacity.clamp(0.0, 1.0)),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
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
          ),
        ),
      ),
    );
  }
}

class _MidoraStarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.18);
    final stars = <Offset>[
      Offset(size.width * 0.18, size.height * 0.16),
      Offset(size.width * 0.34, size.height * 0.10),
      Offset(size.width * 0.72, size.height * 0.22),
      Offset(size.width * 0.84, size.height * 0.32),
      Offset(size.width * 0.14, size.height * 0.62),
      Offset(size.width * 0.58, size.height * 0.74),
      Offset(size.width * 0.82, size.height * 0.84),
      Offset(size.width * 0.26, size.height * 0.88),
    ];

    for (var i = 0; i < stars.length; i++) {
      final radius = i.isEven ? 1.4 : 2.1;
      canvas.drawCircle(stars[i], radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
