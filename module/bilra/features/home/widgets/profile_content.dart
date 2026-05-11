import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:bilra/bilra/controllers/history_controller.dart';
import 'package:bilra/bilra/controllers/user_controller.dart';
import 'package:bilra/bilra/env/app_env.dart';
import 'package:bilra/bilra/routes/app_router.dart';
import 'package:bilra/bilra/services/coins_manager.dart';
import 'package:bilra/bilra/theme/app_theme.dart';
import 'package:bilra/bilra/widgets/bilra_ui.dart';
import 'package:bilra/gen_a/A.dart';

class ProfileContent extends StatefulWidget {
  const ProfileContent({
    super.key,
    required this.embeddedInHome,
  });

  final bool embeddedInHome;

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  final CoinsManager _coinsManager = CoinsManager();
  bool _isDeletingAccount = false;

  @override
  void initState() {
    super.initState();
    _coinsManager.initialize();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _openFeedback() async {
    final submitted = await context.push<bool>(
      Uri(
        path: AppRoutes.feedback,
        queryParameters: const {'returnTab': '2'},
      ).toString(),
    );
    if (!mounted || submitted != true) return;
    await _showFeedbackSuccessSheet();
  }

  Future<void> _showFeedbackSuccessSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        Future<void>.delayed(const Duration(milliseconds: 1600), () {
          if (!sheetContext.mounted) return;
          Navigator.of(sheetContext).pop();
        });

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: BilraGlassCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              radius: 30,
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceTertiary,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.primaryMain,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Successful', style: AppTextStyles.h3),
                        SizedBox(height: 4),
                        Text(
                          'Feedback submitted successfully.',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final historyController = Get.find<HistoryController>();
    final userController = Get.find<UserController>();

    return Stack(
      children: [
        SafeArea(
          bottom: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              widget.embeddedInHome ? 120 : AppSpacing.xl,
            ),
            children: [
              BilraTopBar(
                title: widget.embeddedInHome ? 'Profile' : 'My profile',
                subtitle: 'Soft glam studio',
              ),
              const SizedBox(height: AppSpacing.md),
              BilraGlassCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                radius: 32,
                child: Column(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.secondaryLight,
                            AppColors.accentMain,
                          ],
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.asset(
                          A.assets_bilra_BilraLogo,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text('Bilra', style: AppTextStyles.h3),
                    const SizedBox(height: 6),
                    const Text(
                      'Save looks, unlock more analyses, and keep your image-first moodboard tidy.',
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Saved looks',
                            value: '${historyController.historyItems.length}',
                            onTap: () =>
                                AppRoutes.pushNamed(context, AppRoutes.history),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: ValueListenableBuilder<int>(
                            valueListenable: _coinsManager.coinsNotifier,
                            builder: (context, coins, child) {
                              return _StatCard(
                                label: 'Coins',
                                value: '$coins',
                                onTap: () =>
                                    AppRoutes.toCoinStore(context, returnTab: 2),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ValueListenableBuilder<int>(
                valueListenable: _coinsManager.coinsNotifier,
                builder: (context, coins, child) {
                  return BilraGlassCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    color: AppColors.surfaceTertiary.withValues(alpha: 0.92),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primaryMain,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: AppColors.textInverse,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Analysis balance',
                                  style: AppTextStyles.small),
                              const SizedBox(height: 2),
                              Text('$coins coins ready',
                                  style: AppTextStyles.h3),
                            ],
                          ),
                        ),
                        BilraPrimaryButton(
                          label: 'Store',
                          onTap: () =>
                              AppRoutes.toCoinStore(context, returnTab: 2),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _MenuCard(
                items: [
                  _MenuAction(
                    icon: Icons.mail_outline_rounded,
                    title: 'Feedback',
                    subtitle: 'Tell us how the experience feels',
                    onTap: _openFeedback,
                  ),
                  _MenuAction(
                    icon: Icons.description_outlined,
                    title: 'Terms of service',
                    subtitle: 'Review the app agreement',
                    onTap: () => AppRoutes.toAgreement(
                      context,
                      'Terms of Service',
                      AppEnv().h5User,
                      returnTab: 2,
                    ),
                  ),
                  _MenuAction(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy policy',
                    subtitle: 'See how your data is handled',
                    onTap: () => AppRoutes.toAgreement(
                      context,
                      'Privacy Policy',
                      AppEnv().h5Privacy,
                      returnTab: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _MenuCard(
                danger: true,
                items: [
                  _MenuAction(
                    icon: Icons.logout_rounded,
                    title: 'Log out',
                    subtitle: 'Sign out and return to the welcome screen',
                    onTap: () => _showLogoutDialog(userController),
                  ),
                  _MenuAction(
                    icon: Icons.person_remove_outlined,
                    title: 'Delete account',
                    subtitle: 'Remove your local account data on this device',
                    onTap: () => _deleteAccount(userController),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_isDeletingAccount)
          Positioned.fill(
            child: AbsorbPointer(
              child: Container(
                color: AppColors.primaryMain.withValues(alpha: 0.12),
                child: Center(
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: AppShadows.md,
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.accentMain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showLogoutDialog(UserController userController) {
    _showConfirmationDialog(
      title: 'Log out',
      message: 'You will be signed out and returned to the welcome screen.',
      confirmLabel: 'Log out',
      onConfirm: () async {
        await userController.signOut();
        if (!mounted) return;
        AppRoutes.pushReplacementNamed(context, AppRoutes.login);
      },
    );
  }

  Future<void> _deleteAccount(UserController userController) async {
    if (_isDeletingAccount) return;

    setState(() {
      _isDeletingAccount = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 650));
      await userController.clearUserData();
      await _coinsManager.clear();
      await Get.find<HistoryController>().clearHistory();
      if (!mounted) return;
      AppRoutes.pushReplacementNamed(context, AppRoutes.login);
    } finally {
      if (mounted) {
        setState(() {
          _isDeletingAccount = false;
        });
      }
    }
  }

  Future<void> _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required Future<void> Function() onConfirm,
    bool destructive = false,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title, style: AppTextStyles.h3),
        content: Text(message, style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await onConfirm();
            },
            style: TextButton.styleFrom(
              foregroundColor:
                  destructive ? AppColors.semanticError : AppColors.primaryMain,
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceSecondary,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.small),
              const SizedBox(height: 6),
              Text(value, style: AppTextStyles.h3),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.items,
    this.danger = false,
  });

  final List<_MenuAction> items;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return BilraGlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _MenuTile(
              action: items[i],
              danger: danger,
            ),
            if (i != items.length - 1)
              const Divider(
                  height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.action,
    required this.danger,
  });

  final _MenuAction action;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final foreground = danger ? AppColors.semanticError : AppColors.primaryMain;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: danger ? AppColors.secondaryLight : AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(action.icon, color: foreground),
      ),
      title: Text(
        action.title,
        style: AppTextStyles.body.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(action.subtitle, style: AppTextStyles.small),
      trailing: Icon(Icons.chevron_right_rounded, color: foreground),
      onTap: action.onTap,
    );
  }
}

class _MenuAction {
  const _MenuAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}
