import 'dart:convert';

import 'package:encrypt/encrypt.dart';

class EncryptUtil {
  static final Map<String, Encrypter> _encryptMap = {};

  static String _normalizeKey(String key) {
    if (key.length < 32) {
      return key.padRight(32, '0');
    } else if (key.length > 32) {
      return key.substring(0, 32);
    }
    return key;
  }

  static Encrypter _getEncrypt(String key) {
    final normalized = _normalizeKey(key);
    if (!_encryptMap.containsKey(normalized)) {
      final keyData = Key.fromUtf8(normalized);
      _encryptMap[normalized] = Encrypter(AES(keyData, mode: AESMode.ecb));
    }
    return _encryptMap[normalized]!;
  }

  /// AES-ECB + Base64
  static String encryptionBody(String data, String eKey) {
    if (eKey.isEmpty) return '';
    final encrypt = _getEncrypt(eKey);
    final encrypted = encrypt.encrypt(data);
    return encrypted.base64;
  }

  /// Base64 + AES-ECB 解密
  static String decryptBody(String data, String dKey) {
    final fData = data.toString().replaceAll(RegExp(r'\s+'), '');
    if (fData.startsWith('{') || fData.startsWith('[')) {
      return fData;
    }
    return _getEncrypt(dKey).decrypt64(fData);
  }

  /// config 接口返回体解析
  static Map<String, dynamic> handleConfigBody(String data, String eKey) {
    final cData = jsonDecode(decryptBody(data.toString(), eKey));
    _parseConfigData(cData);
    return (cData as Map).cast<String, dynamic>();
  }

  static void _parseConfigData(dynamic cData) {
    final rData = (cData is Map) ? cData['data'] : null;
    if (rData is Map &&
        rData['k2'] != null &&
        rData['k3'] != null &&
        rData['k4'] != null) {
      cData['data'] = _configBody(rData);
    }
  }

  /// k2/k3/k4 三层解密
  static dynamic _configBody(Map rData) {
    final key2Data = rData['k2'];
    final key3Data = rData['k3'];
    final key4Data = rData['k4'];

    var decodedBytes = base64Decode('$key2Data');
    final key2 = utf8.decode(decodedBytes);

    decodedBytes = base64Decode('$key3Data');
    final key3 = utf8.decode(decodedBytes);

    decodedBytes = base64Decode('$key4Data');
    final key4 = utf8.decode(decodedBytes);

    final res4 = jsonDecode(decryptBody(key4, '$key2$key3'));
    return res4;
  }

  /// 配置接口 key 生成
  static String getAppConfigApiKey(String hostApi) {
    String newKey = hostApi;
    newKey = newKey.replaceAll(RegExp(r'^https?://'), '');

    return _normalizeKey(newKey);
  }
}
