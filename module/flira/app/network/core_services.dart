import 'package:dio/dio.dart' as dio;

import 'ai_service.dart';
import 'api/app_config_api.dart';
import 'api/auth_api.dart';
import 'core/app_env_config_adapter.dart';
import 'core/app_service_config.dart';

/// Network 服务统一入口
///
/// 负责复用 AppServiceConfig 和 Dio，按需懒加载各 API 服务。
class CoreServices {
  CoreServices._();

  static final CoreServices instance = CoreServices._();

  final AppEnvConfigAdapter _config = AppEnvConfigAdapter();
  dio.Dio? _dio;

  AppConfigApi? _appConfigApi;
  AuthApi? _authApi;
  AiService? _aiService;
  dio.Dio? _aiDio;

  AppServiceConfig get config => _config;

  dio.Dio get dioClient => _dio ??= _buildDio();

  AppConfigApi get appConfigApi =>
      _appConfigApi ??= AppConfigApi(dioClient, _config);

  AuthApi get authApi => _authApi ??= AuthApi(dioClient, _config);

  AiService get aiService => _aiService ??= AiService(_aiDio ?? dioClient);

  /// 可选：设置独立的 AI Dio（比如不同 baseUrl 和超时）
  void setAiDio(dio.Dio client) {
    _aiDio = client;
    _aiService = AiService(client);
  }

  /// 重置 Dio 与服务实例（用于切换环境后重建）
  void resetDio() {
    _dio = null;
    _appConfigApi = null;
    _authApi = null;
    _aiService = null;
    _aiDio = null;
  }

  dio.Dio _buildDio() {
    const timeout = Duration(seconds: 25);
    return dio.Dio(
      dio.BaseOptions(
        baseUrl: _config.hostApi,
        connectTimeout: timeout,
        receiveTimeout: timeout,
        sendTimeout: timeout,
      ),
    );
  }
}
