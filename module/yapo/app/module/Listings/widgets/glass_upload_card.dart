import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yapo/yapo/app/routes/app_pages.dart';
import '../listings_logic.dart';

/// 毛玻璃上传卡片组件
class GlassUploadCard extends StatelessWidget {
  const GlassUploadCard({super.key});

  Widget _buildBreathingCircle(
      BuildContext context, ListingsLogic logic, double size, Color color) {
    return AnimatedBuilder(
      animation: logic.breath,
      builder: (context, child) {
        return Transform.scale(
          scale: logic.breath.value,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
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
  static const _glassTitleGradient = LinearGradient(
    colors: [
      Color(0xFFf9a8d4),
      Color(0xFFd8b4fe),
      Color(0xFFf9a8d4),
    ],
  );

  @override
  Widget build(BuildContext context) {
    // ✅ 性能优化：使用 GetView 的 controller 属性，避免重复 Get.find
    final logic = Get.find<ListingsLogic>();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ✅ 性能优化：RepaintBoundary 隔离动画重绘区域（必须在 Positioned 内部）
          Positioned(
            top: -50,
            right: -50,
            child: RepaintBoundary(
              child: _buildBreathingCircle(
                  context, logic, 200, const Color(0xFFf472b6)),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: RepaintBoundary(
              child: _buildBreathingCircle(
                  context, logic, 120, const Color(0xFFa855f7)),
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
                    // ✅ 性能优化：使用静态渐变
                    gradient: _glassGradient,
                    border: Border.all(
                      color: _glassBorderColor,
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 10),
                        // ✅ 性能优化：使用静态渐变，RepaintBoundary 隔离
                        RepaintBoundary(
                          child: ShaderMask(
                            shaderCallback: (bounds) =>
                                _glassTitleGradient.createShader(bounds),
                            child: const Text(
                              'Transform Your Memories',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Description
                        Text(
                          'Upload your travel photos and let AI create stunning, personalized album covers and designs',
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFFf9a8d4).withValues(alpha: 0.7),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Upload Button
                        InkWell(
                          onTap: () => Get.toNamed(Routes.creation),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFdb2777), Color(0xFF9333ea)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFec4899)
                                      .withValues(alpha: 0.25),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, color: Colors.white, size: 20),
                                SizedBox(width: 10),
                                Text(
                                  'Upload Photos',
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
