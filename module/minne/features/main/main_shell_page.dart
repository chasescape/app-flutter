import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../create/create_page.dart';
import '../history/history_page.dart';
import '../home/home_page.dart';
import '../profile/profile_page.dart';

class MainShellController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void setIndex(int index) {
    currentIndex.value = index;
  }
}

class MainShellPage extends StatefulWidget {
  final int initialIndex;

  const MainShellPage({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  static const Color _berryPrimary = Color(0xFF8F355B);
  static const Color _berrySecondary = Color(0xFFB06A84);
  static const Color _navShellStart = Color(0xFFFFFCFE);
  static const Color _navShellEnd = Color(0xFFFFF2F7);
  static const Color _navActiveStart = Color(0xFFFFB2CB);
  static const Color _navActiveEnd = Color(0xFFFFDB84);

  late final MainShellController _controller;

  final List<Widget> _pages = const [
    HomePage(showBottomNav: false),
    CreatePage(),
    HistoryPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<MainShellController>()
        ? Get.find<MainShellController>()
        : Get.put(MainShellController(), permanent: true);
    _controller.setIndex(widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            IndexedStack(
              index: _controller.currentIndex.value,
              children: _pages,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomNav(_controller.currentIndex.value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(int currentIndex) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Container(
          height: 74,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_navShellStart, _navShellEnd],
            ),
            borderRadius: AppBorderRadius.borderRadiusFull,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.92),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: _berrySecondary.withValues(alpha: 0.10),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildNavIcon(0, Icons.home_rounded, 'Home', currentIndex),
              ),
              Expanded(
                child: _buildNavIcon(1, Icons.add_circle_rounded, 'Create', currentIndex),
              ),
              Expanded(
                child: _buildNavIcon(2, Icons.history_rounded, 'History', currentIndex),
              ),
              Expanded(
                child: _buildNavIcon(3, Icons.person_rounded, 'Profile', currentIndex),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(
    int index,
    IconData icon,
    String label,
    int currentIndex,
  ) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => _controller.setIndex(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: AppBorderRadius.borderRadiusFull,
          gradient: isActive
              ? const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    _navActiveStart,
                    _navActiveEnd,
                  ],
                )
              : null,
          color: isActive ? null : Colors.transparent,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: _navActiveStart.withValues(alpha: 0.22),
                    blurRadius: 10,
                    offset: const Offset(-2, 4),
                  ),
                  BoxShadow(
                    color: _navActiveEnd.withValues(alpha: 0.28),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? _berryPrimary : _berrySecondary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.smallStyle.copyWith(
                fontSize: 10,
                height: 1.0,
                color: isActive ? _berryPrimary : _berrySecondary,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
