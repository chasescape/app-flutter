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

  /// AES-ECB 加密
  /// 
  /// [plainText] 明文字符串
  /// [key] 密钥（自动归一化到 32 字节）
  /// 返回 Base64 编码的密文
  String encryptString(String plainText, String key) {
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
    
    // 检查是否已经是明文 JSON（兼容某些接口可能返回明文）
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
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
    return jsonDecode(decrypted) as Map<String, dynamic>;
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
    if (key.length < 32) {
      return key.padRight(32, '0');
    } else if (key.length > 32) {
      return key.substring(0, 32);
    }
    return key;
  }

  /// 归一化密钥到 32 字节（返回 Key 对象）
  encrypt.Key normalizeAesKey(String key) {
    final bytes = Uint8List.fromList(utf8.encode(key));
    if (bytes.length < 32) {
      final out = Uint8List(32)..setRange(0, bytes.length, bytes);
      return encrypt.Key(out);
    }
    if (bytes.length > 32) {
      return encrypt.Key(bytes.sublist(0, 32));
    }
    return encrypt.Key(bytes);
  }

  /// 获取或创建加密器（带缓存）
  encrypt.Encrypter _getEncrypter(String key) {
    if (_encryptMap.containsKey(key)) {
      return _encryptMap[key]!;
    }

    final normalizedKey = normalizeKey(key);
    final keyData = encrypt.Key.fromUtf8(normalizedKey);
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
