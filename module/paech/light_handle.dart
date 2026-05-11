import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../interface.dart';
import 'app/service/auth_service.dart';
import 'interface.dart';

/// 轻量级处理器 - 负责退出登录等核心逻辑
class LightHandle {
  static AuthService? _authService;

  /// 初始化（在 LoginLogic 中设置 AuthService 实例）
  static void init(AuthService authService) {
    _authService = authService;
  }

  /// 准备初始化（在 Unshaved408Interface.prevInitialize 中调用）
  /// - 初始化持久化存储，并从本地恢复 token/encryptKey/deviceId 到 Unshaved408Interface，供冷启动时判断是否已登录
  static Future<void> readyToInit() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final i = Unshaved408Interface();
      // 从本地恢复登录态到内存，避免杀进程后重新打开仍进登录页
      final cachedToken = prefs.getString('auth_token');
      final cachedEncryptKey = prefs.getString('encrypt_key');
      final cachedDeviceId = prefs.getString('device_id');
      if (cachedToken != null && cachedToken.isNotEmpty) {
        // i.authToken = cachedToken;
      }
      if (cachedEncryptKey != null && cachedEncryptKey.isNotEmpty) {
        i.encryptKey = cachedEncryptKey;
      }
      if (cachedDeviceId != null && cachedDeviceId.isNotEmpty) {
        i.deviceId = cachedDeviceId;
      }
      debugPrint('[LightHandle] Ready to init completed');
    } catch (e) {
      debugPrint('[LightHandle] Ready to init error: $e');
    }
  }

  /// 登录操作（在 Unshaved408Interface.doSignInAction 中调用）
  /// - 这是一个占位方法，实际登录逻辑在 LoginLogic 中
  static Future<void> login() async {
    // 实际登录逻辑在 LoginLogic.doLogin() 中
    // 这里只是一个接口占位，供 Unshaved408Interface 调用
    debugPrint('[LightHandle] Login action called (placeholder)');
  }

  /// 退出登录
  /// 1. 调用 API /security/logout
  /// 2. 延迟 300ms
  /// 3. 清除本地数据
  static Future<void> logout() async {
    try {
      // 1. 调用退出登录 API
      if (_authService != null) {
         _authService!.logout();
      }

      // // 2. 延迟 300ms（给服务端处理时间）
      await Future.delayed(const Duration(milliseconds: 300));

      // 3. 清除本地数据
      await onAuthTokenRemoved();
    } catch (e) {
      debugPrint('Logout error: $e');
      // 即使出错也要清除本地数据
      await onAuthTokenRemoved();
    }
  }


  static Future<bool> deleteAccount() async {
    bool result = false;
    try {

      // 1. 调用刷新 token API
      if (_authService != null) {
        result = await _authService!.deleteAccount();
      }
      // 3. 保存 token 到 SharedPreferences
      final i = Unshaved408Interface();
      final prefs = await SharedPreferences.getInstance();

    } catch (e) {
      debugPrint('Delete account error: $e');
    }

    return result;
  }

  /// 清除认证 token 和相关数据
  /// - 清除内存中的 token 和 encryptKey
  /// - 清除 SharedPreferences 中的数据
  /// - 调用 Unshaved408Interface 的清理方法
  static Future<void> onAuthTokenRemoved() async {
    try {
      // 1. 清除 Unshaved408Interface 中的数据
      final i = Unshaved408Interface();
      i.authToken = null;
      i.encryptKey = null;
      i.deviceId = null;

      // 2. 清除 SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('encrypt_key');
      await prefs.remove('device_id');
      await prefs.remove('user_info');
      await prefs.remove('agreed_to_terms');
      await prefs.remove('logged_in');

      debugPrint('[LightHandle] Auth token and user data cleared');

      Combing154AwesomeInterface().onAuthTokenRemoved();
    } catch (e) {
      debugPrint('[LightHandle] Error clearing auth data: $e');
    }
  }

  /// 跳转到登录页
  /// - 清空路由堆栈
  /// - 导航到登录页
  static void toLogin() {
    Get.offAllNamed('/login');
  }

  /// 清除所有数据（用于删除账号）
  /// - 清除所有 SharedPreferences 数据
  /// - 清除 Unshaved408Interface 中的数据
  static Future<void> clearAllData() async {
    try {
      // 1. 清除 Unshaved408Interface 中的数据
      final i = Unshaved408Interface();
      i.authToken = null;
      i.encryptKey = null;
      i.deviceId = null;

      // 2. 清除所有 SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      debugPrint('[LightHandle] All data cleared');
    } catch (e) {
      debugPrint('[LightHandle] Error clearing all data: $e');
    }
  }
}
