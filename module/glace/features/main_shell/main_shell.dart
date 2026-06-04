import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/glace_ui.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GlaceScaffold(
      safeArea: false,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFECE7FF),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 14,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(14, 8, 14, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: _isSelected(context, Routes.home),
                onTap: () => context.go(Routes.home),
              ),
              _NavItem(
                icon: Icons.add_circle_rounded,
                label: 'Log',
                isActive: _isSelected(context, Routes.record),
                onTap: () => context.go(Routes.record),
              ),
              _NavItem(
                icon: Icons.favorite_rounded,
                label: 'Me',
                isActive: _isSelected(context, Routes.settings),
                onTap: () => context.go(Routes.settings),
              ),
            ],
          ),
        ),
      ),
      child: child,
    );
  }

  bool _isSelected(BuildContext context, String route) {
    final location = GoRouterState.of(context).uri.path;
    return location == route;
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: 0.78)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isActive
                ? Colors.white.withValues(alpha: 0.94)
                : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isActive
                    ? AppColors.primary
                    : AppColors.textPrimary.withValues(alpha: 0.72),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                fontSize: 11,
                height: 1,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w700,
                color: isActive
                    ? AppColors.primary
                    : AppColors.textPrimary.withValues(alpha: 0.72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
