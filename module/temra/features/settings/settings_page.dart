import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../gen_a/A.dart';
import '../../env/app_env.dart';
import '../../light_handle.dart';
import '../../routes/app_routes.dart';
import '../../services/coin_manager.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SettingsHeader(),
          const SizedBox(height: AppSpacing.lg),
          _buildProfileCard(),
          const SizedBox(height: AppSpacing.lg),
          _buildWalletCard(context),
          const SizedBox(height: AppSpacing.lg),
          _buildMenuSection(context),
          const SizedBox(height: AppSpacing.lg),
          _buildDangerZone(context),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.heroGradient,
              image: DecorationImage(
                image: AssetImage(A.assets_temra_temra),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NailVibe Muse',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Saving soft, sparkly and playful nail references.',
                  style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Wallet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Coins Balance',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${CoinManager.to.coins}',
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 140,
                  child: AppButton(
                    text: 'Get Coins',
                    onPressed: () => context.push(AppRoutes.coins),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        children: [
          _menuItem(icon: Icons.history_rounded, title: 'History', onTap: () => context.go(AppRoutes.history)),
          _menuItem(icon: Icons.feedback_rounded, title: 'Feedback', onTap: () => context.push(AppRoutes.feedback)),
          _menuItem(
            icon: Icons.privacy_tip_rounded,
            title: 'Privacy Policy',
            onTap: () => AppRoutes.toAgreement('Privacy Policy', AppEnv().h5Privacy),
          ),
          _menuItem(
            icon: Icons.description_rounded,
            title: 'Terms of Service',
            onTap: () => AppRoutes.toAgreement('Terms of Service', AppEnv().h5User),
          ),
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.secondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textDisabled),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        children: [
          _menuItem(
            icon: Icons.logout_rounded,
            title: 'Sign Out',
            onTap: () => _showLogoutDialog(context),
          ),
          _menuItem(
            icon: Icons.delete_forever_rounded,
            title: 'Delete Account',
            onTap: () => _showDeleteAccountDialog(context),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                LightHandle.logout();
              });
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete all your data, including history and coins.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  _showDeleteConfirmDialog(context);
                }
              });
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Final Confirmation'),
        content: const Text(
          'Are you absolutely sure? All data will be permanently lost and cannot be recovered.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                LightHandle.clearAllData();
              });
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage your account and balance.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                height: 1.25,
              ),
        ),
      ],
    );
  }
}
