import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:enkou/enkou/app/module/calendar/calendar_view.dart';
import 'package:enkou/enkou/app/module/home/home_view.dart';
import 'package:enkou/enkou/app/module/profile/profile_view.dart';

import 'nav_logic.dart';

// Lunar Whisper（雾感渐变）底部导航栏配色
const Color _lunarPink = Color(0xB3EED0F2);
const Color _lunarLavender = Color(0xB39EBAEB);
const Color _lunarSky = Color(0x9F96DFF5);
const LinearGradient _navGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [_lunarPink, _lunarLavender, _lunarSky],
);

const Color _navBg = Color(0xFFF6F4FB);
const Color _navSurface = Color(0xCCFDFBFF);
const Color _navAccent = Color(0xFF8F6AD8);
const Color _navMuted = Color(0xFF7C7785);

class NavPage extends GetView<NavLogic> {
  const NavPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navBg,
      body: Obx(() {
        switch (controller.currentIndex.value) {
          case 0:
            return HomePage();
          case 1:
            return CalendarPage();
          case 2:
          default:
            return ProfilePage();
        }
      }),
      bottomNavigationBar: Obx(() {
        final int index = controller.currentIndex.value;

        return SizedBox(
          height: 82,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 90.h,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: _navGradient,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 16,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    // 三个 Tab 改为均匀分布，避免删掉 Guides 后两侧空旷
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _NavItem(
                        index: 0,
                        isSelected: index == 0,
                        icon: Icons.home_rounded,
                        label: 'Home',
                        onTap: () => controller.changeTab(0),
                      ),
                      _NavItem(
                        index: 1,
                        isSelected: index == 1,
                        icon: Icons.calendar_month_rounded,
                        label: 'Calendar',
                        onTap: () => controller.changeTab(1),
                      ),
                      _NavItem(
                        index: 2,
                        isSelected: index == 2,
                        icon: Icons.person_rounded,
                        label: 'Profile',
                        onTap: () => controller.changeTab(2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.index,
    required this.isSelected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final int index;
  final bool isSelected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: 44,
              height: 34,
              decoration: BoxDecoration(
                color: isSelected ? _navSurface : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? _navAccent.withValues(alpha: 0.18)
                      : Colors.transparent,
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 22,
                color: isSelected ? _navAccent : _navMuted,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? _navAccent : _navMuted,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
