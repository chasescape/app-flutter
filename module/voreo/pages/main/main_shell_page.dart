import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/main_tab_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../generate/generate_page.dart';
import '../home/home_page.dart';
import '../settings/settings_page.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  late final MainTabController _controller;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<MainTabController>()
        ? Get.find<MainTabController>()
        : Get.put(MainTabController(), permanent: true);
    _pages = const [
      HomePage(),
      GeneratePage(showBackButton: false),
      SettingsPage(showBackButton: false),
    ];
    _controller.changeTab(_tabFromArguments(Get.arguments));
  }

  MainTab _tabFromArguments(Object? arguments) {
    if (arguments is Map) {
      final Object? tab = arguments['tab'];
      if (tab is String) {
        return MainTab.values.firstWhere(
          (item) => item.name == tab,
          orElse: () => MainTab.home,
        );
      }
    }
    return MainTab.home;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Obx(
        () => _pages[_controller.currentIndex.value],
      ),
      bottomNavigationBar: Obx(
        () => _SimpleBottomNavigation(
          currentIndex: _controller.currentIndex.value,
          onTap: _controller.changeByIndex,
        ),
      ),
    );
  }
}

class _SimpleBottomNavigation extends StatelessWidget {
  const _SimpleBottomNavigation({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.cardStroke),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _SimpleNavButton(
              label: 'Home',
              icon: Icons.home_rounded,
              selected: currentIndex == MainTab.home.index,
              onTap: () => onTap(MainTab.home.index),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _SimpleNavButton(
              label: 'Upload',
              icon: Icons.cloud_upload_rounded,
              selected: currentIndex == MainTab.generate.index,
              onTap: () => onTap(MainTab.generate.index),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _SimpleNavButton(
              label: 'Profile',
              icon: Icons.person_rounded,
              selected: currentIndex == MainTab.profile.index,
              onTap: () => onTap(MainTab.profile.index),
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleNavButton extends StatelessWidget {
  const _SimpleNavButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const Color activeBg = AppColors.primaryMain;
    const Color activeColor = AppColors.white;
    const Color inactiveColor = AppColors.textGrey;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x33F55CA8),
                    blurRadius: 20,
                    spreadRadius: -8,
                    offset: Offset(0, 8),
                  ),
                ]
              : const [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.small.copyWith(
                color: selected ? activeColor : inactiveColor,
                fontWeight: FontWeight.w700,
                fontSize: 11,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
