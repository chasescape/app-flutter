import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'nav_logic.dart';
import '../home/home_view.dart';
import '../generate/generate_view.dart';
import '../history/history_view.dart';
import '../profile/profile_view.dart';
import '../../theme/app_colors.dart';

class NavPage extends StatelessWidget {
  NavPage({Key? key}) : super(key: key);

  final NavLogic logic = Get.put(NavLogic());

  final List<Widget> pages = [
    HomePage(),
    HistoryPage(),
    GeneratePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
            index: logic.currentIndex.value,
            children: pages,
          )),
      bottomNavigationBar: GetBuilder<NavLogic>(
        builder: (_) => _buildBottomBar(context),
      ),
      floatingActionButton: Obx(
        () => _buildFloatingButton(isActive: logic.currentIndex.value == 2),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        AppColors.darkCard.withOpacity(0.95),
                        AppColors.darkCard.withOpacity(0.9),
                      ]
                    : [
                        Colors.white.withOpacity(0.95),
                        Colors.white.withOpacity(0.9),
                      ],
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      0,
                      Icons.explore_outlined,
                      Icons.explore,
                      'Explore',
                    ),
                    const SizedBox(width: 60),
                    _buildNavItem(
                      3,
                      Icons.person_outline,
                      Icons.person,
                      'Profile',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = logic.currentIndex.value == index;

    return Expanded(
      child: Center(
        child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          tween: Tween<double>(begin: 0, end: isSelected ? 1 : 0),
          builder: (context, double value, child) {
            final iconColor = Color.lerp(
              AppColors.textLight,
              AppColors.primary,
              value,
            )!;
            final textColor = Color.lerp(
              AppColors.textSecondary,
              AppColors.primaryDark,
              value,
            )!;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => logic.changePage(index),
                borderRadius: BorderRadius.circular(18),
                splashColor: AppColors.primary.withOpacity(0.18),
                highlightColor: AppColors.primary.withOpacity(0.08),
                child: Ink(
                  width: 92,
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    gradient: value > 0
                        ? LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.14 * value),
                              AppColors.secondary.withOpacity(0.12 * value),
                            ],
                          )
                        : null,
                    color: value == 0 ? Colors.transparent : null,
                    borderRadius: BorderRadius.circular(18),
                    border: value > 0.2
                        ? Border.all(
                            color: AppColors.primary.withOpacity(0.18 * value),
                          )
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? activeIcon : icon,
                        color: iconColor,
                        size: 24,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFloatingButton({required bool isActive}) {
    return Container(
      width: 60,
      height: 60,
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.gradientSunset,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(isActive ? 0.55 : 0.35),
            blurRadius: isActive ? 16 : 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => logic.changePage(2),
          borderRadius: BorderRadius.circular(30),
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.12),
          child: Icon(
            isActive ? Icons.camera_enhance_rounded : Icons.add_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}
