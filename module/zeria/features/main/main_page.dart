import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zeria/zeria/constants/app_colors.dart';
import 'package:zeria/zeria/constants/app_dimensions.dart';
import 'package:zeria/zeria/constants/app_routes.dart';
import 'package:zeria/zeria/constants/app_strings.dart';
import 'package:zeria/zeria/constants/app_text_styles.dart';
import 'package:zeria/zeria/features/create/create_page.dart';
import 'package:zeria/zeria/features/history/history_page.dart';
import 'package:zeria/zeria/features/home/home_page.dart';
import 'package:zeria/zeria/features/profile/profile_page.dart';
import 'package:zeria/zeria/widgets/zeria_ui.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    HomePage(),
    CreatePage(),
    HistoryPage(),
    ProfilePage(),
  ];

  final List<_MainTab> _tabs = const [
    _MainTab(label: AppStrings.home, icon: Icons.grid_view_rounded, index: 0),
    _MainTab(
        label: AppStrings.create, icon: Icons.auto_awesome_rounded, index: 1),
    _MainTab(
        label: AppStrings.history,
        icon: Icons.collections_bookmark_rounded,
        index: 2),
    _MainTab(
        label: AppStrings.profile,
        icon: Icons.person_outline_rounded,
        index: 3),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant MainPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      _currentIndex = widget.initialIndex;
    }
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
    });
    context.go(AppRoutes.buildMainTabUrl(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: ZeriaSurfaceCard(
          radius: 30,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: _tabs.map((tab) {
              final isActive = tab.index == _currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onTabTapped(tab.index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isActive ? AppColors.accentGradient : null,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab.icon,
                          size: 22,
                          color:
                              isActive ? Colors.white : AppColors.textSecondary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tab.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.small.copyWith(
                            color: isActive
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _MainTab {
  const _MainTab({
    required this.label,
    required this.icon,
    required this.index,
  });

  final String label;
  final IconData icon;
  final int index;
}
