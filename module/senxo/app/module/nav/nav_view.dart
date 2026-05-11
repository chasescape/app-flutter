import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../routes/app_pages.dart';
import 'nav_logic.dart';
import 'widgets/nav_item.dart';

/// Apple-style bottom navigation bar with sliding indicator
class NavPage extends StatelessWidget {
  const NavPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用permanent实例，确保不会被销毁
    final logic = Get.put(NavLogic(), permanent: true);
    
    // 每次构建时更新当前路由
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logic.updateRoute(Get.currentRoute);
    });

    return Container(
      color: Colors.transparent, // 外层容器透明
      margin: EdgeInsets.symmetric(horizontal: 80.w, vertical: 20.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95), // 半透明白色
          borderRadius: BorderRadius.circular(50.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
        children: [
          // 滑动指示器
          AnimatedBuilder(
            animation: logic.slideAnimation,
            builder: (context, child) {
              final position = _calculateIndicatorPosition(logic.slideAnimation.value);
              return Positioned(
                left: position,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 80.w,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFDAE0),
                        Color(0xFFFFF4DC),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(50.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFDAE0).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // 导航项
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              NavItem(
                icon: LucideIcons.house,
                label: 'home',
                route: Routes.home,
                index: 0,
              ),
              NavItem(
                icon: LucideIcons.camera,
                label: 'generate',
                route: Routes.generate,
                index: 1,
              ),
              NavItem(
                icon: LucideIcons.user_star,
                label: 'profile',
                route: Routes.profile,
                index: 2,
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  double _calculateIndicatorPosition(double index) {
    // 计算指示器位置
    // 容器总宽度 = 屏幕宽度 - 左右边距(80*2) - 左右padding(12*2)
    final containerWidth = 1.sw - 160.w - 24.w;
    final itemWidth = containerWidth / 3;
    return index * itemWidth + (itemWidth - 80.w) / 2;
  }
}

