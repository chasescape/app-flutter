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

  /// 可选：持久化存储接口（如缓存 encryptKey / authToken）
  Future<void> saveString(String key, String value) async {}

  Future<String?> getString(String key) async {
    return null;
  }
}
