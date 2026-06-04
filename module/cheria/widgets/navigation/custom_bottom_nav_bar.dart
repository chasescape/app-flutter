import 'package:flutter/material.dart';
import '../../app/theme/theme.dart';

/// Custom Floating Capsule Bottom Navigation Bar
///
/// Features:
/// - Floating capsule container with glassmorphism effect
/// - Individual capsule highlight for selected item
/// - Smooth transition animations
/// - Icon-top, text-bottom vertical layout
/// - Colors derived from theme (no hardcoding)
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const containerColor = Color(AppColors.navBackground);
    const activeColor = Color(AppColors.navActive);
    const inactiveColor = Color(AppColors.navInactive);
    final highlightBg = activeColor.withOpacity(0.12);
    final shadowColor = const Color(AppColors.primaryDark).withOpacity(0.18);

    return Container(
      height: 96 + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: AppSpacing.sm + MediaQuery.of(context).padding.bottom,
        top: AppSpacing.sm,
      ),
      child: Center(
        child: _buildFloatingContainer(
          context,
          containerColor,
          activeColor,
          inactiveColor,
          highlightBg,
          shadowColor,
        ),
      ),
    );
  }

  Widget _buildFloatingContainer(
    BuildContext context,
    Color containerColor,
    Color activeColor,
    Color inactiveColor,
    Color highlightBg,
    Color shadowColor,
  ) {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: AppBorderRadius.allXL,
        border: Border.all(
          color: const Color(AppColors.divider),
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppBorderRadius.allXL,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                highlightBg: highlightBg,
              ),
              _buildNavItem(
                context,
                index: 1,
                icon: Icons.menu_book_outlined,
                activeIcon: Icons.menu_book,
                label: 'Library',
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                highlightBg: highlightBg,
              ),
              _buildNavItem(
                context,
                index: 2,
                icon: Icons.bar_chart_outlined,
                activeIcon: Icons.bar_chart,
                label: 'Stats',
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                highlightBg: highlightBg,
              ),
              _buildNavItem(
                context,
                index: 3,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                highlightBg: highlightBg,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required Color activeColor,
    required Color inactiveColor,
    required Color highlightBg,
  }) {
    final isSelected = currentIndex == index;
    final itemWidth = (MediaQuery.of(context).size.width - 32) / 4;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: itemWidth - 8,
        height: 64,
        decoration: BoxDecoration(
          color: isSelected ? highlightBg : Colors.transparent,
          borderRadius: AppBorderRadius.allXL,
          border: isSelected
              ? Border.all(
                  color: activeColor.withOpacity(0.14),
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                );
              },
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey(isSelected ? activeIcon.hashCode : icon.hashCode),
                color: isSelected ? activeColor : inactiveColor,
                size: 26,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontSize: AppTypography.small,
                fontWeight:
                    isSelected ? AppTypography.semibold : AppTypography.regular,
                color: isSelected ? activeColor : inactiveColor,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
