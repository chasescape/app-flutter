import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../generate/generate_view.dart';
import '../home/home_view.dart';
import '../profile/profile_view.dart';
import '../../widgets/rova_background.dart';
import 'nav_logic.dart';

class NavPage extends StatelessWidget {
  const NavPage({super.key});

  @override
  Widget build(BuildContext context) {
    final NavLogic logic = Get.find<NavLogic>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RovaBackground(
        blurSigma: 4,
        overlayColor: const Color(0x22FFFFFF),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x33FFE7EF),
            Color(0x22FFFFFF),
          ],
        ),
        child: Obx(() {
          final index = logic.tabIndex.value;
          return Stack(
            children: [
              IndexedStack(
                index: index,
                children: const [
                  HomePage(),
                  GeneratePage(),
                  ProfilePage(),
                ],
              ),
              _FrostedTabBar(
                index: index,
                onTap: (i) {
                  logic.setTab(i);
                },
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _FrostedTabBar extends StatelessWidget {
  const _FrostedTabBar({
    required this.index,
    required this.onTap,
  });

  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const Color pink = Color(0xFFE84B7B);

    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: SafeArea(
        top: false,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.50),
                borderRadius: BorderRadius.circular(44),
                border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TabItem(
                    label: 'Home',
                    icon: Icons.home_rounded,
                    active: index == 0,
                    activeColor: pink,
                    onTap: () => onTap(0),
                  ),
                  _TabItem(
                    label: 'Generate',
                    icon: Icons.auto_awesome_rounded,
                    active: index == 1,
                    activeColor: pink,
                    onTap: () => onTap(1),
                  ),
                  _TabItem(
                    label: 'Profile',
                    icon: Icons.person_rounded,
                    active: index == 2,
                    activeColor: pink,
                    onTap: () => onTap(2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color =
        active ? activeColor : Colors.black.withValues(alpha: 0.55);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
