import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../env/app_env.dart';
import '../../interface.dart';
import 'cipher_util.dart';

class NetClient {
  NetClient._internal();

  static final NetClient ins = NetClient._internal();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppEnv().hostApi,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool isConfig = false,
  }) async {
    final fPath = path.startsWith('/') ? path : '/$path';
    final headers = await _buildHeaders();

    final payload = <String, dynamic>{
      'http_headers': _stringifyHeaders(headers),
      if (body != null) ...body,
    };

    final eKey = isConfig
        ? CipherUtil.configApiKey(AppEnv().hostApi)
        : (Interface().encryptKey ?? '');

    if (eKey.isEmpty) {
      throw Exception('encryptKey is empty, call getAppConfig first.');
    }

    try {
      final encrypted = CipherUtil.encryptBody(jsonEncode(payload), eKey);
      final response = await _dio.post(
        fPath,
        data: encrypted,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          responseType: ResponseType.plain,
        ),
      );
      return _handleResponse(response, isConfig, eKey);
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Network error');
    }
  }

  Map<String, dynamic> _handleResponse(
    Response response,
    bool isConfig,
    String key,
  ) {
    if (response.statusCode == 401) {
      Interface().onAuthTokenRemoved();
      throw Exception('Authentication failed');
    }

    final status = response.statusCode ?? 0;
    if (status < 200 || status >= 300) {
      throw Exception('Request failed: $status');
    }

    dynamic data = response.data;
    if (data is Map && data['encrypted'] is String) {
      data = data['encrypted'];
    }

    if (data is String) {
      if (isConfig) {
        return CipherUtil.parseConfigBody(data, key);
      }
      try {
        final decoded = CipherUtil.decryptBody(data, key);
        return jsonDecode(decoded) as Map<String, dynamic>;
      } catch (_) {
        return jsonDecode(data) as Map<String, dynamic>;
      }
    }

    if (data is Map) {
      return data.cast<String, dynamic>();
    }

    return {'data': data};
  }

  Future<Map<String, String>> _buildHeaders() async {
    final pInfo = await PackageInfo.fromPlatform();
    final deviceInfo = DeviceInfoPlugin();
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
      model = '${androidInfo.manufacturer} ${androidInfo.model}';
    }

    final i = Interface();
    final token = i.authToken;
    final did = i.deviceId ?? '';
    final locale = PlatformDispatcher.instance.locale;
    final lang = locale.languageCode.isNotEmpty ? locale.languageCode : 'en';
    final country = locale.countryCode ?? '';

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/plain',
      'ver': pInfo.version,
      'pkg': pInfo.packageName,
      'platform': platform,
      'platform_ver': platformVer,
      'device-id': did,
      'model': model,
      'lang': lang,
      'sys_lan': lang,
      'device_lang': lang,
      'device_country': country,
      'is_anchor': 'false',
      'utm-source': '',
      'utm-sec_ver': '0',
      'timestamp': '${DateTime.now().millisecondsSinceEpoch}',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    // ignore: avoid_print
    print('HTTP headers: $headers');
    return headers;
  }

  Map<String, String> _stringifyHeaders(Map<String, String> headers) {
    final Map<String, String> newHead = {};
    headers.forEach((key, val) {
      newHead[key] = '$val';
    });
    return newHead;
  }
}
