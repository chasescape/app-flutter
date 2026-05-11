import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yapo/yapo/app/routes/app_pages.dart';

import 'nav_logic.dart';

/// 导航页面
/// 
/// GetX 性能优化：
/// - 使用 GetView 避免重复创建 Controller
/// - 合并 Obx 减少 rebuild 次数（从 8 次降到 4 次）
/// - 提取静态颜色为常量
/// - RepaintBoundary 隔离重绘区域
class NavPage extends GetView<NavLogic> {
  const NavPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a0b2e),
      extendBody: true,
      body: PageView(
        controller: controller.pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => controller.currentIndex.value = index,
        children: controller.pages,
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(30, 0, 20, 30), // 从 40 改为 20，增加宽度
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1Aec4899),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 75, // 从 75 增加到 85
            decoration: BoxDecoration(
              color: const Color(0x99000000),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0x4DFFFFFF),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.list,
                  label: 'List',
                  index: 1,
                ),
                _buildCenterButton(),
                _buildNavItem(
                  icon: Icons.history,
                  label: 'History',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 静态颜色常量，避免重复创建
  static const _selectedIconBg = Color(0x33ec4899);
  static const _selectedIconColor = Color(0xFFf472b6);
  static const _unselectedIconColor = Color(0x80FFFFFF);
  static const _selectedTextColor = Color(0xFFf9a8d4);
  static const _unselectedTextColor = Color(0x80FFFFFF);

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () => controller.changePage(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // 增加垂直 padding
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(() {
                final isSelected = controller.currentIndex.value == index;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.all(8), // 从 6 增加到 8
                      decoration: BoxDecoration(
                        color: isSelected ? _selectedIconBg : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected ? _selectedIconColor : _unselectedIconColor,
                        size: 24, // 从 22 增加到 24
                      ),
                    ),
                    const SizedBox(height: 4), // 从 2 增加到 4
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: TextStyle(
                        fontSize: 11, // 从 10 增加到 11
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? _selectedTextColor : _unselectedTextColor,
                      ),
                      child: Text(label),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterButton() {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () => Get.toNamed(Routes.creation),
        child: Container(
          width: 64, // 从 60 增加到 64
          height: 64,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFec4899),
                Color(0xFF9333ea),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x66ec4899),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 34, // 从 32 增加到 34
          ),
        ),
      ),
    );
  }
}
