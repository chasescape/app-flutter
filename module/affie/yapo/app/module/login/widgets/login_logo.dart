import 'package:flutter/material.dart';
import 'package:yapo/gen_a/A.dart';

/// Logo 区域组件
/// 
/// 职责：
/// - 显示 App Logo 图片
/// - 显示 App 名称和标语
/// 
/// 优化：
/// - 使用 const 构造函数
/// - 图片添加 cacheWidth/cacheHeight 减少内存占用
/// - 减少 BoxShadow 层数和模糊半径（降低 GPU 负载）
/// 
/// 使用方式：
/// ```dart
/// const LoginLogo()
/// ```
class LoginLogo extends StatelessWidget {
  const LoginLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            // ✅ 减少 BoxShadow 层数和模糊半径
            boxShadow: const [
              BoxShadow(
                color: Color(0x80ec4899),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            // ✅ 添加图片缓存尺寸，减少内存占用
            child: Image.asset(
              A.assets_yapo_logo,
              fit: BoxFit.cover,
              cacheWidth: 240, // 2x 密度
              cacheHeight: 240,
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // App 名称
        const Text(
          'Yapo',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Color(0xFFf9a8d4),
            letterSpacing: 2,
          ),
        ),

      ],
    );
  }
}
