import 'package:get/get.dart';
import 'package:dio/dio.dart';

import 'package:enkou/enkou/app/core/app_config_service.dart';
import 'package:enkou/enkou/app/core/auth_service.dart';
import 'package:enkou/enkou/app/core/enkou_service_adapter.dart';
import 'package:enkou/enkou/app/widget/app_toast.dart';
import 'package:enkou/enkou/app/widget/loading_overlay.dart';
import 'package:enkou/enkou/env/app_env.dart';
import 'package:enkou/enkou/interface.dart';

class LoginLogic extends GetxController {
  final RxBool agreed = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorText = ''.obs;

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

  void toggleAgreed() {
    agreed.value = !agreed.value;
  }

  Future<bool> signIn() async {
    if (isSubmitting.value) return false;
    if (!_ensureHostReady()) return false;

    isSubmitting.value = true;
    errorText.value = '';
    LoadingOverlay.show();
    try {
      final deviceId = await _config.ensureDeviceId();
      Interface().deviceId = deviceId;

      // 登录前显式调用一次 AppConfig，确保 encryptKey 与服务端保持最新
      await _appConfigService.getAppConfig();
      await _ensureEncryptKey();

      final result = await _authService.signIn(deviceId);
      final token = (result['token'] ?? result['authToken'])?.toString();
      if (token != null && token.isNotEmpty) {
        _config.authToken = token;
        Interface().authToken = token;
      }

      return true;
    } catch (e) {
      errorText.value = e.toString();
      AppToast.short('Login failed', isError: true);
      return false;
    } finally {
      LoadingOverlay.hide();
      isSubmitting.value = false;
    }
  }

  bool _ensureHostReady() {
    if (AppEnv().hostApi.isEmpty) {
      AppToast.short('API host is not configured', isError: true);
      return false;
    }
    return true;
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
}
