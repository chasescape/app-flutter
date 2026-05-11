import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:get/get.dart';
import 'package:yapo/yapo/app/routes/app_pages.dart';
import 'package:yapo/yapo/app/services/auth_manager.dart';
import 'package:yapo/yapo/core/adapters/yapo_service_adapter.dart';
import 'package:yapo/yapo/core/network/app_config_service.dart';
import 'package:yapo/yapo/core/network/auth_service.dart';
import 'package:yapo/yapo/env/app_env.dart';
import 'package:yapo/yapo/interface.dart';

class LoginLogic extends GetxController with GetSingleTickerProviderStateMixin {
  final agreedToTerms = false.obs;
  final isLoading = false.obs;

  late final AppConfigService _appConfigService;
  late final AuthService _authService;
  late final YapoServiceAdapter _config;
  late final Dio _dio;

  late AnimationController animationController;
  late Animation<double> logoScale;
  late Animation<double> buttonSlide;
  late Animation<double> buttonFade;

  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void onInit() {
    super.onInit();
    _initServices();
    _initAnimations();
    _initGestureRecognizers();
  }

  @override
  void onClose() {
    if (animationController.isAnimating) {
      animationController.stop();
    }
    animationController.dispose();

    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();

    _dio.close(force: true);
    
    super.onClose();
  }

  void _initGestureRecognizers() {
    _termsRecognizer = TapGestureRecognizer()..onTap = openTerms;
    _privacyRecognizer = TapGestureRecognizer()..onTap = openPrivacy;
  }

  TapGestureRecognizer get termsRecognizer => _termsRecognizer;

  TapGestureRecognizer get privacyRecognizer => _privacyRecognizer;

  void _initAnimations() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    buttonSlide = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!Get.isRegistered<LoginLogic>(tag: 'login_page')) return;
      if (animationController.isAnimating) return;
      animationController.forward();
    });
  }

  void _initServices() {
    _config = YapoServiceAdapter();
    _dio = Dio(BaseOptions(
      baseUrl: AppEnv().hostApi,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
    
    _appConfigService = AppConfigService(_dio, _config);
    _authService = AuthService(_dio, _config);
  }

  void toggleAgreement() {
    agreedToTerms.value = !agreedToTerms.value;
  }

  void openTerms() {
    final url = AppEnv().h5User;
    if (url.isEmpty) return;

    Get.toNamed(
      Routes.webview,
      arguments: {
        'url': url,
        'title': 'Terms of Service',
      },
    );
  }

  void openPrivacy() {
    final url = AppEnv().h5Privacy;
    if (url.isEmpty) return;

    Get.toNamed(
      Routes.webview,
      arguments: {
        'url': url,
        'title': 'Privacy Policy',
      },
    );
  }

  Future<void> onStartTap() async {
    if (!agreedToTerms.value) {
      final result = await showAgreementDialog?.call();
      if (result != true) {
        return;
      }
      agreedToTerms.value = true;
    }

    try {
      isLoading.value = true;

      if (_config.deviceId == null || _config.deviceId!.isEmpty) {
        final deviceId = await FlutterUdid.udid;
        Interface().deviceId = deviceId;
      }

      final configResult = await _appConfigService.getAppConfig();
      final encryptKey = configResult['encryptKey'];

      final deviceId = _config.deviceId ?? '';
      final loginResult = await _authService.signIn(deviceId);

      final authToken = loginResult['token'] as String?;
      if (authToken != null && authToken.isNotEmpty) {
        await AuthManager.to.login(
          token: authToken,
          encryptKey: encryptKey,
          navigateToHome: false,
        );
      }

      Get.offAllNamed(Routes.nav);

      Get.snackbar(
        'Welcome',
        'Login successful!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10b981),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'Login Failed',
        'Failed to login, please try again',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFef4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool?> Function()? showAgreementDialog;
}
