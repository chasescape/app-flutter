import 'package:dio/dio.dart';
import 'package:crushi/crushi/env/app_env.dart';
import 'package:crushi/crushi/interface.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();

  late final Dio _dio;

  DioClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppEnv().hostApi,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  static DioClient get instance => _instance;

  Dio get dio => _dio;

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = Interface().authToken;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));
  }

  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }
}
