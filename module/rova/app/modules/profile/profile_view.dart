import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rova/gen_a/A.dart';

import '../../routes/app_routes.dart';
import '../../widgets/glass_card.dart';

import 'profile_logic.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileLogic logic = Get.find<ProfileLogic>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 80, 16, 120),
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.14),
                          blurRadius: 22,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        A.assets_rova_logo,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Rova',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
            GestureDetector(
              onTap: () async {
                await logic.refreshCoins();
                Get.toNamed(AppRoutes.coins);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFFD45A),
                              Color(0xFFFFB128),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0x33FFFFFF),
                                Color(0x00FFFFFF),
                                Color(0x11FFFFFF),
                              ],
                              stops: [0.0, 0.55, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 22,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Coins Wallet',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.black.withValues(alpha: 0.70),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.monetization_on_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Obx(() {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${logic.coins.value}',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      'Available coins',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black
                                            .withValues(alpha: 0.65),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.30),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Tap to recharge',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            const GlassCard(
              borderRadius: 18,
              blurSigma: 20,
              backgroundColor: Color(0x66FFFFFF),
              borderColor: Color(0x66FFFFFF),
              shadowColor: Color(0x12000000),
              highlight: true,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _ActionTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Feedback',
                    subtitle: '',
                    routeName: AppRoutes.feedback,
                  ),
                  _Divider(),
                  _ActionTile(
                    icon: Icons.description_outlined,
                    title: 'History',
                    subtitle: '',
                    routeName: AppRoutes.history,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const GlassCard(
              borderRadius: 18,
              blurSigma: 20,
              backgroundColor: Color(0x66FFFFFF),
              borderColor: Color(0x66FFFFFF),
              shadowColor: Color(0x12000000),
              highlight: true,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _ActionTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle: '',
                    routeName: AppRoutes.privacyPolicy,
                  ),
                  _Divider(),
                  _ActionTile(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    subtitle: '',
                    routeName: AppRoutes.termsOfService,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const GlassCard(
              borderRadius: 18,
              blurSigma: 20,
              backgroundColor: Color(0x66FFFFFF),
              borderColor: Color(0x66FFFFFF),
              shadowColor: Color(0x12000000),
              highlight: true,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _ActionTile(
                    icon: Icons.logout_rounded,
                    title: 'Log Out',
                    subtitle: '',
                    routeName: '__logout__',
                    danger: true,
                  ),
                  _Divider(),
                  _ActionTile(
                    icon: Icons.delete_forever_rounded,
                    title: 'Delete Account',
                    subtitle: '',
                    routeName: '__delete_account__',
                    danger: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.routeName,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String routeName;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    const Color pink = Color(0xFFE84B7B);
    final Color iconColor = danger ? const Color(0xFFD92D20) : pink;

    return InkWell(
      onTap: () async {
        if (routeName == '__logout__') {
          showDialog<void>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Log out?'),
                content: const Text('You can log in again at any time.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFD92D20),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Get.offAllNamed(AppRoutes.login);
                    },
                    child: const Text('Log out'),
                  ),
                ],
              );
            },
          );
          return;
        }

        if (routeName == '__delete_account__') {
          final bool? confirmed = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Delete account?'),
                content: const Text(
                  'This will remove local data on this device. '
                  'If you have a server-side account, this will not delete it.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFD92D20),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              );
            },
          );

          if (confirmed == true) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            Get.offAllNamed(AppRoutes.login);
          }
          return;
        }

        if (routeName.isEmpty) {
          Get.snackbar(
            'Coming soon',
            title,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
        Get.toNamed(routeName);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE7EF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: danger
                          ? const Color(0xFFD92D20)
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.2,
                        color: Colors.black.withValues(alpha: 0.62),
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.black.withValues(alpha: 0.35),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.black.withValues(alpha: 0.04),
    );
  }
}

// (intentionally no diffuse blob on the coins card; keep it a clean gold card)
