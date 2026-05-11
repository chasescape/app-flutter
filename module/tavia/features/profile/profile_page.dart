import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tavia/gen_a/A.dart';

import '../../core/router/app_routes.dart';
import '../../core/state/state_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/dialog_widget.dart';
import '../../core/widgets/tavia_ui.dart';
import '../../env/app_env.dart';
import '../../interface.dart';
import '../../light_handle.dart';
import '../../shared/constants/app_constants.dart';

/// Profile page unified with the new gallery styling.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TaviaBackground(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacingLg,
              AppConstants.spacingMd,
              AppConstants.spacingLg,
              AppConstants.spacingXxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: AppConstants.spacingLg),
                _buildHeroCard(),
                const SizedBox(height: AppConstants.spacingLg),
                _buildMenuSection(
                  context,
                  title: 'Explore',
                  items: [
                    _ProfileMenuItem(
                      icon: Icons.history,
                      title: 'History',
                      subtitle: 'Revisit saved image cards',
                      onTap: () => context.push(AppRoutes.history),
                    ),
                    _ProfileMenuItem(
                      icon: Icons.storefront_outlined,
                      title: 'Coin Store',
                      subtitle: 'Unlock more moments and exports',
                      onTap: () => context.push(AppRoutes.store),
                    ),
                    _ProfileMenuItem(
                      icon: Icons.feedback_outlined,
                      title: 'Feedback',
                      subtitle: 'Tell us what should feel sweeter',
                      onTap: () => context.push(AppRoutes.feedback),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingLg),
                _buildMenuSection(
                  context,
                  title: 'Policies',
                  items: [
                    _ProfileMenuItem(
                      icon: Icons.description_outlined,
                      title: 'Privacy Policy',
                      subtitle: 'How we treat your data',
                      onTap: () => context.push(
                        '${AppRoutes.agreement}?${AppRoutes.paramTitle}=Privacy Policy&${AppRoutes.paramUrl}=${AppEnv().h5Privacy}',
                      ),
                    ),
                    _ProfileMenuItem(
                      icon: Icons.gavel_outlined,
                      title: 'Terms of Service',
                      subtitle: 'Review the service rules',
                      onTap: () => context.push(
                        '${AppRoutes.agreement}?${AppRoutes.paramTitle}=Terms of Service&${AppRoutes.paramUrl}=${AppEnv().h5User}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingLg),
                _buildAccountSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        TaviaIconButton(
          icon: Icons.arrow_back_ios_new,
          onTap: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: AppConstants.spacingMd),
        const Expanded(
          child: TaviaSectionTitle(
            title: 'Profile',
            subtitle:
                'A warmer account view with softer utility surfaces.',
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return TaviaPanel(
      color: AppColors.white.withValues(alpha: 0.2),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(24),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              A.assets_tavia_TaviaLogo,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tavia',
                  style: AppTextStyles.h2.copyWith(color: AppColors.white),
                ),
                const SizedBox(height: AppConstants.spacingXs),
                Text(
                  'Visual collector',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.white.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),
          StreamCoinBalanceWidget(
            builder: (context, balance) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingMd,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                ),
                child: Text(
                  '$balance coins',
                  style: AppTextStyles.captionMedium.copyWith(
                    color: AppColors.primaryMain,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context, {
    required String title,
    required List<_ProfileMenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTextStyles.small.copyWith(
            color: AppColors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        TaviaPanel(
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              return Column(
                children: [
                  if (index > 0)
                    const Divider(color: AppColors.outline, height: 1),
                  item,
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACCOUNT',
          style: AppTextStyles.small.copyWith(
            color: AppColors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        TaviaPanel(
          child: Column(
            children: [
              _ProfileMenuItem(
                icon: Icons.logout,
                title: 'Log Out',
                subtitle: 'Return to the splash experience',
                danger: true,
                onTap: () => _handleLogout(context),
              ),
              const Divider(color: AppColors.outline, height: 1),
              _ProfileMenuItem(
                icon: Icons.delete_forever_outlined,
                title: 'Delete Account',
                subtitle: 'Permanently remove this account and its local data',
                danger: true,
                onTap: () => _handleDeleteAccount(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await AppDialog.showConfirmDialog(
      context,
      title: 'Log Out',
      content: 'Log out and return to the splash page?',
      confirmText: 'Log Out',
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    Interface().authToken = null;
    StateProvider.of(context).clearUser();
    context.go(AppRoutes.login);
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    final confirmed = await AppDialog.showConfirmDialog(
      context,
      title: 'Delete Account',
      content:
          'This will sign you out and permanently clear local coins and saved history on this device. Continue?',
      confirmText: 'Delete',
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await LightHandle.deleteAccount(context);
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.semanticError : AppColors.textPrimary;
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: danger
              ? AppColors.semanticError.withValues(alpha: 0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(color: color),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.caption,
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
