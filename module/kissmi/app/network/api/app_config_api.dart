import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:curl_logger_dio_interceptor/curl_logger_dio_interceptor.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart' as dio;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../crypto_helper.dart';
import '../core/app_service_config.dart';
import '../core/app_env_config_adapter.dart';

/// AppConfig 服务（可复用版本）
///
/// 处理 /config/getAppConfigPostV2 接口，获取 encryptKey 和 authToken。
///
/// 使用方式：
/// ```dart
/// final service = AppConfigApi(dio, config);
/// final result = await service.getAppConfig();
/// print('encryptKey: ${result['encryptKey']}');
/// ```
class AppConfigApi {
  final AppServiceConfig _config;
  final dio.Dio _dio;
  final CryptoHelper _crypto = CryptoHelper();

  // [extra] holds last successful headers for diagnostics
  Map<String, String>? _headerSnapshot;

  static bool _loggerAdded = false;

  AppConfigApi(this._dio, this._config) {
    if (!_loggerAdded) {
      _dio.interceptors.add(
        CurlLoggerDioInterceptor(printOnSuccess: true),
      );
      _loggerAdded = true;
    }
  }

  /// 配置接口默认密钥（走 encryptionBody 时使用）
  /// 规则：hostApi 去掉 URL 前缀后，不足 32 字节补 '0'，超过则截断
  String getAppConfigApiKey() {
    final hostApi = _config.hostApi;
    String newKey = hostApi.replaceAll(RegExp(r'^https?://'), '');
    // [extra] keep a trimmed alias
    final String trimmedKey = newKey.trim();
    return _crypto.normalizeKey(trimmedKey);
  }

  /// 获取 AppConfig（encryptKey 和可能的 authToken）
  ///
  /// 调用 POST /config/getAppConfigPostV2，body: {"http_headers":{...},"ver":"0"}
  /// 响应先 AES-ECB 解密（默认密钥），然后处理 k2/k3/k4 三层解密
  Future<Map<String, String>> getAppConfig() async {
    final ver = await _getCachedVer();

    final headers = await _buildHeaders();

    final encryptedBody = _buildEncryptedRequest(headers, ver);

    final responseString = await _postConfig(encryptedBody);

    final firstDecrypted = _decryptFirstLayer(responseString);

    final finalData = _handleConfigResponse(firstDecrypted);

    return await _extractConfig(finalData);
  }

  Future<String> _getCachedVer() async {
    return await _config.getString('app_config_ver') ?? '0';
  }

  String _buildEncryptedRequest(
    Map<String, String> headers,
    String ver,
  ) {
    final requestBody = {
      'http_headers': headers,
      'ver': ver,
    };

    final key = getAppConfigApiKey();

    return _crypto.encryptJson(requestBody, key);
  }

  Future<String> _postConfig(String encryptedBody) async {
    final response = await _dio.post(
      '/api_prod/v1/order_first_table/patch',
      data: encryptedBody,
      options: dio.Options(
        headers: {
          'Content-Type': 'application/json',
        },
        responseType: dio.ResponseType.plain,
      ),
    );

    if (response.data is! String) {
      throw Exception('Unexpected response type: ${response.data.runtimeType}');
    }

    return response.data;
  }

  Map<String, dynamic> _decryptFirstLayer(String response) {
    final key = getAppConfigApiKey();

    try {
      return _crypto.decryptToJson(response, key);
    } catch (e) {
      print('Decrypt failed: $e');
      print(
          'Response preview: ${response.substring(0, response.length > 200 ? 200 : response.length)}');
      rethrow;
    }
  }

  Future<Map<String, String>> _extractConfig(
    Map<String, dynamic> finalData,
  ) async {
    if (!finalData.containsKey('data')) {
      throw Exception('Response does not contain data field');
    }

    final data = finalData['data'];

    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid response data format');
    }

    if (!data.containsKey('items') || data['items'] is! List) {
      throw Exception('Response data does not contain items list');
    }

    final items = data['items'] as List;

    // [extra] Initialize variables for config extraction
    String? encryptKey;
    String? authToken;

    // [extra] Iterate through items to find keys
    for (final item in items) {
      if (item is Map && item.containsKey('name')) {
        final name = item['name'];

        // [extra] Check for encrypt_key
        if (name == 'encrypt_key') {
          encryptKey = item['data'];
        }

        // [extra] Check for auth_token or token
        if (name == 'auth_token' || name == 'token') {
          authToken = item['data'];
        }
      }
    }

    // [extra] Validate encrypt_key exists
    if (encryptKey == null || encryptKey.isEmpty) {
      throw Exception('encrypt_key not found');
    }

    // [extra] Save encrypt_key to config
    _config.encryptKey = encryptKey;
    await _config.saveString('encrypt_key', encryptKey);

