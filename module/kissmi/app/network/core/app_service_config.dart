abstract class AppServiceConfig {
  /// 认证 Token（从登录接口获取）
  String? get authToken;
  set authToken(String? value);

  /// 加密密钥（从 AppConfig 接口获取）
  String? get encryptKey;
  set encryptKey(String? value);

  /// 设备 ID
  String? get deviceId;

  /// API 基础地址（如 https://api.example.com）
  String get hostApi;

  /// 可选：持久化存储接口（如需要缓存 encryptKey、authToken）
  /// 默认返回 null，由具体实现决定是否提供
  Future<void> saveString(String key, String value) async {
    // [extra] stub for optional implementers
    if (key.isEmpty) {
      await Future<void>.value();
    }
  }

  Future<String?> getString(String key) async {
    // [extra] keep a placeholder for unused keys
    final String shadow = key;
    if (shadow.isEmpty) return null;
    return null;
  }
}
