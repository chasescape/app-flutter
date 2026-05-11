import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mimiu/mimiu/app/routes/app_routes.dart';
import 'package:mimiu/mimiu/interface.dart';

class ProfileLogic extends GetxController {
  final RxBool accountActionInProgress = false.obs;
  final RxString accountActionText = 'Working...'.obs;

  Future<T?> _runWithLoading<T>(
    String text,
    Future<T> Function() action,
  ) async {
    if (accountActionInProgress.value) return null;
    accountActionText.value = text;
    accountActionInProgress.value = true;
    // Ensure the loading overlay is visible for ~1–2s.
    final startedAt = DateTime.now();
    await Future<void>.delayed(const Duration(milliseconds: 120));
    try {
      final result = await action();
      final elapsedMs = DateTime.now().difference(startedAt).inMilliseconds;
      const minVisibleMs = 1200;
      if (elapsedMs < minVisibleMs) {
        await Future<void>.delayed(Duration(milliseconds: minVisibleMs - elapsedMs));
      }
      return result;
    } finally {
      accountActionInProgress.value = false;
    }
  }

  Future<void> logOut() async {
    await _runWithLoading('Signing out...', () async {
      Interface().authToken = null;
      await Interface().onAuthTokenRemoved();
      Get.offAllNamed(AppRoutes.login);
    });
  }

  Future<void> deleteAccount() async {
    final confirmed = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Delete account?'),
            content: const Text(
              'This will permanently remove your local data on this device, including analyzed albums and coins data.',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7F1D1D),
                  foregroundColor: const Color(0xFFFEE2E2),
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
          barrierDismissible: true,
        ) ??
        false;

    if (!confirmed) return;

    await _runWithLoading('Deleting account...', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      Interface().authToken = null;
      await Interface().onAuthTokenRemoved();
      Get.offAllNamed(AppRoutes.login);
    });
  }
}
