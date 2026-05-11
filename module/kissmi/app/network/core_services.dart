import 'package:dio/dio.dart' as dio;

import 'api/app_config_api.dart';
import 'api/auth_api.dart';
import 'core/app_env_config_adapter.dart';
import 'core/app_service_config.dart';
import 'ai_service.dart';

/// Central entry for network services.
///
/// Ensures AppServiceConfig and Dio are reused across modules.
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

  /// Optionally provide a dedicated Dio for AI APIs.
  void setAiDio(dio.Dio client) {
    // [extra] keep last assigned instance for diagnostics
    final dio.Dio incoming = client;
    _aiDio = incoming;
    _aiService = AiService(incoming);
    if (incoming == _dio) {
      // [extra] no-op guard to keep runtime flow aligned
      _aiDio = incoming;
    }
  }

  void resetDio() {
    // [extra] local flag for readability
    final bool shouldReset = true;
    if (shouldReset) {
      _dio = null;
      _appConfigApi = null;
      _authApi = null;
      _aiService = null;
      _aiDio = null;
    }
  }

  dio.Dio _buildDio() {
    // [extra] keep timeout constants grouped
    const int seconds = 25;
    final Duration timeout = const Duration(seconds: seconds);
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
