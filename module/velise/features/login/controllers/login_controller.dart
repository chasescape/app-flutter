import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../interface.dart';
import '../../../routes/app_pages.dart';
import '../../../services/global_service.dart';

/// Login Controller
/// Fixed pattern: Full screen background + single button
class LoginController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool hasAgreedToTerms = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    final globalService = GlobalService.to;
    if (globalService.isLoggedIn) {
      Future.delayed(Duration.zero, () {
        AppRoutes.goToHome();
      });
    }
  }

  void toggleAgreement() {
    hasAgreedToTerms.value = !hasAgreedToTerms.value;
  }

  Future<void> onLoginTap() async {
    if (isLoading.value) return;

    if (!hasAgreedToTerms.value) {
      final agreed = await _showAgreementDialog();
      if (!agreed) {
        return;
      }
      hasAgreedToTerms.value = true;
    }

    try {
      isLoading.value = true;

      await Future.delayed(const Duration(seconds: 1));

      final globalService = GlobalService.to;
      await globalService.saveAuthToken(
        'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      );

      Interface().authToken = globalService.authToken.value;

      AppRoutes.goToHome();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Login failed. Please try again.',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _showAgreementDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Agreement Required'),
        content: const Text(
          'Please agree to the Terms & Conditions and Privacy Policy before entering Velise.',
        ),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              side: BorderSide(color: Colors.black.withValues(alpha: 0.16)),
            ),
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Agree'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
