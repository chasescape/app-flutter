import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../env/app_env.dart';
import '../../../interface.dart';
import '../../core/auth_service.dart';
import '../../core/service_config.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/loading_overlay.dart';

class ProfileLogic extends GetxController {
  final isPushNotification = true.obs;
  bool get isDarkMode => Get.isDarkMode;
  final isSubmitting = false.obs;
  static const _authTokenKey = 'auth_token_v1';
  static const _coinBalanceKey = 'coin_balance_v1';
  static const _historyItemsKey = 'history_items_v1';

  late final Dio _dio;
  late final AuthService _authService;

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(BaseOptions(
      baseUrl: AppEnv().hostApi,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
    _authService = AuthService(_dio, _ServiceConfigImpl());
  }

  void toggleDarkMode(bool value) {
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    // 强制更新UI以反映主题变化
    update();
  }

  void togglePushNotification(bool value) {
    isPushNotification.value = value;
    // Add actual push notification logic here
  }

  void logout() {
    _showStyledConfirmDialog(
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      icon: Icons.logout_rounded,
      confirmText: 'Logout',
      onConfirm: _performLogout,
    );
  }

  void deleteAccount() {
    _showStyledConfirmDialog(
      title: 'Delete Account',
      message:
          'Are you sure you want to delete your account? This action cannot be undone.',
      icon: Icons.delete_forever_rounded,
      confirmText: 'Delete',
      isDanger: true,
      barrierDismissible: false,
      onConfirm: _performDeleteAccount,
    );
  }

  void _showStyledConfirmDialog({
    required String title,
    required String message,
    required IconData icon,
    required String confirmText,
    required Future<void> Function() onConfirm,
    bool barrierDismissible = true,
    bool isDanger = false,
  }) {
    final isDark = Get.isDarkMode;
    final confirmColor = isDanger ? AppColors.error : AppColors.primaryDark;

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
                  gradient: isDanger
                      ? const LinearGradient(
                          colors: [Color(0xFFFF8A80), Color(0xFFE57373)],
                        )
                      : const LinearGradient(colors: AppColors.gradientSunset),
                  boxShadow: [
                    BoxShadow(
                      color: (isDanger ? AppColors.error : AppColors.primary)
                          .withValues(alpha: 0.35),
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        await onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: confirmColor,
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

  Future<void> _performLogout() async {
    if (isSubmitting.value) return;
    isSubmitting.value = true;
    LoadingOverlay.show(message: 'Logging out...');
    try {
      await _authService.logout();
    } catch (_) {
      // 登出失败不阻塞本地退出，保证用户可回到登录页
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_authTokenKey);
      Interface().authToken = null;
      await Interface().onAuthTokenRemoved();
      LoadingOverlay.hide();
      isSubmitting.value = false;
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<void> _performDeleteAccount() async {
    if (isSubmitting.value) return;
    isSubmitting.value = true;
    LoadingOverlay.show(message: 'Deleting account...');
    try {
      final ok = await _authService.deleteAccount();
      if (!ok) {
        throw Exception('Delete account failed');
      }
      await _clearLocalAccountData();
      await Interface().onAuthTokenRemoved();
      LoadingOverlay.hide();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      LoadingOverlay.hide();
      Get.snackbar(
        'Delete failed',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.isDarkMode ? const Color(0xFF2A2D35) : Colors.black87,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _clearLocalAccountData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await prefs.remove(_coinBalanceKey);
    await prefs.remove(_historyItemsKey);
    Interface().authToken = null;
    Interface().encryptKey = null;
  }

  @override
  void onClose() {
    _dio.close();
    super.onClose();
  }
}

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
