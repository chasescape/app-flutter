import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Floating bottom navigation with neon glass styling.
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
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(18, 8, 18, bottom + 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 74,
            decoration: BoxDecoration(
              color: AppTheme.bgCardStrong,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
              ),
              boxShadow: AppTheme.shadowLg,
            ),
            child: Row(
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.grid_view_rounded,
                  label: 'Discover',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isActive = index == currentIndex;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: AnimatedContainer(
            duration: AppTheme.durationNormal,
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              gradient: isActive ? AppTheme.primaryGradient : null,
              color: isActive ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryMain.withValues(alpha: 0.24),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isActive
                      ? AppTheme.textInverse
                      : AppTheme.textSecondary.withValues(alpha: 0.85),
                  size: 22,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive
                        ? AppTheme.textInverse
                        : AppTheme.textSecondary.withValues(alpha: 0.85),
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
