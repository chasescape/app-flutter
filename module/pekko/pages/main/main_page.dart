import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/main_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../collection/collection_page.dart';
import '../home/home_page.dart';
import '../history/history_page.dart';
import '../analysis/analysis_page.dart';
import '../settings/settings_page.dart';

/// Main page with bottom navigation
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainController>();

    return Scaffold(
      body: Obx(
        () {
          final currentIndex = controller.currentIndex.value;
          const pages = <Widget>[
            HomePage(),
            CollectionPage(),
            HistoryPage(),
            AnalysisPage(),
            SettingsPage(),
          ];

          return IndexedStack(
            index: currentIndex,
            children: List.generate(
              pages.length,
              (index) => HeroMode(
                enabled: currentIndex == index,
                child: pages[index],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Obx(
        () => _CustomBottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
        ),
      ),
    );
  }
}

class _CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
  });

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    _NavItem(
        icon: Icons.grid_view_rounded,
        activeIcon: Icons.grid_view_rounded,
        label: 'Collection'),
    _NavItem(
        icon: Icons.history_outlined,
        activeIcon: Icons.history,
        label: 'Diary'),
    _NavItem(
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart,
        label: 'Insights'),
    _NavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary,
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isActive = currentIndex == index;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isActive ? item.activeIcon : item.icon,
                        color: isActive
                            ? AppColors.primary
                            : AppColors.textDisabled,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: AppTextStyles.small.copyWith(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textDisabled,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
