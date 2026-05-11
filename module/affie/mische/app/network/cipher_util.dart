import 'dart:convert';

import 'package:encrypt/encrypt.dart';

class CipherUtil {
  static final Map<String, Encrypter> _cache = {};

  static String _normalizeKey(String key) {
    if (key.length < 32) {
      return key.padRight(32, '0');
    }
    if (key.length > 32) {
      return key.substring(0, 32);
    }
    return key;
  }

  static Encrypter _getEncrypter(String key) {
    final normalized = _normalizeKey(key);
    return _cache.putIfAbsent(
      normalized,
      () => Encrypter(AES(Key.fromUtf8(normalized), mode: AESMode.ecb)),
    );
  }

  static String encryptBody(String data, String key) {
    if (key.isEmpty) return '';
    final encrypted = _getEncrypter(key).encrypt(data);
    return encrypted.base64;
  }

  static String decryptBody(String data, String key) {
    final cleaned = data.toString().replaceAll(RegExp(r'\s+'), '');
    if (cleaned.startsWith('{') || cleaned.startsWith('[')) {
      return cleaned;
    }
    return _getEncrypter(key).decrypt64(cleaned);
  }

  static Map<String, dynamic> parseConfigBody(String data, String key) {
    final decoded = jsonDecode(decryptBody(data, key));
    _unpackConfigData(decoded);
    return (decoded as Map).cast<String, dynamic>();
  }

  static void _unpackConfigData(dynamic decoded) {
    final rData = (decoded is Map) ? decoded['data'] : null;
    if (rData is Map && rData['k2'] != null && rData['k3'] != null && rData['k4'] != null) {
      decoded['data'] = _decryptConfigPayload(rData);
    }
  }

  static dynamic _decryptConfigPayload(Map rData) {
    final key2 = utf8.decode(base64Decode('${rData['k2']}'));
    final key3 = utf8.decode(base64Decode('${rData['k3']}'));
    final key4 = utf8.decode(base64Decode('${rData['k4']}'));
    return jsonDecode(decryptBody(key4, '$key2$key3'));
  }

  static String configApiKey(String hostApi) {
    final raw = hostApi.replaceAll(RegExp(r'^https?://'), '');
    return _normalizeKey(raw);
  }
}
