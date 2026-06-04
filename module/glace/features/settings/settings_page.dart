import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../env/app_env.dart';
import '../../light_handle.dart';
import '../../widgets/glace_ui.dart';
import '../../widgets/scent_loading_dialog.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GlaceScaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        foregroundColor: AppColors.textPrimary,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      safeArea: false,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlaceGlassCard(
                padding: const EdgeInsets.all(16),
                borderRadius: BorderRadius.circular(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.42),
                            ),
                          ),
                          child: const GlaceLogoBadge(size: 64),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Glace',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'Scent journal',
                                  style: TextStyle(
                                    color: AppColors.textPrimary
                                        .withValues(alpha: 0.72),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GlaceSurfaceCard(
                      onTap: () => context.push(Routes.coinStore),
                      color: Colors.white.withValues(alpha: 0.88),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF4D9),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.monetization_on_rounded,
                              color: Color(0xFFF6A400),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Coins',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                    height: 1.1,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Top up and unlock more journal extras.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: AppColors.textDisabled,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SectionGroup(
                title: 'More',
                children: [
                  _menuItem(
                    icon: Icons.photo_library_outlined,
                    title: 'Journal',
                    subtitle: 'Open your saved entries',
                    onTap: () => context.toHistory(),
                  ),
                  _divider(),
                  _menuItem(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    subtitle: 'Read usage terms and conditions',
                    onTap: () => context.toAgreement(
                        'Terms of Service', AppEnv().h5User),
                  ),
                  _divider(),
                  _menuItem(
                    icon: Icons.shield_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'See how your information is handled',
                    onTap: () => context.toAgreement(
                      'Privacy Policy',
                      AppEnv().h5Privacy,
                    ),
                  ),
                  _divider(),
                  _menuItem(
                    icon: Icons.feedback_outlined,
                    title: 'Feedback',
                    subtitle: 'Tell us what to refine next',
                    onTap: () => context.toFeedback(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SectionGroup(
                title: 'Account',
                children: [
                  _menuItem(
                    icon: Icons.logout_rounded,
                    title: 'Sign out',
                    subtitle: 'Return to the welcome screen',
                    onTap: () => _signOut(context),
                  ),
                  _divider(),
                  _menuItem(
                    icon: Icons.delete_forever_rounded,
                    title: 'Delete account',
                    subtitle: 'Clear local journal history and coin data',
                    iconColor: AppColors.error,
                    onTap: () => _deleteAccount(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withValues(alpha: 0.46),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    final color = iconColor ?? AppColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 19, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.15,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textDisabled,
            ),
          ],
        ),
      ),
    );
  }

  void _signOut(BuildContext context) {
    SmartDialog.show(
      builder: (_) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.surfaceWarm,
                      foregroundColor: AppColors.textPrimary,
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.12),
                      ),
                    ),
                    onPressed: () => SmartDialog.dismiss(),
                    child: const Text(
                      'Cancel',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      SmartDialog.dismiss();
                      ScentLoadingDialog.show(showMessage: false);
                      await LightHandle.logout();
                      ScentLoadingDialog.dismiss();
                      if (context.mounted) context.go(Routes.login);
                    },
                    child: const Text(
                      'Sign out',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _deleteAccount(BuildContext context) {
    SmartDialog.show(
      builder: (_) => AlertDialog(
        title: const Text('Delete account'),
        content: const Text(
          'This will clear local history records and local coin data on this device.',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.surfaceWarm,
                      foregroundColor: AppColors.textPrimary,
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.12),
                      ),
                    ),
                    onPressed: () => SmartDialog.dismiss(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      SmartDialog.dismiss();
                      ScentLoadingDialog.show(showMessage: false);
                      await LightHandle.deleteAccount();
                      ScentLoadingDialog.dismiss();
                      // SmartDialog.showToast(
                      //   'Local history and coin data cleared',
                      // );
                      if (context.mounted) context.go(Routes.login);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Delete'),
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

class _SectionGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionGroup({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
              color: AppColors.textPrimary.withValues(alpha: 0.72),
            ),
          ),
        ),
        GlaceSurfaceCard(
          color: Colors.white.withValues(alpha: 0.74),
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(28),
          child: Column(children: children),
        ),
      ],
    );
  }
}
