import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants/app_border_radius.dart';
import '../core/constants/app_colors.dart';
import '../interface.dart';
import '../services/storage_service.dart';
import '../services/coins_manager.dart';
import '../routes/app_routes.dart';
import '../env/app_env.dart';

class SettingsController extends GetxController {
  final StorageService _storage = StorageService.to;
  final CoinsManager _coinsManager = CoinsManager.to;

  ValueNotifier<int> get coinsNotifier => _coinsManager.coinsNotifier;
  int get coins => _coinsManager.coins;

  @override
  void refresh() {
    _coinsManager.refresh();
  }

  Future<void> clearAllData() async {
    await Get.dialog<void>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
        ),
        title: const Text(
          'Delete Account',
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'This will delete all your data including history and coins. This action cannot be undone.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          OutlinedButton(
            onPressed: Get.back,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: BorderSide(
                color: AppColors.textPrimary.withValues(alpha: 0.34),
              ),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.full),
              ),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _coinsManager.clear();
              await _storage.clearAllData();
              Interface().authToken = null;
              Interface().onAuthTokenRemoved();
              Get.offAllNamed(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppColors.semanticError,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.full),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void logout() {
    Interface().authToken = null;
    Interface().onAuthTokenRemoved();
    Get.offAllNamed(AppRoutes.login);
  }

  void openCoinStore() {
    Get.toNamed(AppRoutes.coinStore);
  }

  void openAgreement() {
    Get.toNamed(AppRoutes.agreement, arguments: {
      'title': 'Terms of Service',
      'url': AppEnv().h5User,
    });
  }

  void openPrivacy() {
    Get.toNamed(AppRoutes.agreement, arguments: {
      'title': 'Privacy Policy',
      'url': AppEnv().h5Privacy,
    });
  }

  Future<void> openFeedback() async {
    final submitted = await Get.toNamed(AppRoutes.feedback);
    if (submitted == true) {
      Get.snackbar(
        'Success',
        'Thank you for your feedback!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.textPrimary,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: AppBorderRadius.xl,
      );
    }
  }
}
