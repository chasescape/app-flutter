import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yapo/yapo/app/routes/app_pages.dart';
import 'package:yapo/yapo/app/services/generated_photo_service.dart';
import 'package:yapo/yapo/core/adapters/yapo_service_adapter.dart';
import 'package:yapo/yapo/core/network/auth_service.dart';
import 'package:yapo/yapo/env/app_env.dart';

class ProfileLogic extends GetxController {
  final userCoins = 100.obs;
  final userName = 'Travel Explorer'.obs;
  final userEmail = 'traveler@example.com'.obs;
  final isLoggingOut = false.obs;
  final isDeletingAccount = false.obs;

  late final AuthService _authService;
  late final YapoServiceAdapter _config;

  @override
  void onInit() {
    super.onInit();
    _initServices();
  }

  /// 初始化服务
  void _initServices() {
    _config = YapoServiceAdapter();
    final dio = Dio(BaseOptions(
      baseUrl: AppEnv().hostApi,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
    
    _authService = AuthService(dio, _config);
  }

  /// 打开隐私政策
  void openPrivacyPolicy() {
    final env = AppEnv();
    final privacyUrl = env.h5Privacy;
    
    if (privacyUrl.isEmpty) {
      Get.snackbar(
        'Error',
        'Privacy policy URL not configured',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFef4444),
        colorText: Colors.white,
      );
      return;
    }
    
    Get.toNamed(
      Routes.webview,
      arguments: {
        'url': privacyUrl,
        'title': 'Privacy Policy',
        'textZoom': 200, // 字体缩放 200%
      },
    );
  }

  /// 打开用户协议
  void openTermsOfService() {
    final env = AppEnv();
    final userUrl = env.h5User;
    
    if (userUrl.isEmpty) {
      Get.snackbar(
        'Error',
        'Terms of service URL not configured',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFef4444),
        colorText: Colors.white,
      );
      return;
    }
    
    Get.toNamed(
      Routes.webview,
      arguments: {
        'url': userUrl,
        'title': 'Terms of Service',
        'textZoom': 200, // 字体缩放 200%
      },
    );
  }

  /// 注销账户
  Future<void> deleteAccount() async {
    // 显示确认对话框
    final confirmed = await _showDeleteAccountConfirmDialog();
    if (confirmed != true) {
      return;
    }

    try {
      isDeletingAccount.value = true;

      // 调用注销账户接口
      await _authService.deleteAccount();
      
      // 清除本地数据（账户、AI 照片、金币等）
      await _clearLocalDataAfterAccountDeletion();

      // 清除鉴权配置
      _config.authToken = null;
      _config.encryptKey = null;
      await _config.saveString('auth_token', '');
      await _config.saveString('encrypt_key', '');
      
      // 返回登录页
      Get.offAllNamed(Routes.login);
      
      Get.snackbar(
        'Account Deleted',
        'Your account has been permanently deleted',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFef4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );
    } catch (e, stackTrace) {
      Get.snackbar(
        'Error',
        'Failed to delete account. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFef4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isDeletingAccount.value = false;
    }
  }

  /// 登出
  Future<void> logout() async {
    // 显示确认对话框
    final confirmed = await _showLogoutConfirmDialog();
    if (confirmed != true) {
      return;
    }

    try {
      isLoggingOut.value = true;

      // 调用登出接口
      await _authService.logout();
      
      // 清除本地数据
      _config.authToken = null;
      _config.encryptKey = null;
      await _config.saveString('auth_token', '');
      await _config.saveString('encrypt_key', '');
      
      // 返回登录页
      Get.offAllNamed(Routes.login);
      
      Get.snackbar(
        'Logged Out',
        'You have been logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10b981),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      );
    } catch (e, stackTrace) {
      // 即使失败，也清除本地数据并返回登录页
      _config.authToken = null;
      _config.encryptKey = null;
      await _config.saveString('auth_token', '');
      await _config.saveString('encrypt_key', '');
      
      Get.offAllNamed(Routes.login);
    } finally {
      isLoggingOut.value = false;
    }
  }

  /// 显示登出确认对话框
  Future<bool?> _showLogoutConfirmDialog() {
    return Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1a0b2e),
                Color(0xFF2d1b4e),
              ],
            ),
            border: Border.all(
              color: const Color(0xFFfbbf24).withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFfbbf24).withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 图标
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFfbbf24), Color(0xFFf97316)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFfbbf24).withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              
              // 标题
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFfde68a), Color(0xFFfbbf24)],
                ).createShader(bounds),
                child: const Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 内容
              Text(
                'Are you sure you want to log out?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: const Color(0xFFd8b4fe).withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              
              // 按钮
              Row(
                children: [
                  // 取消按钮
                  Expanded(
                    child: InkWell(
                      onTap: () => Get.back(result: false),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: const Color(0xFFec4899).withValues(alpha: 0.15),
                          border: Border.all(
                            color: const Color(0xFFec4899).withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFd8b4fe).withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // 确认按钮
                  Expanded(
                    child: InkWell(
                      onTap: () => Get.back(result: true),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFfbbf24), Color(0xFFf97316)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFfbbf24).withValues(alpha: 0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Log Out',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  /// 显示注销账户确认对话框
  Future<bool?> _showDeleteAccountConfirmDialog() {
    return Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1a0b2e),
                Color(0xFF2d1b4e),
              ],
            ),
            border: Border.all(
              color: const Color(0xFFef4444).withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFef4444).withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 图标
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFef4444), Color(0xFFdc2626)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFef4444).withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              
              // 标题
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFfca5a5), Color(0xFFef4444)],
                ).createShader(bounds),
                child: const Text(
                  'Delete Account?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 内容
              Text(
                'This action cannot be undone. All your data will be permanently deleted.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: const Color(0xFFd8b4fe).withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              
              // 按钮
              Row(
                children: [
                  // 取消按钮
                  Expanded(
                    child: InkWell(
                      onTap: () => Get.back(result: false),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: const Color(0xFFec4899).withValues(alpha: 0.15),
                          border: Border.all(
                            color: const Color(0xFFec4899).withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFd8b4fe).withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // 确认按钮
                  Expanded(
                    child: InkWell(
                      onTap: () => Get.back(result: true),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFef4444), Color(0xFFdc2626)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFef4444).withValues(alpha: 0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Delete',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  /// 注销账户后清理本地业务数据（AI 图片、金币等）
  Future<void> _clearLocalDataAfterAccountDeletion() async {
    // 清空本地生成的 AI 照片及卡片列表
    if (Get.isRegistered<GeneratedPhotoService>()) {
      try {
        final photoService = Get.find<GeneratedPhotoService>();
        await photoService.clearAll();
      } catch (e) {
        // 静默失败，避免影响注销流程
      }
    }

    // 重置本地金币存储
    try {
      const String keyUserCoins = 'user_coins';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(keyUserCoins, 0);
      userCoins.value = 0;
    } catch (e) {
      // 静默失败
    }
  }
}
