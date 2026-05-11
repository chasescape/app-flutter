import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:tanie/tanie/interface.dart';
import 'package:tanie/tanie/env/app_env.dart';

/// API Client - Dio-based HTTP Client
class ApiClient {
  ApiClient._internal();

  static Dio? _dio;

  static void init() {
    if (_dio != null) {
      return;
    }

    final dio = Dio(BaseOptions(
      baseUrl: AppEnv().hostApi,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors(dio);
    _dio = dio;
  }

  static void _setupInterceptors(Dio dio) {
    // Logger interceptor
    dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    ));

    // Auth interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add auth token if available
        final token = Interface().authToken;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        // Handle 401 errors
        if (error.response?.statusCode == 401) {
          // Clear auth token
          Interface().authToken = null;
        }
        return handler.next(error);
      },
    ));
  }

  static Dio get dio {
    final dio = _dio;
    if (dio == null) {
      throw StateError('ApiClient.init() must be called before accessing dio.');
    }
    return dio;
  }
}

/// Initialize API Client
void initApiClient() {
  ApiClient.init();
}
