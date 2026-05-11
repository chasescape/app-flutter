import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

import 'package:enkou/enkou/app/routes/app_routes.dart';
import 'package:enkou/enkou/app/core/app_config_service.dart';
import 'package:enkou/enkou/app/core/auth_service.dart';
import 'package:enkou/enkou/app/core/enkou_service_adapter.dart';
import 'package:enkou/enkou/app/widget/app_toast.dart';
import 'package:enkou/enkou/app/widget/inapp_webview_page.dart';
import 'package:enkou/enkou/app/widget/loading_overlay.dart';
import 'package:enkou/enkou/env/app_env.dart';
import 'package:enkou/enkou/light_handle.dart';
import 'package:enkou/enkou/interface.dart';

class ProfileLogic extends GetxController {
  final isSubmitting = false.obs;

  late final EnkouServiceAdapter _config;
  late final Dio _dio;
  late final AppConfigService _appConfigService;
  late final AuthService _authService;

  @override
  void onInit() {
    super.onInit();
    _config = EnkouServiceAdapter();
    _dio = Dio(
      BaseOptions(
        baseUrl: AppEnv().hostApi,
        connectTimeout: const Duration(seconds: 25),
        receiveTimeout: const Duration(seconds: 25),
        sendTimeout: const Duration(seconds: 25),
      ),
    );
    _appConfigService = AppConfigService(_dio, _config);
    _authService = AuthService(_dio, _config);
  }

  void openFeedback() {
    Get.toNamed(AppRoutes.feedback);
  }

  void openTerms() {
    _openLink(
      title: 'Terms of Service',
      link: AppEnv().h5User,
    );
  }

  void openPrivacy() {
    _openLink(
      title: 'Privacy Policy',
      link: AppEnv().h5Privacy,
    );
  }

  void openRecharge() {
    Get.toNamed(AppRoutes.coins);
  }

  void openHistory() {
    Get.toNamed(AppRoutes.history);
  }

  Future<void> logout() async {
    if (isSubmitting.value) return;
    isSubmitting.value = true;
    LoadingOverlay.show();
    try {
      await _config.ensureDeviceId();
      await _ensureEncryptKey();
      await _authService.logout();
      await _config.clearAuthToken();
      Interface().authToken = null;
      await LightHandle.onAuthTokenRemoved();
      AppToast.short('Logged out');
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      AppToast.short('Logout failed', isError: true);
    } finally {
      LoadingOverlay.hide();
      isSubmitting.value = false;
    }
  }

  Future<void> deleteAccount() async {
    if (isSubmitting.value) return;
    isSubmitting.value = true;
    LoadingOverlay.show();
    try {
      await _config.ensureDeviceId();
      await _ensureEncryptKey();
      await _authService.deleteAccount();
      await _config.clearAuthToken();
      Interface().authToken = null;
      await LightHandle.deleteAccount();
      AppToast.short('Account deleted');
    } catch (e) {
      AppToast.short('Delete account failed', isError: true);
    } finally {
      LoadingOverlay.hide();
      isSubmitting.value = false;
    }
  }

  Future<void> _ensureEncryptKey() async {
    final i = Interface();
    if (i.encryptKey != null && i.encryptKey!.isNotEmpty) {
      _config.encryptKey = i.encryptKey;
      return;
    }

    final cached = await _config.getString('encrypt_key');
    if (cached != null && cached.isNotEmpty) {
      _config.encryptKey = cached;
      return;
    }

    await _appConfigService.getAppConfig();
  }

  void _openLink({
    required String title,
    required String link,
  }) {
    if (link.isEmpty) {
      Get.dialog(
        AlertDialog(
          title: Text(title),
          content: const Text(
            'No URL configured yet.',
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: Get.back,
              child: const Text('Close'),
            ),
          ],
        ),
      );
      return;
    }
    Get.to(
      () => InAppWebViewPage(
        title: title,
        url: link,
      ),
    );
  }
}
