import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../data/models/cherish_card.dart';
import '../interface.dart';

/// AI Analysis Exception
class AiAnalysisException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  AiAnalysisException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => 'AiAnalysisException: $message (statusCode: $statusCode)';
}

/// AI Analysis Service - CherishLens Image Analysis
/// Based on V-API documentation: https://api-gpt-ge.apifox.cn/215473722e0
class AiAnalysisService {
  AiAnalysisService._();

  static final AiAnalysisService _instance = AiAnalysisService._();
  factory AiAnalysisService() => _instance;

  static const String _apiKey = 'sk-qVDgJ0IYpJrp1sFBD1A555513501444eB6BcFe5758A28fCe';
  late final Dio _dio;
  static const Duration _timeout = Duration(seconds: 60);

  /// Initialize Dio client
  void init() {
    _dio = Dio(BaseOptions(
      connectTimeout: _timeout,
      receiveTimeout: _timeout,
      sendTimeout: _timeout,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('[AI Service] Request: ${options.method} ${options.uri}');
        print('[AI Service] Headers: ${options.headers}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('[AI Service] Response: ${response.statusCode}');
        return handler.next(response);
      },
      onError: (error, handler) {
        print('[AI Service] Error: ${error.message}');
        print('[AI Service] Error Type: ${error.type}');
        return handler.next(error);
      },
    ));
  }

  /// Analyze image and return CherishCard
  /// [imagePath] - Local file path to the image
  /// [assetImg] - Asset image path for display (from A.dart)
  Future<CherishCard> analyzeImage({
    required String imagePath,
    required String assetImg,
  }) async {
    if (_dio == null) init();

    // Validate image file exists
    final imageFile = File(imagePath);
    if (!await imageFile.exists()) {
      throw AiAnalysisException(
        message: 'Image file not found: $imagePath',
        statusCode: 404,
      );
    }

    // Read and encode image to base64
    final imageBytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);
    final mimeType = _getMimeType(imagePath);

    // Build request according to API documentation
    final requestData = {
      'model': 'gpt-4o',
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': _buildUserPrompt(),
            },
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:$mimeType;base64,$base64Image',
              },
            },
          ],
        },
      ],
      'max_tokens': 800,
    };

    try {
      final response = await _dio.post(
        'https://api.gpt.ge/v1/chat/completions',
        data: requestData,
      );

      // Parse response
      return _parseResponse(response.data, assetImg: assetImg);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw AiAnalysisException(
        message: 'Unexpected error: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Build user prompt from ai_analysis_prompt.md
  String _buildUserPrompt() {
    return '''Analyze this photo for CherishLens.

Allowed enums:
- time_atmosphere: ["Morning", "LateMorning", "Afternoon", "GoldenHour", "Twilight", "Evening", "Night", "Unknown"]
- scene_type: ["Indoor", "Outdoor", "Home", "Office", "Cafe", "Nature", "Street", "Window", "Balcony", "Unknown"]
- primary_subject: ["Coffee", "Tea", "Food", "Plant", "Book", "Sky", "Sunset", "Sunrise", "Pet", "Flower", "Workspace", "View", "Other", "Unknown"]
- mood_tone: ["Serenity", "Warmth", "Solitary", "Cozy", "Melancholic", "Vibrant", "Peaceful", "Quiet", "Unknown"]
- light_quality: ["Soft", "Harsh", "Natural", "Artificial", "Dim", "Warm", "Cool", "Unknown"]
- color_temperature: ["Warm", "Cool", "Neutral", "Mixed", "Unknown"]

Output schema (return ONLY JSON):
{
  "scene_card": {
    "time_atmosphere": {"value": "...", "confidence": 0.0, "evidence": "..."},
    "scene_type": {"value": "...", "confidence": 0.0, "evidence": "..."},
    "primary_subject": {"value": "...", "confidence": 0.0, "evidence": "..."},
    "mood_tone": {"value": "...", "confidence": 0.0, "evidence": "..."},
    "light_quality": {"value": "...", "confidence": 0.0, "evidence": "..."},
    "color_temperature": {"value": "...", "confidence": 0.0, "evidence": "..."}
  },
  "visual_poetry": {
    "short_healing_text": "... (150-200 chars, warm & poetic)",
    "daily_affirmation": "... (60-120 chars, 1 sentence)",
    "cherish_tags": ["...", "...", "..."]
  },
  "meta": {
    "one_line_moment": "...",
    "safety": {"has_sensitive_content": false, "notes": ""}
  }
}''';
  }

  /// Parse API response and create CherishCard
  CherishCard _parseResponse(dynamic responseData, {required String assetImg}) {
    try {
      if (responseData == null) {
        throw AiAnalysisException(message: 'Empty response from API');
      }

      final choices = responseData['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        throw AiAnalysisException(message: 'No choices in response');
      }

      final firstChoice = choices[0];
      final message = firstChoice['message'];
      final content = message['content'] as String?;

      if (content == null || content.isEmpty) {
        throw AiAnalysisException(message: 'Empty content in response');
      }

      // Clean JSON response (remove markdown code blocks if present)
      final cleanedContent = _cleanJsonResponse(content);

      // Parse JSON
      final jsonData = jsonDecode(cleanedContent) as Map<String, dynamic>;

      return CherishCard.fromJson(jsonData, assetImg: assetImg);
    } on FormatException catch (e) {
      throw AiAnalysisException(
        message: 'Failed to parse JSON response: ${e.message}',
        originalError: e,
      );
    } catch (e) {
      throw AiAnalysisException(
        message: 'Failed to parse response: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Clean JSON response by removing markdown code blocks
  String _cleanJsonResponse(String content) {
    String cleaned = content.trim();

    // Remove ```json and ``` markers
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }

    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }

    return cleaned.trim();
  }

  /// Handle Dio errors and convert to AiAnalysisException
  AiAnalysisException _handleDioError(DioException error) {
    String message;
    int? statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Request timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        statusCode = error.response?.statusCode;
        message = 'API error: ${error.response?.statusMessage ?? "Unknown error"}';
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled';
        break;
      case DioExceptionType.unknown:
        message = 'Network error: ${error.message}';
        break;
      default:
        message = 'Unexpected error: ${error.message}';
    }

    return AiAnalysisException(
      message: message,
      statusCode: statusCode,
      originalError: error,
    );
  }

  /// Get MIME type from file path
  String _getMimeType(String path) {
    final extension = path.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  /// Dispose resources
  void dispose() {
    _dio.close(force: true);
  }
}
