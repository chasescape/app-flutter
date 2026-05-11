import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../services/global_service.dart';
import '../../../services/coins/coins_manager.dart';
import '../../../services/storage/storage_service.dart';
import '../../../interface.dart';
import '../../../env/app_env.dart';

/// Profile Controller
class ProfileController extends GetxController {
  final GlobalService _globalService = GlobalService.to;
  final CoinsManager _coinsManager = CoinsManager.instance;
  final StorageService _storage = StorageService.instance;
  final RxBool isLoading = false.obs;

  String get userName => _globalService.userName.value ?? 'Artist';
  String get coinBalance => _coinsManager.balanceString;

  void onTopUp() {
    Get.toNamed('/coin_store');
  }

  void onHistory() {
    Get.toNamed('/history');
  }

  void onFeedback() {
    Get.toNamed('/feedback');
  }

  void onPrivacyPolicy() {
    final env = AppEnv();
    Get.toNamed('/agreement', arguments: {
      'title': 'Privacy Policy',
      'url': env.h5Privacy,
    });
  }

  void onTermsOfService() {
    final env = AppEnv();
    Get.toNamed('/agreement', arguments: {
      'title': 'Terms of Service',
      'url': env.h5User,
    });
  }

  Future<void> onLogout() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            style: _cancelButtonStyle(),
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (result == true) {
      isLoading.value = true;

      // Clear auth state
      await _globalService.clearAuthState();
      Interface().authToken = null;

      // Navigate to login
      Get.offAllNamed('/login');
    }
  }

  Future<void> onDeleteAccount() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This will also clear your saved history and coin balance on this device.',
        ),
        actions: [
          TextButton(
            style: _cancelButtonStyle(),
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      isLoading.value = true;

      try {
        await _globalService.historyService.clear();
        await _storage.remove(StorageKeys.deliveredPurchaseIds);
        await _globalService.clearAuthState();
        await _coinsManager.clear();
        Interface().authToken = null;

        Get.offAllNamed('/login');
        Get.snackbar(
          'Account Deleted',
          'History records and coin balance were cleared.',
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  ButtonStyle _cancelButtonStyle() {
    return TextButton.styleFrom(
      foregroundColor: AppColors.textOnSurfaceMuted,
      textStyle: const TextStyle(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
