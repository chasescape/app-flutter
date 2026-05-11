import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riko/riko/app/routes/app_routes.dart';
import 'package:riko/riko/app/widgets/diffuse_background.dart';
import 'package:riko/riko/light_handle.dart';
import 'package:riko/gen_a/A.dart';
import 'package:riko/riko/app/services/coin_store.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: DiffuseBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              _ProfileCard(
                onRecharge: () => Get.toNamed(AppRoutes.coins),
              ),
              const SizedBox(height: 12),
              _MenuItem(
                title: 'Feedback',
                icon: Icons.feedback_outlined,
                onTap: () => Get.toNamed(AppRoutes.feedback),
              ),
              const SizedBox(height: 18),
          _MenuItem(
            title: 'Privacy Policy',
            icon: Icons.privacy_tip_outlined,
            onTap: () => Get.toNamed(AppRoutes.privacyPolicy),
          ),
          const SizedBox(height: 12),
          _MenuItem(
            title: 'Terms of Service',
            icon: Icons.description_outlined,
            onTap: () => Get.toNamed(AppRoutes.termsOfService),
          ),
              const SizedBox(height: 12),
          _MenuItem(
            title: 'Log Out',
            icon: Icons.logout,
            iconBg: const Color(0xFFFFE8D6),
            iconColor: const Color(0xFFFF8A3D),
            onTap: () async {
              _showLoading(context);
              await LightHandle.logout();
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).pop();
                Get.offAllNamed(AppRoutes.login);
              }
            },
          ),
          const SizedBox(height: 12),
          _MenuItem(
            title: 'Delete Account',
            icon: Icons.delete_outline,
            iconBg: const Color(0xFFFFE4E4),
            iconColor: const Color(0xFFFF4D4F),
            titleColor: const Color(0xFFFF4D4F),
            onTap: () async {
              _showDeleteConfirm(context);
            },
          ),
              const SizedBox(height: 12),
              _MenuItem(
                title: 'History',
                icon: Icons.storage_rounded,
                iconBg: const Color(0xFFEFF1F6),
                iconColor: const Color(0xFF6D7485),
                onTap: () => Get.toNamed(AppRoutes.history),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final VoidCallback onRecharge;

  const _ProfileCard({required this.onRecharge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          CircleAvatar(
            radius: 48,
            backgroundColor: const Color(0xFFF3D6DE),
            child: CircleAvatar(
              radius: 46,
              backgroundImage: AssetImage(A.assets_riko_logo),
            ),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8FD3FF), Color(0xFFFFA7D6)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.savings, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Coin Balance',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      SizedBox(height: 2),
                      _CoinBalanceText(),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: onRecharge,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.22),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Recharge'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.title,
    required this.icon,
    this.subtitle,
    this.iconBg = const Color(0xFFF5EEF2),
    this.iconColor = const Color(0xFFEE7FA0),
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: iconBg,
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? const Color(0xFF2B2B2B),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8A8A8A),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFB0B0B0)),
          ],
        ),
      ),
    );
  }
}

class _CoinBalanceText extends StatelessWidget {
  const _CoinBalanceText();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: CoinStore.balance,
      builder: (context, balance, _) {
        return Text(
          balance.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        );
      },
    );
  }
}

void _showLoading(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    ),
  );
}

void _showDeleteConfirm(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFFF4D4F), size: 24),
          SizedBox(width: 8),
          Text('Delete Account?'),
        ],
      ),
      content: const Text(
        'Are you sure you want to delete your account? This action cannot be undone and will:\n\n• Delete all your account data\n• Clear all local data\n• Log you out immediately',
        style: TextStyle(fontSize: 14, height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF6D7485),
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(dialogContext).pop();
            _showLoading(context);
            await LightHandle.deleteAccount();
            if (context.mounted) {
              final nav = Navigator.of(context, rootNavigator: true);
              if (nav.canPop()) {
                nav.pop();
              }
              Get.offAllNamed(AppRoutes.login);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF4D4F),
            foregroundColor: Colors.white,
          ),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
