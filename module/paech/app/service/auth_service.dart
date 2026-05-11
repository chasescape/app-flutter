import 'dart:convert';
import 'dart:io';

import 'package:curl_logger_dio_interceptor/curl_logger_dio_interceptor.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart' as dio;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:paech/interface.dart';

import '../../interface.dart';

/// 登录服务：/security/oauth 使用 encryptKey 做请求加密、响应解密
class AuthService {
  final dio.Dio _dio;
  final Map<String, encrypt.Encrypter> _encryptMap = {};

  AuthService(this._dio) {
    if (!_dio.interceptors.any((i) => i is CurlLoggerDioInterceptor)) {
      _dio.interceptors.add(CurlLoggerDioInterceptor(printOnSuccess: true));
    }
  }

  /// 登录接口（与 login_flow.md 一致）
  /// - 设备 ID 由外层传入：signIn(deviceToken)，通常由 LoginLogic._getDeviceId() 提供
  /// - 必须先拿到 encryptKey（先调 getAppConfig），再调本接口
  /// - 请求：body 含 http_headers + oauthType + token，用 encryptKey 加密后 POST
  /// - 响应：服务端返回密文，先解密再 jsonDecode
  Future<Map<String, dynamic>> signIn(String deviceToken) async {
    final i = Combing154AwesomeInterface();
    if (i.encryptKey == null || i.encryptKey!.isEmpty) {
      throw Exception(
        'encryptKey 为空，请先调用 getAppConfig 获取加密密钥再登录',
      );
    }

    print('encryptKey: ${i.encryptKey}');

    // 1. 构建请求体（http_headers + 业务参数，与 login_flow Step 6.1 一致）
    final headers = await _buildHeaders();
    final body = <String, dynamic>{
      'http_headers': headers,
      'oauthType': 4,
      'token': deviceToken,
    };

    // 2. 请求加密：用 encryptKey 加密 body 再发
    final encryptedBody = _encryptRequestBody(body);

    // 3. 发送 POST（密文为 body，Content-Type: application/json）
    final response = await _dio.post(
      '/api_prod/resource/order_first_item/upsert',
      data: encryptedBody,
      options: dio.Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        responseType: dio.ResponseType.plain,
      ),
    );

    // 4. 响应解密：服务端返回密文，先解密再 jsonDecode
    if (response.data is! String) {
      throw Exception('Unexpected response type: ${response.data.runtimeType}');
    }
    final responseStr = response.data as String;
    final decrypted = _decryptResponse(responseStr);

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

    // 兼容两种返回：token 在顶层 或 在 data 里，合并后外层可直接用 loginResult['token'] / ['userInfo'] / ['isFirstRegister']
    final data = decrypted['data'];
    if (data is Map<String, dynamic>) {
      return <String, dynamic>{...decrypted, ...data};
    }
    return decrypted;
  }

  /// 构建请求头（与 appconfig 同结构，供加密时放入 http_headers）
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
    if (i.authToken != null && i.authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer${i.authToken}';
    }
    return headers;
  }

  /// 请求加密：用 encryptKey 把 body（含 http_headers）加密为 Base64 密文
  String _encryptRequestBody(Map<String, dynamic> body) {
    final eKey = Combing154AwesomeInterface().encryptKey!;
    if (eKey.isEmpty) {
      throw Exception('encryptKey is empty');
    }
    final encrypter = _getEncrypter(eKey);
    final jsonString = jsonEncode(body);
    final encrypted = encrypter.encrypt(jsonString);
    return encrypted.base64;
  }

  /// 响应解密：密文 Base64 字符串 → AES-ECB 解密 → JSON
  Map<String, dynamic> _decryptResponse(String responseData) {
    final dKey = Combing154AwesomeInterface().encryptKey ?? '';
    if (dKey.isEmpty) {
      throw Exception('encryptKey is empty, cannot decrypt response');
    }

    final trimmed = responseData.trim();
    if (trimmed.isEmpty) {
      throw Exception('Empty response data');
    }
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      try {
        return jsonDecode(trimmed) as Map<String, dynamic>;
      } catch (_) {}
    }
    final clean = trimmed.replaceAll(RegExp(r'\s'), '');
    final encrypted = encrypt.Encrypted.fromBase64(clean);
    final encrypter = _getEncrypter(dKey);
    final decrypted = encrypter.decrypt(encrypted);
    return jsonDecode(decrypted) as Map<String, dynamic>;
  }

  encrypt.Encrypter _getEncrypter(String key) {
    if (_encryptMap.containsKey(key)) {
      return _encryptMap[key]!;
    }
    String n = key;
    if (n.length < 32) {
      n = n.padRight(32, '0');
    } else if (n.length > 32) {
      n = n.substring(0, 32);
    }
    final k = encrypt.Key.fromUtf8(n);
    final enc = encrypt.Encrypter(encrypt.AES(k, mode: encrypt.AESMode.ecb));
    _encryptMap[key] = enc;
    return enc;
  }

  /// 退出登录接口
  /// - 返回 true 表示成功，false 表示失败
  Future<bool> logout() async {
    try {
      final headers = await _buildHeaders();
      final body = <String, dynamic>{
        'http_headers': headers,
      };
      final encryptedBody = _encryptRequestBody(body);


      final response = await _dio.post(
        '/api_prod/resource/frame_first_hash/download',
        data: encryptedBody,
        options: dio.Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          responseType: dio.ResponseType.plain,
        ),
      );
      // print('xxxxx response logout: $response');
      // 检查响应状态
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final code = data['code'];
          final success = data['success'] as bool?;
          return code == 0 || success == true;
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Logout API error: $e');
      // 即使 API 调用失败，也返回 true，让客户端继续清理本地数据
      return true;
    }
  }



  /// 退出登录接口
  /// - 返回 true 表示成功，false 表示失败
  Future<bool> deleteAccount() async {
    try {
      final headers = await _buildHeaders();
      final body = <String, dynamic>{
        'http_headers': headers,
      };
      final encryptedBody = _encryptRequestBody(body);

      final deleteApi = '/api_prod/v3/dateinfo_maximum_rank/add';
      final response = await _dio.post(
        deleteApi,
        data: encryptedBody,
        options: dio.Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          responseType: dio.ResponseType.plain,
        ),
      );



      print('xxxxx response deleteAccount: ${response.statusCode}');
      // 检查响应状态
      if (response.statusCode == 200) {
        // 4. 响应解密：服务端返回密文，先解密再 jsonDecode
        if (response.data is! String) {
          throw Exception('Unexpected response type: ${response.data.runtimeType}');
        }
        final responseStr = response.data as String;
        final data = _decryptResponse(responseStr);
        print('xxxxx response deleteAccount: $data');
        // 5. 业务码与数据提取
        // final code = decrypted['code'];
        // final success = decrypted['success'] as bool?;
        // final fail = decrypted['fail'] as bool?;
        // final msg = decrypted['msg'] as String?;
        // final key = decrypted['key'] as String?;
        //
        // final data = response.data;
        final code = data['code'];
        final success = data['success'] as bool?;
        return code == 0 || success == true;
              return true;
      }
      return false;
    } catch (e) {
      print('Logout API error: $e');
      // 即使 API 调用失败，也返回 true，让客户端继续清理本地数据
      return true;
    }
  }


}
