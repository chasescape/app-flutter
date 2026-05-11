import 'dart:convert';
import 'dart:io';

import 'package:curl_logger_dio_interceptor/curl_logger_dio_interceptor.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart' as dio;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:paech/interface.dart';

import '../../interface.dart';

/// 金币服务：处理商品列表和充值订单
class CoinService {
  final dio.Dio _dio;
  final Map<String, encrypt.Encrypter> _encryptMap = {};

  CoinService(this._dio) {
    if (!_dio.interceptors.any((i) => i is CurlLoggerDioInterceptor)) {
      _dio.interceptors.add(CurlLoggerDioInterceptor(printOnSuccess: true));
    }
  }

  /// 获取商品列表
  /// 接口：/coin/goods/search -> api_prod/res/doc_minimum_int/set
  /// 参数：
  /// - isIncludeSubscription: 是否包含订阅商品
  /// - payChannel: 支付通道（IAP-苹果内购 GP-谷歌支付）
  Future<List<Map<String, dynamic>>> getGoodsList({
    bool? isIncludeSubscription,
    String? payChannel,
  }) async {
    final i = Combing154AwesomeInterface();
    if (i.encryptKey == null || i.encryptKey!.isEmpty) {
      throw Exception('encryptKey 为空，请先调用 getAppConfig 获取加密密钥');
    }

    // 构建请求体
    final headers = await _buildHeaders();
    final body = <String, dynamic>{
      'http_headers': headers,
    };
    
    // 添加可选参数
    if (isIncludeSubscription != null) {
      body['isIncludeSubscription'] = isIncludeSubscription;
    }
    if (payChannel != null && payChannel.isNotEmpty) {
      body['payChannel'] = payChannel;
    }

    // 请求加密
    final encryptedBody = _encryptRequestBody(body);

    // 发送 POST
    final response = await _dio.post(
      '/api_prod/res/doc_minimum_int/set',
      data: encryptedBody,
      options: dio.Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        responseType: dio.ResponseType.plain,
      ),
    );

    // 响应解密
    if (response.data is! String) {
      throw Exception('Unexpected response type: ${response.data.runtimeType}');
    }
    final responseStr = response.data as String;
    final decrypted = _decryptResponse(responseStr);

    // 业务码检查
    final code = decrypted['code'];
    final msg = decrypted['msg'] as String?;
    final key = decrypted['key'] as String?;

    if (code != null && code != 0) {
      final errorMsg = msg ?? key ?? 'Failed to get goods list';
      throw Exception('Get goods list failed: $errorMsg (code: $code)');
    }

    // 提取商品列表（data 直接是数组）
    final data = decrypted['data'];
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }

    return [];
  }

  /// 创建充值订单
  /// 接口：/coin/recharge/create -> api_prod/v1/gift_top_string/download
  /// 参数：
  /// - email: 如果是CC就要传
  /// - entry: 入口来源
  /// - goodsCode: 商品编号
  /// - payChannel: 渠道编码 如 LP SP
  /// - source: invitationId
  Future<Map<String, dynamic>> createRechargeOrder({
    required String goodsCode,
    required String payChannel,
    String? email,
    String? entry,
    String? source,
  }) async {
    final i = Combing154AwesomeInterface();
    if (i.encryptKey == null || i.encryptKey!.isEmpty) {
      throw Exception('encryptKey empty');
    }

    // 构建请求体
    final headers = await _buildHeaders();
    final body = <String, dynamic>{
      'http_headers': headers,
      'goodsCode': goodsCode,
      'payChannel': payChannel,
    };
    
    // 添加可选参数
    if (email != null && email.isNotEmpty) {
      body['email'] = email;
    }
    if (entry != null && entry.isNotEmpty) {
      body['entry'] = entry;
    }
    if (source != null && source.isNotEmpty) {
      body['source'] = source;
    }

    // 请求加密
    final encryptedBody = _encryptRequestBody(body);

    // 发送 POST
    final response = await _dio.post(
      '/api_prod/v1/gift_top_string/download',
      data: encryptedBody,
      options: dio.Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        responseType: dio.ResponseType.plain,
      ),
    );

    // 响应解密
    if (response.data is! String) {
      throw Exception('Unexpected response type: ${response.data.runtimeType}');
    }
    final responseStr = response.data as String;
    final decrypted = _decryptResponse(responseStr);

    // 业务码检查
    final code = decrypted['code'];
    final msg = decrypted['msg'] as String?;
    final key = decrypted['key'] as String?;

    if (code != null && code != 0) {
      final errorMsg = msg ?? key ?? 'Failed to create recharge order';
      throw Exception('Create recharge order failed: $errorMsg (code: $code)');
    }

    // 返回订单数据（包含 requestUrl 等信息）
    final data = decrypted['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    
    // 如果 data 不是 Map，返回整个响应
    return decrypted;
  }

  /// 构建请求头
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

  /// 请求加密
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

  /// 响应解密
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
}
