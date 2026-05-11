import 'dart:convert';
import 'package:dio/dio.dart' as dio;

/// AI 服务层
///
/// 包含：
/// - 图生图（images edits）
/// - 文案生成（chat completions）
/// - Vision（图+文）
class AiService {
  final dio.Dio _dio;

  AiService(this._dio);

  /// 通用 POST 请求（带简单重试）
  Future<dynamic> _postJson(
    String path, {
    dynamic data,
    Duration sendTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 60),
    int retry = 1,
  }) async {
    int attempt = 0;

    while (true) {
      try {
        final response = await _dio.post(
          path,
          data: data,
          options: dio.Options(
            sendTimeout: sendTimeout,
            receiveTimeout: receiveTimeout,
          ),
        );

        if (response.statusCode != 200) {
          throw Exception('API failed: ${response.statusCode}');
        }

        return _parseJson(response.data);
      } catch (_) {
        attempt++;
        if (attempt > retry) rethrow;
        await Future.delayed(const Duration(milliseconds: 800));
      }
    }
  }

  dynamic _parseJson(dynamic data) {
    if (data is String) return jsonDecode(data);
    return data;
  }

  String _extractContent(dynamic data) {
    if (data is Map &&
        data['choices'] is List &&
        (data['choices'] as List).isNotEmpty) {
      final choice = (data['choices'] as List).first;
      if (choice is Map &&
          choice['message'] is Map &&
          choice['message']['content'] != null) {
        return choice['message']['content'].toString().trim();
      }
    }
    throw Exception('Invalid AI response format');
  }

  /// 图生图
  Future<String> generateEditedImage({
    required String imagePath,
    required String prompt,
    String model = 'flux-kontext-pro',
    String size = '1024x1024',
  }) async {
    final formData = dio.FormData.fromMap({
      'image': await dio.MultipartFile.fromFile(imagePath, filename: 'image.jpg'),
      'model': model,
      'prompt': prompt,
      'n': '1',
      'size': size,
      'response_format': 'url',
    });

    final data = await _postJson(
      '/v1/images/edits',
      data: formData,
      sendTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      retry: 2,
    );

    if (data is Map && data['data'] is List && (data['data'] as List).isNotEmpty) {
      final first = (data['data'] as List).first;
      if (first is Map && first['url'] is String) {
        return first['url'];
      }
    }

    throw Exception('Invalid AI image response format');
  }

  /// 文本生成
  Future<String> generateStory({
    required String prompt,
    required String model,
    double temperature = 0.7,
    int maxTokens = 200,
  }) async {
    final data = await _postJson(
      '/v1/chat/completions',
      data: {
        'model': model,
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'temperature': temperature,
        'max_tokens': maxTokens,
      },
      retry: 2,
    );

    return _extractContent(data);
  }

  /// Vision（图 + 文）
  Future<String> generateVisionStory({
    required String base64Image,
    required String prompt,
    String model = 'gpt-4o-2024-05-13',
    int maxTokens = 2000,
    double temperature = 0.8,
  }) async {
    final data = await _postJson(
      '/v1/chat/completions',
      data: {
        'model': model,
        'messages': [
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': prompt},
              {
                'type': 'image_url',
                'image_url': {'url': 'data:image/jpeg;base64,$base64Image'}
              }
            ]
          }
        ],
        'max_tokens': maxTokens,
        'temperature': temperature,
      },
      sendTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 120),
      retry: 2,
    );

    return _extractContent(data);
  }
}
