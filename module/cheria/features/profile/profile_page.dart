import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import '../../app/theme/theme.dart';
import '../../app/state/app_state_provider.dart';
import '../../router/app_router.dart';
import '../../router/app_router_extension.dart';
import '../../widgets/animations/bounce_in_animation.dart';
import '../../widgets/visuals/sunny_visuals.dart';
import '../../interface.dart';
import '../../env/app_env.dart';

/// Profile Page
/// User settings, coin store, feedback, agreements, and data management
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SunnyPage(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: AppTypography.getH2TextStyle(
                  const Color(AppColors.textPrimary),
                ).copyWith(fontWeight: AppTypography.bold),
              ),
              const SizedBox(height: AppSpacing.lg),
              _BrandSection(),
              const SizedBox(height: AppSpacing.lg),
              _MenuSection(),
              const SizedBox(height: AppSpacing.xl),
              _DangerZone(),
              const SizedBox(height: 96),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BounceInAnimation(
      delay: const Duration(milliseconds: 100),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(AppColors.backgroundSecondary),
              Color(AppColors.secondaryMain)
            ],
          ),
          borderRadius: AppBorderRadius.allLG,
          border: Border.all(
            color: const Color(AppColors.cardElevated),
            width: 3,
          ),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          children: [
            const CheriaLogoMark(size: 86),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Cheria',
              style: AppTypography.getH1TextStyle(
                const Color(AppColors.textInverse),
              ).copyWith(fontWeight: AppTypography.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your bright reading buddy',
              style: AppTypography.getCaptionTextStyle(
                const Color(AppColors.textInverse),
              ).copyWith(
                color: const Color(AppColors.textInverse).withOpacity(0.86),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BounceInAnimation(
      delay: const Duration(milliseconds: 200),
      child: SunnyCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            _MenuItem(
              icon: Icons.monetization_on,
              title: 'Coin Store',
              subtitle: 'Get more coins',
              onTap: () => context.push(AppRoutes.coinStore),
            ),
            _Divider(),
            _MenuItem(
              icon: Icons.feedback,
              title: 'Feedback',
              subtitle: 'Send us your thoughts',
              onTap: () => context.push(AppRoutes.feedback),
            ),
            _Divider(),
            _MenuItem(
              icon: Icons.description,
              title: 'User Agreement',
              subtitle: 'Terms of service',
              onTap: () {
                context.toAgreement('Terms of Service', AppEnv().h5User);
              },
            ),
            _Divider(),
            _MenuItem(
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              subtitle: 'How we handle your data',
              onTap: () {
                context.toAgreement('Privacy Policy', AppEnv().h5Privacy);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppBorderRadius.allLG,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(AppColors.secondaryLight),
                borderRadius: AppBorderRadius.allMD,
              ),
              child: Icon(
                icon,
                color: const Color(AppColors.primaryMain),
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.getBodyTextStyle(
                      const Color(AppColors.textPrimary),
                    ).copyWith(
                      fontWeight: AppTypography.semibold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.getSmallTextStyle(
                      const Color(AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(AppColors.textSecondary),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 72),
      child: Divider(
        color: const Color(AppColors.divider),
        height: 1,
      ),
    );
  }
}

class _DangerZone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BounceInAnimation(
      delay: const Duration(milliseconds: 300),
      child: SunnyCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            _DangerMenuItem(
              icon: Icons.exit_to_app,
              title: 'Sign Out',
              subtitle: 'Sign out of your account',
              onTap: () => _showExitDialog(context),
            ),
            _Divider(),
            _DangerMenuItem(
              icon: Icons.delete_forever,
              title: 'Delete All Data',
              subtitle: 'Delete all your data',
              isDangerous: true,
              onTap: () => _showClearDataDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _DangerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDangerous;
  final VoidCallback onTap;

  const _DangerMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isDangerous = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDangerous
        ? const Color(AppColors.error)
        : const Color(AppColors.textSecondary);

    return InkWell(
      onTap: onTap,
      borderRadius: AppBorderRadius.allLG,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDangerous
                    ? const Color(AppColors.error).withOpacity(0.1)
                    : const Color(AppColors.secondaryLight),
                borderRadius: AppBorderRadius.allMD,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.getBodyTextStyle(color).copyWith(
                      fontWeight: AppTypography.semibold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.getSmallTextStyle(
                      const Color(AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: const Color(AppColors.textSecondary),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

void _showExitDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Sign Out'),
      content: const Text('Are you sure you want to sign out?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            // Close dialog
            Navigator.pop(context);

            // 显示全局 loading
            SmartDialog.showLoading(
              msg: 'Signing out...',
              backType: SmartBackType.normal,
            );

            try {
              // 调用 Interface().onAuthTokenRemoved 清除登录态
              await Interface().onAuthTokenRemoved();

              // 关闭 loading 并跳转登录页
              SmartDialog.dismiss();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            } catch (e) {
              SmartDialog.dismiss();
              SmartDialog.showToast('Sign out failed, please try again');
            }
          },
          child: const Text('Sign Out'),
        ),
      ],
    ),
  );
}

void _showClearDataDialog(BuildContext context) {
  final pageContext = context;

  showDialog(
    context: pageContext,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete All Data'),
      content: const Text(
        'This will delete all your data including novels, characters, achievements, and coin balance. This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            // 第一次确认后，显示二次确认弹窗
            Navigator.pop(dialogContext);
            if (!pageContext.mounted) return;

            final secondConfirmed = await showDialog<bool>(
              context: pageContext,
              builder: (confirmDialogContext) => AlertDialog(
                title: const Text('Final Confirmation'),
                content: const Text(
                  'Are you really sure you want to delete all data? This action is irreversible!',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(confirmDialogContext, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(confirmDialogContext, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(AppColors.error),
                    ),
                    child: const Text('Delete All'),
                  ),
                ],
              ),
            );

            if (secondConfirmed != true) return;

            // 显示全局 loading
            SmartDialog.showLoading(
              msg: 'Deleting data...',
              backType: SmartBackType.normal,
            );

            try {
              // 1. 调用 Interface().onAuthTokenRemoved 清除登录态（包含金币数据）
              await Interface().onAuthTokenRemoved();

              // 2. 清除所有内存状态和本地数据
              if (pageContext.mounted) {
                await AppStateProvider.of(pageContext).clearAllData();
              }

              // 关闭 loading 并跳转登录页
              SmartDialog.dismiss();
              SmartDialog.showToast('All data deleted');
              if (pageContext.mounted) {
                pageContext.go(AppRoutes.login);
              }
            } catch (e) {
              SmartDialog.dismiss();
              SmartDialog.showToast('Delete data failed, please try again');
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(AppColors.error),
          ),
          child: const Text('Delete All'),
        ),
      ],
    ),
  );
}