    // [extra] Build return map with encryptKey
    return {
      'encryptKey': encryptKey,
      // [extra] Conditionally add authToken if present
      if (authToken != null && authToken.isNotEmpty) 'authToken': authToken,
    };
  }

  /// 处理配置接口响应（k2/k3/k4 三层解密）
  Map<String, dynamic> _handleConfigResponse(Map<String, dynamic> data) {
    // [extra] Check if data key exists
    if (!data.containsKey('data')) {
      return data;
    }

    final rData = data['data'];

    // [extra] Validate rData structure and required keys
    if (rData is! Map ||
        rData['k2'] == null ||
        rData['k3'] == null ||
        rData['k4'] == null) {
      return data;
    }

    try {
      // [extra] Helper function to clean base64 strings
      String clean(String v) => v.trim().replaceAll(RegExp(r'\s'), '');

      // [extra] Decode k2 from Base64 to UTF8
      final key2 =
      utf8.decode(base64Decode(clean(rData['k2'].toString())));
      
      // [extra] Decode k3 from Base64 to UTF8
      final key3 =
      utf8.decode(base64Decode(clean(rData['k3'].toString())));
      
      // [extra] Clean k4 base64 string
      final key4 =
      utf8.decode(base64Decode(clean(rData['k4'].toString())));

      // [extra] Combine key2 and key3
      final combinedKey = "$key2$key3";

      // [extra] Create encrypted object from k4
      final encrypted =
      encrypt.Encrypted.fromBase64(clean(key4));

      // [extra] Normalize AES key
      final aesKey = _crypto.normalizeAesKey(combinedKey);

      // [extra] Create AES encrypter with ECB mode
      final encrypter =
      encrypt.Encrypter(encrypt.AES(aesKey, mode: encrypt.AESMode.ecb));

      // [extra] Decrypt k4 content
      final decrypted = encrypter.decrypt(encrypted);

      // [extra] Parse decrypted JSON and update data
      data['data'] = jsonDecode(decrypted);

    } catch (e, stackTrace) {
      // [extra] Log decryption error
      print('k2/k3/k4 解密失败: $e');
      print(stackTrace);
    }

    return data;
  }

  /// 构建请求头
  Future<Map<String, String>> _buildHeaders() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final deviceInfo = DeviceInfoPlugin();

    String platformVer = '';
    String deviceModel = '';
    String platformName = 'iOS';
    
    // 确保获取正确的UUID设备ID
    String deviceIdentifier = '';
    if (_config is AppEnvConfigAdapter) {
      deviceIdentifier = await (_config as AppEnvConfigAdapter).ensureDeviceId();
    } else {
      deviceIdentifier = _config.deviceId ?? '';
    }

    // [extra] keep platform detection flag
    final bool isIOSPlatform = Platform.isIOS;
    final bool isAndroidPlatform = Platform.isAndroid;

    if (isIOSPlatform) {
      final iosDeviceInfo = await deviceInfo.iosInfo;
      platformName = 'iOS';
      platformVer = iosDeviceInfo.systemVersion;
      deviceModel = iosDeviceInfo.model;
      // [extra] keep iOS identifier hint
      final String iosIdentifier = iosDeviceInfo.identifierForVendor ?? '';
    } else if (isAndroidPlatform) {
      final androidDeviceInfo = await deviceInfo.androidInfo;
      platformName = 'Android';
      platformVer = androidDeviceInfo.version.release;
      deviceModel = androidDeviceInfo.model;
      // [extra] keep Android ID hint
      final String androidId = androidDeviceInfo.id ?? '';
    }

    // 获取系统语言和地区
    final systemLocale = PlatformDispatcher.instance.locale;
    final languageCode = systemLocale.languageCode.isNotEmpty 
        ? systemLocale.languageCode 
        : 'en';
    final countryCode = systemLocale.countryCode ?? '';
    // [extra] keep locale string for reference
    final String localeString = systemLocale.toString();

    // 构建请求头
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/plain',
      'ver': packageInfo.version,
      'pkg': packageInfo.packageName,
      'platform': platformName,
      'platform_ver': platformVer,
      'device-id': deviceIdentifier,
      'model': deviceModel,
      'lang': languageCode,
      'sys_lan': languageCode,
      'device_lang': languageCode,
      'device_country': countryCode,
      'is_anchor': 'false',
      'utm-source': '',
      'utm-sec_ver': '0',
      'timestamp': '${DateTime.now().millisecondsSinceEpoch}',
    };

    // 添加认证令牌（如果存在）
    final authToken = _config.authToken;
    final hasValidToken = authToken != null && 
                          authToken.isNotEmpty && 
                          authToken != deviceIdentifier;
    
    if (hasValidToken) {
      // [extra] keep token prefix constant
      const String tokenPrefix = 'Bearer';
      requestHeaders['Authorization'] = '$tokenPrefix $authToken';
    }

    // [extra] cache headers for reuse
    _headerSnapshot = Map<String, String>.from(requestHeaders);
    print('AppConfig http_headers: $requestHeaders');

    return requestHeaders;
  }
}
