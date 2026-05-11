import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:curl_logger_dio_interceptor/curl_logger_dio_interceptor.dart';
import 'package:dio/dio.dart' as dio;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:paech/interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../env/app_env.dart';
import '../../interface.dart';

/// AppConfig 服务
/// 处理 /config/getAppConfigPostV2 接口
class AppConfigService {
  final dio.Dio _dio;
  final Map<String, encrypt.Encrypter> _encryptMap = {};
  SharedPreferences? _prefs;

  AppConfigService(this._dio) {
    if (!_dio.interceptors.any((i) => i is CurlLoggerDioInterceptor)) {
      _dio.interceptors.add(CurlLoggerDioInterceptor(printOnSuccess: true));
    }
  }

  /// 初始化 SharedPreferences
  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 配置接口默认密钥（走 encryptionBody 时使用）
  /// 规则：hostApi 去掉 URL 前缀后，不足 32 字节补 '0'，超过则截断
  static String getAppConfigApiKey() {
    final hostApi = Aquaria255AppEnv().hostApi;
    String newKey = hostApi.replaceAll(RegExp(r'^https?://'), '');
    final count = newKey.length;
    if (count < 32) {
      newKey = newKey.padRight(32, '0');
    } else if (count > 32) {
      newKey = newKey.substring(0, 32);
    }
    return newKey;
  }

  /// 获取 AppConfig（encryptKey 和可能的 authToken）
  /// 调用 POST /config/getAppConfigPostV2，body: {"ver":"0"}
  /// 响应先 AES-ECB 解密（默认密钥），然后处理 k2/k3/k4 三层解密
  Future<Map<String, String>> getAppConfig() async {
    final i = Unshaved408Interface();
    
    await _initPrefs();
    final cachedVer = _prefs?.getString('app_config_ver') ?? '0';
    
    // 构建请求体（加密前）
    final requestBody = <String, dynamic>{
      'http_headers': await _buildHeaders(),
      'ver': cachedVer,
    };
    
    // 加密请求体
    final encryptedBody = _encryptRequestBody(requestBody);
    
    // 发送 POST 请求（发送加密后的 Base64 字符串）
    final response = await _dio.post(
      '/api_prod/v3/model_top_json/post',
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
    final appConfigKey = getAppConfigApiKey();
    Map<String, dynamic> firstDecrypted;
    try {
      firstDecrypted = _decryptResponse(responseString, eKey: appConfigKey);
      print('First decrypted keys: ${firstDecrypted.keys.toList()}');
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
    print('Final data keys after k2/k3/k4 decryption: ${finalData.keys.toList()}');
    
    // 提取 encryptKey 和可能的 authToken
    if (!finalData.containsKey('data')) {
      // 添加调试信息
      print('Response structure: ${finalData.keys.toList()}');
      print('Response data: $finalData');
      print('First decrypted data: $firstDecrypted');
      throw Exception('Response does not contain "data" field. Response keys: ${finalData.keys.toList()}');
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
      await _prefs?.setString('app_config_ver', newVer);
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

    print('encryptKey: $encryptKey');

    // 保存到 Unshaved408Interface 和本地
    i.encryptKey = encryptKey;
    await _prefs?.setString('encrypt_key', encryptKey);
    
    return {
      'encryptKey': encryptKey,
      if (authToken != null && authToken.isNotEmpty) 'authToken': authToken,
    };
  }

  /// 解密响应（第一步：AES-ECB 解密）
  /// [eKey] 若传入则优先使用（如 AppConfig 使用 getAppConfigApiKey）
  Map<String, dynamic> _decryptResponse(String responseData, {String? eKey}) {
    String dKey = eKey ?? Combing154AwesomeInterface().encryptKey ?? '';
    if (dKey.isEmpty) {
      dKey = getAppConfigApiKey();
    }

    final trimmed = responseData.trim();
    if (trimmed.isEmpty) {
      throw Exception('Empty response data');
    }
    
    // 检查是否是 JSON 格式（可能已经是明文）
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      try {
        return jsonDecode(trimmed) as Map<String, dynamic>;
      } catch (_) {
        // 不是 JSON，当作加密数据处理
      }
    }

    // 移除所有空白（含换行），Base64 仅允许 A-Za-z0-9+/=，否则会 FormatException: Invalid character
    final clean = trimmed.replaceAll(RegExp(r'\s'), '');
    final encrypted = encrypt.Encrypted.fromBase64(clean);
    
    // AES-ECB 解密
    final encrypter = _getEncrypter(dKey);
    final decrypted = encrypter.decrypt(encrypted);
    
    // JSON 解析
    return jsonDecode(decrypted) as Map<String, dynamic>;
  }

  /// 处理配置接口响应（k2/k3/k4 三层解密，与 appconfig_flow.md configBody 一致）
  ///
  /// 流程：Base64 解码 k2/k3/k4 → key2/key3/key4 字符串，再用 decryptBody(key4, "$key2$key3") 解密
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

      // 1. 提取并解码 k2, k3, k4（与 appconfig_flow configBody 一致：Base64 解码 → UTF-8 → 字符串）
      String cleanBase64(String v) => ("$v").trim().replaceAll(RegExp(r'\s'), '');
      Uint8List decodedBytes = base64Decode(cleanBase64("$key2Data"));
      final key2 = utf8.decode(decodedBytes);

      decodedBytes = base64Decode(cleanBase64("$key3Data"));
      final key3 = utf8.decode(decodedBytes);

      decodedBytes = base64Decode(cleanBase64("$key4Data"));
      final key4 = utf8.decode(decodedBytes);

      // 2. 使用 key2 + key3 作为密钥解密 k4：jsonDecode(decryptBody(key4, "$key2$key3"))
      final res4 = jsonDecode(_decryptBody(key4, "$key2$key3")) as Map<String, dynamic>;

      data['data'] = res4;
    } catch (e, stackTrace) {
      print('k2/k3/k4 第二层解密失败: $e');
      print('$stackTrace');
    }
    return data;
  }

