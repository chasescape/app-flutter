import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_pages.dart';

/// App Navigation Helper
class AppNavigation {
  AppNavigation._();

  /// Get current route
  static String get currentRoute => Get.currentRoute;

  /// Navigate back
  static void back<T>({T? result}) {
    Get.back(result: result);
  }

  /// Navigate until route
  static void backUntil(String route) {
    Get.until((route) => Get.currentRoute == route);
  }

  /// Show loading dialog
  static void showLoading({String message = 'Loading...'}) {
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );
  }

  /// Hide loading dialog
  static void hideLoading() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  /// Show snackbar
  static void showSnackbar(
    String title,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title,
      message,
      duration: duration,
      snackPosition: SnackPosition.TOP,
    );
  }

  /// Show error dialog
  static void showError(String message) {
    Get.dialog(
      AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show success dialog
  static void showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
      duration: const Duration(seconds: 2),
    );
  }

  /// Show confirm dialog
  static Future<bool?> showConfirmDialog(
    String title,
    String message, {
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) {
    return Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Show bottom sheet
  static Future<T?> showBottomSheet<T>(Widget widget) {
    return Get.bottomSheet<T>(
      widget,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
