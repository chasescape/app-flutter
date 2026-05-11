import 'package:flutter/material.dart';
import 'dart:ui';

import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../create/create_page.dart';
import '../profile/profile_page.dart';
import 'feed_tab.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    FeedTab(),
    CreatePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          child: ClipRRect(
            borderRadius: AppBorderRadius.borderRadiusFull,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  borderRadius: AppBorderRadius.borderRadiusFull,
                  color: Colors.white.withValues(alpha: 0.78),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      offset: Offset(0, 16),
                      blurRadius: 32,
                    ),
                    BoxShadow(
                      color: Color(0x14000000),
                      offset: Offset(0, 6),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildNavItem(
                      index: 0,
                      icon: Icons.home_rounded,
                      label: 'Home',
                    ),
                    _buildNavItem(
                      index: 1,
                      icon: Icons.auto_awesome_rounded,
                      label: 'Create',
                    ),
                    _buildNavItem(
                      index: 2,
                      icon: Icons.person_rounded,
                      label: 'Profile',
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

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isActive = _currentIndex == index;
    final activeColor = const Color(0xFF584874);
    final inactiveColor = const Color(0xFF7E7694);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: isActive
                ? Colors.white.withValues(alpha: 0.94)
                : Colors.transparent,
            border: isActive
                ? Border.all(
                    color: Colors.white.withValues(alpha: 0.92),
                  )
                : null,
            boxShadow: isActive
                ? const [
                    BoxShadow(
                      color: Color(0x16000000),
                      offset: Offset(0, 8),
                      blurRadius: 18,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive
                    ? activeColor
                    : inactiveColor.withValues(alpha: 0.9),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: AppTextStyles.smallMedium.copyWith(
                  color: isActive ? activeColor : inactiveColor,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
