import 'env/app_env.dart';
import 'core/managers/coins_manager.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

/// Interface singleton for global app management
class Interface {
  Interface._();

  static Interface? _instance;

  factory Interface() {
    _instance ??= Interface._();
    return _instance!;
  }

  // Routes
  String lightHome = '';
  String loginPage = '';

  // Environment
  String? env;

  // User authentication token
  String? authToken;

  /// Set environment configuration
  void setRunEnv({
    required String runEnv,
    required String apiUrl,
    required String h5Url,
    required String imUrl,
    required String logUrl,
    required String h5User,
    required String h5Privacy,
  }) {
    env = runEnv;

    final config = AppEnv();
    config.env = runEnv == 'prod' ? AppEnvType.product : AppEnvType.test;
    config.hostApi = apiUrl;
    config.hostH5 = h5Url;
    config.hostIM = imUrl;
    config.hostLog = logUrl;
    config.h5User = '$h5Url/$h5User';
    config.h5Privacy = '$h5Url/$h5Privacy';
  }

  /// Initialize app services
  Future<void> prevInitialize() async {
    await StorageService.instance.init();

    // Load auth token from storage
    final storage = StorageService.instance;
    authToken = await storage.getAuthToken();
  }

  /// Sign in action (mock login with global loading)
  Future<void> doSignInAction() async {
    // Show global loading dialog
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B9D)),
              ),
              SizedBox(height: 16),
              Text(
                'Signing in...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    // Simulate API request delay (1-2 seconds)
    await Future.delayed(
      Duration(seconds: 1 + (DateTime.now().millisecond % 2)),
    );

    // Set mock auth token
    authToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';

    // Save to storage
    await StorageService.instance.setAuthToken(authToken!);

    // Set home route
    lightHome = '/home';

    // Close loading dialog
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  /// Sign out action with confirmation dialog and global loading
  Future<void> signOut() async {
    // Show confirmation dialog
    AwesomeDialog(
      context: Get.overlayContext!,
      dialogType: DialogType.warning,
      customHeader: Container(
        width: 88,
        height: 88,
        decoration: const BoxDecoration(
          color: AppColors.roseDeep,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.priority_high_rounded,
          color: Colors.white,
          size: 54,
        ),
      ),
      animType: AnimType.scale,
      title: 'Sign Out',
      desc: 'Are you sure you want to sign out?',
      btnCancelText: 'Cancel',
      btnOkText: 'Sign Out',
      btnCancelColor: AppColors.rose,
      btnOkColor: AppColors.mint,
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        // Show global loading dialog
        Get.dialog(
          Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFFFF6B9D)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Signing out...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          barrierDismissible: false,
        );

        // Simulate API request delay
        await Future.delayed(const Duration(milliseconds: 800));

        // Call onAuthTokenRemoved for token removal
        await onAuthTokenRemoved();

        // Close loading dialog
        if (Get.isDialogOpen == true) {
          Get.back();
        }

        // Navigate to login page
        Get.offAllNamed('/login');
      },
    ).show();
  }

  /// Clear all user data with confirmation dialog and global loading
  Future<void> clearAllUserData() async {
    // Show confirmation dialog
    AwesomeDialog(
      context: Get.overlayContext!,
      dialogType: DialogType.warning,
      customHeader: Container(
        width: 88,
        height: 88,
        decoration: const BoxDecoration(
          color: AppColors.roseDeep,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.priority_high_rounded,
          color: Colors.white,
          size: 54,
        ),
      ),
      animType: AnimType.scale,
      title: 'Delete Account',
      desc:
          'This will permanently delete your account and all data. This action cannot be undone.',
      btnCancelText: 'Cancel',
      btnOkText: 'Delete',
      btnCancelColor: AppColors.rose,
      btnOkColor: AppColors.mint,
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        // Show second confirmation dialog
        AwesomeDialog(
          context: Get.overlayContext!,
          dialogType: DialogType.noHeader,
          animType: AnimType.scale,
          title: 'Confirm Deletion',
          desc:
              'Are you really sure? This will delete all your data including records, coins, and profile.',
          btnCancelText: 'Cancel',
          btnOkText: 'Yes, Delete',
          btnCancelColor: AppColors.rose,
          btnOkColor: AppColors.mint,
          btnCancelOnPress: () {},
          btnOkOnPress: () async {
            // Show global loading dialog
            Get.dialog(
              Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFFFF6B9D)),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Deleting account...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              barrierDismissible: false,
            );

            // Simulate API request delay
            await Future.delayed(const Duration(milliseconds: 1200));

            // Clear all user data from storage
            await StorageService.instance.clearAll();

            // Clear coins data
            await CoinsManager.instance.clear();

            // Call onAuthTokenRemoved for token removal
            await onAuthTokenRemoved();

            // Close loading dialog
            if (Get.isDialogOpen == true) {
              Get.back();
            }

            // Navigate to login page
            Get.offAllNamed('/login');
          },
        ).show();
      },
    ).show();
  }

  /// Set home entrance for Side A
  Future<void> setHomeEntranceForSideA() async {
    // Not needed for Side A
  }

  /// Handle auth token removal
  Future<void> onAuthTokenRemoved() async {
    await StorageService.instance.removeAuthToken();
    _doShuffleActions();
  }

  void _doShuffleActions() {
    // Placeholder for shuffle actions
  }
}
