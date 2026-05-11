import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:paech/interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_udid/flutter_udid.dart';

import '../../../env/app_env.dart';
import '../../../light_handle.dart';
import '../../../interface.dart';
import '../../service/app_config_service.dart';
import '../../service/auth_service.dart';

class LoginLogic extends GetxController {
  final RxBool agreedPrivacy = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Dio 实例
  late final dio.Dio _dio;
  
  // 服务实例
  late final AppConfigService _appConfigService;
  late final AuthService _authService;
  
  // SharedPreferences 实例
  SharedPreferences? _prefs;

  @override
  void onInit() {
    super.onInit();
    _initDio();
    _initPrefs();
  }

  /// 初始化 Dio
  void _initDio() {
    final baseUrl = Aquaria255AppEnv().hostApi;
    if (baseUrl.isEmpty) {
      debugPrint('Warning: API base URL is empty');
    }
    
    _dio = dio.Dio(dio.BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // 添加请求拦截器：自动添加 token，但排除 appconfig 接口
    _dio.interceptors.add(dio.InterceptorsWrapper(
      onRequest: (options, handler) {
        final path = options.uri.path;
        final isAppConfig = path.contains('getAppConfig') || path.contains('appConfig');
        
        // 如果不是 appconfig 接口，且 token 存在，则添加 Authorization header
        if (!isAppConfig) {
          final i = Combing154AwesomeInterface();
          if (i.authToken != null && i.authToken!.isNotEmpty) {
            if (!options.headers.containsKey('Authorization')) {
              options.headers['Authorization'] = 'Bearer${i.authToken}';
            }
          }
        } else {
          // 确保 appconfig 接口不包含 Authorization header
          options.headers.remove('Authorization');
        }
        
        return handler.next(options);
      },
      onError: (error, handler) async {
        // 401 时自动清除登录态并触发 onAuthTokenRemoved（Dio 后续请求不再带 Authorization）
        if (error.response?.statusCode == 401) {
          debugPrint('[LoginLogic] 401 触发 onAuthTokenRemoved');
          await LightHandle.onAuthTokenRemoved();
        }
        return handler.next(error);
      },
    ));
    
    // 初始化服务
    _appConfigService = AppConfigService(_dio);
    _authService = AuthService(_dio);
    
    // 初始化 LightHandle
    LightHandle.init(_authService);
  }

  /// 初始化 SharedPreferences
  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  void togglePrivacy(bool value) {
    agreedPrivacy.value = value;
  }

  /// 点击 Start：未勾选协议时由 view 弹窗，已勾选则执行登录
  void onStartPressed() {
    if (!agreedPrivacy.value) {
      return;
    }
    doLogin();
  }

  /// 执行登录
  Future<void> doLogin() async {
    if (!agreedPrivacy.value) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await Combing154AwesomeInterface().doSignInAction();

    } catch (e) {
      debugPrint('Login error: $e');
      
      String errorMsg = 'Login failed';
      if (e is dio.DioException) {
        if (e.response != null) {
          final responseData = e.response?.data;
          if (responseData is Map<String, dynamic>) {
            final msg = responseData['msg'] as String?;
            final key = responseData['key'] as String?;
            if (msg != null && msg.isNotEmpty) {
              errorMsg = msg;
            } else if (key != null && key.isNotEmpty) {
              errorMsg = key;
            } else {
              errorMsg = 'Server error: ${e.response?.statusCode} - ${e.response?.statusMessage}';
            }
          } else {
            errorMsg = 'Server error: ${e.response?.statusCode} - ${e.response?.statusMessage}';
          }
          debugPrint('Response data: ${e.response?.data}');
        } else if (e.type == dio.DioExceptionType.connectionTimeout) {
          errorMsg = 'Connection timeout. Please check your network.';
        } else if (e.type == dio.DioExceptionType.receiveTimeout) {
          errorMsg = 'Receive timeout. Please try again.';
        } else if (e.response?.statusCode == 404) {
          errorMsg = 'API endpoint not found (404). Please check:\n1. Base URL: ${Aquaria255AppEnv().hostApi}\n2. API path: /security/oauth\n3. Contact backend team to verify the endpoint exists.';
        } else {
          errorMsg = 'Network error: ${e.message}';
        }
      } else {
        // 处理业务逻辑异常（如 _signIn 抛出的异常）
        final errorString = e.toString();
        // 如果异常信息包含 "Login failed:"，提取后面的错误信息
        if (errorString.contains('Login failed:')) {
          errorMsg = errorString.replaceFirst('Exception: Login failed: ', '').trim();
        } else {
          errorMsg = errorString;
        }
      }
      
      errorMessage.value = errorMsg;
    } finally {
      isLoading.value = false;
    }
  }

  /// 获取设备ID
  Future<String> _getDeviceId() async {
    final i = Unshaved408Interface();
    
    // 如果已有设备ID，直接返回
    if (i.deviceId != null && i.deviceId!.isNotEmpty) {
      return i.deviceId!;
    }

    // 从本地读取
    await _initPrefs();
    final cachedDeviceId = _prefs?.getString('device_id');
    if (cachedDeviceId != null && cachedDeviceId.isNotEmpty) {
      i.deviceId = cachedDeviceId;
      return cachedDeviceId;
    }

    String deviceId;
    try {
      deviceId = await FlutterUdid.udid;
      debugPrint('Generated device ID using flutter_udid: $deviceId');
    } catch (e) {
      debugPrint('Error getting UDID: $e, falling back to device info');
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 
                   iosInfo.name ?? 
                   _generateUUID();
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else {
        deviceId = _generateUUID();
      }
    }

    // 保存设备ID
    i.deviceId = deviceId;
    await _prefs?.setString('device_id', deviceId);

    return deviceId;
  }

  String _generateUUID() {
    return '${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().microsecondsSinceEpoch}';
  }

  /// 保存 Token
  Future<void> _saveToken(String token) async {
    await _initPrefs();
    await _prefs?.setString('auth_token', token);
  }

  /// 保存用户信息
  Future<void> _saveUserInfo(Map<String, dynamic> userInfo) async {
    await _initPrefs();
    await _prefs?.setString('user_info', jsonEncode(userInfo));
  }

  /// 保存登录状态
  Future<void> _saveLoginState() async {
    await _initPrefs();
    await _prefs?.setBool('agreed_to_terms', true);
    await _prefs?.setBool('logged_in', true);
  }
}
