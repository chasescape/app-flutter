import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

import '../../../gen_a/A.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/evara_scaffold.dart';
import '../../features/settings/settings_controller.dart';

/// Settings page with consistent glass styling.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());

    return EvaraScaffold(
      safeTop: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverAppBar(
            pinned: true,
            backgroundColor: Colors.transparent,
            title: Text('Profile'),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingLg,
              AppTheme.spacingSm,
              AppTheme.spacingLg,
              120,
            ),
            sliver: SliverToBoxAdapter(
              child: Watch((context) {
                final coins = controller.userCoins.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EvaraGlassCard(
                      blur: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusMd),
                                child: Image.asset(
                                  A.assets_evara_logo,
                                  width: 58,
                                  height: 58,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacingMd),
                              const Expanded(
                                child: Text(
                                  'Evara',
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: AppTheme.body,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacingLg),
                          SizedBox(
                            width: double.infinity,
                            child: Container(
                              padding: const EdgeInsets.all(AppTheme.spacingMd),
                              decoration: BoxDecoration(
                                gradient: AppTheme.accentGradient,
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusLg),
                              ),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final button = SizedBox(
                                    width: 112,
                                    height: 44,
                                    child: ElevatedButton(
                                      onPressed: controller.goToCoinStore,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.white.withValues(alpha: 0.18),
                                        foregroundColor:
                                            AppTheme.textInverse,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppTheme.radiusFull,
                                          ),
                                        ),
                                      ),
                                      child: const Text('Top up'),
                                    ),
                                  );

                                  final balanceInfo = Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Current balance',
                                        style: TextStyle(
                                          color: AppTheme.textInverse,
                                          fontSize: AppTheme.caption,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '$coins coins',
                                        style: const TextStyle(
                                          color: AppTheme.textInverse,
                                          fontSize: 30,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  );

                                  if (constraints.maxWidth < 320) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        balanceInfo,
                                        const SizedBox(
                                          height: AppTheme.spacingMd,
                                        ),
                                        button,
                                      ],
                                    );
                                  }

                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Expanded(child: balanceInfo),
                                      const SizedBox(
                                        width: AppTheme.spacingMd,
                                      ),
                                      button,
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    const Text(
                      'Support',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: AppTheme.caption,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    _buildMenuItem(
                      icon: Icons.storefront_rounded,
                      title: 'Coin Store',
                      subtitle: 'Purchase more analyses',
                      onTap: controller.goToCoinStore,
                    ),
                    _buildMenuItem(
                      icon: Icons.feedback_outlined,
                      title: 'Feedback',
                      subtitle: 'Share product notes, bug reports, and polish ideas',
                      onTap: controller.goToFeedback,
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    const Text(
                      'Legal',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: AppTheme.caption,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    _buildMenuItem(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      subtitle: 'Review data handling details',
                      onTap: controller.goToPrivacyPolicy,
                    ),
                    _buildMenuItem(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      subtitle: 'See product usage terms',
                      onTap: controller.goToTermsOfService,
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    _buildMenuItem(
                      icon: Icons.logout_rounded,
                      title: 'Log out',
                      subtitle: 'Sign out without removing coins or history',
                      onTap: controller.logout,
                    ),
                    _buildMenuItem(
                      icon: Icons.delete_forever_outlined,
                      title: 'Delete account',
                      subtitle: 'Permanent removal of your account data',
                      onTap: controller.deleteAccount,
                      isDestructive: true,
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final iconColor = AppTheme.textInverse;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: EvaraGlassCard(
        onTap: onTap,
        color: isDestructive
            ? AppTheme.error.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.08),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: isDestructive
                    ? AppTheme.errorGradient
                    : AppTheme.accentGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color:
                          isDestructive ? AppTheme.error : AppTheme.textPrimary,
                      fontSize: AppTheme.body,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: AppTheme.small,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSecondary.withValues(alpha: 0.8),
            ),
          ],
        ),
      ),
    );
  }
}
