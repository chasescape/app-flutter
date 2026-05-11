import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paech/gen_a/A.dart';

import '../generate/generate_view.dart';
import '../home/home_view.dart';
import '../profile/profile_view.dart';
import 'nav_logic.dart';

class NavPage extends StatelessWidget {
  NavPage({super.key});

  final NavLogic logic = Get.put(NavLogic());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final index = logic.tabIndex.value;

      return Scaffold(
        backgroundColor: const Color(0xFFF6F1EA),
        body: IndexedStack(
          index: index,
          children: [
            HomePage(),
            GeneratePage(),
            ProfilePage(),
          ],
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            currentIndex: index,
            onTap: logic.changeTab,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFFD0B08E),
            unselectedItemColor: const Color(0xFF9A948C),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  A.assets_paech_ic_create,
                  width: 24,
                  height: 24,
                ),
                activeIcon: Image.asset(
                  A.assets_paech_ic_create,
                  width: 24,
                  height: 24,
                ),
                label: 'Generate',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      );
    });
  }
}
