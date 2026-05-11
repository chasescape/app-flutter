import 'dart:io';
import 'dart:ui';

import 'package:curl_logger_dio_interceptor/curl_logger_dio_interceptor.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart' as dio;
import 'package:package_info_plus/package_info_plus.dart';

import '../core/app_env_config_adapter.dart';
import '../core/app_service_config.dart';
import '../crypto_helper.dart';

/// 登录服务
///
/// 处理：
/// - 登录 /security/oauth
/// - 登出 /security/logout
/// - 注销账号 /user/deleteAccount
class AuthApi {
  final AppServiceConfig _config;
  final dio.Dio _dio;
  final CryptoHelper _crypto = CryptoHelper();

  AuthApi(this._dio, this._config) {
    if (!_dio.interceptors.any((i) => i is CurlLoggerDioInterceptor)) {
      _dio.interceptors.add(CurlLoggerDioInterceptor(printOnSuccess: true));
    }
  }

  /// 登录接口
  ///
  /// [deviceToken] 设备 ID
  /// 必须先调用 AppConfigApi 获取 encryptKey。
  Future<Map<String, dynamic>> signIn(String deviceToken) async {
    final encryptKey = _config.encryptKey;
    if (encryptKey == null || encryptKey.isEmpty) {
      throw Exception('encryptKey 为空，请先调用 getAppConfig 获取加密密钥再登录');
    }

    final headers = await _buildHeaders(includeAuth: true);
    final body = <String, dynamic>{
      'http_headers': headers,
      'oauthType': '4',
      'token': deviceToken,
    };

    final encryptedBody = _crypto.encryptJson(body, encryptKey);

    final response = await _dio.post(
      '/baseApi/res/mem_max_map/update',
      data: encryptedBody,
      options: dio.Options(
        headers: {'Content-Type': 'application/json'},
        responseType: dio.ResponseType.plain,
      ),
    );

    if (response.data is! String) {
      throw Exception('Unexpected response type: ${response.data.runtimeType}');
    }

    final decrypted = _crypto.decryptToJson(response.data as String, encryptKey);

    final code = decrypted['code'];
    final fail = decrypted['fail'] as bool?;
    final msg = decrypted['msg'] as String?;
    final key = decrypted['key'] as String?;
    final success = decrypted['success'] as bool?;

    if ((code != null && code != 0) || success == false || fail == true) {
      final errorMsg = msg ?? key ?? 'Login failed';
      throw Exception('Login failed: $errorMsg (code: $code)');
    }

    final data = decrypted['data'];
    if (data is Map<String, dynamic>) {
      return <String, dynamic>{...decrypted, ...data};
    }
    return decrypted;
  }

  /// 退出登录接口
  Future<bool> logout() async {
    try {
      final headers = await _buildHeaders();

      final requestPayload = <String, dynamic>{
        'http_headers': headers,
      };

      final encryptKey = _config.encryptKey;
      if (encryptKey == null || encryptKey.isEmpty) {
        throw Exception('encryptKey 为空，无法加密请求');
      }

      final encryptedPayload = _crypto.encryptJson(requestPayload, encryptKey);

      final apiResponse = await _dio.post(
        '/baseApi/v0/product_first_json/upload',
        data: encryptedPayload,
        options: dio.Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          responseType: dio.ResponseType.plain,
        ),
      );

      if (apiResponse.statusCode != 200) return false;

      final rawData = apiResponse.data;
      if (rawData is String) {
        final decryptedData = _crypto.decryptToJson(rawData, encryptKey);
        final resultCode = decryptedData['code'];
        final isSuccess = decryptedData['success'] as bool?;
        return resultCode == 0 || isSuccess == true;
      }

      if (rawData is Map<String, dynamic>) {
        final resultCode = rawData['code'];
        final isSuccess = rawData['success'] as bool?;
        return resultCode == 0 || isSuccess == true;
      }

      return true;
    } catch (_) {
      // 登出失败不阻断本地清理流程
      return true;
    }
  }

  /// 注销账户接口
  Future<bool> deleteAccount() async {
    final requestHeaders = await _buildHeaders();

    final requestBody = <String, dynamic>{
      'http_headers': requestHeaders,
    };

    final encryptionKey = _config.encryptKey;
    if (encryptionKey == null || encryptionKey.isEmpty) {
      throw Exception('encryptKey 为空，无法加密请求');
    }

    final encryptedPayload = _crypto.encryptJson(requestBody, encryptionKey);

    final apiResponse = await _dio.post(
      '/baseApi/v1/page_min_array/erase',
      data: encryptedPayload,
      options: dio.Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        responseType: dio.ResponseType.plain,
      ),
    );

    if (apiResponse.statusCode != 200) {
      throw Exception('Delete account failed with status: ${apiResponse.statusCode}');
    }

    final responseData = apiResponse.data;

    if (responseData is String) {
      final decryptedData = _crypto.decryptToJson(responseData, encryptionKey);
      final responseCode = decryptedData['code'];
      final operationSuccess = decryptedData['success'] as bool?;
      if (responseCode == 0 || operationSuccess == true) {
        return true;
      }
      throw Exception(decryptedData['msg'] as String? ?? 'Delete account operation failed');
    }

    if (responseData is Map<String, dynamic>) {
      final responseCode = responseData['code'];
      final operationSuccess = responseData['success'] as bool?;
      if (responseCode == 0 || operationSuccess == true) {
        return true;
      }
      throw Exception(responseData['msg'] as String? ?? 'Account deletion failed');
    }

    return true;
  }

  /// 构建请求头
  Future<Map<String, String>> _buildHeaders({bool includeAuth = true}) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final deviceInfo = DeviceInfoPlugin();

    String platform = 'iOS';
    String platformVer = '';
    String model = '';

    String deviceId = '';
    if (_config is AppEnvConfigAdapter) {
      deviceId = await (_config as AppEnvConfigAdapter).ensureDeviceId();
    } else {
      deviceId = _config.deviceId ?? '';
    }

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
      'model': model,
      'lang': lang,
      'sys_lan': lang,
      'device_lang': lang,
      'device_country': country,
      'timestamp': '${DateTime.now().millisecondsSinceEpoch}',
    };

    final authToken = _config.authToken;
    if (includeAuth && authToken != null && authToken.isNotEmpty && authToken != deviceId) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    return headers;
  }
}
