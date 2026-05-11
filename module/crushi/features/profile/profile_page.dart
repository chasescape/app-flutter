import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:crushi/crushi/core/theme/app_theme.dart';
import 'package:crushi/crushi/core/router/global_router.dart';
import 'package:crushi/crushi/core/widgets/diffuse_background.dart';
import 'package:crushi/crushi/env/app_env.dart';
import 'package:crushi/crushi/light_handle.dart';
import 'package:crushi/gen_a/A.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isBusy = false;

  Future<void> _runWithLoading(Future<void> Function() fn) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      await Future.delayed(const Duration(milliseconds: 320));
      await fn();
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const _DeleteAccountDialog(),
    );
    if (ok != true) return;

    await _runWithLoading(() async {
      await LightHandle.deleteAccount();
      if (!mounted) return;
      GlobalRouter.I.goToLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            fit: StackFit.expand,
            children: [
              const Positioned.fill(
                child: DiffuseBackground(
                  base: Color(0xFF070B16),
                  bottom: Color(0xFF070B16),
                ),
              ),
              Positioned.fill(
                child: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraints.maxHeight),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg),
                              child: Text(
                                'Profile',
                                style: AppTypography.h2.copyWith(
                                  color: AppColors.textInverse,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg),
                              child: _GlassCard(
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: Colors.white.withOpacity(0.14),
                                      child: ClipOval(
                                        child: Image.asset(
                                          A.assets_crushi_logo,
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Crushi',
                                              style: AppTypography.h3),
                                          SizedBox(height: 2),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg),
                              child: _GlassCard(
                                child: Column(
                                  children: [
                                    _buildMenuItem(
                                      icon: Icons.history,
                                      title: 'Creation History',
                                      onTap: () =>
                                          GlobalRouter.I.goToHistory(),
                                    ),
                                    _divider(),
                                    _buildMenuItem(
                                      icon: Icons.monetization_on,
                                      title: 'Coins Store',
                                      onTap: () => GlobalRouter.I.goToCoins(),
                                    ),
                                    _divider(),
                                    _buildMenuItem(
                                      icon: Icons.feedback_outlined,
                                      title: 'Feedback',
                                      onTap: () =>
                                          GlobalRouter.I.goToFeedback(),
                                    ),
                                    _divider(),
                                    _buildMenuItem(
                                      icon: Icons.privacy_tip_outlined,
                                      title: 'Privacy Policy',
                                      onTap: () => GlobalRouter.I.goToAgreement(
                                        url: AppEnv().h5Privacy,
                                        title: 'Privacy Policy',
                                      ),
                                    ),
                                    _divider(),
                                    _buildMenuItem(
                                      icon: Icons.description_outlined,
                                      title: 'Terms of Service',
                                      onTap: () => GlobalRouter.I.goToAgreement(
                                        url: AppEnv().h5User,
                                        title: 'Terms of Service',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg),
                              child: _GlassCard(
                                child: Column(
                                  children: [
                                    _buildMenuItem(
                                      icon: Icons.delete_forever,
                                      title: 'Delete Account',
                                      isDestructive: true,
                                      onTap: _confirmDeleteAccount,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg),
                              child: SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  onPressed: () => _runWithLoading(() async {
                                    await LightHandle.logout();
                                    if (!mounted) return;
                                    GlobalRouter.I.goToLogin();
                                  }),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryMain,
                                    foregroundColor: AppColors.textInverse,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppRadius.full),
                                    ),
                                  ),
                                  icon: const Icon(Icons.logout, size: 18),
                                  label: const Text(
                                    'Log Out',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: AppTypography.fontFamily,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isBusy)
          Positioned.fill(
            child: Container(
              color: AppColors.overlay,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primaryMain),
              ),
            ),
          ),
      ],
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withOpacity(0.22),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? AppColors.error : AppColors.primaryMain,
              size: 22,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: AppTypography.body.copyWith(
                  color: isDestructive ? AppColors.error : AppColors.textInverse,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0x99FFFFFF),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: Colors.white.withOpacity(0.22)),
            boxShadow: AppShadows.md,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DeleteAccountDialog extends StatelessWidget {
  const _DeleteAccountDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryMain.withOpacity(0.14),
              blurRadius: 30,
              spreadRadius: -10,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.06),
              blurRadius: 20,
              spreadRadius: -12,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: Colors.white.withOpacity(0.22)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(
                            color: AppColors.error.withOpacity(0.25),
                          ),
                        ),
                        child: const Icon(
                          Icons.delete_forever_rounded,
                          color: AppColors.error,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Delete Account',
                          style: AppTypography.h3.copyWith(
                            color: AppColors.textInverse,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'This action cannot be undone. All your data will be permanently deleted.',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textInverse.withOpacity(0.8),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _DialogButton(
                          label: 'Cancel',
                          background: Colors.white.withOpacity(0.12),
                          foreground: AppColors.textInverse.withOpacity(0.9),
                          border: Colors.white.withOpacity(0.22),
                          onTap: () => Navigator.pop(context, false),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _DialogButton(
                          label: 'Delete',
                          background: AppColors.error.withOpacity(0.22),
                          foreground: AppColors.textInverse,
                          border: AppColors.error.withOpacity(0.35),
                          onTap: () => Navigator.pop(context, true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.border,
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color foreground;
  final Color border;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textInverse,
            fontFamily: AppTypography.fontFamily,
          ).copyWith(color: foreground),
        ),
      ),
    );
  }
}
