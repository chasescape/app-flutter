import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../interface.dart';
import '../routes/app_pages.dart';

/// 认证管理服务
/// 
/// 负责管理用户登录态、token 存储和路由跳转
class AuthManager extends GetxService {
  static AuthManager get to => Get.find();

  // SharedPreferences keys
  static const String _keyAuthToken = 'auth_token';
  static const String _keyEncryptKey = 'encrypt_key';
  static const String _keyDeviceId = 'device_id';

  // 响应式状态
  final isLoggedIn = false.obs;
  final isInitialized = false.obs;

  // 私有变量
  String? _authToken;
  String? _encryptKey;
  String? _deviceId;

  // Getters
  String? get authToken => _authToken;
  String? get encryptKey => _encryptKey;
  String? get deviceId => _deviceId;

  /// 初始化服务
  static Future<AuthManager> init() async {
    final service = Get.put(AuthManager());
    await service._initialize();
    return service;
  }

  /// 内部初始化逻辑
  Future<void> _initialize() async {
    try {
      _debugLog('🔐 AuthManager 初始化开始...');

      // 1. 从本地存储加载数据
      await _loadFromStorage();

      // 2. 同步到 Interface（兼容现有代码）
      _syncToInterface();

      // 3. 标记为已初始化
      isInitialized.value = true;

      _debugLog('✅ AuthManager 初始化完成');
      _debugLog('   - isLoggedIn: ${isLoggedIn.value}');
      _debugLog('   - hasToken: ${_authToken != null}');
      _debugLog('   - hasEncryptKey: ${_encryptKey != null}');
    } catch (e) {
      _debugLog('❌ AuthManager 初始化失败: $e');
      isInitialized.value = true;
    }
  }

  /// 从本地存储加载数据
  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();

    _authToken = prefs.getString(_keyAuthToken);
    _encryptKey = prefs.getString(_keyEncryptKey);
    _deviceId = prefs.getString(_keyDeviceId);

    // 更新登录状态
    isLoggedIn.value = _authToken != null && _authToken!.isNotEmpty;

    _debugLog('📦 从本地加载数据:');
    _debugLog('   - authToken: ${_authToken != null ? "已加载" : "未找到"}');
    _debugLog('   - encryptKey: ${_encryptKey != null ? "已加载" : "未找到"}');
    _debugLog('   - deviceId: ${_deviceId ?? "未找到"}');
  }

  /// 同步到 Interface（兼容现有代码）
  void _syncToInterface() {
    final interface = Interface();
    interface.authToken = _authToken;
    interface.encryptKey = _encryptKey;
    interface.deviceId = _deviceId;

    _debugLog('🔄 已同步到 Interface');
  }

  /// 登录
  Future<void> login({
    required String token,
    String? encryptKey,
    bool navigateToHome = true,
  }) async {
    try {
      _debugLog('🔐 开始登录...');

      // 1. 保存到内存
      _authToken = token;
      if (encryptKey != null) {
        _encryptKey = encryptKey;
      }

      // 2. 保存到本地存储
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAuthToken, token);
      if (encryptKey != null) {
        await prefs.setString(_keyEncryptKey, encryptKey);
      }

      // 3. 更新登录状态
      isLoggedIn.value = true;

      // 4. 同步到 Interface
      _syncToInterface();

      _debugLog('✅ 登录成功');

      // 5. 跳转到首页
      if (navigateToHome) {
        Get.offAllNamed(Routes.nav);
        _debugLog('🏠 已跳转到首页');
      }
    } catch (e) {
      _debugLog('❌ 登录失败: $e');
      rethrow;
    }
  }

  /// 登出
  Future<void> logout({bool navigateToLogin = true}) async {
    try {
      _debugLog('🚪 开始登出...');

      // 1. 清除内存数据
      _authToken = null;

      // 2. 清除本地存储
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyAuthToken);

      // 3. 更新登录状态
      isLoggedIn.value = false;

      // 4. 同步到 Interface
      _syncToInterface();

      // 5. 调用 Interface 的登出逻辑（兼容现有代码）
      await Interface().onAuthTokenRemoved();

      _debugLog('✅ 登出成功');

      // 6. 跳转到登录页
      if (navigateToLogin) {
        Get.offAllNamed(Routes.login);
        _debugLog('🔑 已跳转到登录页');
      }
    } catch (e) {
      _debugLog('❌ 登出失败: $e');
      rethrow;
    }
  }

  /// 删除账号（清除所有数据）
  Future<void> deleteAccount({bool navigateToLogin = true}) async {
    try {
      _debugLog('🗑️  开始删除账号...');

      // 1. 清除所有内存数据
      _authToken = null;
      _encryptKey = null;
      _deviceId = null;

      // 2. 清除所有本地存储
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyAuthToken);
      await prefs.remove(_keyEncryptKey);
      await prefs.remove(_keyDeviceId);

      // 3. 更新登录状态
      isLoggedIn.value = false;

      // 4. 同步到 Interface
      _syncToInterface();

      _debugLog('✅ 账号已删除');

      // 5. 跳转到登录页
      if (navigateToLogin) {
        Get.offAllNamed(Routes.login);
        _debugLog('🔑 已跳转到登录页');
      }
    } catch (e) {
      _debugLog('❌ 删除账号失败: $e');
      rethrow;
    }
  }

  /// 更新 encryptKey
  Future<void> updateEncryptKey(String encryptKey) async {
    try {
      _encryptKey = encryptKey;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyEncryptKey, encryptKey);

      _syncToInterface();

      _debugLog('✅ encryptKey 已更新');
    } catch (e) {
      _debugLog('❌ 更新 encryptKey 失败: $e');
      rethrow;
    }
  }

  /// 更新 deviceId
  Future<void> updateDeviceId(String deviceId) async {
    try {
      _deviceId = deviceId;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyDeviceId, deviceId);

      _syncToInterface();

      _debugLog('✅ deviceId 已更新');
    } catch (e) {
      _debugLog('❌ 更新 deviceId 失败: $e');
      rethrow;
    }
  }

  /// 获取初始路由
  String getInitialRoute() {
    if (isLoggedIn.value) {
      _debugLog('🏠 用户已登录，跳转到首页');
      return Routes.nav;
    } else {
      _debugLog('🔑 用户未登录，跳转到登录页');
      return Routes.login;
    }
  }

  /// 条件日志（只在 Debug 模式打印）
  void _debugLog(String message) {
    if (kDebugMode) {
      print('[AuthManager] $message');
    }
  }

  @override
  void onClose() {
    _debugLog('🔐 AuthManager 关闭');
    super.onClose();
  }
}
