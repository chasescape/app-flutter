import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../env/app_env.dart';
import '../../../light_handle.dart';
import '../../../routes/app_routes.dart';
import '../../../services/coins_manager.dart';
import '../../../theme/app_theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final CoinsManager coinsManager = CoinsManager.instance;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppTheme.appBackgroundGradient,
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHero(),
                      const SizedBox(height: 18),
                      _buildCoinsCard(coinsManager),
                      const SizedBox(height: 18),
                      _buildSectionTitle('Account'),
                      const SizedBox(height: 10),
                      _buildMenuPanel(
                        children: [
                          _buildMenuItem(
                            icon: Icons.shopping_bag_outlined,
                            title: 'Coin Shop',
                            subtitle: 'Use coins for premium features',
                            onTap: AppRoutes.toCoinShop,
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.settings_outlined,
                            title: 'Settings',
                            subtitle: 'Goal, reminders, and preferences',
                            onTap: AppRoutes.toSettings,
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.feedback_outlined,
                            title: 'Feedback',
                            subtitle: 'Tell us what feels good or needs work',
                            onTap: AppRoutes.toFeedback,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _buildSectionTitle('Legal'),
                      const SizedBox(height: 10),
                      _buildMenuPanel(
                        children: [
                          _buildMenuItem(
                            icon: Icons.description_outlined,
                            title: 'Privacy Policy',
                            subtitle: 'How your data is handled',
                            onTap: () => AppRoutes.toAgreement(
                              'Privacy Policy',
                              AppEnv().h5Privacy,
                            ),
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.gavel_outlined,
                            title: 'Terms of Service',
                            subtitle: 'Rules and service terms',
                            onTap: () => AppRoutes.toAgreement(
                              'Terms of Service',
                              AppEnv().h5User,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _buildSectionTitle('Danger Zone'),
                      const SizedBox(height: 10),
                      _buildMenuPanel(
                        children: [
                          _buildMenuItem(
                            icon: Icons.logout_rounded,
                            title: 'Log Out',
                            subtitle: 'Sign out on this device',
                            textColor: AppTheme.semanticError,
                            iconBackground: const Color(0x1AF06D6D),
                            onTap: _handleLogout,
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.delete_forever_outlined,
                            title: 'Delete Account',
                            subtitle: 'Permanently remove all your data',
                            textColor: AppTheme.semanticError,
                            iconBackground: const Color(0x1AF06D6D),
                            onTap: _handleDeleteAccount,
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
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppTheme.aquaPrimaryGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppTheme.shadowsElevated,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -16,
            right: -12,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -28,
            left: -8,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileDropBadge(),
              SizedBox(height: 18),
              Text(
                'Wekoo keeps you in flow',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Coins, settings, support, and account tools all stay together here.',
                style: TextStyle(
                  color: Color(0xE6FFFFFF),
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoinsCard(CoinsManager coinsManager) {
    return ValueListenableBuilder<int>(
      valueListenable: coinsManager.coinsNotifier,
      builder: (context, coins, child) {
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: AppTheme.cardGlowGradient,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppTheme.secondaryLight),
            boxShadow: AppTheme.shadows,
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.waveMint, AppTheme.waveBlue],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.savings_outlined,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coins',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Earn more by staying consistent.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: coins),
                duration: const Duration(milliseconds: 450),
                builder: (context, value, child) {
                  return Text(
                    '$value',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryMain,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildMenuPanel({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppTheme.secondaryLight),
        boxShadow: AppTheme.shadows,
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.only(left: 74),
      child: Divider(height: 1, thickness: 1, color: AppTheme.bgTertiary),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconBackground,
  }) {
    final Color resolvedTextColor = textColor ?? AppTheme.textPrimary;

    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBackground ?? AppTheme.secondaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: textColor ?? AppTheme.accentMain,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: resolvedTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textDisabled,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout() {
    Get.dialog(
      _ProfileActionDialog(
        icon: Icons.logout_rounded,
        title: 'Log out',
        message: 'Are you sure you want to sign out on this device?',
        confirmLabel: 'Log Out',
        confirmColor: AppTheme.waveMint,
        onConfirm: () async {
          Get.back();
          Get.dialog(
            const _ProfileLoadingDialog(
              text: 'Logging out...',
              color: AppTheme.primaryMain,
            ),
            barrierDismissible: false,
          );
          await LightHandle.logout();
          Get.back();
          Get.offAllNamed(AppRoutes.login);
        },
      ),
    );
  }

  void _handleDeleteAccount() {
    Get.dialog(
      _ProfileActionDialog(
        icon: Icons.warning_amber_rounded,
        title: 'Delete account',
        message: 'This permanently removes your account and all saved data.',
        confirmLabel: 'Delete',
        confirmColor: AppTheme.semanticError,
        onConfirm: () async {
          Get.back();
          Get.dialog(
            const _ProfileLoadingDialog(
              text: 'Deleting account...',
              color: AppTheme.semanticError,
            ),
            barrierDismissible: false,
          );
          await LightHandle.deleteAccount();
          Get.back();
          Get.offAllNamed(AppRoutes.login);
        },
      ),
    );
  }
}

class _ProfileDropBadge extends StatelessWidget {
  const _ProfileDropBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 66,
      height: 66,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Icon(
        Icons.water_drop_rounded,
        size: 34,
        color: AppTheme.primaryMain,
      ),
    );
  }
}

class _ProfileActionDialog extends StatelessWidget {
  const _ProfileActionDialog({
    required this.icon,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.confirmColor,
    required this.onConfirm,
  });

  final IconData icon;
  final String title;
  final String message;
  final String confirmLabel;
  final Color confirmColor;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: confirmColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: confirmColor, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: Get.back,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryMain,
                      side: const BorderSide(color: AppTheme.primaryMain, width: 1.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: Text(
                      confirmLabel,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileLoadingDialog extends StatelessWidget {
  const _ProfileLoadingDialog({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
