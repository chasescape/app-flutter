import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import 'home_page.dart';
import 'history_page.dart';
import 'profile_page.dart';
import '../../app/router/app_router.dart';
import '../../app/widgets/bounce_in_animation.dart';
import 'home_tab_controller.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final List<Widget> _pages = const [
    HomePage(),
    HistoryPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A0A2E), Color(0xFF120820)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Page content
          ValueListenableBuilder<int>(
            valueListenable: HomeTabController.index,
            builder: (context, currentIndex, _) {
              return IndexedStack(
                index: currentIndex,
                children: _pages,
              );
            },
          ),
        ],
      ),
      floatingActionButton: BounceInAnimation(
        delay: const Duration(milliseconds: 500),
        duration: const Duration(milliseconds: 600),
        child: FloatingActionButton(
          onPressed: () => AppRouter.toCreate(context),
          backgroundColor: AppColors.accentMain,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
              gradient: AppColors.buttonGradient,
            ),
            child: const Icon(Icons.add_a_photo, color: Colors.white, size: 28),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundPrimary.withOpacity(0.9),
          border: Border(
            top: BorderSide(color: AppColors.cardBorder, width: 0.5),
          ),
        ),
        child: ValueListenableBuilder<int>(
          valueListenable: HomeTabController.index,
          builder: (context, currentIndex, _) {
            return BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) {
                if (index == 1) return;
                HomeTabController.index.value = index;
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore_outlined),
                  activeIcon: Icon(Icons.explore),
                  label: 'Explore',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history_outlined),
                  activeIcon: Icon(Icons.history),
                  label: 'ganerate',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
