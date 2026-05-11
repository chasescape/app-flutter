import 'package:flutter/material.dart';

/// 简单的渐变背景组件
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE3F2FD), // 浅蓝色
            Color(0xFFFCE4EC), // 柔和粉色
            Color(0xFFFFFFFF), // 纯白色
          ],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      child: child,
    );
  }
}