import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:encrypt/encrypt.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:dio/dio.dart';
import 'dart:ui' as ui;

import '../storage/local_storage.dart';
import '../network/dio_client.dart';
import '../constants/api_constants.dart';
import '../../../env/app_env.dart';
import '../../../interface.dart';
import '../services/auth_service.dart';

/// 加密服务
/// 管理接口加解密相关功能，使用 AES-ECB 模式
class EncryptService extends GetxService {
  late LocalStorage _storage;
  late DioClient _dioClient;

  // 加密密钥
  String? _encryptKey;

  String? get encryptKey => _encryptKey;

  // 加密器缓存（相同 key 复用）
  final Map<String, Encrypter> _encryptMap = {};

  @override
  void onInit() {
    super.onInit();
    _storage = Get.find<LocalStorage>();
    _dioClient = Get.find<DioClient>();
    _loadEncryptKey();
  }

  void _loadEncryptKey() {
    _encryptKey = _storage.getString('encrypt_key');
  }

  /// 获取应用配置（包含加密密钥）
  /// 支持 k2/k3/k4 三层解密
  Future<bool> getAppConfig() async {
    try {
      print('getAppConfig: 开始获取应用配置...');
      // 使用默认密钥或从 hostApi 生成（首次调用时可能还没有 encryptKey）
      final defaultKey = _getDefaultKeyForAppConfig();
      print('getAppConfig: 使用默认密钥: ${defaultKey.substring(0, 8)}...');

      // 构建请求体（包含 http_headers）
      final headers = await _buildHeaders();
      final requestBody = {
        'http_headers': _headerValueSureString(headers),
        'ver': '0',
      };

      // 加密请求体
      final encryptedBody = encryptionBody(
        jsonEncode(requestBody),
        defaultKey,
        isAppConfig: true,
        path: ApiConstants.getAppConfig,
      );
      print('getAppConfig: 请求体已加密，长度: ${encryptedBody.length}');

      // 发送请求（响应是加密的 Base64 字符串，需要设置为 plain）
      print('getAppConfig: 发送请求到 ${ApiConstants.getAppConfig}');
      final response = await _dioClient.post(
        ApiConstants.getAppConfig,
        data: encryptedBody,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          responseType: ResponseType.plain, // 接收原始字符串，不自动解析 JSON
        ),
      );
      print('getAppConfig: 收到响应，状态码: ${response.statusCode}');

      if (response.statusCode == ApiConstants.success) {
        // 响应是加密的 Base64 字符串
        String responseBody = '';
        if (response.data is String) {
          responseBody = response.data as String;
        } else {
          responseBody = response.data.toString();
        }

        if (responseBody.isEmpty) {
          return false;
        }

        // 解密响应（处理 k2/k3/k4）
        print('getAppConfig: 开始解密响应...');
        final decryptedData = handleConfigBody(responseBody, defaultKey);
        print('getAppConfig: 响应解密成功');

        // 提取 encrypt_key
        final payload = decryptedData['data'];
        if (payload is Map && payload.containsKey('items')) {
          final items = payload['items'];
          if (items is List) {
            print('getAppConfig: 找到 ${items.length} 个配置项');
            for (var item in items) {
              if (item is Map && item['name'] == 'encrypt_key') {
                _encryptKey = item['data']?.toString();
                if (_encryptKey != null && _encryptKey!.isNotEmpty) {
                  await _storage.setString('encrypt_key', _encryptKey!);
                  print('getAppConfig: 成功提取并保存 encrypt_key');
                  return true;
                }
              }
            }
          }
        }
        print('getAppConfig: 未找到 encrypt_key');
      } else {
        print('getAppConfig: 响应状态码不是 200: ${response.statusCode}');
      }

      return false;
    } catch (e) {
      print('getAppConfig: 获取应用配置失败: $e');
      return false;
    }
  }

  /// 获取 getAppConfig 接口的默认密钥（从 hostApi 生成）
  String _getDefaultKeyForAppConfig() {
    final hostApi = AppEnv().hostApi;
    if (hostApi.isEmpty) return '00000000000000000000000000000000';

    // 移除 URL 前缀
    String newKey = hostApi.replaceAll(RegExp(r'^https?://'), '');
    newKey = newKey.replaceAll(RegExp(r'^www\.'), '');

    // 调整长度到 32 字节
    if (newKey.length < 32) {
      newKey = newKey.padRight(32, '0');
    } else if (newKey.length > 32) {
      newKey = newKey.substring(0, 32);
    }

    return newKey;
  }

  /// 构建请求头（用于加密）
  Future<Map<String, dynamic>> _buildHeaders() async {
    try {
      final pInfo = await PackageInfo.fromPlatform();
      final deviceInfo = DeviceInfoPlugin();
      final locale = ui.PlatformDispatcher.instance.locale;
      final i = Interface();

      String platform = 'unknown';
      String platformVer = '';
      String model = '';

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

      // 获取 device-id：优先从 Interface，否则从 flutter_udid
      String deviceId = i.deviceId ?? '';
      if (deviceId.isEmpty) {
        try {
          deviceId = await FlutterUdid.udid;
          i.deviceId = deviceId;
        } catch (_) {}
      }

      final authService = Get.find<AuthService>();
      final token = authService.token;

      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
        'Accept': 'application/plain',
        'ver': pInfo.version,
        'pkg': pInfo.packageName,
        'platform': platform,
        'platform_ver': platformVer,
        'device-id': deviceId,
        'model': model,
        'lang': locale.languageCode,
        'sys_lan': locale.languageCode,
        'device_lang': locale.languageCode,
        'device_country': locale.countryCode ?? '',
        'is_anchor': 'false',
        'utm-source': '',
        'utm-sec_ver': '0',
        'timestamp': '${DateTime.now().millisecondsSinceEpoch}',
      };

      if (token != null && token.isNotEmpty) {
        // 注意：Bearer 与 token 之间必须有空格，否则服务端可能无法识别导致 401
        headers['Authorization'] = 'Bearer $token';
      }

      return headers;
    } catch (e) {
      // 降级：返回基础请求头
      return {
        'Content-Type': 'application/json',
        'Accept': 'application/plain',
        'timestamp': '${DateTime.now().millisecondsSinceEpoch}',
      };
    }
  }

  /// 将请求头转为字符串类型（用于加密）
  Map<String, String> _headerValueSureString(Map<String, dynamic> head) {
    final Map<String, String> newHead = {};
    head.forEach((key, val) {
      newHead[key] = val.toString();
    });
    return newHead;
  }

  /// 加密请求体
  /// [data] JSON 字符串
  /// [eKey] 加密密钥
  /// [isAppConfig] 是否为配置接口
  /// [path] 接口路径（用于调试）
  String encryptionBody(
    String data,
    String eKey, {
    bool isAppConfig = false,
    String path = '',
  }) {
    if (eKey.isEmpty) return '';

    try {
      final encrypt = _getEncrypt(eKey);
      final encrypted = encrypt.encrypt(data);
      return encrypted.base64;
    } catch (e) {
      print('加密失败: $e');
      return '';
    }
  }

  /// 解密响应体
  String decryptBody(String data, String dKey) {
    try {
      final fData = data.trim().replaceAll(RegExp(r'\s'), '');
      return _getEncrypt(dKey).decrypt64(fData);
    } catch (e) {
      print('解密失败: $e');
      rethrow;
    }
  }

  /// 获取或创建 AES 加密器（带缓存）
  Encrypter _getEncrypt(String key) {
    if (!_encryptMap.containsKey(key)) {
      final keyData = Key.fromUtf8(key);
      _encryptMap[key] = Encrypter(AES(keyData, mode: AESMode.ecb));
    }
    return _encryptMap[key]!;
  }

  /// 处理配置接口响应（k2/k3/k4 三层解密）
  Map<String, dynamic> handleConfigBody(String data, String eKey) {
    try {
      // 第一层解密
      final cData = jsonDecode(decryptBody(data, eKey)) as Map<String, dynamic>;

      // 解析特殊配置数据（k2/k3/k4）
      parseData(cData);

      return cData;
    } catch (e) {
      // 降级：尝试直接解析 JSON
      try {
        final map = jsonDecode(data) as Map<String, dynamic>?;
        if (map != null) {
          parseData(map);
          return map;
        }
      } catch (_) {}
      rethrow;
    }
  }

  /// 解析并处理特殊配置数据（k2/k3/k4）
  void parseData(dynamic cData) {
    final rData = cData is Map ? cData['data'] : null;

    if (rData is Map &&
        rData['k2'] != null &&
        rData['k3'] != null &&
        rData['k4'] != null) {
      cData['data'] = _configBody(rData);
    }
  }

  /// k2/k3/k4 三层解密
  Map<String, dynamic> _configBody(Map rData) {
    final key2Data = rData['k2']?.toString() ?? '';
    final key3Data = rData['k3']?.toString() ?? '';
    final key4Data = rData['k4']?.toString() ?? '';

    // Base64 解码 k2
    Uint8List decodedBytes = base64Decode(key2Data);
    String key2 = utf8.decode(decodedBytes);

    // Base64 解码 k3
    decodedBytes = base64Decode(key3Data);
    String key3 = utf8.decode(decodedBytes);

    // Base64 解码 k4
    decodedBytes = base64Decode(key4Data);
    String key4 = utf8.decode(decodedBytes);

    // 使用 key2 + key3 解密 k4
    final res4 =
        jsonDecode(decryptBody(key4, '$key2$key3')) as Map<String, dynamic>;

    return res4;
  }

  /// 加密业务数据（用于普通接口）
  /// [data] 业务参数 Map
  /// [headers] 请求头 Map（可选，会自动构建）
  Future<String> encodeData(
    Map<String, dynamic> data, {
    Map<String, dynamic>? headers,
  }) async {
    if (_encryptKey == null || _encryptKey!.isEmpty) {
      return jsonEncode(data);
    }

    try {
      final headersToUse = headers ?? await _buildHeaders();
      final combinedData = {
        'http_headers': _headerValueSureString(headersToUse),
        ...data,
      };

      final jsonString = jsonEncode(combinedData);
      return encryptionBody(jsonString, _encryptKey!);
    } catch (e) {
      throw Exception('Data encoding failed: $e');
    }
  }

  /// 解密响应数据（用于普通接口）
  Map<String, dynamic> decodeData(String encodedData) {
    if (_encryptKey == null || _encryptKey!.isEmpty) {
      return jsonDecode(encodedData);
    }

    try {
      final decrypted = decryptBody(encodedData, _encryptKey!);
      return jsonDecode(decrypted) as Map<String, dynamic>;
    } catch (e) {
      // 降级：尝试直接解析 JSON
      try {
        return jsonDecode(encodedData) as Map<String, dynamic>;
      } catch (_) {
        throw Exception('Data decoding failed: $e');
      }
    }
  }

  /// 检查是否需要重新获取配置
  bool needRefreshConfig() {
    return _encryptKey == null || _encryptKey!.isEmpty;
  }

  /// 清除加密配置（用于登出时）
  void clearEncryptConfig() {
    _encryptKey = null;
    _storage.remove('encrypt_key');
    _encryptMap.clear();
  }
}
