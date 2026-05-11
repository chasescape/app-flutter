import 'dart:io';

import 'package:curl_logger_dio_interceptor/curl_logger_dio_interceptor.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart' as dio;
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:ui';

import '../core/crypto_helper.dart';
import '../core/service_config.dart';

/// 金币服务（可复用版本）
///
/// 处理商品列表和充值订单接口。
///
/// 使用方式：
/// ```dart
/// final service = CoinService(dio, config);
/// final goods = await service.getGoodsList(payChannel: 'IAP');
/// final order = await service.createRechargeOrder(goodsCode: 'coin_100', payChannel: 'IAP');
/// ```
class CoinService {
  final dio.Dio _dio;
  final ServiceConfig _config;
  final CryptoHelper _crypto;

  // 缓存设备信息，避免重复获取
  Map<String, String>? _cachedDeviceHeaders;
  
  // 商品列表缓存（可选）
  List<Map<String, dynamic>>? _cachedGoodsList;
  DateTime? _cacheTime;
  static const _cacheDuration = Duration(minutes: 5);

  CoinService(this._dio, this._config, {CryptoHelper? crypto})
      : _crypto = crypto ?? CryptoHelper() {
    if (!_dio.interceptors.any((i) => i is CurlLoggerDioInterceptor)) {
      _dio.interceptors.add(CurlLoggerDioInterceptor(printOnSuccess: true));
    }
  }

  /// 清除缓存
  void clearCache() {
    _cachedGoodsList = null;
    _cacheTime = null;
    _cachedDeviceHeaders = null;
  }


  Future<List<Map<String, dynamic>>> getGoodsList({
    bool? isIncludeSubscription,
    String? payChannel,
    bool forceRefresh = false,
  }) async {
    // 检查缓存
    if (!forceRefresh && _cachedGoodsList != null && _cacheTime != null) {
      if (DateTime.now().difference(_cacheTime!) < _cacheDuration) {
        return _cachedGoodsList!;
      }
    }

    _validateEncryptKey();

    // 构建请求体
    final headers = await _getHeaders();
    final body = <String, dynamic>{
      'http_headers': headers,
      if (isIncludeSubscription != null) 'isIncludeSubscription': isIncludeSubscription,
      if (payChannel?.isNotEmpty ?? false) 'payChannel': payChannel,
    };

    // 发送加密请求并解密响应
    final decrypted = await _sendEncryptedRequest('/rpc_api/res/deviceinfo_maximum_result/delete', body);

    // 提取商品列表
    final data = decrypted['data'];
    final result = data is List ? data.cast<Map<String, dynamic>>() : <Map<String, dynamic>>[];
    
    // 更新缓存
    _cachedGoodsList = result;
    _cacheTime = DateTime.now();
    
    return result;
  }

  /// 创建充值订单
  /// 
  /// [goodsCode] 商品编号
  /// [payChannel] 渠道编码 如 LP SP
  /// [email] 如果是CC就要传
  /// [entry] 入口来源
  /// [source] invitationId
  Future<Map<String, dynamic>> createRechargeOrder({
    required String goodsCode,
    required String payChannel,
    String? email,
    String? entry,
    String? source,
  }) async {
    _validateEncryptKey();

    // 构建请求体
    final headers = await _getHeaders();
    final body = <String, dynamic>{
      'http_headers': headers,
      'goodsCode': goodsCode,
      'payChannel': payChannel,
      if (email?.isNotEmpty ?? false) 'email': email,
      if (entry?.isNotEmpty ?? false) 'entry': entry,
      if (source?.isNotEmpty ?? false) 'source': source,
    };

    // 发送加密请求并解密响应
    final decrypted = await _sendEncryptedRequest('/rpc_api/money_top_group/post', body);

    // 返回订单数据
    final data = decrypted['data'];
    return data is Map<String, dynamic> ? data : decrypted;
  }

  /// 验证加密密钥
  void _validateEncryptKey() {
    if (_config.encryptKey == null || _config.encryptKey!.isEmpty) {
      throw Exception('encryptKey 为空，请先调用 getAppConfig 获取加密密钥');
    }
  }

  /// 发送加密请求并解密响应（复用逻辑）
  Future<Map<String, dynamic>> _sendEncryptedRequest(
    String path,
    Map<String, dynamic> body,
  ) async {
    // 请求加密
    final encryptedBody = _crypto.encryptJson(body, _config.encryptKey!);

    // 发送 POST
    final response = await _dio.post(
      path,
      data: encryptedBody,
      options: _defaultOptions,
    );

    // 响应解密
    if (response.data is! String) {
      throw Exception('Unexpected response type: ${response.data.runtimeType}');
    }
    
    final decrypted = _crypto.decryptToJson(response.data as String, _config.encryptKey!);

    // 业务码检查
    _checkResponseCode(decrypted, path);

    return decrypted;
  }

  /// 检查响应业务码
  void _checkResponseCode(Map<String, dynamic> response, String path) {
    final code = response['code'];
    if (code != null && code != 0) {
      final msg = response['msg'] as String?;
      final key = response['key'] as String?;
      final errorMsg = msg ?? key ?? 'Request failed';
      throw Exception('$path failed: $errorMsg (code: $code)');
    }
  }

  /// 获取请求头（带缓存）
  Future<Map<String, String>> _getHeaders() async {
    // 获取缓存的设备信息
    _cachedDeviceHeaders ??= await _buildDeviceHeaders();

    // 动态部分：时间戳和 token
    final headers = Map<String, String>.from(_cachedDeviceHeaders!);
    headers['timestamp'] = '${DateTime.now().millisecondsSinceEpoch}';
    
    if ((_config.authToken?.isNotEmpty ?? false) &&
        _config.authToken != (_config.deviceId ?? '')) {
      headers['Authorization'] = 'Bearer ${_config.authToken}';
    }
    
    return headers;
  }

  /// 构建设备相关请求头（仅执行一次）
  Future<Map<String, String>> _buildDeviceHeaders() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final deviceInfo = DeviceInfoPlugin();

    String platform = 'iOS';
    String platformVer = '';
    String model = '';

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
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

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/plain',
      'ver': packageInfo.version,
      'pkg': packageInfo.packageName,
      'platform': platform,
      'platform_ver': platformVer,
      'device-id': _config.deviceId ?? '',
      'model': model,
      'lang': lang,
      'sys_lan': lang,
      'device_lang': lang,
      'device_country': country,
      'is_anchor': 'false',
      'utm-source': '',
      'utm-sec_ver': '0',
    };
  }

  /// 默认请求配置（复用）
  static final _defaultOptions = dio.Options(
    headers: {
      'Content-Type': 'application/json',
    },
    responseType: dio.ResponseType.plain,
  );
}
