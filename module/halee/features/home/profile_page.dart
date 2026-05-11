import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/widgets/glass_card.dart';
import '../../app/widgets/bounce_in_animation.dart';
import '../../app/router/app_router.dart';
import '../../env/app_env.dart';
import '../../light_handle.dart';
import '../../services/coins_manager.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'home_tab_controller.dart';
import '../../../gen_a/A.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),

            // Profile avatar card
            BounceInAnimation(
              delay: const Duration(milliseconds: 100),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    padding: const EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(80),
                    child: Image.asset(
                      A.assets_halee_HaleeLogo,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                  const SizedBox(height: 10),
                  Text(
                    'Halee',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      fontSize: 32,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: AppSpacing.xxl),

          // Coins card
          BounceInAnimation(
            delay: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: () => AppRouter.toCoinStore(context),
              child: GlassCard(
                borderRadius: AppSpacing.borderRadiusXl,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: AppColors.coinCardGradient,
                    borderRadius: BorderRadius.circular(AppSpacing.borderRadiusXl),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Coins',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 4),
                          ValueListenableBuilder<int>(
                            valueListenable: CoinsManager.instance.coinsNotifier,
                            builder: (context, value, _) {
                              return Text(
                                CoinsManager.instance.formatCoins(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Inter',
                                  letterSpacing: -1,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.diamond, color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Get Coins',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Settings menu
          BounceInAnimation(
            delay: const Duration(milliseconds: 300),
            child: GlassCard(
              borderRadius: AppSpacing.borderRadiusXl,
              child: Column(
                children: [
                  _SettingsMenuItem(
                    icon: Icons.history,
                    title: 'My History',
                    onTap: () => HomeTabController.index.value = 1,
                  ),
                  const Divider(height: 1, indent: AppSpacing.md, endIndent: AppSpacing.md),
                  _SettingsMenuItem(
                    icon: Icons.feedback_outlined,
                    title: 'Feedback',
                    onTap: () => AppRouter.toFeedback(context),
                  ),
                  const Divider(height: 1, indent: AppSpacing.md, endIndent: AppSpacing.md),
                  _SettingsMenuItem(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    onTap: () => AppRouter.toAgreement(context, 'Terms of Service', AppEnv().h5User),
                  ),
                  const Divider(height: 1, indent: AppSpacing.md, endIndent: AppSpacing.md),
                  _SettingsMenuItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () => AppRouter.toAgreement(context, 'Privacy Policy', AppEnv().h5Privacy),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Account actions
          BounceInAnimation(
            delay: const Duration(milliseconds: 400),
            child: GlassCard(
              borderRadius: AppSpacing.borderRadiusXl,
              child: Column(
                children: [
                  _SettingsMenuItem(
                    icon: Icons.logout,
                    title: 'Log Out',
                    titleColor: AppColors.warning,
                    onTap: () {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.warning,
                        animType: AnimType.scale,
                        title: 'Log Out',
                        desc: 'Are you sure you want to log out?',
                        btnCancelText: 'Cancel',
                        btnOkText: 'Log Out',
                        btnOkColor: AppColors.warning,
                          btnCancelOnPress: () {},
                          btnOkOnPress: () async {
                            await LightHandle.logout();
                            if (context.mounted) {
                              AppRouter.toLogin(context);
                            }
                          },
                        ).show();
                      },
                    ),
                  const Divider(height: 1, indent: AppSpacing.md, endIndent: AppSpacing.md),
                  _SettingsMenuItem(
                    icon: Icons.delete_forever,
                    title: 'Delete Account',
                    titleColor: AppColors.error,
                    onTap: () {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.error,
                        animType: AnimType.scale,
                        title: 'Delete Account',
                        desc: 'This action cannot be undone. All your data will be permanently deleted.',
                        btnCancelText: 'Cancel',
                        btnOkText: 'Delete',
                        btnOkColor: AppColors.error,
                          btnCancelOnPress: () {},
                          btnOkOnPress: () async {
                            await LightHandle.deleteAccount();
                            if (context.mounted) {
                              AppRouter.toLogin(context);
                            }
                          },
                        ).show();
                      },
                    ),
                ],
              ),
            ),
          ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _SettingsMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? titleColor;
  final VoidCallback onTap;

  const _SettingsMenuItem({
    required this.icon,
    required this.title,
    this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md + 4,
        ),
        child: Row(
          children: [
            Icon(icon, color: titleColor ?? AppColors.textSecondary, size: 22),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: titleColor,
                    ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
