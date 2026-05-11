import 'dart:io';

import 'package:curl_logger_dio_interceptor/curl_logger_dio_interceptor.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart' as dio;
import 'package:package_info_plus/package_info_plus.dart';

import '../core/crypto_helper.dart';
import '../core/service_config.dart';

/// 登录服务（可复用版本）
///
/// 处理 /security/oauth、/security/logout、/user/deleteAccount 接口，
/// 使用 encryptKey 做请求加密、响应解密。
class AuthService {
  final dio.Dio _dio;
  final ServiceConfig _config;
  final CryptoHelper _crypto = CryptoHelper();

  AuthService(this._dio, this._config) {
    if (!_dio.interceptors.any((i) => i is CurlLoggerDioInterceptor)) {
      _dio.interceptors.add(CurlLoggerDioInterceptor(printOnSuccess: true));
    }
  }

  /// 登录接口
  ///
  /// [deviceToken] 设备 ID
  /// 必须先拿到 encryptKey（先调 getAppConfig），再调本接口
  Future<Map<String, dynamic>> signIn(String deviceToken) async {
    if (_config.encryptKey == null || _config.encryptKey!.isEmpty) {
      throw Exception('encryptKey 为空，请先调用 getAppConfig 获取加密密钥再登录');
    }

    // 1. 构建请求体
    final headers = await _buildHeaders();
    final body = <String, dynamic>{
      'http_headers': headers,
      'oauthType': 4,
      'token': deviceToken,
    };

    // 2. 请求加密
    final encryptedBody = _crypto.encryptJson(body, _config.encryptKey!);

    // 3. 发送 POST
    final response = await _dio.post(
      '/security/oauth',
      data: encryptedBody,
      options: dio.Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        responseType: dio.ResponseType.plain,
      ),
    );

    // 4. 响应解密
    if (response.data is! String) {
      throw Exception('Unexpected response type: ${response.data.runtimeType}');
    }
    final responseStr = response.data as String;
    final decrypted = _crypto.decryptToJson(responseStr, _config.encryptKey!);

    // 5. 业务码与数据提取
    final code = decrypted['code'];
    final success = decrypted['success'] as bool?;
    final fail = decrypted['fail'] as bool?;
    final msg = decrypted['msg'] as String?;
    final key = decrypted['key'] as String?;

    if ((code != null && code != 0) || success == false || fail == true) {
      final errorMsg = msg ?? key ?? 'Login failed';
      throw Exception('Login failed: $errorMsg (code: $code)');
    }

    // 兼容两种返回：token 在顶层 或 在 data 里
    final data = decrypted['data'];
    if (data is Map<String, dynamic>) {
      return <String, dynamic>{...decrypted, ...data};
    }
    return decrypted;
  }

  /// 退出登录接口
  Future<bool> logout() async {
    try {
      // 构建请求头
      final headers = await _buildHeaders();
      
      // 构建请求体
      final body = <String, dynamic>{
        'http_headers': headers,
      };
      
      // 加密请求体
      if (_config.encryptKey == null || _config.encryptKey!.isEmpty) {
        throw Exception('encryptKey 为空，无法加密请求');
      }
      
      final encryptedBody = _crypto.encryptJson(body, _config.encryptKey!);
      
      final response = await _dio.post(
        '/security/logout',
        data: encryptedBody,
        options: dio.Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          responseType: dio.ResponseType.plain,
        ),
      );

      if (response.statusCode == 200) {
        // 解密响应
        if (response.data is String) {
          final responseStr = response.data as String;
          final decrypted = _crypto.decryptToJson(responseStr, _config.encryptKey!);
          
          final code = decrypted['code'];
          final success = decrypted['success'] as bool?;
          
          return code == 0 || success == true;
        } else {
          final data = response.data;
          if (data is Map<String, dynamic>) {
            final code = data['code'];
            final success = data['success'] as bool?;
            return code == 0 || success == true;
          }
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print('Logout API error: $e');
      return true; // 即使 API 调用失败，也返回 true
    }
  }

  /// 注销账户接口
  Future<bool> deleteAccount() async {
    try {
      print('\n========== 🔍 注销账户 - 调试信息 ==========');
      
      // 构建请求头
      final headers = await _buildHeaders();
      print('📋 构建的 headers:');
      headers.forEach((key, value) {
        if (key == 'Authorization') {
          print('   $key: ${value.substring(0, value.length > 30 ? 30 : value.length)}...');
        } else {
          print('   $key: $value');
        }
      });
      
      // 构建请求体
      final body = <String, dynamic>{
        'http_headers': headers,
      };
      
      print('\n📦 请求体（加密前）:');
      print('   http_headers 包含 ${headers.length} 个字段');
      print('   Authorization 存在: ${headers.containsKey('Authorization')}');
      
      // 加密请求体
      if (_config.encryptKey == null || _config.encryptKey!.isEmpty) {
        throw Exception('encryptKey 为空，无法加密请求');
      }
      
      print('\n🔐 使用 encryptKey 加密请求体');
      print('   encryptKey: ${_config.encryptKey!.substring(0, 10)}...');
      
      final encryptedBody = _crypto.encryptJson(body, _config.encryptKey!);
      
      print('✅ 加密完成，发送请求...');
      print('========================================\n');
      
      final response = await _dio.post(
        '/user/deleteAccount',
        data: encryptedBody,
        options: dio.Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          responseType: dio.ResponseType.plain,
        ),
      );

      if (response.statusCode == 200) {
        // 解密响应
        if (response.data is String) {
          final responseStr = response.data as String;
          final decrypted = _crypto.decryptToJson(responseStr, _config.encryptKey!);
          
          print('📥 解密后的响应: $decrypted');
          
          final code = decrypted['code'];
          final success = decrypted['success'] as bool?;
          
          if (code == 0 || success == true) {
            return true;
          } else {
            final msg = decrypted['msg'] as String? ?? 'Delete account failed';
            throw Exception(msg);
          }
        } else {
          final data = response.data;
          if (data is Map<String, dynamic>) {
            final code = data['code'];
            final success = data['success'] as bool?;
            
            if (code == 0 || success == true) {
              return true;
            } else {
              final msg = data['msg'] as String? ?? 'Delete account failed';
              throw Exception(msg);
            }
          }
          return true;
        }
      }
      
      throw Exception('Delete account failed with status code: ${response.statusCode}');
    } catch (e) {
      print('Delete account API error: $e');
      rethrow; // 注销账户失败需要抛出异常，不能静默处理
    }
  }

  /// 构建请求头
  Future<Map<String, String>> _buildHeaders() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final deviceInfo = DeviceInfoPlugin();

    String platform = 'iOS';
    String platformVer = '';
    String model = '';
    String deviceId = _config.deviceId ?? '';

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      platform = 'iOS';
      platformVer = iosInfo.systemVersion;
      model = iosInfo.model;
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      platform = 'Android';
      platformVer = androidInfo.version.release;
      model = androidInfo.model;
    }

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'ver': packageInfo.version,
      'pkg': packageInfo.packageName,
      'platform': platform,
      'platform_ver': platformVer,
      'device-id': deviceId,
      'model': model,
      'lang': Platform.localeName.split('_').first,
      'timestamp': '${DateTime.now().millisecondsSinceEpoch}',
    };
    
    if (_config.authToken != null && _config.authToken!.isNotEmpty) {
      // 注意：Bearer 后面需要有空格
      headers['Authorization'] = 'Bearer ${_config.authToken}';
    }
    
    return headers;
  }
}

