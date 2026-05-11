import 'dart:math';
import 'package:flutter/material.dart';
import 'bubble_particle_painter.dart';

/// 气泡粒子动画组件
class BubbleParticleAnimation extends StatefulWidget {
  final int particleCount;
  final Color? particleColor;

  const BubbleParticleAnimation({
    super.key,
    this.particleCount = 20,
    this.particleColor,
  });

  @override
  State<BubbleParticleAnimation> createState() =>
      _BubbleParticleAnimationState();
}

class _BubbleParticleAnimationState extends State<BubbleParticleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<BubbleParticle> _bubbles;
  final Random _random = Random();
  Size? _size;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _controller.addListener(() {
      if (mounted && _size != null) {
        setState(() {
          _updateBubbles();
        });
      }
    });
  }

  void _initBubbles(Size size) {
    _bubbles = List.generate(widget.particleCount, (index) {
      return BubbleParticle(
        x: _random.nextDouble() * size.width,
        y: size.height + _random.nextDouble() * 200,
        radius: _random.nextDouble() * 25 + 12, // 12-37px
        speed: _random.nextDouble() * 1.2 + 0.5, // 0.5-1.7
        opacity: _random.nextDouble() * 0.35 + 0.35, // 0.35-0.7
        wobbleOffset: _random.nextDouble() * pi * 2,
        wobbleSpeed: _random.nextDouble() * 0.015 + 0.008,
      );
    });
  }

  void _updateBubbles() {
    if (_size == null) return;

    for (var bubble in _bubbles) {
      // 向上移动
      bubble.y -= bubble.speed;

      // 左右摆动
      bubble.wobbleOffset += bubble.wobbleSpeed;
      bubble.x += sin(bubble.wobbleOffset) * 0.5;

      // 边界检查：重置到底部
      if (bubble.y < -bubble.radius * 2) {
        bubble.y = _size!.height + bubble.radius;
        bubble.x = _random.nextDouble() * _size!.width;
        bubble.radius = _random.nextDouble() * 25 + 12;
        bubble.speed = _random.nextDouble() * 1.2 + 0.5;
        bubble.opacity = _random.nextDouble() * 0.35 + 0.35;
      }

      // 左右边界检查
      if (bubble.x < -bubble.radius) {
        bubble.x = _size!.width + bubble.radius;
      } else if (bubble.x > _size!.width + bubble.radius) {
        bubble.x = -bubble.radius;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        
        // 初始化气泡（仅在尺寸变化时）
        if (_size != size) {
          _size = size;
          _initBubbles(size);
        }

        return CustomPaint(
          painter: BubbleParticlePainter(
            bubbles: _bubbles,
            animation: _controller,
          ),
          size: size,
        );
      },
    );
  }
}
