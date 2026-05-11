import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:zeria/zeria/constants/app_colors.dart';
import 'package:zeria/zeria/constants/app_routes.dart';
import 'package:zeria/zeria/constants/app_strings.dart';
import 'package:zeria/zeria/constants/app_text_styles.dart';
import 'package:zeria/zeria/env/app_env.dart';
import 'package:zeria/zeria/services/app_service.dart';
import 'package:zeria/zeria/services/coins_manager.dart';
import 'package:zeria/zeria/widgets/zeria_ui.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appService = AppService.to;

    return ZeriaScreen(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 130),
          children: [
            const ZeriaHeader(
              title: 'Profile',
              subtitle: 'ACCOUNT AND APP SETTINGS',
            ),
            const SizedBox(height: 22),
            Obx(() {
              final user = appService.currentUser.value;
              return ZeriaSurfaceCard(
                radius: 34,
                child: Row(
                  children: [
                    const ZeriaBrandMark(size: 74),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'User',
                            style: AppTextStyles.h3,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'A calm, image-led workspace for building visual ideas.',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ValueListenableBuilder<int>(
                            valueListenable:
                                CoinsManager.instance.coinsNotifier,
                            builder: (context, coins, child) {
                              return ZeriaPill(
                                label: '$coins ${AppStrings.coins}',
                                icon: Icons.auto_awesome_rounded,
                                backgroundColor: AppColors.surfaceTint,
                                foregroundColor: AppColors.brandHotPink,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 18),
            ZeriaSurfaceCard(
              onTap: () => context.push(AppRoutes.coinStore),
              radius: 32,
              gradient: AppColors.accentGradient,
              borderColor: Colors.white.withOpacity(0.28),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.monetization_on_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.coinStore,
                          style: AppTextStyles.h3Inverse
                              .copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Top up and keep generating polished concepts.',
                          style: AppTextStyles.bodyInverse.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const ZeriaSectionTitle(
              title: 'Support',
              subtitle: 'HELPFUL LINKS',
            ),
            const SizedBox(height: 14),
            _buildMenuCard(
              icon: Icons.description_outlined,
              title: AppStrings.userAgreement,
              subtitle: 'Terms of service and app usage details',
              onTap: () => context.push(
                AppRoutes.buildAgreementUrl(
                  'Terms of Service',
                  AppEnv().h5User,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildMenuCard(
              icon: Icons.security_outlined,
              title: AppStrings.privacyPolicy,
              subtitle: 'How your information is handled',
              onTap: () => context.push(
                AppRoutes.buildAgreementUrl(
                  'Privacy Policy',
                  AppEnv().h5Privacy,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildMenuCard(
              icon: Icons.feedback_outlined,
              title: AppStrings.feedback,
              subtitle: 'Send product ideas, issues, or suggestions',
              onTap: () => context.push(AppRoutes.feedback),
            ),
            const SizedBox(height: 22),
            const ZeriaSectionTitle(
              title: 'Account',
              subtitle: 'SESSION CONTROLS',
            ),
            const SizedBox(height: 14),
            _buildMenuCard(
              icon: Icons.logout_rounded,
              title: AppStrings.logout,
              subtitle: 'Sign out and return to the launch screen',
              onTap: () => _confirmAction(
                context,
                title: AppStrings.logout,
                description: AppStrings.logoutConfirm,
                onConfirm: () async {
                  // Logout should not clear local data (history/coins/profile).
                  await AppService.to.signOut();
                  if (context.mounted) {
                    context.go(AppRoutes.login);
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
            _buildMenuCard(
              icon: Icons.delete_forever_outlined,
              title: AppStrings.deleteAccount,
              subtitle: 'Clear local data and reset your profile',
              foregroundColor: AppColors.error,
              onTap: () => _confirmAction(
                context,
                title: AppStrings.deleteAccount,
                description: AppStrings.deleteAccountConfirm,
                confirmLabel: AppStrings.delete,
                onConfirm: () async {
                  await AppService.to.clearAllData();
                  if (context.mounted) {
                    context.go(AppRoutes.login);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color foregroundColor = AppColors.textPrimary,
  }) {
    return ZeriaSurfaceCard(
      onTap: onTap,
      radius: 28,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: foregroundColor == AppColors.error
                  ? AppColors.error.withOpacity(0.12)
                  : AppColors.surfaceTint,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: foregroundColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      AppTextStyles.bodyBold.copyWith(color: foregroundColor),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: foregroundColor == AppColors.error
                ? AppColors.error
                : AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  void _confirmAction(
    BuildContext context, {
    required String title,
    required String description,
    required Future<void> Function() onConfirm,
    String confirmLabel = AppStrings.confirm,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          ZeriaDialogActions(
            onCancel: () => Navigator.pop(dialogContext),
            onConfirm: () async {
              Navigator.pop(dialogContext);
              await onConfirm();
            },
            confirmLabel: confirmLabel,
          ),
        ],
      ),
    );
  }
}
