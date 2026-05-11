import 'package:get/get.dart';
import 'package:flutter_udid/flutter_udid.dart';

import '../storage/local_storage.dart';
import 'encrypt_service.dart';
import '../../data/repositories/auth_repository.dart';

/// 认证服务
/// 管理用户登录状态、token等认证相关功能
class AuthService extends GetxService {
  static const String _keyAccessToken = 'auth_access_token';
  static const String _keyRefreshToken = 'auth_refresh_token';

  final _isLoggedIn = false.obs;
  bool get isLoggedIn => _isLoggedIn.value;

  String? _token;
  String? get token => _token;

  late LocalStorage _storage;
  late AuthRepository _authRepository;
  late EncryptService _encryptService;

  @override
  void onInit() {
    super.onInit();
    _storage = Get.find<LocalStorage>();
    _authRepository = Get.find<AuthRepository>();
    _encryptService = Get.find<EncryptService>();
  }

  /// 初始化认证状态（需要在app启动时调用）
  Future<void> init() async {
    print('AuthService.init: start load auth state');
    await _loadAuthState();
    print('AuthService.init: done, isLoggedIn=$isLoggedIn, tokenLength=${_token?.length ?? 0}');
  }

  Future<void> _loadAuthState() async {
    // 优先读新的 token key
    String? token = _storage.getString(_keyAccessToken);

    // 兼容老版本：如果新 key 为空，尝试从 LocalStorage 的 user_token 迁移
    if (token == null || token.isEmpty) {
      final legacyToken = _storage.getToken();
      if (legacyToken != null && legacyToken.isNotEmpty) {
        print('AuthService._loadAuthState: migrate legacy user_token to $_keyAccessToken');
        token = legacyToken;
        await _storage.setString(_keyAccessToken, legacyToken);
      }
    }

    _token = token;
    _isLoggedIn.value = _token != null && _token!.isNotEmpty;
    print('AuthService._loadAuthState: loaded tokenExists=${_token != null}, isLoggedIn=$_isLoggedIn, length=${_token?.length ?? 0}');
  }

  /// 点击进入：先 getAppConfig 取加密 key，再拿 udid 调 /security/oauth（oauthType+udid），并走加密
  Future<bool> loginWithDevice() async {
    try {
      final configOk = await _encryptService.getAppConfig();
      if (!configOk) {
        print('AuthService.loginWithDevice: getAppConfig failed');
        return false;
      }
      final udid = await FlutterUdid.udid;
      print('AuthService.loginWithDevice: udid=$udid');
      
      final res = await _authRepository.login(
        oauthType: '4',
        udid: udid,
      );
      
      print('AuthService.loginWithDevice: response=$res');
      
      // 检查登录是否成功
      if (res.accessToken.isEmpty) {
        print('AuthService.loginWithDevice: login failed - empty token');
        return false;
      }
      
      _token = res.accessToken;
      _isLoggedIn.value = true;
      await _storage.setString(_keyAccessToken, res.accessToken);
      await _storage.setString(_keyRefreshToken, res.refreshToken);
      print('AuthService.loginWithDevice: login ok, tokenLength=${_token?.length ?? 0}');
      return true;
    } catch (e) {
      print('AuthService.loginWithDevice: login failed with exception: $e');
      return false;
    }
  }

  /// 登出：调接口并清除本地 token
  Future<void> logout() async {
    try {
      // 确保有 encryptKey（登出接口需要加密）
      if (_encryptService.needRefreshConfig()) {
        print('AuthService.logout: encryptKey 不存在，先调用 getAppConfig...');
        final configOk = await _encryptService.getAppConfig();
        print('AuthService.logout: getAppConfig 结果: $configOk');
        if (!configOk) {
          print('AuthService.logout: getAppConfig 失败，但继续尝试登出');
        }
      } else {
        print('AuthService.logout: encryptKey 已存在');
      }
      
      // 调用登出接口
      await _authRepository.logout();
      print('AuthService.logout: 登出接口调用成功');
    } catch (e) {
      print('AuthService.logout: 登出接口调用失败: $e');
    }
    
    // 无论接口是否成功，都清除本地状态
    clearAuthState();
  }

  /// 清除登录状态（如注销后），不调登出接口
  void clearAuthState() {
    _token = null;
    _isLoggedIn.value = false;
    _storage.remove(_keyAccessToken);
    _storage.remove(_keyRefreshToken);
    print('AuthService.clearAuthState: 认证状态已清除');
  }

  /// 刷新token
  Future<bool> refreshToken() async {
    try {
      final refresh = _storage.getString(_keyRefreshToken);
      if (refresh == null || refresh.isEmpty) return false;
      final res = await _authRepository.refreshToken(refreshToken: refresh);
      _token = res.accessToken;
      await _storage.setString(_keyAccessToken, res.accessToken);
      await _storage.setString(_keyRefreshToken, res.refreshToken);
      return true;
    } catch (e) {
      return false;
    }
  }
}