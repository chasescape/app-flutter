import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimiu/mimiu/app/modules/home/home_view.dart';
import 'package:mimiu/mimiu/app/modules/nav/nav_logic.dart';
import 'package:mimiu/mimiu/app/modules/profile/profile_view.dart';
import 'package:mimiu/mimiu/app/widgets/symmetric_gradient_background.dart';

import '../upload/upload_view.dart';

class NavPage extends GetView<NavLogic> {
  const NavPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: SymmetricGradientBackground()),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Obx(() {
                    switch (controller.currentView.value) {
                      case NavViewType.home:
                        return HomePage();
                      case NavViewType.upload:
                        return const UploadPage();
                      case NavViewType.profile:
                        return ProfilePage();
                    }
                  }),
                ),
                _BottomNavigation(
                  current: controller.currentView,
                  onChanged: controller.setView,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.current,
    required this.onChanged,
  });

  final Rx<NavViewType> current;
  final void Function(NavViewType) onChanged;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.60),
              border: Border(
                top: BorderSide(
                  color: const Color(0xFF78350F).withValues(alpha: 0.30),
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  label: 'Home',
                  icon: Icons.home_rounded,
                  active: current.value == NavViewType.home,
                  onTap: () => onChanged(NavViewType.home),
                ),
                _NavItem(
                  label: 'Upload',
                  icon: Icons.cloud_upload_rounded,
                  active: current.value == NavViewType.upload,
                  showPing: true,
                  onTap: () => onChanged(NavViewType.upload),
                ),
                _NavItem(
                  label: 'Profile',
                  icon: Icons.person_rounded,
                  active: current.value == NavViewType.profile,
                  onTap: () => onChanged(NavViewType.profile),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
    this.showPing = false,
  });

  final String label;
  final IconData icon;
  final bool active;
  final bool showPing;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  late final AnimationController _ping = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat();

  @override
  void dispose() {
    _ping.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fg = widget.active ? const Color(0xFFF59E0B) : Colors.grey.shade400;
    final bg = widget.active
        ? const Color(0xFF422006).withValues(alpha: 0.40)
        : Colors.transparent;

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: widget.active
              ? [
                  BoxShadow(
                    color: const Color(0xFF78350F).withValues(alpha: 0.30),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(widget.icon, size: 24, color: fg),
                if (widget.active && widget.showPing)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: AnimatedBuilder(
                      animation: _ping,
                      builder: (context, _) {
                        final t = _ping.value;
                        return Opacity(
                          opacity: (1 - t).clamp(0.0, 1.0),
                          child: Transform.scale(
                            scale: 0.8 + 0.8 * t,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF59E0B),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
