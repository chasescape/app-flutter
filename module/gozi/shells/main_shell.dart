import 'package:flutter/material.dart';
import '../features/home/home_page.dart';
import '../features/history/history_page.dart';
import '../features/profile/profile_page.dart';
import '../theme/app_theme.dart';

/// Navigation Tab Data
class _NavTab {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _NavTab({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

/// Main Shell - Floating Capsule Bottom Navigation
/// Ensures all bottom nav pages remain as first-level pages
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  /// Current selected tab index
  int _currentIndex = 0;

  /// Navigation tabs
  static const List<_NavTab> _tabs = [
    _NavTab(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
    ),
    _NavTab(
      label: 'History',
      icon: Icons.history_outlined,
      activeIcon: Icons.history,
    ),
    _NavTab(
      label: 'Profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
    ),
  ];

  /// Handle tab selection
  void _onTabTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomePage(),
          HistoryPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: _FloatingCapsuleNavBar(
        tabs: _tabs,
        currentIndex: _currentIndex,
        onTap: _onTabTap,
      ),
    );
  }
}

/// Floating Capsule Bottom Navigation Bar
/// Lightweight, rounded, refined, with breathing feel
class _FloatingCapsuleNavBar extends StatelessWidget {
  final List<_NavTab> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingCapsuleNavBar({
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      height: 84 + bottomInset,
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 9, 28, 0),
          child: Container(
            height: 62,
            decoration: BoxDecoration(
              gradient: AppTheme.softSurfaceGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              border: Border.all(
                color: AppTheme.primaryWhite.withValues(alpha: 0.72),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentRed.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(tabs.length, (index) {
                final tab = tabs[index];
                final isSelected = index == currentIndex;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(index),
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: Tooltip(
                        message: tab.label,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppTheme.accentRed.withValues(alpha: 0.14)
                                : Colors.transparent,
                            border: isSelected
                                ? Border.all(
                                    color: AppTheme.primaryWhite
                                        .withValues(alpha: 0.82),
                                  )
                                : null,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppTheme.accentRed
                                          .withValues(alpha: 0.16),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            isSelected ? tab.activeIcon : tab.icon,
                            color: isSelected
                                ? AppTheme.accentRed
                                : AppTheme.textSecondary,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
