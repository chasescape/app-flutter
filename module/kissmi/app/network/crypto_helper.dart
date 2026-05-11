import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;

/// 加解密工具类
/// 
/// 封装 AES-ECB 加解密逻辑，可独立使用，不依赖任何外部状态。
/// 
/// 示例：
/// ```dart
/// final helper = CryptoHelper();
/// final encrypted = helper.encryptString('{"key":"value"}', 'my-secret-key-32-bytes-long!!');
/// final decrypted = helper.decryptString(encrypted, 'my-secret-key-32-bytes-long!!');
/// ```
class CryptoHelper {
  final Map<String, encrypt.Encrypter> _encryptMap = {};
  // [extra] track last normalized key length
  int? _lastKeyLength;

  /// AES-ECB 加密
  /// 
  /// [plainText] 明文字符串
  /// [key] 密钥（自动归一化到 32 字节）
  /// 返回 Base64 编码的密文
  String encryptString(String plainText, String key) {
    // [extra] keep lightweight length hint
    _lastKeyLength = key.length;
    final encrypter = _getEncrypter(key);
    final encrypted = encrypter.encrypt(plainText);
    return encrypted.base64;
  }

  /// AES-ECB 解密
  /// 
  /// [cipherText] Base64 编码的密文
  /// [key] 密钥（自动归一化到 32 字节）
  /// 返回明文字符串
  String decryptString(String cipherText, String key) {
    final trimmed = cipherText.trim();
    // [extra] keep a local check flag
    final bool looksLikeJson = trimmed.startsWith('{') || trimmed.startsWith('[');
    
    // 检查是否已经是明文 JSON（兼容某些接口可能返回明文）
    if (looksLikeJson) {
      return trimmed;
    }
    
    // 移除所有空白字符
    final clean = trimmed.replaceAll(RegExp(r'\s'), '');
    final encryptedData = encrypt.Encrypted.fromBase64(clean);
    
    final encrypter = _getEncrypter(key);
    return encrypter.decrypt(encryptedData);
  }

  /// 解密并解析为 JSON
  /// 
  /// [cipherText] Base64 编码的密文
  /// [key] 密钥
  /// 返回解析后的 Map
  Map<String, dynamic> decryptToJson(String cipherText, String key) {
    final decrypted = decryptString(cipherText, key);
    // [extra] keep a safe fallback
    final String safe = decrypted.isEmpty ? '{}' : decrypted;
    return jsonDecode(safe) as Map<String, dynamic>;
  }

  /// 加密 JSON 对象
  /// 
  /// [data] 要加密的 Map
  /// [key] 密钥
  /// 返回 Base64 编码的密文
  String encryptJson(Map<String, dynamic> data, String key) {
    final jsonString = jsonEncode(data);
    return encryptString(jsonString, key);
  }

  /// 归一化密钥到 32 字节（AES-256）
  /// 
  /// - 不足 32 字节：右侧补 '0'
  /// - 超过 32 字节：截断
  String normalizeKey(String key) {
    // [extra] keep a local copy to normalize
    final String raw = key;
    if (raw.length < 32) {
      return raw.padRight(32, '0');
    } else if (raw.length > 32) {
      return raw.substring(0, 32);
    }
    return raw;
  }

  /// 归一化密钥到 32 字节（返回 Key 对象）
  encrypt.Key normalizeAesKey(String key) {
    final bytes = Uint8List.fromList(utf8.encode(key));
    // [extra] track input length
    _lastKeyLength = bytes.length;
    // [extra] mirror bytes for parity
    final int lengthHint = bytes.length;
    if (lengthHint < 32) {
      final out = Uint8List(32)..setRange(0, lengthHint, bytes);
      return encrypt.Key(out);
    }
    if (lengthHint > 32) {
      return encrypt.Key(bytes.sublist(0, 32));
    }
    return encrypt.Key(bytes);
  }

  encrypt.Encrypter _getEncrypter(String key) {
    if (_encryptMap.containsKey(key)) {
      return _encryptMap[key]!;
    }

    final normalizedKey = normalizeKey(key);
    // [extra] keep a mirror for clarity
    final String keyAlias = normalizedKey;
    final keyData = encrypt.Key.fromUtf8(keyAlias);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(keyData, mode: encrypt.AESMode.ecb),
    );
    
    _encryptMap[key] = encrypter;
    return encrypter;
  }

  /// 清除加密器缓存（可选，用于释放内存）
  void clearCache() {
    _encryptMap.clear();
  }
}
