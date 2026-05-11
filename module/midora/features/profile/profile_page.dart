import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/midora_design.dart';
import '../../core/widgets/midora_open_background.dart';
import '../../env/app_env.dart';
import '../../services/coins_manager.dart';
import '../feedback/feedback_page.dart';
import '../history/history_page.dart';
import '../store/store_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AppController _controller = AppController.I;
  bool _isDeletingAccount = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const MidoraOpenBackground(overlayOpacity: 0.24),
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    child: Column(
                      children: [
                        const MidoraTopBar(
                          title: 'Profile',
                          subtitle:
                              'Everything about your collection in one soft corner.',
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Obx(
                          () => _ProfileSurface(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const MidoraMascotBadge(size: 74),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _controller
                                                    .currentUser.value?.name ??
                                                'Music Lover',
                                            style: AppTextStyles.h2.copyWith(
                                              color: _ProfilePalette.title,
                                            ),
                                          ),
                                          const SizedBox(height: AppSpacing.xs),
                                          Text(
                                            'Collector of soft visuals and little stories.',
                                            style:
                                                AppTextStyles.caption.copyWith(
                                              color: _ProfilePalette.subtitle,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                _ProfileSurface(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.md,
                                  ),
                                  borderRadius: AppBorderRadius.borderRadiusLg,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 46,
                                        height: 46,
                                        decoration: BoxDecoration(
                                          gradient: AppColors.buttonGradient,
                                          borderRadius:
                                              AppBorderRadius.borderRadiusLg,
                                          boxShadow: AppColors.shadowSm,
                                        ),
                                        child: const Icon(
                                          Icons.monetization_on_rounded,
                                          color: AppColors.primaryDark,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: Text(
                                          'Current balance',
                                          style: AppTextStyles.caption.copyWith(
                                            color: _ProfilePalette.subtitle,
                                          ),
                                        ),
                                      ),
                                      CoinsBuilder(
                                        builder: (coins) => Text(
                                          '$coins coins',
                                          style:
                                              AppTextStyles.bodyBold.copyWith(
                                            color: _ProfilePalette.title,
                                          ),
                                        ),
                                      ),
                                    ],
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
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.md),
                        _ProfileGroup(
                          children: [
                            _ProfileGroupItem(
                              title: 'Coin Store',
                              icon: Icons.shopping_bag_rounded,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const StorePage()),
                                );
                              },
                            ),
                            _ProfileGroupItem(
                              title: 'Privacy Policy',
                              icon: Icons.privacy_tip_rounded,
                              onTap: () => _openAgreement(
                                  'Privacy Policy', AppEnv().h5Privacy),
                            ),
                            _ProfileGroupItem(
                              title: 'Terms of Service',
                              icon: Icons.description_rounded,
                              onTap: () => _openAgreement(
                                  'Terms of Service', AppEnv().h5User),
                            ),
                            _ProfileGroupItem(
                              title: 'Feedback',
                              icon: Icons.chat_bubble_rounded,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const FeedbackPage()),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _ProfileGroup(
                          surfaceColor: _ProfilePalette.actionSurface,
                          surfaceSoftColor: _ProfilePalette.actionSurfaceSoft,
                          borderColor: _ProfilePalette.actionBorder,
                          children: [
                            _ProfileGroupItem(
                              title: 'Logout',
                              icon: Icons.logout_rounded,
                              iconColor: _ProfilePalette.warningIcon,
                              iconSurfaceColor:
                                  _ProfilePalette.actionIconSurface,
                              chevronColor: _ProfilePalette.chevron,
                              onTap: _showLogoutDialog,
                            ),
                            _ProfileGroupItem(
                              title: 'Delete Account',
                              icon: Icons.delete_forever_rounded,
                              iconColor: _ProfilePalette.dangerIcon,
                              iconSurfaceColor:
                                  _ProfilePalette.actionIconSurface,
                              chevronColor: _ProfilePalette.chevron,
                              onTap: _showDeleteAccountDialog,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        const SizedBox(height: AppSpacing.xxl),
                        const SizedBox(height: AppSpacing.xxl),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isDeletingAccount)
            Container(
              color: AppColors.backgroundOverlay,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primaryLight),
              ),
            ),
        ],
      ),
    );
  }

  void _openAgreement(String title, String url) {
    AppRoutes.toAgreement(context, title, url);
  }

  void _showLogoutDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: AppBorderRadius.shapeXl,
          backgroundColor: AppColors.backgroundSecondary,
          title: const Text('Logout'),
          content: const Text('Leave Midora for now?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Stay'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                AppController.I.logout();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: AppBorderRadius.shapeXl,
          backgroundColor: AppColors.backgroundSecondary,
          title: const Text('Delete Account'),
          content: const Text(
            'This removes your local data and cannot be undone. Do you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                Navigator.of(context).pop();
                setState(() => _isDeletingAccount = true);
                await Future.delayed(const Duration(seconds: 1));
                await AppController.I.deleteAccount();
                await CoinsManager.I.clear();
                if (!mounted) return;
                setState(() => _isDeletingAccount = false);
                navigator.pushReplacementNamed('/login');
              },
              child: Text(
                'Delete',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  const _ProfileStatCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final int count;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _ProfileSurface(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: AppBorderRadius.borderRadiusLg,
                boxShadow: AppColors.glowMd,
              ),
              child: Icon(icon, color: AppColors.textInverse),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '$count',
              style: AppTextStyles.h2.copyWith(color: _ProfilePalette.title),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: _ProfilePalette.subtitle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileGroup extends StatelessWidget {
  const _ProfileGroup({
    required this.children,
    this.surfaceColor,
    this.surfaceSoftColor,
    this.borderColor,
  });

  final List<Widget> children;
  final Color? surfaceColor;
  final Color? surfaceSoftColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: _ProfileSurface(
        surfaceColor: surfaceColor ?? _ProfilePalette.listSurface,
        surfaceSoftColor: surfaceSoftColor ?? _ProfilePalette.listSurfaceSoft,
        borderColor: borderColor ?? _ProfilePalette.listBorder,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              children[i],
              if (i != children.length - 1)
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  color: Colors.white.withValues(alpha: 0.18),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileGroupItem extends StatelessWidget {
  const _ProfileGroupItem({
    required this.title,
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.primaryDark,
    this.iconSurfaceColor = _ProfilePalette.iconSurface,
    this.chevronColor = _ProfilePalette.chevron,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final Color iconSurfaceColor;
  final Color chevronColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppBorderRadius.borderRadiusLg,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: iconSurfaceColor,
                borderRadius: AppBorderRadius.borderRadiusLg,
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyBold.copyWith(
                  color: _ProfilePalette.title,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: chevronColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSurface extends StatelessWidget {
  const _ProfileSurface({
    required this.child,
    this.padding = AppSpacing.paddingMd,
    this.borderRadius = const BorderRadius.all(Radius.circular(36)),
    this.surfaceColor,
    this.surfaceSoftColor,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color? surfaceColor;
  final Color? surfaceSoftColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                surfaceColor ?? _ProfilePalette.surface,
                surfaceSoftColor ?? _ProfilePalette.surfaceSoft,
              ],
            ),
            borderRadius: borderRadius,
            border: Border.all(color: borderColor ?? _ProfilePalette.border),
            boxShadow: AppColors.shadowMd,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ProfilePalette {
  // Make profile surfaces match the app's glassmorphism (more see-through).
  static const Color surface = Color(0x4AFFFFFF);
  static const Color surfaceSoft = Color(0x227F5CA8);
  static const Color border = Color(0x52FFFFFF);
  static const Color listSurface = Color(0x3FFFFFFF);
  static const Color listSurfaceSoft = Color(0x1E7F5CA8);
  static const Color listBorder = Color(0x40FFFFFF);
  static const Color actionSurface = Color(0x46FFFFFF);
  static const Color actionSurfaceSoft = Color(0x247F5CA8);
  static const Color actionBorder = Color(0x45FFFFFF);
  static const Color actionIconSurface = Color(0xA6FFFFFF);
  static const Color warningIcon = Color(0xFF9A6A17);
  static const Color dangerIcon = Color(0xFFB13F69);
  static const Color title = Color(0xF2FFFFFF);
  static const Color subtitle = Color(0xBFFFFFFF);
  static const Color iconSurface = Color(0x26FFFFFF);
  static const Color chevron = Color(0xBFFFFFFF);
}
