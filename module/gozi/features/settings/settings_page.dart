import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:achievenote/gozi/routes/global_router.dart';
import 'package:achievenote/gozi/services/achievement_storage_service.dart';
import 'package:achievenote/gozi/services/auth_service.dart';
import 'package:achievenote/gozi/services/coins_manager.dart';
import 'package:achievenote/gozi/services/theme_service.dart';
import 'package:achievenote/gozi/widgets/common/app_card.dart';
import 'package:achievenote/gozi/widgets/common/app_scaffold.dart';
import 'package:achievenote/gozi/widgets/common/loading_overlay.dart';
import 'package:achievenote/gozi/theme/app_theme.dart';
import 'package:achievenote/gozi/env/app_env.dart';

/// Settings Page - App settings and data management
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _showDeleteAccountDialog() async {
    // First confirmation
    final firstConfirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete your account and all associated data. This action cannot be undone.\n\nAre you sure you want to continue?',
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

    // Second confirmation
    final secondConfirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This is your last chance. After this, your account and all data will be permanently deleted.\n\nAre you absolutely sure?',
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
    // Show global loading
    AppLoadingOverlay.show(Get.context!);

    try {
      // Clear achievements
      final achievementService = Get.find<AchievementStorageService>();
      await achievementService.clearAll();

      // Clear coins
      final coinsManager = CoinsManager.instance;
      await coinsManager.clear();

      // Logout (calls Interface.onAuthTokenRemoved)
      final authService = Get.find<AuthService>();
      await authService.logout();

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
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppTheme.xl),
        children: [
          const SizedBox(height: AppTheme.lg),

          // Theme Toggle
          AppCard(
            child: GetX<ThemeService>(
              builder: (service) {
                return SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Toggle dark theme'),
                  activeColor: AppTheme.accentRed,
                  value: service.isDarkMode,
                  onChanged: (value) {
                    service.toggleTheme();
                  },
                );
              },
            ),
          ),

          const SizedBox(height: AppTheme.lg),

          // Legal Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.lg),
            child: Text(
              'Legal',
              style: AppTheme.caption.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.sm),

          _SettingItem(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () => GlobalRouter.I.goToAgreement(
              url: AppEnv().h5User,
              title: 'Terms of Service',
            ),
          ),
          _SettingItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () => GlobalRouter.I.goToAgreement(
              url: AppEnv().h5Privacy,
              title: 'Privacy Policy',
            ),
          ),

          const SizedBox(height: AppTheme.lg),

          // Account Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.lg),
            child: Text(
              'Account',
              style: AppTheme.caption.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.sm),

          AppCard(
            child: ListTile(
              leading: const Icon(
                Icons.delete_forever,
                color: AppTheme.error,
              ),
              title: const Text(
                'Delete Account',
                style: TextStyle(color: AppTheme.error),
              ),
              subtitle: const Text(
                'Permanently delete your account and all data',
              ),
              onTap: _showDeleteAccountDialog,
            ),
          ),

          const SizedBox(height: AppTheme.xl),

          // App Version
          Center(
            child: Text(
              'AchieveNote v1.0.0',
              style: AppTheme.small.copyWith(
                color: AppTheme.textDisabled,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.lg),
        ],
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.accentRed,
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
