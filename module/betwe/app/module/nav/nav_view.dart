import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/app_colors.dart';
import '../coins/coins_view.dart';
import '../generate/generate_view.dart';
import '../home/home_view.dart';
import '../profile/profile_view.dart';
import 'nav_logic.dart';

class NavPage extends StatelessWidget {
  NavPage({Key? key}) : super(key: key);

  final NavLogic logic = Get.put(NavLogic());

  final List<Widget> pages = [
    HomePage(),
    GeneratePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: PageView(
          controller: logic.pageController,
          onPageChanged: logic.onPageChanged,
          physics: const NeverScrollableScrollPhysics(),
          children: pages,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: BottomNavigationBar(
              currentIndex: logic.currentIndex.value,
              onTap: logic.onTap,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: const Color(0xFFFF6B9D),
              unselectedItemColor: Colors.grey,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_filled),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.auto_awesome),
                  label: 'Generate',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
