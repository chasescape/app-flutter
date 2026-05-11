import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vesper/vesper/app/modules/home/home_view.dart';
import 'package:vesper/vesper/app/modules/history/history_view.dart';
import 'package:vesper/vesper/app/modules/profile/profile_view.dart';
import 'package:vesper/vesper/app/modules/generate/generate_view.dart';

import 'nav_logic.dart';

class NavPage extends StatelessWidget {
  NavPage({super.key});

  final NavLogic logic = Get.put(NavLogic());

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(),
      HistoryPage(),
      GeneratePage(),
      ProfilePage(),
    ];

    return Obx(() => Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(
            index: logic.currentIndex.value,
            children: pages,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: BottomNavigationBar(
                        currentIndex: logic.currentIndex.value,
                        onTap: logic.changePage,
                        type: BottomNavigationBarType.fixed,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        selectedItemColor: Colors.white,
                        unselectedItemColor: Colors.white.withValues(alpha: 0.65),
                        selectedFontSize: 12,
                        unselectedFontSize: 12,
                        items: const [
                          BottomNavigationBarItem(
                            icon: Icon(Icons.home),
                            label: 'Home',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.library_books),
                            label: 'Library',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.camera_alt),
                            label: 'Train',
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
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF6B9D),
              Color(0xFFFFA07A),
              Color(0xFFFFD700),
            ],
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
