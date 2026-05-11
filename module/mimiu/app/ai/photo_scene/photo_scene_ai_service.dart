import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;

import '../ai_request_config.dart';
import 'photo_scene_models.dart';

class PhotoSceneAiException implements Exception {
  PhotoSceneAiException(this.message, {this.statusCode, this.responseBody});

  final String message;
  final int? statusCode;
  final String? responseBody;

  @override
  String toString() => 'PhotoSceneAiException: $message';
}

class PhotoSceneAiService {
  PhotoSceneAiService({
    Dio? dio,
    String? apiKey,
    String? baseUrl,
    String? model,
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? AiRequestConfig.baseUrl,
                connectTimeout:
                    const Duration(seconds: AiRequestConfig.timeoutSeconds),
                receiveTimeout:
                    const Duration(seconds: AiRequestConfig.timeoutSeconds),
                sendTimeout:
                    const Duration(seconds: AiRequestConfig.timeoutSeconds),
              ),
            ),
        _apiKey = apiKey ?? _defaultApiKey,
        _model = model ?? AiRequestConfig.defaultModel;

  static const String _defaultApiKey = 'sk-QaaY8MM8WwiS9eLfC31f0fB08742448bA75b6a7f1b75E61a';

  final Dio _dio;
  final String _apiKey;
  final String _model;

  static const String _systemPrompt = '''
You are a strict image classifier for a photo organizing app.
Always respond in pure JSON (no Markdown, no extra text).
''';

  static const String _userPrompt = '''
Analyze the photo and classify it into ONE category:
- food
- landscape
- portrait
- pets
- other

Return JSON with:
{
  "category": "food|landscape|portrait|pets|other",
  "summary": "1 short English sentence describing what's in the photo"
}
''';

  Future<String> _readOptimizedImageBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return base64Encode(bytes);

      const maxSide = 1024;
      final w = decoded.width;
      final h = decoded.height;
      final shouldResize = w > maxSide || h > maxSide;
      final resized = shouldResize
          ? img.copyResize(
              decoded,
              width: w >= h ? maxSide : null,
              height: h > w ? maxSide : null,
              interpolation: img.Interpolation.average,
            )
          : decoded;

      final jpg = img.encodeJpg(resized, quality: 75);
      return base64Encode(jpg);
    } catch (_) {
      return base64Encode(bytes);
    }
  }

  Future<PhotoSceneAnalysis> analyzeImage(File imageFile) async {
    try {
      final base64Image = await _readOptimizedImageBase64(imageFile);

      final body = AiRequestConfig.buildRequestBody(
        imageBase64: base64Image,
        systemPrompt: _systemPrompt,
        userPrompt: _userPrompt,
        model: _model,
      );

      final resp = await _dio.post<Map<String, dynamic>>(
        AiRequestConfig.endpoint,
        data: jsonEncode(body),
        options: Options(headers: AiRequestConfig.buildHeaders(_apiKey)),
      );

      final data = resp.data;
      if (data == null) {
        throw PhotoSceneAiException('Empty response from AI.');
      }

      final content = AiRequestConfig.extractContent(data);
      if (content == null || content.trim().isEmpty) {
        throw PhotoSceneAiException('AI returned empty content.');
      }

      final cleaned = AiRequestConfig.cleanJsonResponse(content);
      final json = (jsonDecode(cleaned) as Map).cast<String, dynamic>();
      return PhotoSceneAnalysis.fromJson(json);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data?.toString();
      throw PhotoSceneAiException(
        'AI request failed.',
        statusCode: status,
        responseBody: body,
      );
    } on TimeoutException {
      throw PhotoSceneAiException('Request timed out.');
    } on SocketException {
      throw PhotoSceneAiException('Network connection failed.');
    } catch (e) {
      throw PhotoSceneAiException('Analyze failed: $e');
    }
  }
}
