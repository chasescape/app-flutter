import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:curl_logger_dio_interceptor/curl_logger_dio_interceptor.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart' as dio;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:package_info_plus/package_info_plus.dart';

import '../crypto_helper.dart';
import '../core/app_env_config_adapter.dart';
import '../core/app_service_config.dart';

/// AppConfig 服务
///
/// 处理 /config/getAppConfigPostV2 接口，获取 encryptKey 与 authToken。
class AppConfigApi {
  final AppServiceConfig _config;
  final dio.Dio _dio;
  final CryptoHelper _crypto = CryptoHelper();

  static bool _loggerAdded = false;

  AppConfigApi(this._dio, this._config) {
    if (!_loggerAdded) {
      _dio.interceptors.add(CurlLoggerDioInterceptor(printOnSuccess: true));
      _loggerAdded = true;
    }
  }

  /// 配置接口默认密钥（走 encryptionBody 时使用）
  /// 规则：hostApi 去掉 URL 前缀后，不足 32 字节补 '0'，超过则截断
  String getAppConfigApiKey() {
    final hostApi = _config.hostApi;
    final newKey = hostApi.replaceAll(RegExp(r'^https?://'), '');
    return _crypto.normalizeKey(newKey.trim());
  }

  /// 获取 AppConfig（encryptKey 和可能的 authToken）
  ///
  /// 调用 POST /config/getAppConfigPostV2
  /// body: {"http_headers":{...},"ver":"0"}
  /// 响应先 AES-ECB 解密（默认密钥），再处理 k2/k3/k4 三层解密
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

  String _buildEncryptedRequest(Map<String, String> headers, String ver) {
    final requestBody = {
      'http_headers': headers,
      'ver': ver,
    };

    final key = getAppConfigApiKey();
    return _crypto.encryptJson(requestBody, key);
  }

  Future<String> _postConfig(String encryptedBody) async {
    final response = await _dio.post(
      '/baseApi/v3/datetime_second_entry/remove',
      data: encryptedBody,
      options: dio.Options(
        headers: {'Content-Type': 'application/json'},
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
    return _crypto.decryptToJson(response, key);
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

    String? encryptKey;
    String? authToken;

    for (final item in items) {
      if (item is Map && item.containsKey('name')) {
        final name = item['name'];
        if (name == 'encrypt_key') {
          encryptKey = item['data'];
        }
        if (name == 'auth_token' || name == 'token') {
          authToken = item['data'];
        }
      }
    }

    if (encryptKey == null || encryptKey.isEmpty) {
      throw Exception('encrypt_key not found');
    }

    _config.encryptKey = encryptKey;
    await _config.saveString('encrypt_key', encryptKey);

    return {
      'encryptKey': encryptKey,
      if (authToken != null && authToken.isNotEmpty) 'authToken': authToken,
    };
  }

  /// 处理配置接口响应（k2/k3/k4 三层解密）
  Map<String, dynamic> _handleConfigResponse(Map<String, dynamic> data) {
    if (!data.containsKey('data')) return data;

    final rData = data['data'];
    if (rData is! Map || rData['k2'] == null || rData['k3'] == null || rData['k4'] == null) {
      return data;
    }

    try {
      String clean(String v) => v.trim().replaceAll(RegExp(r'\s'), '');

      final key2 = utf8.decode(base64Decode(clean(rData['k2'].toString())));
      final key3 = utf8.decode(base64Decode(clean(rData['k3'].toString())));
      final key4 = utf8.decode(base64Decode(clean(rData['k4'].toString())));

      final combinedKey = "$key2$key3";
      final encryptedData = encrypt.Encrypted.fromBase64(clean(key4));
      final aesKey = _crypto.normalizeAesKey(combinedKey);
      final encrypter = encrypt.Encrypter(
        encrypt.AES(aesKey, mode: encrypt.AESMode.ecb),
      );

      final decrypted = encrypter.decrypt(encryptedData);
      data['data'] = jsonDecode(decrypted);
    } catch (_) {
      // ignore decrypt errors to keep compatibility
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

    // 设备 ID
    String deviceIdentifier = '';
    if (_config is AppEnvConfigAdapter) {
      deviceIdentifier = await (_config as AppEnvConfigAdapter).ensureDeviceId();
    } else {
      deviceIdentifier = _config.deviceId ?? '';
    }

    if (Platform.isIOS) {
      final iosDeviceInfo = await deviceInfo.iosInfo;
      platformName = 'iOS';
      platformVer = iosDeviceInfo.systemVersion;
      deviceModel = iosDeviceInfo.model;
    } else if (Platform.isAndroid) {
      final androidDeviceInfo = await deviceInfo.androidInfo;
      platformName = 'Android';
      platformVer = androidDeviceInfo.version.release;
      deviceModel = androidDeviceInfo.model;
    }

    final systemLocale = PlatformDispatcher.instance.locale;
    final languageCode = systemLocale.languageCode.isNotEmpty ? systemLocale.languageCode : 'en';
    final countryCode = systemLocale.countryCode ?? '';

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

    final authToken = _config.authToken;
    if (authToken != null && authToken.isNotEmpty && authToken != deviceIdentifier) {
      requestHeaders['Authorization'] = 'Bearer $authToken';
    }

    return requestHeaders;
  }
}
