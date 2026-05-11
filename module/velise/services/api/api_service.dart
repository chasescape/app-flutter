import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';
import '../../env/app_env.dart';
import '../../core/theme/app_colors.dart';
import '../storage/storage_service.dart';

part 'api_service.g.dart';

/// API Service - Type-safe REST API with Retrofit
@RestApi(baseUrl: '')
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  // Auth endpoints
  @POST('/auth/login')
  Future<ApiResponse<JsonMap>> login(@Body() Map<String, dynamic> request);

  @POST('/auth/logout')
  Future<ApiResponse<JsonMap>> logout();

  // User endpoints
  @GET('/user/profile')
  Future<ApiResponse<JsonMap>> getProfile();

  @PUT('/user/profile')
  Future<ApiResponse<JsonMap>> updateProfile(@Body() Map<String, dynamic> data);

  @DELETE('/user/account')
  Future<ApiResponse<JsonMap>> deleteAccount();

  // Content endpoints
  @GET('/content/list')
  Future<ApiResponse<List<JsonMap>>> getContentList(@Query('page') int page);

  @GET('/content/{id}')
  Future<ApiResponse<JsonMap>> getContentDetail(@Path('id') String id);

  @POST('/content/create')
  Future<ApiResponse<JsonMap>> createContent(@Body() Map<String, dynamic> data);

  @DELETE('/content/{id}')
  Future<ApiResponse<JsonMap>> deleteContent(@Path('id') String id);

  // Coin endpoints
  @GET('/coin/balance')
  Future<ApiResponse<JsonMap>> getCoinBalance();

  @GET('/coin/packages')
  Future<ApiResponse<List<JsonMap>>> getCoinPackages();

  @POST('/coin/purchase')
  Future<ApiResponse<JsonMap>> purchaseCoin(@Body() Map<String, dynamic> data);
}

/// API Response Wrapper
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;

  ApiResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResponse(
      code: json['code'] as int,
      message: json['message'] as String,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) {
    return {
      'code': code,
      'message': message,
      'data': data != null ? toJsonT(data as T) : null,
    };
  }

  bool get isSuccess => code == 200;
}

/// Lightweight JSON object wrapper so Retrofit can deserialize map payloads.
class JsonMap extends MapView<String, dynamic> {
  JsonMap([Map<String, dynamic>? map]) : super(map ?? <String, dynamic>{});

  factory JsonMap.fromJson(Map<String, dynamic> json) {
    return JsonMap(Map<String, dynamic>.from(json));
  }

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(this);
}

/// Dio Configuration
class ApiConfig {
  ApiConfig._();

  static Dio createDio() {
    final config = AppEnv();
    final baseUrl = config.hostApi;

    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add interceptors
    dio.interceptors.addAll([
      AuthInterceptor(),
      LogInterceptor(),
      ErrorInterceptor(),
    ]);

    return dio;
  }
}

/// Auth Interceptor
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add auth token if available
    final storageService = StorageService.instance;
    storageService.getString(StorageKeys.authToken).then((token) {
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    });
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Handle unauthorized - clear token and navigate to login
      StorageService.instance.clear();
      Get.offAllNamed('/login');
    }
    handler.next(err);
  }
}

/// Log Interceptor
class LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('API Request: ${options.method} ${options.uri}');
    if (options.data != null) {
      print('Request Data: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('API Response: ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('API Error: ${err.message}');
    handler.next(err);
  }
}

/// Error Interceptor
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage = 'An error occurred';

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Connection timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        errorMessage = 'Server error: ${err.response?.statusCode}';
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request was cancelled';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'No internet connection';
        break;
      default:
        errorMessage = 'An unexpected error occurred';
    }

    // Show error snackbar
    if (Get.isSnackbarOpen != true) {
      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: AppColors.error,
        colorText: AppColors.textInverse,
      );
    }

    handler.next(err);
  }
}
