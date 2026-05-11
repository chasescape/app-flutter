import 'dart:math';
import 'package:flutter/material.dart';


class LoginBackground extends StatelessWidget {
  const LoginBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        _GradientBackground(),
        Positioned.fill(child: _StarsWidget()),
      ],
    );
  }
}

class _GradientBackground extends StatelessWidget {
  const _GradientBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0a0412),
            Color(0xFF1a0b2e),
            Color(0xFF2d1b4e),
            Color(0xFF1a0b2e),
          ],
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}

class _StarsWidget extends StatelessWidget {
  const _StarsWidget();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarsPainter.instance,
    );
  }
}

class _StarsPainter extends CustomPainter {
  _StarsPainter._();

  // ✅ 单例模式，避免重复创建 Painter
  static final _StarsPainter instance = _StarsPainter._();

  static final List<_Star> _cachedStars = _generateStars();

  static List<_Star> _generateStars() {
    final random = Random(42);
    final stars = <_Star>[];

    // ✅ 减少星星数量从 25 到 18，降低绘制成本
    for (int i = 0; i < 18; i++) {
      double x, y;

      final edgeWeight = random.nextDouble();
      if (edgeWeight < 0.6) {
        if (random.nextBool()) {
          x = random.nextBool()
              ? random.nextDouble() * 0.2
              : 0.8 + random.nextDouble() * 0.2;
          y = random.nextDouble();
        } else {
          x = random.nextDouble();
          y = random.nextBool()
              ? random.nextDouble() * 0.25
              : 0.75 + random.nextDouble() * 0.25;
        }
      } else {
        x = random.nextDouble();
        y = random.nextDouble();
      }

      final opacity = 0.15 + random.nextDouble() * 0.4;
      final starSize = 0.8 + random.nextDouble() * 1.5;

      stars.add(_Star(x, y, opacity, starSize));
    }

    return stars;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false; // ✅ 禁用抗锯齿，提升性能

    for (final star in _cachedStars) {
      final x = star.x * size.width;
      final y = star.y * size.height;

      paint.color = Color.fromRGBO(255, 255, 255, star.opacity);

      // ✅ 简化绘制，只画圆点，移除十字线
      canvas.drawCircle(Offset(x, y), star.size, paint);
    }
  }

  @override
  bool shouldRepaint(_StarsPainter oldDelegate) => false;
}

class _Star {
  final double x;
  final double y;
  final double opacity;
  final double size;

  const _Star(this.x, this.y, this.opacity, this.size);
}
