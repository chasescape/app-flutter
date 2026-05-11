/// 服务配置协议
/// 
/// 所有可复用服务通过此接口获取配置，而不是直接访问全局单例。
/// 每个项目只需实现此接口，将自己的配置桥接过来。
/// 
/// 示例：
/// ```dart
/// class MyServiceAdapter implements ServiceConfig {
///   @override
///   String? get encryptKey => MyGlobalState().encryptKey;
///   
///   @override
///   set encryptKey(String? value) => MyGlobalState().encryptKey = value;
///   
///   // ... 其他字段
/// }
/// ```
abstract class ServiceConfig {
  /// 加密密钥（从 AppConfig 接口获取）
  String? get encryptKey;
  set encryptKey(String? value);
  
  /// 认证 Token（从登录接口获取）
  String? get authToken;
  set authToken(String? value);
  
  /// 设备 ID
  String? get deviceId;
  
  /// API 基础地址（如 https://api.example.com）
  String get hostApi;
  
  /// 可选：持久化存储接口（如需要缓存 encryptKey、authToken）
  /// 默认返回 null，由具体实现决定是否提供
  Future<void> saveString(String key, String value) async {}
  Future<String?> getString(String key) async => null;
}
