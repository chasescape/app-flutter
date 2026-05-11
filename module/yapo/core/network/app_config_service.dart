import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:curl_logger_dio_interceptor/curl_logger_dio_interceptor.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart' as dio;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:package_info_plus/package_info_plus.dart';

import '../core/crypto_helper.dart';
import '../core/service_config.dart';

/// AppConfig 服务（可复用版本）
///
/// 处理 /config/getAppConfigPostV2 接口，获取 encryptKey 和 authToken。
///
/// 使用方式：
/// ```dart
/// final service = AppConfigService(dio, config);
/// final result = await service.getAppConfig();
/// print('encryptKey: ${result['encryptKey']}');
/// ```
class AppConfigService {
  final dio.Dio _dio;
  final ServiceConfig _config;
  final CryptoHelper _crypto = CryptoHelper();

  AppConfigService(this._dio, this._config) {
    if (!_dio.interceptors.any((i) => i is CurlLoggerDioInterceptor)) {
      _dio.interceptors.add(CurlLoggerDioInterceptor(printOnSuccess: true));
    }
  }

  /// 配置接口默认密钥（走 encryptionBody 时使用）
  /// 规则：hostApi 去掉 URL 前缀后，不足 32 字节补 '0'，超过则截断
  String getAppConfigApiKey() {
    final hostApi = _config.hostApi;
    String newKey = hostApi.replaceAll(RegExp(r'^https?://'), '');
    return _crypto.normalizeKey(newKey);
  }

  /// 获取 AppConfig（encryptKey 和可能的 authToken）
  ///
  /// 调用 POST /config/getAppConfigPostV2，body: {"http_headers":{...},"ver":"0"}
  /// 响应先 AES-ECB 解密（默认密钥），然后处理 k2/k3/k4 三层解密
  Future<Map<String, String>> getAppConfig() async {
    // 获取缓存的版本号
    final cachedVer = await _config.getString('app_config_ver') ?? '0';
    
    // 构建请求头
    final headers = await _buildHeaders();
    
    // 构建请求体（加密前）- 需要包含 http_headers
    final requestBody = <String, dynamic>{
      'http_headers': headers,
      'ver': cachedVer,
    };
    
    // 加密请求体 - 使用默认密钥
    final appConfigKey = getAppConfigApiKey();
    final encryptedBody = _crypto.encryptJson(requestBody, appConfigKey);
    
    // 发送 POST 请求
    final response = await _dio.post(
      '/config/getAppConfigPostV2',
      data: encryptedBody,
      options: dio.Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        responseType: dio.ResponseType.plain,
      ),
    );
    
    // 处理响应（需要解密）
    if (response.data is! String) {
      throw Exception('Unexpected response type: ${response.data.runtimeType}');
    }
    
    final responseString = response.data as String;
    
    // 第一步：AES-ECB 解密（使用默认密码 getAppConfigApiKey）
    Map<String, dynamic> firstDecrypted;
    try {
      firstDecrypted = _crypto.decryptToJson(responseString, appConfigKey);
    } catch (e) {
      print('Failed to decrypt response: $e');
      print('Response string (first 200 chars): ${responseString.length > 200 ? responseString.substring(0, 200) : responseString}');
      rethrow;
    }
    
    // 检查业务错误码
    final code = firstDecrypted['code'];
    if (code != null && code != 0) {
      final msg = firstDecrypted['msg'] as String? ?? 'Unknown error';
      final key = firstDecrypted['key'] as String?;
      throw Exception('AppConfig API error: $msg (code: $code, key: $key)');
    }
    
    // 第二步：处理 k2/k3/k4 三层解密
    final finalData = _handleConfigResponse(firstDecrypted);
    
    // 提取 encryptKey 和可能的 authToken
    if (!finalData.containsKey('data')) {
      print('Response structure: ${finalData.keys.toList()}');
      print('Response data: $finalData');
      throw Exception('Response does not contain "data" field');
    }
    
    final data = finalData['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid response data format: expected Map');
    }
    
    if (!data.containsKey('items') || data['items'] is! List) {
      throw Exception('Response data does not contain "items" List');
    }
    
    final items = data['items'] as List;
    
    // 保存新的 ver
    if (finalData.containsKey('ver')) {
      final newVer = finalData['ver'].toString();
      await _config.saveString('app_config_ver', newVer);
    }
    
    // 查找 encrypt_key 和可能的 authToken
    String? encryptKey;
    String? authToken;
    
    for (final item in items) {
      if (item is Map && item.containsKey('name')) {
        final name = item['name'] as String;
        
        if (name == 'encrypt_key' && item.containsKey('data')) {
          encryptKey = item['data'] as String;
        } else if ((name == 'auth_token' || name == 'token') && item.containsKey('data')) {
          authToken = item['data'] as String?;
        }
      }
    }
    
    if (encryptKey == null || encryptKey.isEmpty) {
      throw Exception('encrypt_key not found in response items');
    }

    // 保存到配置和本地
    _config.encryptKey = encryptKey;
    await _config.saveString('encrypt_key', encryptKey);
    
    return {
      'encryptKey': encryptKey,
      if (authToken != null && authToken.isNotEmpty) 'authToken': authToken,
    };
  }

  /// 处理配置接口响应（k2/k3/k4 三层解密）
  Map<String, dynamic> _handleConfigResponse(Map<String, dynamic> data) {
    if (!data.containsKey('data')) {
      return data;
    }
    final rData = data['data'];
    if (rData is! Map ||
        rData['k2'] == null ||
        rData['k3'] == null ||
        rData['k4'] == null) {
      return data;
    }

    try {
      final key2Data = rData['k2'];
      final key3Data = rData['k3'];
      final key4Data = rData['k4'];

      // 1. 提取并解码 k2, k3, k4（Base64 解码 → UTF-8 → 字符串）
      String cleanBase64(String v) => ("$v").trim().replaceAll(RegExp(r'\s'), '');
      
      Uint8List decodedBytes = base64Decode(cleanBase64("$key2Data"));
      final key2 = utf8.decode(decodedBytes);

      decodedBytes = base64Decode(cleanBase64("$key3Data"));
      final key3 = utf8.decode(decodedBytes);

      decodedBytes = base64Decode(cleanBase64("$key4Data"));
      final key4 = utf8.decode(decodedBytes);

      // 2. 使用 key2 + key3 作为密钥解密 k4
      // 关键：使用字节级别的密钥归一化（与能用的版本一致）
      final combinedKey = "$key2$key3";
      
      // 清理 k4 数据
      final trimmed = key4.trim().replaceAll(RegExp(r'\s'), '');
      final encryptedData = encrypt.Encrypted.fromBase64(trimmed);
      
      // 使用 normalizeAesKey 进行字节级别的归一化
      final keyData = _crypto.normalizeAesKey(combinedKey);
      final encrypter = encrypt.Encrypter(encrypt.AES(keyData, mode: encrypt.AESMode.ecb));
      final decrypted = encrypter.decrypt(encryptedData);
      
      final res4 = jsonDecode(decrypted) as Map<String, dynamic>;

      data['data'] = res4;
    } catch (e, stackTrace) {
      print('k2/k3/k4 第二层解密失败: $e');
      print('$stackTrace');
    }
    return data;
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

    // 如果有 token，添加到请求头
    if (_config.authToken != null && _config.authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer${_config.authToken}';
    }

    return headers;
  }
}

