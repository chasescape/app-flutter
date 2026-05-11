import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../nav_logic.dart';

/// Navigation item widget
class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final int index;

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.route,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final navLogic = Get.find<NavLogic>();

    return GetBuilder<NavLogic>(
      builder: (logic) {
        final isActive = logic.isActive(route);

        return GestureDetector(
          onTap: () => navLogic.navigateTo(route, index),
          behavior: HitTestBehavior.opaque, // 确保整个区域都可点击
          child: Container(
            width: 80.w,
            height: 52.h, // 增加高度以扩大触控区域
            alignment: Alignment.center,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: isActive ? 1.1 : 1.0,
              child: Icon(
                icon,
                size: 24.sp,
                color: isActive ? Colors.black87 : Colors.grey[400],
              ),
            ),
          ),
        );
      },
    );
  }
}
