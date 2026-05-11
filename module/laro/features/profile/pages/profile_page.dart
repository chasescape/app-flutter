import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../gen_a/A.dart';
import '../../../core/app_routes.dart';
import '../../../core/app_theme.dart';
import '../../../core/pink_ui.dart';
import '../../../env/app_env.dart';
import '../../../light_handle.dart';
import '../../../services/coins_manager.dart';
import '../../home/providers/lash_provider.dart';
import '../providers/profile_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PinkPageScaffold(
      leading: const PinkBackButton(onTap: AppRoutes.back),
      title: 'Profile',
      centerTitle: true,
      child: Consumer2<LashProvider, ProfileProvider>(
        builder: (context, lashProvider, profileProvider, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PinkGlassCard(
                  child: Column(
                    children: [
                      Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          gradient: AppTheme.heroGradient,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Image.asset(
                            A.assets_laro_lash_preview_larologo,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingLg),
                      Text(
                        'Laro',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      Text(
                        '${lashProvider.history.length} previews saved in your soft archive.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      ValueListenableBuilder<int>(
                        valueListenable: CoinsManager().coinsNotifier,
                        builder: (context, coins, child) {
                          return PinkPill(
                            text: '$coins coins available',
                            backgroundColor: AppTheme.secondaryLight,
                            icon: Icons.monetization_on_rounded,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMd),
                _MenuGroupCard(
                  items: [
                    _MenuItemData(
                      title: 'Preview History',
                      subtitle: '${lashProvider.history.length} saved looks',
                      icon: Icons.history_rounded,
                      onTap: AppRoutes.toHistory,
                    ),
                    const _MenuItemData(
                      title: 'Coin Store',
                      subtitle: 'Top up for more previews',
                      icon: Icons.shopping_bag_outlined,
                      onTap: AppRoutes.toCoinStore,
                    ),
                    const _MenuItemData(
                      title: 'Feedback',
                      subtitle: 'Share what should feel even more polished',
                      icon: Icons.chat_bubble_outline_rounded,
                      onTap: AppRoutes.toFeedback,
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingMd),
                _MenuGroupCard(
                  items: [
                    _MenuItemData(
                      title: 'Terms of Service',
                      subtitle: 'Review the legal text',
                      icon: Icons.description_outlined,
                      onTap: () => AppRoutes.toAgreement(
                          'Terms of Service', AppEnv().h5User),
                    ),
                    _MenuItemData(
                      title: 'Privacy Policy',
                      subtitle: 'Read how the app handles data',
                      icon: Icons.privacy_tip_outlined,
                      onTap: () => AppRoutes.toAgreement(
                          'Privacy Policy', AppEnv().h5Privacy),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingMd),
                _MenuGroupCard(
                  items: [
                    _MenuItemData(
                      title: 'Sign Out',
                      subtitle: 'Return to the start screen',
                      icon: Icons.logout_rounded,
                      destructive: true,
                      onTap: () => _showExitDialog(context),
                    ),
                    _MenuItemData(
                      title: 'Delete',
                      subtitle: 'Delete local previews and coin data',
                      icon: Icons.delete_forever_outlined,
                      destructive: true,
                      onTap: () =>
                          _showClearDataDialog(context, profileProvider),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingLg),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Return to the welcome screen?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await LightHandle.logout();
                AppRoutes.toLogin();
              },
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  void _showClearDataDialog(
      BuildContext context, ProfileProvider profileProvider) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear All Data'),
          content: const Text(
              'This removes local history and coins. You cannot undo it.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await profileProvider.clearAllData();
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                  AppRoutes.toLogin();
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.error,
              ),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }
}

class _MenuItemData {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool destructive;

  const _MenuItemData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.destructive = false,
  });
}

class _MenuGroupCard extends StatelessWidget {
  final List<_MenuItemData> items;

  const _MenuGroupCard({
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return PinkGlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            _MenuRow(item: items[index]),
            if (index != items.length - 1)
              Divider(
                height: 1,
                indent: 76,
                endIndent: AppTheme.spacingMd,
                color: AppTheme.surfaceColor.withValues(alpha: 0.7),
              ),
          ],
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final _MenuItemData item;

  const _MenuRow({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = item.destructive ? AppTheme.error : AppTheme.textPrimary;

    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.destructive
                    ? AppTheme.error.withValues(alpha: 0.12)
                    : AppTheme.secondaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(item.icon, color: iconColor),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: item.destructive
                              ? AppTheme.error
                              : AppTheme.textPrimary,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spacingXs),
                  Text(
                    item.subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: item.destructive ? AppTheme.error : AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
