import 'package:flutter/material.dart';
import 'package:havki/gen_a/A.dart';
import 'package:havki/havki/app/routes/app_routes.dart';
import 'package:havki/havki/app/services/coins_manager.dart';
import 'package:havki/havki/app/theme/app_theme.dart';
import 'package:havki/havki/env/app_env.dart';
import 'package:havki/havki/services/quote_vibe_storage_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                AppCircleIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: AppSpacing.md),
                const Expanded(
                  child: AppSectionTitle(
                    eyebrow: 'Profile',
                    title: 'Your calm corner',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppGlassCard(
                      child: Row(
                        children: [
                          _AvatarBadge(),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Havki',
                                  style: TextStyle(
                                    fontSize: AppFontSizes.h3,
                                    fontWeight: AppFontWeights.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const _SectionLabel('Support'),
                    _menuGroupCard(
                      context,
                      items: [
                        _MenuItemData(
                          icon: Icons.feedback_outlined,
                          title: 'Feedback',
                          subtitle: 'Tell us what feels good and what still needs smoothing.',
                          onTap: AppNavigator.I.toFeedback,
                        ),
                        _MenuItemData(
                          icon: Icons.workspace_premium_outlined,
                          title: 'Coin Store',
                          subtitle: 'Add more credits for new analyses.',
                          onTap: AppNavigator.I.toStore,
                        ),
                        _MenuItemData(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy',
                          subtitle: 'How we handle your data.',
                          onTap: () => AppNavigator.I.toAgreement(
                            'Privacy Policy',
                            AppEnv().h5Privacy,
                          ),
                        ),
                        _MenuItemData(
                          icon: Icons.description_outlined,
                          title: 'Terms',
                          subtitle: 'Rules and billing terms.',
                          onTap: () => AppNavigator.I.toAgreement(
                            'Terms',
                            AppEnv().h5User,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const _SectionLabel('Account'),
                    _menuGroupCard(
                      context,
                      items: [
                        _MenuItemData(
                          icon: Icons.logout_rounded,
                          title: 'Log Out',
                          subtitle: 'Sign out on this device and keep your setup safe.',
                          onTap: () => _confirmLogout(context),
                        ),
                        _MenuItemData(
                          icon: Icons.person_remove_outlined,
                          title: 'Delete Account',
                          subtitle: 'Clear saved data from this device and start fresh.',
                          onTap: () => _confirmDeleteAccount(context),
                          accentColor: AppColors.error,
                          trailingColor: AppColors.error,
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

  Widget _menuGroupCard(
    BuildContext context, {
    required List<_MenuItemData> items,
  }) {
    return AppGlassCard(
      child: Column(
        children: [
          for (int index = 0; index < items.length; index++) ...[
            _menuRow(context, item: items[index]),
            if (index != items.length - 1) const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }

  Widget _menuRow(
    BuildContext context, {
    required _MenuItemData item,
  }) {
    final Color resolvedAccentColor = item.accentColor ?? AppColors.secondary;
    final Color resolvedTrailingColor = item.trailingColor ?? AppColors.textSecondary;

    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: resolvedAccentColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item.icon, color: item.accentColor ?? AppColors.textPrimary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: AppFontSizes.body,
                      fontWeight: AppFontWeights.semibold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: AppFontSizes.caption,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: resolvedTrailingColor),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final bool? confirmed = await _showActionDialog(
      context,
      title: 'Log out?',
      message: 'You will be signed out on this device.',
      actionLabel: 'Log Out',
    );

    if (confirmed != true || !context.mounted) return;

    await AppNavigator.I.toLogin();
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final bool? confirmed = await _showActionDialog(
      context,
      title: 'Delete account?',
      message: 'This clears your saved data on this device and returns you to login.',
      actionLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed != true || !context.mounted) return;

    final historyService = QuoteVibeStorageService.instance;
    await historyService.initialize();
    await historyService.clearHistory();

    final coinsManager = CoinsManager();
    await coinsManager.initialize();
    await coinsManager.clear();

    await AppNavigator.I.toLogin();
  }

  Future<bool?> _showActionDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String actionLabel,
    bool isDestructive = false,
  }) {
    final Color actionColor = isDestructive ? AppColors.error : AppColors.textPrimary;

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                actionLabel,
                style: TextStyle(color: actionColor),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: AppFontSizes.small,
          fontWeight: AppFontWeights.semibold,
          letterSpacing: 1.2,
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
  final Color? accentColor;
  final Color? trailingColor;

  const _MenuItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.accentColor,
    this.trailingColor,
  });
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.glow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.asset(
          A.assets_Havkilogo,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
