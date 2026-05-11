/// ---------------------------------------------------------------------------
/// File: profile_view.dart
/// Description: Kissmi profile page entry, wired with GetX routing.
/// ---------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widget/kissmi_background.dart';
import '../../../../gen_a/A.dart';
import '../../routes/app_routes.dart';
import 'profile_logic.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final ProfileLogic logic = Get.put(ProfileLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: KissmiBackground(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text('Profile'),
                centerTitle: true,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Image.asset(
                              A.assets_kissmi_logo,
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Kissmi',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.95),
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'AI companion',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _RechargeCard(
                        onTap: () => Get.toNamed(AppRoutes.coins),
                      ),
                      const SizedBox(height: 18),
                      _ProfileCard(
                        title: 'Account',
                        items: <_ProfileItem>[
                          _ProfileItem(
                            icon: Icons.delete_outline,
                            label: 'Delete Account',
                            onTap: () => logic.confirmDeleteAccount(),
                          ),
                          _ProfileItem(
                            icon: Icons.logout,
                            label: 'Logout',
                            onTap: () => logic.confirmLogout(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const _ProfileCard(
                        title: 'Support',
                        items: <_ProfileItem>[
                          _ProfileItem(
                            icon: Icons.help,
                            label: 'Feedback',
                            route: AppRoutes.feedback,
                          ),
                          _ProfileItem(
                            icon: Icons.privacy_tip_outlined,
                            label: 'Privacy Policy',
                            route: AppRoutes.privacyPolicy,
                          ),
                          _ProfileItem(
                            icon: Icons.description_outlined,
                            label: 'Terms of service',
                            route: AppRoutes.termsOfService,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RechargeCard extends StatelessWidget {
  const _RechargeCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFF7C3AED),
              Color(0xFFEC4899),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.monetization_on,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Coins Balance',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Top up',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(
              () => Text(
                Get.find<ProfileLogic>().balance.value.toString(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.98),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Available coins',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.title,
    required this.items,
  });

  final String title;
  final List<_ProfileItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B203B).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.7),
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 10),
          ...items.map((item) => _ProfileRow(item: item)).toList(),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.item,
  });

  final _ProfileItem item;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? onTap = item.onTap ??
        (item.route == null ? null : () => Get.toNamed(item.route!));
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: <Widget>[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileItem {
  const _ProfileItem({
    required this.icon,
    required this.label,
    this.route,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? route;
  final VoidCallback? onTap;
}
