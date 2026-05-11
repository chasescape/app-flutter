import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../constants/api_constants.dart';
import '../../../env/app_env.dart';

/// Dio网络客户端
/// 封装Dio，提供统一的网络请求接口
class DioClient extends GetxService {
  late Dio _dio;
  Dio get dio => _dio;

  @override
  void onInit() {
    super.onInit();
    _initDio();
  }

  /// 初始化Dio配置
  void _initDio() {
    _dio = Dio();

    // 基础配置
    _dio.options = BaseOptions(
      baseUrl: AppEnv().hostApi, // 从环境配置获取API地址
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // 添加拦截器
    _dio.interceptors.add(_getAuthInterceptor());
    _dio.interceptors.add(_getLogInterceptor());
  }

  /// 认证拦截器
  Interceptor _getAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        // 添加认证token
        final authService = Get.find<AuthService>();
        if (authService.token != null && authService.token!.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer ${authService.token}';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // 处理401未授权错误
        if (error.response?.statusCode == ApiConstants.unauthorized) {
          // token过期，尝试刷新或跳转登录
        }
        handler.next(error);
      },
    );
  }

  /// 日志拦截器
  Interceptor _getLogInterceptor() {
    // 生产环境不添加日志拦截器
    if (!kDebugMode) {
      return InterceptorsWrapper(); // 空拦截器
    }
    
    return LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
      error: true,
      logPrint: (object) => print(object),
    );
  }

  // ==================== HTTP请求方法 ====================

  /// GET请求
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// POST请求
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// PUT请求
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// DELETE请求
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// 上传图片到 GPT Vision API 进行图生文分析（如极限运动设备佩戴安全检查）
  /// [imagePath] 本地图片路径；[prompt] 分析提示词，见 [AppConstants.equipmentSafetyCheckPrompt]
  Future<Response<T>> uploadImageForAnalysis<T>(
    String imagePath, {
    required String prompt,
    String? model,
    int? maxTokens,
    double? temperature,
  }) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(bytes);

      print('*** Request ***');
      print('uri: ${ApiConstants.gptChatCompletionsFullUrl}');
      print('Image size: ${bytes.length} bytes');
      print('Model: ${model ?? ApiConstants.gptModelVision}');

      final requestData = {
        'model': model ?? ApiConstants.gptModelVision,
        'messages': [
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': prompt},
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:image/jpeg;base64,$base64Image',
                },
              },
            ],
          },
        ],
        'max_tokens': maxTokens ?? ApiConstants.gptMaxTokens,
        'temperature': temperature ?? ApiConstants.gptTemperature,
      };

      print('*** Response ***');
      print('uri: ${ApiConstants.gptChatCompletionsFullUrl}');

      final response = await _dio.post<T>(
        ApiConstants.gptChatCompletionsFullUrl,
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${ApiConstants.gptApiKey}',
            'Content-Type': 'application/json',
          },
          // 增加GPT API的超时时间
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      print('Response Text:');
      print(response.data);
      print('');

      return response;
    } catch (e) {
      print('Error in uploadImageForAnalysis: $e');
      rethrow;
    }
  }

  // 如果你需要其他类型的文件上传，可以添加这个通用方法
  // /// 通用文件上传
  // Future<Response<T>> uploadFile<T>(...) async { ... }

  // 如果你不需要下载功能，可以删除这个方法
  // /// 下载文件
  // Future<Response> download(...) async { ... }
}