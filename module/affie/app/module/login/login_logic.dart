import 'package:affie/affie/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../theme/app_colors.dart';
import '../../core/auth_service.dart';
import '../../core/app_config_service.dart';
import '../../core/service_config.dart';
import '../../../interface.dart';
import '../../../env/app_env.dart';
import '../../widgets/loading_overlay.dart';

class LoginLogic extends GetxController {
  final isAgreed = false.obs;
  final isLoading = false.obs;
  static const _authTokenKey = 'auth_token_v1';
  static const _deviceIdKey = 'device_uuid_v1';
  static final _uuid = Uuid();

  late final AuthService _authService;
  late final AppConfigService _appConfigService;
  late final Dio _dio;

  @override
  void onInit() {
    super.onInit();
    // 初始化 Dio 和服务
    _dio = Dio(BaseOptions(
      baseUrl: AppEnv().hostApi,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
    final serviceConfig = _ServiceConfigImpl();
    _appConfigService = AppConfigService(_dio, serviceConfig);
    _authService = AuthService(_dio, serviceConfig);
  }

  void toggleAgree() {
    isAgreed.value = !isAgreed.value;
  }

  Future<void> login() async {
    if (!isAgreed.value) {
      // 显示未勾选协议的弹窗
      _showAgreementDialog();
      return;
    }

    // 已勾选协议，执行登录
    await _performLogin();
  }

  void _showAgreementDialog() {
    _showStyledActionDialog(
      title: 'Agreement Required',
      message:
          'Please agree to the Terms & Conditions and Privacy Policy before continuing.',
      icon: Icons.verified_user_outlined,
      confirmText: 'Agree',
      onConfirm: () {
        // 用户点击同意，自动勾选并登录
        isAgreed.value = true;
        _performLogin();
      },
      barrierDismissible: false,
    );
  }

  Future<void> _performLogin() async {
    try {
      isLoading.value = true;
      LoadingOverlay.show(message: 'Signing you in...');

      // 1. 先获取 encryptKey
      print('📱 Step 1: Getting encryptKey from AppConfig...');
      final configResult = await _appConfigService.getAppConfig();
      final encryptKey = configResult['encryptKey'];
      final preAuthToken = configResult['authToken'];

      if (encryptKey == null || encryptKey.isEmpty) {
        throw Exception('Failed to get encryptKey');
      }

      print('✅ Got encryptKey: ${encryptKey.substring(0, 10)}...');

      // 保存 encryptKey 到 Interface
      Interface().encryptKey = encryptKey;
      // AppConfig 仅用于获取 encryptKey，登录不依赖其 authToken
      Interface().authToken = null;

      // 2. 获取设备ID
      print('📱 Step 2: Getting device ID...');
      final prefs = await SharedPreferences.getInstance();
      var deviceToken = Interface().deviceId;
      if (deviceToken == null || deviceToken.isEmpty) {
        deviceToken = prefs.getString(_deviceIdKey);
      }
      if (!_isUuid(deviceToken)) {
        deviceToken = _uuid.v4();
        await prefs.setString(_deviceIdKey, deviceToken);
      }
      Interface().deviceId = deviceToken;
      print('✅ Got device ID: $deviceToken');

      // 3. 调用 auth_service 的 signIn 接口
      print('📱 Step 3: Calling signIn API...');
      final result = await _authService.signIn(deviceToken!);

      // 4. 保存 token 到 Interface
      final token = (result['token'] ??
          result['authToken'] ??
          result['access_token'] ??
          result['accessToken']) as String?;
      final altAuthToken =
          (result['authToken'] ?? result['accessToken']) as String?;
      final resolvedToken = (token != null &&
              token.isNotEmpty &&
              token == deviceToken &&
              altAuthToken != null &&
              altAuthToken.isNotEmpty &&
              altAuthToken != deviceToken)
          ? altAuthToken
          : token;
      if (resolvedToken != null && resolvedToken.isNotEmpty) {
        Interface().authToken = resolvedToken;
        await prefs.setString(_authTokenKey, resolvedToken);
        if (resolvedToken == deviceToken) {
          print(
              '⚠️ Login token equals deviceId; check backend response fields.');
        }
        print(
            '✅ Login successful! Token: ${resolvedToken.substring(0, 20)}...');

        // 登录成功，跳转到主页面
        Get.offAllNamed(AppRoutes.nav);
      } else {
        throw Exception('Login failed: token is empty');
      }
    } catch (e) {
      print('❌ Login error: $e');
      // 登录失败，显示错误提示
      _showErrorDialog('Login failed: ${e.toString()}');
    } finally {
      isLoading.value = false;
      LoadingOverlay.hide();
    }
  }

  void _showErrorDialog(String message) {
    _showStyledActionDialog(
      title: 'Login Failed',
      message: message,
      icon: Icons.warning_amber_rounded,
      confirmText: 'OK',
      showCancel: false,
      onConfirm: () {},
    );
  }

  void _showStyledActionDialog({
    required String title,
    required String message,
    required IconData icon,
    required String confirmText,
    required VoidCallback onConfirm,
    bool barrierDismissible = true,
    bool showCancel = true,
  }) {
    final context = Get.context;
    final isDark =
        context != null && Theme.of(context).brightness == Brightness.dark;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: (isDark ? Colors.white : AppColors.primaryDark)
                  .withValues(alpha: 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient:
                      const LinearGradient(colors: AppColors.gradientSunset),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  if (showCancel)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary)
                                .withValues(alpha: 0.35),
                          ),
                          minimumSize: const Size(0, 44),
                        ),
                        child: Text(
                          'Cancel',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (showCancel) const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(0, 44),
                      ),
                      child: Text(
                        confirmText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  @override
  void onClose() {
    _dio.close();
    super.onClose();
  }

  bool _isUuid(String? value) {
    if (value == null || value.isEmpty) return false;
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidRegex.hasMatch(value);
  }
}

// ServiceConfig 实现类
class _ServiceConfigImpl extends ServiceConfig {
  @override
  String? get encryptKey => Interface().encryptKey;

  @override
  set encryptKey(String? value) => Interface().encryptKey = value;

  @override
  String? get authToken => Interface().authToken;

  @override
  set authToken(String? value) => Interface().authToken = value;

  @override
  String? get deviceId => Interface().deviceId;

  @override
  String get hostApi => AppEnv().hostApi;
}
