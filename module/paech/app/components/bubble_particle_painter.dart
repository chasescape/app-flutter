import 'dart:math';
import 'package:flutter/material.dart';

/// 气泡粒子模型
class BubbleParticle {
  double x;
  double y;
  double radius;
  double speed;
  double opacity;
  double wobbleOffset; // 左右摆动偏移
  double wobbleSpeed; // 摆动速度

  BubbleParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
    required this.wobbleOffset,
    required this.wobbleSpeed,
  });
}

/// 气泡粒子绘制器
class BubbleParticlePainter extends CustomPainter {
  final List<BubbleParticle> bubbles;
  final Animation<double> animation;

  BubbleParticlePainter({
    required this.bubbles,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    for (var bubble in bubbles) {
      final center = Offset(bubble.x, bubble.y);
      
      // 1. 绘制气泡主体（白色渐变）
      final mainGradient = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 1.0,
        colors: [
          Colors.white.withOpacity(bubble.opacity * 0.5),
          Colors.white.withOpacity(bubble.opacity * 0.25),
          Colors.white.withOpacity(bubble.opacity * 0.1),
          Colors.white.withOpacity(0),
        ],
        stops: const [0.0, 0.5, 0.8, 1.0],
      );

      final mainPaint = Paint()
        ..shader = mainGradient.createShader(
          Rect.fromCircle(center: center, radius: bubble.radius),
        )
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, bubble.radius, mainPaint);

      // 2. 绘制气泡边缘
      final borderPaint = Paint()
        ..color = Colors.white.withOpacity(bubble.opacity * 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawCircle(center, bubble.radius - 0.5, borderPaint);

      // 3. 绘制顶部高光（强烈的白色反光）
      final highlightGradient = RadialGradient(
        colors: [
          Colors.white.withOpacity(bubble.opacity * 0.8),
          Colors.white.withOpacity(bubble.opacity * 0.4),
          Colors.white.withOpacity(0),
        ],
        stops: const [0.0, 0.5, 1.0],
      );

      final highlightPaint = Paint()
        ..shader = highlightGradient.createShader(
          Rect.fromCircle(
            center: Offset(
              center.dx - bubble.radius * 0.3,
              center.dy - bubble.radius * 0.3,
            ),
            radius: bubble.radius * 0.4,
          ),
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(
        Offset(
          center.dx - bubble.radius * 0.3,
          center.dy - bubble.radius * 0.3,
        ),
        bubble.radius * 0.4,
        highlightPaint,
      );

      // 4. 绘制次级高光（小反光点）
      final smallHighlightPaint = Paint()
        ..color = Colors.white.withOpacity(bubble.opacity * 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(
        Offset(
          center.dx + bubble.radius * 0.2,
          center.dy - bubble.radius * 0.1,
        ),
        bubble.radius * 0.15,
        smallHighlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(BubbleParticlePainter oldDelegate) => true;
}
