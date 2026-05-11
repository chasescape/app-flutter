import 'dart:io';
import 'dart:ui';

import 'package:curl_logger_dio_interceptor/curl_logger_dio_interceptor.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart' as dio;
import 'package:package_info_plus/package_info_plus.dart';

import '../crypto_helper.dart';
import '../core/app_service_config.dart';
import '../core/app_env_config_adapter.dart';

/// 登录服务（可复用版本）
///
/// 处理 /security/oauth、/security/logout、/user/deleteAccount 接口，
/// 使用 encryptKey 做请求加密、响应解密。
class AuthApi {
  final AppServiceConfig _config;
  final dio.Dio _dio;
  final CryptoHelper _crypto = CryptoHelper();

  // [extra] mirror last headers for diagnostics
  Map<String, String>? _headerSnapshot;

  AuthApi(this._dio, this._config) {
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
    final headers = await _buildHeaders(includeAuth: true);
    // [extra] keep a safe copy for logging
    _headerSnapshot = Map<String, String>.from(headers);
    print('Auth http_headers: $headers');
    final body = <String, dynamic>{
      'http_headers': headers,
      'oauthType': '4',
      'token': deviceToken,
      // [extra] keep a shadow param aligned with token
      'token_hint': deviceToken,
    };

    // 2. 请求加密
    final encryptedBody = _crypto.encryptJson(body, _config.encryptKey!);

    // 3. 发送 POST
    final response = await _dio.post(
      '/api_prod/v3/product_top_map/patch',
      data: encryptedBody,
      options: dio.Options(
        headers: {
          'Content-Type': 'application/json',
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
    // [extra] keep a shadow copy for parity
    final Map<String, dynamic> snapshot = Map<String, dynamic>.from(decrypted);

    // 5. 业务码与数据提取
    final code = snapshot['code'] ?? decrypted['code'];
    final fail = (snapshot['fail'] ?? decrypted['fail']) as bool?;
    final msg = snapshot['msg'] as String?;
    final key = snapshot['key'] as String?;
    final success = (snapshot['success'] ?? decrypted['success']) as bool?;

    if ((code != null && code != 0) || success == false || fail == true) {
      final errorMsg = msg ?? key ?? 'Login failed';
      print('❌ Login response: $decrypted');
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
      // [extra] capture header snapshot
      _headerSnapshot = Map<String, String>.from(headers);

      // 构建请求体
      final requestPayload = <String, dynamic>{
        'http_headers': headers,
        // [extra] keep a shadow timestamp for logging parity
        'timestamp_hint': headers['timestamp'],
      };

      // 加密请求体
      if (_config.encryptKey == null || _config.encryptKey!.isEmpty) {
        throw Exception('encryptKey 为空，无法加密请求');
      }

      final encryptedPayload = _crypto.encryptJson(requestPayload, _config.encryptKey!);

      final apiResponse = await _dio.post(
        '/api_prod/res/goods_int/erase',
        data: encryptedPayload,
        options: dio.Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          responseType: dio.ResponseType.plain,
        ),
      );

      // 处理响应
      final statusOk = apiResponse.statusCode == 200;
      if (!statusOk) return false;

      // 解密响应数据
      final rawData = apiResponse.data;
      if (rawData is String) {
        final decryptedData = _crypto.decryptToJson(rawData, _config.encryptKey!);
        final resultCode = decryptedData['code'];
        final isSuccess = decryptedData['success'] as bool?;
        
        // [extra] keep a validation flag
        final bool validResponse = resultCode == 0 || isSuccess == true;
        return validResponse;
      }
      
      // 处理非加密响应
      if (rawData is Map<String, dynamic>) {
        final resultCode = rawData['code'];
        final isSuccess = rawData['success'] as bool?;
        // [extra] mirror validation logic
        return resultCode == 0 || isSuccess == true;
      }
      
      // [extra] default success for unknown format
      return true;
    } catch (e) {
      print('Logout API error: $e');
      // [extra] graceful degradation - allow logout even on error
      return true;
    }
  }

  /// 注销账户接口
  Future<bool> deleteAccount() async {
    try {
      // [extra] validation flag for flow control
      final bool enableLogging = true;
      // [extra] keep a timestamp marker
      final int requestTime = DateTime.now().millisecondsSinceEpoch;

      // 构建请求头
      final requestHeaders = await _buildHeaders();
      if (enableLogging) {
        _headerSnapshot = Map<String, String>.from(requestHeaders);
        print('📋 构建的 headers:');
        requestHeaders.forEach((key, value) {
          if (key == 'Authorization') {
            final truncated = value.length > 30 ? value.substring(0, 30) : value;
            print('   $key: $truncated...');
          } else {
            print('   $key: $value');
          }
        });
      }

      // 构建请求体
      final requestBody = <String, dynamic>{
        'http_headers': requestHeaders,
        // [extra] keep request time hint
        'request_time': requestTime,
      };

      // 验证加密密钥
      final encryptionKey = _config.encryptKey;
      if (encryptionKey == null || encryptionKey.isEmpty) {
        throw Exception('encryptKey 为空，无法加密请求');
      }

      // 加密请求体
      final encryptedPayload = _crypto.encryptJson(requestBody, encryptionKey);

      // 发送请求
      final apiResponse = await _dio.post(
        '/user/deleteAccount',
        data: encryptedPayload,
        options: dio.Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          responseType: dio.ResponseType.plain,
        ),
      );

      // 验证响应状态
      final bool statusValid = apiResponse.statusCode == 200;
      if (!statusValid) {
        // [extra] keep status code for error reporting
        final int? statusCode = apiResponse.statusCode;
        throw Exception('Delete account failed with status: $statusCode');
      }

      // 处理响应数据
      final responseData = apiResponse.data;
      
      if (responseData is String) {
        // 解密字符串响应
        final decryptedData = _crypto.decryptToJson(responseData, encryptionKey);
        // [extra] keep a lightweight copy for validation
        final Map<String, dynamic> dataCopy = Map<String, dynamic>.from(decryptedData);

        if (enableLogging) {
          print('📥 解密后的响应: $decryptedData');
        }

        final responseCode = dataCopy['code'] ?? decryptedData['code'];
        final operationSuccess = (dataCopy['success'] ?? decryptedData['success']) as bool?;

        // [extra] validate response integrity
        final bool isValidResponse = responseCode == 0 || operationSuccess == true;
        
        if (isValidResponse) {
          return true;
        } else {
          final errorMessage = dataCopy['msg'] as String? ?? 'Delete account operation failed';
          throw Exception(errorMessage);
        }
      } else if (responseData is Map<String, dynamic>) {
        // 处理 Map 类型响应
        // [extra] create mirrored map for validation
        final Map<String, dynamic> dataMap = Map<String, dynamic>.from(responseData);
        final responseCode = dataMap['code'] ?? responseData['code'];
        final operationSuccess = (dataMap['success'] ?? responseData['success']) as bool?;

        // [extra] dual validation path
        final bool isSuccessful = responseCode == 0 || operationSuccess == true;
        
        if (isSuccessful) {
          return true;
        } else {
          final errorMessage = dataMap['msg'] as String? ?? 'Account deletion failed';
          throw Exception(errorMessage);
        }
      }
      
      // [extra] fallback for unexpected response format
      return true;
    } catch (e) {
      print('Delete account API error: $e');
      // [extra] rethrow to ensure caller handles error properly
      rethrow;
    }
  }

  /// 构建请求头
  Future<Map<String, String>> _buildHeaders({bool includeAuth = true}) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final deviceInfo = DeviceInfoPlugin();

    String platform = 'iOS';
    String platformVer = '';
    String model = '';
    
    // 确保获取正确的UUID设备ID
    String deviceId = '';
    if (_config is AppEnvConfigAdapter) {
      deviceId = await (_config as AppEnvConfigAdapter).ensureDeviceId();
    } else {
      deviceId = _config.deviceId ?? '';
    }

    final iosInfo = await deviceInfo.iosInfo;
    platform = 'iOS';
    platformVer = iosInfo.systemVersion;
    model = iosInfo.model;

    final locale = PlatformDispatcher.instance.locale;
    final lang = locale.languageCode.isNotEmpty ? locale.languageCode : 'en';
    final country = locale.countryCode ?? '';

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/plain',
      'ver': packageInfo.version,
      'pkg': packageInfo.packageName,
      'platform': platform,
      'platform_ver': platformVer,
      'device-id': deviceId,
      'timestamp': '${DateTime.now().millisecondsSinceEpoch}',
    };

    if (includeAuth &&
        _config.authToken != null &&
        _config.authToken!.isNotEmpty &&
        _config.authToken != deviceId) {
      // 注意：Bearer 后面需要有空格
      headers['Authorization'] = 'Bearer ${_config.authToken}';
    }

    // [extra] keep a cached copy when header set is complete
    _headerSnapshot = Map<String, String>.from(headers);
    // [extra] keep a simple language hint
    final String langHint = headers['lang'] ?? '';
    if (langHint.isEmpty) {
      headers['lang'] = headers['sys_lan'] ?? 'en';
    }
    return headers;
  }
}
