import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pliro/pliro/core/theme/app_colors.dart';
import 'package:pliro/pliro/core/theme/app_text_styles.dart';
import 'package:pliro/pliro/core/theme/app_theme.dart';
import 'package:pliro/pliro/features/badges/presentation/pages/badges_page.dart';
import 'package:pliro/pliro/features/home/presentation/controllers/main_controller.dart';
import 'package:pliro/pliro/features/home/presentation/pages/home_page_content.dart';
import 'package:pliro/pliro/features/library/presentation/pages/library_page.dart';
import 'package:pliro/pliro/features/profile/presentation/pages/profile_page.dart';

/// Main page with bottom navigation.
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(MainController());

    return GetBuilder<MainController>(
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: AppColors.dreamCream,
          body: IndexedStack(
            index: ctrl.currentIndex,
            children: const [
              HomePageContent(),
              LibraryPage(),
              BadgesPage(),
              ProfilePage(),
            ],
          ),
          bottomNavigationBar: _DreamBottomNav(controller: ctrl),
        );
      },
    );
  }
}

class _DreamBottomNav extends StatelessWidget {
  final MainController controller;

  const _DreamBottomNav({required this.controller});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.74),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.80)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.roseDeep.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                isSelected: controller.currentIndex == 0,
                onTap: () => controller.changePage(0),
              ),
              _NavItem(
                icon: Icons.photo_library_outlined,
                activeIcon: Icons.photo_library,
                label: 'Library',
                isSelected: controller.currentIndex == 1,
                onTap: () => controller.changePage(1),
              ),
              _NavItem(
                icon: Icons.workspace_premium_outlined,
                activeIcon: Icons.workspace_premium,
                label: 'Badges',
                isSelected: controller.currentIndex == 2,
                onTap: () => controller.changePage(2),
              ),
              _NavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                isSelected: controller.currentIndex == 3,
                onTap: () => controller.changePage(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        height: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 38,
              height: 30,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.blushMist.withOpacity(0.90)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                color:
                    isSelected ? AppColors.roseDeep : AppColors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.smallMedium.copyWith(
                color:
                    isSelected ? AppColors.roseDeep : AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
