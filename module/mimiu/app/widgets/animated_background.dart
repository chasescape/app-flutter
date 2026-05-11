import 'dart:ui';

import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late final AnimationController _pulseA = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);

  late final AnimationController _pulseB = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  late final AnimationController _pulseC = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulseA.dispose();
    _pulseB.dispose();
    _pulseC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black,
                Color(0xFF111827), // gray-900
                Colors.black,
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: Listenable.merge([_pulseA, _pulseB, _pulseC]),
            builder: (context, _) {
              final a = 0.85 + 0.15 * _pulseA.value;
              final b = 0.80 + 0.20 * _pulseB.value;
              final c = 0.90 + 0.10 * _pulseC.value;

              return Stack(
                children: [
                  _orb(
                    left: -120,
                    top: -120,
                    size: 420,
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.30 * a),
                    blur: 120,
                  ),
                  _orb(
                    right: -90,
                    bottom: -90,
                    size: 360,
                    color: const Color(0xFFFBBF24).withValues(alpha: 0.25 * b),
                    blur: 100,
                  ),
                  _orb(
                    left: (MediaQuery.sizeOf(context).width / 2) - 250,
                    top: (MediaQuery.sizeOf(context).height / 2) - 250,
                    size: 520,
                    color: const Color(0xFFD97706).withValues(alpha: 0.15),
                    blur: 150,
                  ),
                  _orb(
                    right: 60,
                    top: 140,
                    size: 280,
                    color: const Color(0xFFFBBF24).withValues(alpha: 0.20 * c),
                    blur: 100,
                  ),
                ],
              );
            },
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Color.fromRGBO(0, 0, 0, 0.20),
                Color.fromRGBO(0, 0, 0, 0.40),
              ],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.02,
              child: CustomPaint(
                painter: _GridDotsPainter(),
              ),
            ),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [
                Color.fromRGBO(120, 53, 15, 0.05), // yellow-900-ish
                Colors.transparent,
                Color.fromRGBO(120, 53, 15, 0.05),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _orb({
    double? left,
    double? top,
    double? right,
    double? bottom,
    required double size,
    required Color color,
    required double blur,
  }) {
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: blur / 6, sigmaY: blur / 6),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _GridDotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    const spacing = 50.0;
    const radius = 1.0;
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
