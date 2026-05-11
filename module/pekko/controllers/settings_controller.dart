import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/services/purchase_service.dart';
import '../core/theme/app_colors.dart';
import '../core/routes/app_routes.dart';
import '../env/app_env.dart';
import '../light_handle.dart';
import '../pages/coin_store/contact_coins.dart';
import '../pages/widgets/common_widgets.dart';
import 'main_controller.dart';

/// Settings controller
class SettingsController extends GetxController {
  final MainController _mainController = Get.find<MainController>();

  // Coin packages
  final List<Contact575CoinProduct> coinPackages =
      Privatised236CoinProductData.allProductsGrouped;

  Future<void> purchaseCoins(Contact575CoinProduct package) async {
    final purchaseService = PurchaseService.to;

    // Show loading
    AppLoading.show();

    await purchaseService.executePurchase(
      package.goodsId,
      package.exchangeCoin,
      onResult: (success, productId, coins, error) {
        AppLoading.hide();

        if (success) {
          // Refresh main controller user data
          _mainController.refreshUserData();

          Get.snackbar(
            'Purchase Successful',
            '+$coins coins added',
            backgroundColor: AppColors.success,
            colorText: AppColors.textInverse,
            duration: const Duration(seconds: 2),
          );
        } else {
          // Handle canceled vs error
          final message = error ?? 'Purchase canceled';
          Get.snackbar(
            error == null ? 'Purchase Canceled' : 'Purchase Failed',
            message,
            backgroundColor: AppColors.error,
            colorText: AppColors.textInverse,
          );
        }
      },
    );
  }

  Future<void> clearAllData() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will delete all your data including records, preferences, and account information. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    AppLoading.show();

    try {
      await LightHandle.deleteAccount();
      AppLoading.hide();
    } catch (e) {
      AppLoading.hide();
      Get.snackbar(
        'Error',
        'Failed to delete account',
        backgroundColor: AppColors.error,
        colorText: AppColors.textInverse,
      );
    }
  }

  Future<void> logout() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    AppLoading.show();

    try {
      await LightHandle.logout();
      AppLoading.hide();
    } catch (e) {
      AppLoading.hide();
      Get.snackbar(
        'Error',
        'Failed to log out',
        backgroundColor: AppColors.error,
        colorText: AppColors.textInverse,
      );
    }
  }

  void openTermsOfService() {
    Get.back();
    Get.toNamed(RouteHelper.toAgreement(
      'Terms of Service',
      AppEnv().h5User,
    ));
  }

  void openPrivacyPolicy() {
    Get.back();
    Get.toNamed(RouteHelper.toAgreement(
      'Privacy Policy',
      AppEnv().h5Privacy,
    ));
  }

  void openFeedback() {
    Get.toNamed('/feedback');
  }

  void openCoinStore() {
    Get.toNamed('/coin-store');
  }

  String get appVersion => '1.0.0';
}
