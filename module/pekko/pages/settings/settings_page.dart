import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../gen_a/A.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/main_controller.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';

/// Settings page
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    final mainController = Get.find<MainController>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            backgroundColor: AppColors.backgroundPrimary,
            pinned: true,
            automaticallyImplyLeading: false,
            title: Text('Settings'),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.backgroundSecondary,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.lg,
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: AppTheme.framedCardDecoration(
                      color: AppColors.backgroundElevated,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.asset(
                            A.assets_pekko_logo,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Archive Studio',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Pekko',
                                style: AppTextStyles.h2,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Your Pekko account and personal space.',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Obx(
                    () => Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: AppTheme.cardDecoration(
                        color: AppColors.backgroundElevated,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _HeroMetric(
                              label: 'Coin balance',
                              value: '${mainController.currentCoins}',
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 36,
                            color: AppColors.backgroundTertiary,
                          ),
                          const Expanded(
                            child: _HeroMetric(
                              label: 'Plan',
                              value: 'Classic',
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          SizedBox(
                            height: 40,
                            child: OutlinedButton(
                              onPressed: controller.openCoinStore,
                              child: const Text('Top up'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FeaturePanel(
                    title: 'Archive Studio',
                    subtitle:
                        'Keep your fragrance diary tidy, available, and ready for quick logging.',
                    actionLabel: 'Open store',
                    onTap: controller.openCoinStore,
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: const [
                          Expanded(
                            child: _MiniInfoTile(
                              icon: Icons.grid_view_rounded,
                              title: 'Collection',
                              subtitle: 'Organize the bottles you own.',
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _MiniInfoTile(
                              icon: Icons.bar_chart_outlined,
                              title: 'Insights',
                              subtitle: 'Review your wearing patterns locally.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const _SectionLabel('Account'),
                  const SizedBox(height: AppSpacing.sm),
                  _SettingsCluster(
                    children: [
                      _SettingsEntry(
                        icon: Icons.description_outlined,
                        title: 'Terms of Service',
                        subtitle: 'Read the latest legal terms.',
                        onTap: controller.openTermsOfService,
                      ),
                      _SettingsEntry(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        subtitle: 'See how your scent data is handled.',
                        onTap: controller.openPrivacyPolicy,
                      ),
                      _SettingsEntry(
                        icon: Icons.chat_bubble_outline_rounded,
                        title: 'Help & Feedback',
                        subtitle: 'Contact us or share product suggestions.',
                        onTap: controller.openFeedback,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const _SectionLabel('Library'),
                  const SizedBox(height: AppSpacing.sm),
                  _SettingsCluster(
                    children: [
                      _SettingsEntry(
                        icon: Icons.logout_rounded,
                        title: 'Log Out',
                        subtitle: 'Sign out from this fragrance diary.',
                        onTap: controller.logout,
                      ),
                      _SettingsEntry(
                        icon: Icons.delete_outline_rounded,
                        title: 'Delete Account',
                        subtitle:
                            'Permanently remove entries and account data.',
                        isDestructive: true,
                        onTap: controller.clearAllData,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String label;
  final String value;

  const _HeroMetric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.small.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturePanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;
  final Widget child;

  const _FeaturePanel({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: AppBorderRadius.allLarge,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.softHighlightGradient,
        ),
        border: Border.all(
          color: AppColors.accentDark.withValues(alpha: 0.24),
        ),
        boxShadow: const [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.h2),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onTap,
                child: Text(actionLabel),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _MiniInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MiniInfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppTheme.cardDecoration(
        color: AppColors.backgroundElevated,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: AppTextStyles.h3.copyWith(fontSize: 16)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: AppTextStyles.small,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;

  const _SectionLabel(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: AppTextStyles.labelLarge.copyWith(
        color: AppColors.textMuted,
      ),
    );
  }
}

class _SettingsCluster extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCluster({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration(
        color: AppColors.backgroundElevated,
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsEntry extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsEntry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final tone = isDestructive ? AppColors.error : AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: AppBorderRadius.allLarge,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.error.withValues(alpha: 0.08)
                    : AppColors.backgroundSecondary,
                borderRadius: AppBorderRadius.allMedium,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isDestructive ? AppColors.error : AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.h3.copyWith(
                      fontSize: 16,
                      color: tone,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: AppTextStyles.small.copyWith(
                      color: isDestructive
                          ? AppColors.error.withValues(alpha: 0.82)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDestructive ? AppColors.error : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
