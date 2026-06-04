import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../gen_a/A.dart';
import '../../interface.dart';
import '../../light_handle.dart';
import '../../managers/coins_manager.dart';
import '../../providers/app_state.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glido_ui.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlidoPageBackground(
        topSafeArea: true,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spacingMd,
                  AppTheme.spacingMd,
                  AppTheme.spacingMd,
                  0,
                ),
                child: _ProfileHero(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spacingMd,
                  AppTheme.spacingLg,
                  AppTheme.spacingMd,
                  270,
                ),
                child: Column(
                  children: [
                    _BalanceCard(),
                    const SizedBox(height: AppTheme.spacingLg),
                    _MenuCard(
                      items: [
                        _MenuItemData(
                          icon: Icons.photo_library_outlined,
                          title: 'Image archive',
                          subtitle: 'Browse every saved image-led card',
                          onTap: () => context.push(AppRoutes.library),
                        ),
                        _MenuItemData(
                          icon: Icons.storefront_rounded,
                          title: 'Coin store',
                          subtitle: 'Top up credits for new saves',
                          onTap: () => context.push(AppRoutes.coinStore),
                        ),
                        _MenuItemData(
                          icon: Icons.feedback_outlined,
                          title: 'Feedback',
                          subtitle:
                              'Tell us what feels good and what needs polish',
                          onTap: () => context.push(AppRoutes.feedback),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    _MenuCard(
                      items: [
                        _MenuItemData(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy policy',
                          subtitle: 'Read how Glido handles your data',
                          onTap: () => AppRoutes.toAgreement(
                            context,
                            'Privacy Policy',
                            Interface().h5Privacy,
                          ),
                        ),
                        _MenuItemData(
                          icon: Icons.description_outlined,
                          title: 'Terms of service',
                          subtitle: 'Review the rules for using the app',
                          onTap: () => AppRoutes.toAgreement(
                            context,
                            'Terms of Service',
                            Interface().h5User,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    _MenuCard(
                      items: [
                        _MenuItemData(
                          icon: Icons.logout_rounded,
                          title: 'Log out',
                          subtitle: 'Return to the welcome screen',
                          onTap: () => _showLogoutDialog(context),
                        ),
                        _MenuItemData(
                          icon: Icons.delete_forever_rounded,
                          title: 'Delete account',
                          subtitle:
                              'Permanently remove your records, balance, and local data',
                          destructive: true,
                          onTap: () => _showDeleteAccountDialog(context),
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
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Are you sure you want to leave Glido for now?'),
            const SizedBox(height: AppTheme.spacingLg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(dialogContext);
                      if (!context.mounted) return;
                      await LightHandle.logout();
                      if (context.mounted) {
                        context.go(AppRoutes.login);
                      }
                    },
                    child: const Text('Log out'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: const [],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'This removes all cards, balance data, and local account information. This action cannot be undone.',
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(dialogContext);
                      if (!context.mounted) return;
                      await LightHandle.deleteAccount();
                      if (context.mounted) {
                        context.read<AppState>().clearLocalData();
                      }
                      if (context.mounted) {
                        context.go(AppRoutes.login);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.error,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: const [],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlidoSurface(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            child: Image.asset(
              A.assets_glido_logo,
              width: 68,
              height: 68,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Glido',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  'Keep your visual references warm, clean, and image-first.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CoinsManager(),
      builder: (context, _) {
        return GlidoSurface(
          gradient: AppTheme.highlightGradient,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Balance',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.42),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                    child: const Icon(
                      Icons.monetization_on_rounded,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Text(
                    '${CoinsManager().balance}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingLg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push(AppRoutes.coinStore),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.86),
                    foregroundColor: AppTheme.textPrimary,
                  ),
                  child: const Text('Get more coins'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<_MenuItemData> items;

  const _MenuCard({
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return GlidoSurface(
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingXs,
                ),
                child: _ProfileMenuItem(item: item),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final _MenuItemData item;

  const _ProfileMenuItem({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final color = item.destructive ? AppTheme.error : AppTheme.textPrimary;
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingSm,
          vertical: AppTheme.spacingSm,
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: item.destructive
                    ? AppTheme.error.withValues(alpha: 0.1)
                    : AppTheme.bgSecondary,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Icon(item.icon, color: color),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: color,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spacingXs),
                  Text(
                    item.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;

  const _MenuItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });
}
