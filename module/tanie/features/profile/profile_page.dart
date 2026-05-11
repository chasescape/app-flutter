import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tanie/gen_a/A.dart';
import 'package:tanie/tanie/bloc/auth/auth_bloc.dart';
import 'package:tanie/tanie/bloc/auth/auth_event.dart';
import 'package:tanie/tanie/bloc/auth/auth_state.dart';
import 'package:tanie/tanie/env/app_env.dart';
import 'package:tanie/tanie/routes/app_routes.dart';
import 'package:tanie/tanie/services/reflection_storage_service.dart';
import 'package:tanie/tanie/theme/app_colors.dart';
import 'package:tanie/tanie/theme/app_shadows.dart';
import 'package:tanie/tanie/theme/app_text_styles.dart';
import 'package:tanie/tanie/widgets/app_button.dart';
import 'package:tanie/tanie/widgets/app_card.dart';
import 'package:tanie/tanie/widgets/app_ui.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<int> _loadGalleryCount() async {
    await reflectionStorageService.init();
    return reflectionStorageService
        .getAllEntries()
        .where((entry) => entry.assetImg.trim().isNotEmpty)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.isAuthenticated != current.isAuthenticated ||
          previous.isLoading != current.isLoading,
      listener: (context, state) {
        if (!state.isAuthenticated && !state.isLoading) {
          context.go(AppRoutes.login);
        }
      },
      child: Scaffold(
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return AppBackdrop(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppSectionTitle(
                      title: 'Profile',
                    ),
                    const SizedBox(height: 18),
                    AppSectionCard(
                      gradient: AppColors.heroGradient,
                      child: Row(
                        children: [
                          Container(
                            width: 82,
                            height: 82,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                A.assets_tanie_TanieLogo,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tanie',
                                  style: AppTextStyles.h2,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${state.coins} coins available',
                                  style: AppTextStyles.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FutureBuilder<int>(
                            future: _loadGalleryCount(),
                            builder: (context, snapshot) {
                              final galleryCount = snapshot.data ?? 0;
                              return AppStatCard(
                                label: 'Gallery',
                                value: '$galleryCount',
                                icon: Icons.photo_library_outlined,
                                onTap: () => context.go(AppRoutes.history),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppStatCard(
                            label: 'Coins',
                            value: '${state.coins}',
                            icon: Icons.monetization_on_outlined,
                            onTap: () => context.push(AppRoutes.coinStore),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    AppPrimaryButton(
                      text: 'Get More Coins',
                      onPressed: () => context.push(AppRoutes.coinStore),
                    ),
                    const SizedBox(height: 18),
                    _ProfileMenuItem(
                      icon: Icons.feedback_outlined,
                      title: 'Feedback',
                      onTap: () => context.push(AppRoutes.feedback),
                    ),
                    const SizedBox(height: 12),
                    _ProfileMenuItem(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () => AppRoutes.toAgreement(
                        context,
                        'Privacy Policy',
                        AppEnv().h5Privacy.isNotEmpty
                            ? AppEnv().h5Privacy
                            : 'https://example.com/privacy',
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ProfileMenuItem(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      onTap: () => AppRoutes.toAgreement(
                        context,
                        'Terms of Service',
                        AppEnv().h5User.isNotEmpty
                            ? AppEnv().h5User
                            : 'https://example.com/terms',
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppSecondaryButton(
                      text: 'Log Out',
                      onPressed: () => _showLogoutDialog(context),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton(
                        onPressed: () => _showDeleteAccountDialog(context),
                        child: Text(
                          'Delete Account',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    _showActionDialog(
      context,
      title: 'Log Out',
      message: 'Are you sure you want to log out?',
      confirmText: 'Log Out',
      onConfirm: () => context.read<AuthBloc>().add(const LogoutEvent()),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    _showActionDialog(
      context,
      title: 'Delete Account',
      message: 'This action cannot be undone. Delete your account?',
      confirmText: 'Delete',
      isDestructive: true,
      onConfirm: () => context.read<AuthBloc>().add(const DeleteAccountEvent()),
    );
  }

  void _showActionDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTextStyles.h3),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _DialogActionButton(
                        text: 'Cancel',
                        onPressed: () => dialogContext.pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DialogActionButton(
                        text: confirmText,
                        isPrimary: true,
                        isDestructive: isDestructive,
                        onPressed: () {
                          dialogContext.pop();
                          onConfirm();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.cardMuted,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.secondaryMain),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title, style: AppTextStyles.bodyLarge),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _DialogActionButton extends StatelessWidget {
  final String text;
  final bool isPrimary;
  final bool isDestructive;
  final VoidCallback onPressed;

  const _DialogActionButton({
    required this.text,
    required this.onPressed,
    this.isPrimary = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isPrimary
        ? (isDestructive ? AppColors.error : AppColors.buttonPrimary)
        : AppColors.cardMuted;
    final textColor = isPrimary ? AppColors.white : AppColors.textPrimary;
    final borderColor = isPrimary
        ? (isDestructive ? AppColors.error : AppColors.secondaryMain)
        : AppColors.cardBorder;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: isPrimary ? AppShadows.button : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Center(
            child: Text(
              text,
              style: AppTextStyles.buttonSecondary.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
