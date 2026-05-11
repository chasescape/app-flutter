import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voreo/gen_a/A.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/user_controller.dart';
import '../../env/app_env.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_border.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../ui/dreamy_ui.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    this.showBackButton = true,
  });

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();
    final AuthController authController = Get.find<AuthController>();

    return DreamyPageScaffold(
      showFloor: false,
      child: Obx(() {
        final int previewCount = userController.history.length;
        final int freeAttempts = userController.freeAttempts.value;
        final int coinBalance = userController.userData.value?.coinBalance ?? 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            132,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DreamyTopBar(
                title: 'Profile',
                subtitle:
                    'Your creative space, shortcuts, and account controls in one calmer layout.',
                onBack: showBackButton ? AppRoutes.goBack : null,
              ),
              const SizedBox(height: AppSpacing.md),
              _ProfileHeroCard(
                userId: 'Voreo',
                coinBalance: coinBalance,
                previewCount: previewCount,
                freeAttempts: freeAttempts,
              ),
              const SizedBox(height: AppSpacing.xl),
              const DreamySectionLabel(
                title: 'Studio shortcuts',
                subtitle:
                    'Jump into the actions you are most likely to need next.',
              ),
              const SizedBox(height: AppSpacing.md),
              const _ShortcutPanel(
                items: [
                  _ShortcutItem(
                    icon: Icons.monetization_on_rounded,
                    title: 'Coin store',
                    subtitle: 'Top up for more generations',
                    tint: AppColors.backgroundTertiary,
                    onTap: AppRoutes.toCoinStore,
                  ),
                  _ShortcutItem(
                    icon: Icons.history_rounded,
                    title: 'History',
                    subtitle: 'Open your saved previews',
                    tint: AppColors.softBlue,
                    onTap: AppRoutes.toHistory,
                  ),
                  _ShortcutItem(
                    icon: Icons.feedback_rounded,
                    title: 'Feedback',
                    subtitle: 'Share bugs, ideas, and requests',
                    tint: AppColors.softPink,
                    onTap: AppRoutes.toFeedback,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              const DreamySectionLabel(
                title: 'Trust and support',
                subtitle:
                    'Policies and account actions live here, grouped a little more cleanly.',
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(AppBorder.radiusXLarge),
                  border: Border.all(color: AppColors.cardStroke),
                  boxShadow: AppShadows.shadowMD,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _LinkRow(
                        icon: Icons.description_rounded,
                        title: 'Terms of Service',
                        subtitle: 'Review how the app is used',
                        onTap: () => AppRoutes.toAgreement(
                          'Terms of Service',
                          AppEnv().h5User,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _LinkRow(
                        icon: Icons.privacy_tip_rounded,
                        title: 'Privacy Policy',
                        subtitle: 'See how your data is handled',
                        onTap: () => AppRoutes.toAgreement(
                          'Privacy Policy',
                          AppEnv().h5Privacy,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _AccountActionCard(
                onLogout: () => _showLogoutDialog(authController),
                onClear: () => _showDeleteAccountDialog(authController),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showLogoutDialog(AuthController controller) {
    Get.dialog(
      Dialog(
        shape: const RoundedRectangleBorder(
            borderRadius: AppBorder.borderRadiusXL),
        child: Padding(
          padding: AppSpacing.allLG,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.logout_rounded,
                size: 42,
                color: AppColors.textGrey,
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('Logout?', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'You can come back anytime.',
                style: AppTypography.body.copyWith(color: AppColors.textGrey),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  const Expanded(
                    child: DreamySecondaryButton(
                      label: 'Cancel',
                      onTap: AppRoutes.goBack,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: DreamyPrimaryButton(
                      label: 'Logout',
                      expanded: false,
                      onTap: controller.logout,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(AuthController controller) {
    Get.dialog(
      Dialog(
        shape: const RoundedRectangleBorder(
            borderRadius: AppBorder.borderRadiusXL),
        child: Padding(
          padding: AppSpacing.allLG,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_rounded,
                size: 42,
                color: AppColors.error,
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('Delete account?', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'This deletes local data and signs you out.',
                style: AppTypography.body.copyWith(color: AppColors.textGrey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  const Expanded(
                    child: DreamySecondaryButton(
                      label: 'Cancel',
                      onTap: AppRoutes.goBack,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: DreamyPrimaryButton(
                      label: 'Delete',
                      expanded: false,
                      onTap: controller.deleteAccount,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({
    required this.userId,
    required this.coinBalance,
    required this.previewCount,
    required this.freeAttempts,
  });

  final String userId;
  final int coinBalance;
  final int previewCount;
  final int freeAttempts;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF9FCF),
            Color(0xFFFFF0C8),
            Color(0xFFE4F4FF),
          ],
        ),
        borderRadius: BorderRadius.circular(AppBorder.radiusXLarge),
        boxShadow: AppShadows.shadowLG,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppBorder.radiusXLarge),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.75)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppBorder.radiusXLarge),
          child: Stack(
            children: [
              Positioned(
                top: -28,
                right: -18,
                child: _SoftOrb(
                  size: 110,
                  color: AppColors.white.withValues(alpha: 0.42),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -12,
                child: _SoftOrb(
                  size: 92,
                  color: AppColors.primaryLight.withValues(alpha: 0.26),
                ),
              ),
              Padding(
                padding: AppSpacing.allLG,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: AppSpacing.allMD,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.56),
                        borderRadius: BorderRadius.circular(
                          AppBorder.radiusXLarge,
                        ),
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.46),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const _ProfileAvatar(),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.md,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.white.withValues(
                                          alpha: 0.72,
                                        ),
                                        borderRadius:
                                            AppBorder.borderRadiusFull,
                                      ),
                                      child: Text(
                                        userId,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            AppTypography.bodyMedium.copyWith(
                                          color: AppColors.textDark,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Ready for preview creation, saved references, and quick support whenever you need it.',
                            style: AppTypography.body.copyWith(
                              color: AppColors.textGrey,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShortcutPanel extends StatelessWidget {
  const _ShortcutPanel({
    required this.items,
  });

  final List<_ShortcutItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppBorder.radiusXLarge),
        border: Border.all(color: AppColors.cardStroke),
        boxShadow: AppShadows.shadowMD,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            for (int index = 0; index < items.length; index++) ...[
              _ShortcutRow(item: items[index]),
              if (index != items.length - 1) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _ShortcutItem {
  const _ShortcutItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tint,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color tint;
  final VoidCallback onTap;
}

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({
    required this.item,
  });

  final _ShortcutItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(AppBorder.radiusLarge),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(AppBorder.radiusLarge),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 14,
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: item.tint,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(item.icon, color: AppColors.textDark, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textDark,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const _ShortcutActionButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.7)),
        boxShadow: AppShadows.shadowWithColor(AppColors.primaryMain),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(27),
        child: Image.asset(
          A.assets_voreo_VoreoLogo,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _ShortcutActionButton extends StatelessWidget {
  const _ShortcutActionButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.accentMain,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.arrow_forward_rounded,
        size: 16,
        color: AppColors.white,
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppBorder.radiusLarge),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(AppBorder.radiusLarge),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.softLavender.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppColors.textDark),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textDark,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountActionCard extends StatelessWidget {
  const _AccountActionCard({
    required this.onLogout,
    required this.onClear,
  });

  final VoidCallback onLogout;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.allLG,
      decoration: BoxDecoration(
        color: AppColors.accentMain.withValues(alpha: 0.93),
        borderRadius: BorderRadius.circular(AppBorder.radiusXLarge),
        boxShadow: AppShadows.shadowLG,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account actions',
            style: AppTypography.h3.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Log out safely, or clear this device if you want a fresh start.',
            style: AppTypography.caption.copyWith(
              color: AppColors.white.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Logout',
                  icon: Icons.logout_rounded,
                  outlined: true,
                  onTap: onLogout,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ActionButton(
                  label: 'Delete',
                  icon: Icons.delete_outline_rounded,
                  onTap: onClear,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.outlined = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final Color background =
        outlined ? AppColors.white.withValues(alpha: 0.08) : AppColors.white;
    final Color foreground = outlined ? AppColors.white : AppColors.accentMain;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorder.borderRadiusFull,
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: AppBorder.borderRadiusFull,
            border: Border.all(
              color: outlined
                  ? AppColors.white.withValues(alpha: 0.16)
                  : AppColors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTypography.bodyMedium.copyWith(color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftOrb extends StatelessWidget {
  const _SoftOrb({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
