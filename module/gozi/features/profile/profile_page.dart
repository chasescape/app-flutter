import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:achievenote/gen_a/A.dart';
import 'package:achievenote/gozi/routes/global_router.dart';
import 'package:achievenote/gozi/services/coins_manager.dart';
import 'package:achievenote/gozi/services/achievement_storage_service.dart';
import 'package:achievenote/gozi/services/auth_service.dart';
import 'package:achievenote/gozi/widgets/common/app_card.dart';
import 'package:achievenote/gozi/widgets/common/app_scaffold.dart';
import 'package:achievenote/gozi/widgets/common/loading_overlay.dart';
import 'package:achievenote/gozi/theme/app_theme.dart';
import 'package:achievenote/gozi/env/app_env.dart';

const double _profileCardHorizontalMargin = AppTheme.lg;

/// Profile Page - User profile and settings
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  /// Coins manager
  final CoinsManager _coinsManager = CoinsManager.instance;

  @override
  void initState() {
    super.initState();
    // Initialize CoinsManager
    _coinsManager.initialize();
  }

  Future<void> _showLogoutDialog() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Logout',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _performLogout();
    }
  }

  Future<void> _performLogout() async {
    // Show global loading
    AppLoadingOverlay.show(Get.context!);

    try {
      // Clear coins data
      await _coinsManager.clear();

      final service = Get.find<AuthService>();
      await service.logout();

      if (Get.context != null) {
        AppLoadingOverlay.hide(Get.context!);
      }

      // Navigate to login page
      GlobalRouter.I.goToLogin();
    } catch (e) {
      if (Get.context != null) {
        AppLoadingOverlay.hide(Get.context!);
      }

      Get.snackbar(
        'Error',
        'Logout failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.error,
        colorText: AppTheme.primaryWhite,
      );
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    final firstConfirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete your account and related data. This action cannot be undone.\n\nAre you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Continue',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );

    if (firstConfirmed != true) return;

    final secondConfirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text(
          'This is your last confirmation. Your account and all data will be permanently deleted.\n\nDelete this account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Delete Account',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );

    if (secondConfirmed == true) {
      await _performDeleteAccount();
    }
  }

  Future<void> _performDeleteAccount() async {
    AppLoadingOverlay.show(Get.context!);

    try {
      final achievementService = Get.find<AchievementStorageService>();
      await achievementService.clearAll();

      await _coinsManager.clear();

      final authService = Get.find<AuthService>();
      await authService.logout();

      if (Get.context != null) {
        AppLoadingOverlay.hide(Get.context!);
      }

      GlobalRouter.I.goToLogin();
    } catch (e) {
      if (Get.context != null) {
        AppLoadingOverlay.hide(Get.context!);
      }

      Get.snackbar(
        'Error',
        'Failed to delete account: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.error,
        colorText: AppTheme.primaryWhite,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 262),
        child: Column(
          children: [
            const SizedBox(height: AppTheme.lg),

            // App Identity Card
            AppCard(
              margin: const EdgeInsets.symmetric(
                horizontal: _profileCardHorizontalMargin,
                vertical: AppTheme.sm,
              ),
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: AppTheme.softSurfaceGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      boxShadow: AppTheme.imageShadow,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      child: Image.asset(
                        A.assets_gozi_logo,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.lg),
                  Expanded(
                    child: Text(
                      'Gozi',
                      style: AppTheme.h3.copyWith(
                        color: AppTheme.textInverse,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.lg),

            // Stats Cards
            GetX<AchievementStorageService>(
              builder: (service) {
                final achievementCount = service.achievements.length;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _profileCardHorizontalMargin - AppTheme.sm,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppCard(
                          child: Column(
                            children: [
                              Text(
                                '$achievementCount',
                                style: AppTheme.h2.copyWith(
                                  color: AppTheme.accentRed,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppTheme.xs),
                              Text(
                                'Achievements',
                                style: AppTheme.caption.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: AppCard(
                          child: Column(
                            children: [
                              // Coins balance with ValueListenableBuilder
                              ValueListenableBuilder<int>(
                                valueListenable: _coinsManager.balanceNotifier,
                                builder: (context, balance, child) {
                                  return Text(
                                    '$balance',
                                    style: AppTheme.h2.copyWith(
                                      color: AppTheme.accentRed,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: AppTheme.xs),
                              Text(
                                'Coins',
                                style: AppTheme.caption.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: AppTheme.lg),

            // Menu Items
            _MenuItem(
              icon: Icons.storefront_outlined,
              title: 'Get Coins',
              onTap: () => GlobalRouter.I.goToStore(),
            ),
            _MenuItem(
              icon: Icons.feedback_outlined,
              title: 'Send Feedback',
              onTap: () => GlobalRouter.I.goToFeedback(),
            ),
            _MenuItem(
              icon: Icons.info_outline,
              title: 'Terms of Service',
              onTap: () => GlobalRouter.I.goToAgreement(
                url: AppEnv().h5User,
                title: 'Terms of Service',
              ),
            ),
            _MenuItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () => GlobalRouter.I.goToAgreement(
                url: AppEnv().h5Privacy,
                title: 'Privacy Policy',
              ),
            ),

            const SizedBox(height: AppTheme.lg),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: _profileCardHorizontalMargin),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _showLogoutDialog,
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.error,
                        backgroundColor:
                            AppTheme.primaryWhite.withValues(alpha: 0.52),
                        side: BorderSide(
                            color: AppTheme.error.withValues(alpha: 0.34)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusFull),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.sm),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _showDeleteAccountDialog,
                      icon: const Icon(Icons.delete_forever_outlined),
                      label: const Text('Delete Account'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.error,
                        backgroundColor:
                            AppTheme.primaryWhite.withValues(alpha: 0.38),
                        side: BorderSide(
                            color: AppTheme.error.withValues(alpha: 0.28)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusFull),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.xl),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.symmetric(
        horizontal: _profileCardHorizontalMargin,
        vertical: AppTheme.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.accentRed.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppTheme.accentRed,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.md),
          Expanded(
            child: Text(
              title,
              style: AppTheme.body.copyWith(
                color: AppTheme.textInverse,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppTheme.textSecondary,
          ),
        ],
      ),
    );
  }
}
