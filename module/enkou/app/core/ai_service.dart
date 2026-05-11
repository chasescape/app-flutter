import 'dart:convert';

import 'package:dio/dio.dart' as dio;

/// AI 接口服务（可复用版本）
///
/// 仅负责调用 AI HTTP 接口并返回结果，不依赖 GetX / UI / 本地存储。
class AiService {
  final dio.Dio _dio;

  AiService(this._dio);

  /// 调用图生图编辑接口，返回图片 URL 或 base64 内容
  ///
  /// 具体 Prompt 由上层拼好传入，这样方便各个项目自定义。
  Future<String> generateEditedImage({
    required String imagePath,
    required String prompt,
    String model = 'flux-kontext-pro',
    String responseFormat = 'url',
  }) async {
    final formData = dio.FormData.fromMap({
      'image': await dio.MultipartFile.fromFile(
        imagePath,
        filename: 'image.jpg',
      ),
      'model': model,
      'prompt': prompt,
      'n': '1',
      'size': '1024x1024',
      'response_format': responseFormat,
    });

    final response = await _dio.post(
      '/v1/images/edits',
      data: formData,
      options: dio.Options(
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    if (response.statusCode != 200) {
      throw dio.DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: dio.DioExceptionType.badResponse,
        message: 'AI image API failed with status code ${response.statusCode}',
      );
    }

    var data = response.data;
    if (data is String) {
      data = jsonDecode(data);
    }

    if (data is Map &&
        data['data'] is List &&
        (data['data'] as List).isNotEmpty) {
      final url = (data['data'] as List)[0]['url'];
      if (url is String && url.isNotEmpty) {
        return url;
      }
    }

    throw Exception('Invalid AI image response format');
  }

  /// 生成 Story 文案（纯文本对话，不带图片）
  ///
  /// 传入已经拼好的 Prompt 和模型名。
  Future<String> generateStory({
    required String prompt,
    required String model,
    double temperature = 0.7,
    int maxTokens = 200,
  }) async {
    final response = await _dio.post(
      '/v1/chat/completions',
      data: {
        'model': model,
        'messages': [
          {
            'role': 'user',
            'content': prompt,
          }
        ],
        'temperature': temperature,
        'max_tokens': maxTokens,
      },
      options: dio.Options(
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    if (response.statusCode != 200) {
      throw dio.DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: dio.DioExceptionType.badResponse,
        message: 'AI story API failed with status code ${response.statusCode}',
      );
    }

    var data = response.data;
    if (data is String) {
      data = jsonDecode(data);
    }

    if (data is Map &&
        data['choices'] is List &&
        (data['choices'] as List).isNotEmpty) {
      final choice = (data['choices'] as List)[0];
      if (choice is Map &&
          choice['message'] is Map &&
          (choice['message'] as Map)['content'] != null) {
        return (choice['message'] as Map)['content'].toString().trim();
      }
    }

    throw Exception('Invalid AI story response format');
  }

  /// 图生文：基于图片 + Prompt 生成结构化文本（如故事、装备分析等）
  ///
  /// - base64Image: JPEG 图片的 Base64 字符串（不含前缀）
  /// - prompt: 上层拼好的业务 Prompt（包含返回格式约束）
  ///
  /// 返回值为模型返回的 content 字符串，上层可以按需再做 JSON 解析。
  Future<String> generateVisionStory({
    required String base64Image,
    required String prompt,
    String model = 'gpt-4o-2024-05-13',
    int maxTokens = 2000,
    double temperature = 0.8,
  }) async {
    final body = {
      'model': model,
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': prompt,
            },
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:image/jpeg;base64,$base64Image',
              },
            },
          ],
        },
      ],
      'max_tokens': maxTokens,
      'temperature': temperature,
    };

    final response = await _dio.post(
      '/v1/chat/completions',
      data: body,
      options: dio.Options(
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 120),
      ),
    );

    if (response.statusCode != 200) {
      throw dio.DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: dio.DioExceptionType.badResponse,
        message:
            'AI vision story API failed with status code ${response.statusCode}',
      );
    }

    var data = response.data;
    if (data is String) {
      data = jsonDecode(data);
    }

    if (data is Map &&
        data['choices'] is List &&
        (data['choices'] as List).isNotEmpty) {
      final choice = (data['choices'] as List)[0];
      if (choice is Map &&
          choice['message'] is Map &&
          (choice['message'] as Map)['content'] != null) {
        return (choice['message'] as Map)['content'].toString().trim();
      }
    }

    throw Exception('Invalid AI vision story response format');
  }
}

