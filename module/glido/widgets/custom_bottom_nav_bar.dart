import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.spacingLg,
          0,
          AppTheme.spacingLg,
          AppTheme.spacingMd,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 78,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                border: Border.all(
                  color: AppTheme.ink.withValues(alpha: 0.08),
                ),
                boxShadow: AppTheme.softShadow,
              ),
              child: Row(
                children: [
                  _buildNavItem(
                    index: 0,
                    label: 'Home',
                    icon: Icons.grid_view_rounded,
                  ),
                  _buildCenterItem(),
                  _buildNavItem(
                    index: 2,
                    label: 'Profile',
                    icon: Icons.person_rounded,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected = currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.all(AppTheme.spacingSm),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryMain.withValues(alpha: 0.28)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color:
                    isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterItem() {
    final isSelected = currentIndex == 1;
    return Expanded(
      child: Center(
        child: InkWell(
          onTap: () => onTap(1),
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: AppTheme.highlightGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  border: Border.all(
                    color: AppTheme.ink.withValues(alpha: 0.08),
                  ),
                  boxShadow: isSelected
                      ? AppTheme.glowShadow
                      : [
                          BoxShadow(
                            color: AppTheme.primaryMain.withValues(alpha: 0.18),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: AppTheme.textPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Create',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
