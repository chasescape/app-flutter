import 'package:flira/flira/app/modules/chat/chat_view.dart';
import 'package:flira/flira/app/modules/home/home_view.dart';
import 'package:flira/flira/app/modules/profile/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'nav_logic.dart';

class NavPage extends StatelessWidget {
  NavPage({Key? key}) : super(key: key);

  final NavLogic logic = Get.put(NavLogic());

  final List<Widget> _pages = <Widget>[
    HomePage(),
    ChatPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: logic.currentIndex.value,
          children: _pages,
        ),
        bottomNavigationBar: _BottomBar(
          currentIndex: logic.currentIndex.value,
          onTap: logic.changeTab,
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 82,
        decoration: const BoxDecoration(
          color: Color(0xFFFDFBFC),
          border: Border(
            top: BorderSide(color: Color(0xFFF6DCE4), width: 1),
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: _NavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: 'Home',
                    selected: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                ),
                const SizedBox(width: 96),
                Expanded(
                  child: _NavItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: 'Profile',
                    selected: currentIndex == 2,
                    onTap: () => onTap(2),
                  ),
                ),
              ],
            ),
            Positioned(
              top: -8,
              child: GestureDetector(
                onTap: () => onTap(1),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF79AB0),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: const Color(0xFFF79AB0).withOpacity(0.32),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 30),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Record',
                      style: TextStyle(
                        fontSize: 12,
                        color: currentIndex == 1
                            ? const Color(0xFF8B8290)
                            : const Color(0xFFA8A1AB),
                        fontWeight: currentIndex == 1 ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
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
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = selected ? const Color(0xFF8F8AA0) : const Color(0xFF9FA0AE);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(selected ? activeIcon : icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
