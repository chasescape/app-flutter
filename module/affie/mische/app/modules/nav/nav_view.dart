import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../emotion/emotion_logic.dart';
import '../home/home_view.dart';
import '../journal/journal_logic.dart';
import '../journal/journal_view.dart';
import '../profile/profile_logic.dart';
import '../profile/profile_view.dart';
import '../tools/tools_logic.dart';
import '../tools/tools_view.dart';
import '../../widgets/glass_card.dart';
import 'nav_logic.dart';

class NavPage extends StatelessWidget {
  NavPage({super.key});

  final NavLogic logic = Get.put(NavLogic());
  final EmotionLogic emotionLogic = Get.put(EmotionLogic(), permanent: true);
  final JournalLogic journalLogic = Get.find<JournalLogic>();
  final ToolsLogic toolsLogic = Get.put(ToolsLogic());
  final ProfileLogic profileLogic = Get.put(ProfileLogic());

  final List<Widget> pages = [
    HomePage(),
    JournalPage(),
    ToolsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: const Color(0xFF0E0E12),
        extendBody: true,
        body: Stack(
          children: [
            Positioned.fill(child: pages[logic.currentIndex.value]),
            Positioned(
              left: 16,
              right: 16,
              bottom: 8 + MediaQuery.of(context).padding.bottom,
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                borderRadius: 30,
                backgroundColor: const Color(0xCC0F1118),
                borderColor: const Color(0x66FFFFFF),
                blur: 18,
                enablePressEffect: false,
                child: SizedBox(
                  height: 64,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _NavItem(
                        icon: Icons.home_rounded,
                        label: 'Home',
                        selected: logic.currentIndex.value == 0,
                        onTap: () => logic.setIndex(0),
                      ),
                      _NavItem(
                        icon: Icons.auto_awesome,
                        label: 'Journal',
                        selected: logic.currentIndex.value == 1,
                        onTap: () => logic.setIndex(1),
                      ),
                      _NavItem(
                        icon: Icons.self_improvement,
                        label: 'Tools',
                        selected: logic.currentIndex.value == 2,
                        onTap: () => logic.setIndex(2),
                      ),
                      _NavItem(
                        icon: Icons.person,
                        label: 'Profile',
                        selected: logic.currentIndex.value == 3,
                        onTap: () => logic.setIndex(3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFFE94AA8) : const Color(0xFF8D8D98);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  height: 1,
                  letterSpacing: 0.4,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
