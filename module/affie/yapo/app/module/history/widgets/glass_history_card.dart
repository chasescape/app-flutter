import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yapo/yapo/app/routes/app_pages.dart';

/// 毛玻璃历史卡片组件（空状态）
class GlassHistoryCard extends StatefulWidget {
  const GlassHistoryCard({super.key});

  @override
  State<GlassHistoryCard> createState() => _GlassHistoryCardState();
}

class _GlassHistoryCardState extends State<GlassHistoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _breath;

  // ✅ 性能优化：静态渐变配置
  static const _glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1Fec4899), // 0.12 alpha 预计算
      Color(0x14a855f7), // 0.08 alpha 预计算
      Color(0x0Aec4899), // 0.04 alpha 预计算
    ],
  );
  static const _glassBorderColor = Color(0x47ec4899); // 0.28 alpha 预计算
  static const _iconGradient = LinearGradient(
    colors: [
      Color(0x33ec4899), // 0.2 alpha 预计算
      Color(0x33a855f7), // 0.2 alpha 预计算
    ],
  );
  static const _titleGradient = LinearGradient(
    colors: [Color(0xFFf9a8d4), Color(0xFFd8b4fe)],
  );
  static const _buttonShadowColor = Color(0x40ec4899); // 0.25 alpha 预计算

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2800),
      vsync: this,
    )..repeat(reverse: true);
    _breath = Tween<double>(begin: 0.88, end: 1.12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildBreathingCircle(double size, Color color) {
    // ✅ 性能优化：静态颜色配置
    final circleColor = color == const Color(0xFFf472b6)
        ? const Color(0x33f472b6) // 0.2 alpha 预计算
        : const Color(0x33a855f7); // 0.2 alpha 预计算
    final shadowColor = color == const Color(0xFFf472b6)
        ? const Color(0x59f472b6) // 0.35 alpha 预计算
        : const Color(0x59a855f7); // 0.35 alpha 预计算

    return AnimatedBuilder(
      animation: _breath,
      builder: (context, child) {
        return Transform.scale(
          scale: _breath.value,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: circleColor,
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 80,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ✅ 性能优化：Positioned 必须是 Stack 的直接子元素，RepaintBoundary 放在 Positioned 内部
          Positioned(
            top: -50,
            right: -50,
            child: RepaintBoundary(
              child: _buildBreathingCircle(200, const Color(0xFFf472b6)),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: RepaintBoundary(
              child: _buildBreathingCircle(120, const Color(0xFFa855f7)),
            ),
          ),
          // ✅ 性能优化：RepaintBoundary 隔离 BackdropFilter 重绘区域
          RepaintBoundary(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    // ✅ 性能优化：使用静态渐变配置
                    gradient: _glassGradient,
                    border: Border.all(
                      color: _glassBorderColor,
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                    child: Column(
                      children: [
                        // Empty state icon
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            // ✅ 性能优化：使用静态渐变配置
                            gradient: _iconGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            size: 60,
                            color: Color(0xFFf472b6),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // ✅ 性能优化：RepaintBoundary 隔离 ShaderMask 重绘
                        RepaintBoundary(
                          child: ShaderMask(
                            shaderCallback: (bounds) =>
                                _titleGradient.createShader(bounds),
                            child: const Text(
                              'No History Yet',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Start exploring and save your history travel memories here',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xB3d8b4fe), // 0.7 alpha 预计算
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),
                        InkWell(
                          onTap: () => Get.toNamed(Routes.creation),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFdb2777), Color(0xFF9333ea)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: _buttonShadowColor,
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.explore_rounded,
                                    color: Colors.white, size: 20),
                                SizedBox(width: 12),
                                Text(
                                  'Create AI Album',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