  /// 与文档 decryptBody 一致：清理数据后 Base64 解码 + AES-ECB 解密
  String _decryptBody(String data, String dKey) {
    final fData = data.trim().replaceAll(RegExp(r'\s'), '');
    final keyData = _normalizeAesKey(dKey);
    final enc = encrypt.Encrypter(encrypt.AES(keyData, mode: encrypt.AESMode.ecb));
    return enc.decrypt(encrypt.Encrypted.fromBase64(fData));
  }

  /// 将 key2+key3 归一化到 32 字节（AES-256），不足补 0，超过截断
  encrypt.Key _normalizeAesKey(String s) {
    final b = Uint8List.fromList(utf8.encode(s));
    if (b.length < 32) {
      final out = Uint8List(32)..setRange(0, b.length, b);
      return encrypt.Key(out);
    }
    if (b.length > 32) {
      return encrypt.Key(b.sublist(0, 32));
    }
    return encrypt.Key(b);
  }

  /// 构建请求头
  /// 包含设备信息、应用信息、用户信息等
  Future<Map<String, String>> _buildHeaders() async {
    final i = Combing154AwesomeInterface();
    final packageInfo = await PackageInfo.fromPlatform();
    final deviceInfo = DeviceInfoPlugin();
    
    String platform = 'iOS';
    String platformVer = '';
    String model = '';
    String deviceId = i.deviceId ?? '';

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
    if (i.authToken != null && i.authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer${i.authToken}';
    }

    return headers;
  }

  /// 加密请求体（走 encryptionBody，使用默认密码 getAppConfigApiKey）
  /// 配置接口在拿 encryptKey 之前，统一用 getAppConfigApiKey 加解密
  String _encryptRequestBody(Map<String, dynamic> body) {
    final eKey = getAppConfigApiKey();
    if (eKey.isEmpty) {
      throw Exception('getAppConfigApiKey is empty, hostApi not set');
    }

    try {
      // 获取加密器
      final encrypter = _getEncrypter(eKey);
      
      // 将请求体转为 JSON 字符串
      final jsonString = jsonEncode(body);
      
      // AES-ECB 加密
      final encrypted = encrypter.encrypt(jsonString);
      
      // Base64 编码
      return encrypted.base64;
    } catch (e) {
      throw Exception('Failed to encrypt request body: $e');
    }
  }

  /// 获取加密器
  encrypt.Encrypter _getEncrypter(String key) {
    if (_encryptMap.containsKey(key)) {
      return _encryptMap[key]!;
    }

    // 确保密钥长度为 32 字节
    String normalizedKey = key;
    if (normalizedKey.length < 32) {
      normalizedKey = normalizedKey.padRight(32, '0');
    } else if (normalizedKey.length > 32) {
      normalizedKey = normalizedKey.substring(0, 32);
    }

    final keyData = encrypt.Key.fromUtf8(normalizedKey);
    final encrypter = encrypt.Encrypter(encrypt.AES(keyData, mode: encrypt.AESMode.ecb));
    _encryptMap[key] = encrypter;
    
    return encrypter;
  }
}
