import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:cliss/cliss/data/models/meal_analysis.dart';
import 'package:cliss/cliss/env/app_env.dart';

class MealAnalysisException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  MealAnalysisException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() {
    if (statusCode != null) {
      return 'MealAnalysisException: $message (Status: $statusCode)';
    }
    return 'MealAnalysisException: $message';
  }
}

class MealAnalysisService {
  MealAnalysisService._();

  static late final MealAnalysisService _instance = MealAnalysisService._internal();
  static MealAnalysisService get instance => _instance;

  MealAnalysisService._internal();

  late final Dio _dio;
  static const String _baseUrl = 'https://api.gpt.ge';
  static const String _model = 'gpt-4o';
  static const Duration _timeout = Duration(seconds: 60);

  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: _timeout,
      receiveTimeout: _timeout,
      sendTimeout: _timeout,
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      request: false,
      requestHeader: false,
      requestBody: false,
      responseBody: false,
      responseHeader: false,
      error: true,
      logPrint: (obj) => print('[MealAnalysisService] $obj'),
    ));
  }

  String _buildMealAnalysisPrompt() {
    return '''
Analyze this meal photo for CalorieSnap Guide and output a comprehensive meal analysis JSON.

Allowed enums:
- meal_type: ["Breakfast", "Brunch", "Lunch", "Dinner", "Late Night Snack", "Unknown"]
- portion_size: ["Small", "Medium", "Large", "Extra Large", "Unknown"]
- oil_level: ["Low", "Medium", "High", "Unknown"]
- balance_tag: ["Balanced", "Carb Heavy", "Protein Focused", "Greasy", "High Sugar", "Unknown"]

Output schema (return ONLY JSON):
{
  "scene_card": {
    "meal_type": "...",
    "main_items": ["...", "...", "..."],
    "estimated_portion": "...",
    "oil_level": "...",
    "balance_tag": "...",
    "visual_description": "..."
  },
  "nutrition_analysis": {
    "calorie_estimate": {
      "min": 450,
      "max": 550,
      "unit": "kcal",
      "confidence": 0.85
    },
    "protein_note": "...",
    "carb_note": "...",
    "fat_note": "...",
    "overall_balance_summary": "..."
  },
  "next_meal_suggestion": {
    "meal_type": "...",
    "focus_area": "...",
    "recommendation_summary": "...",
    "food_suggestions": ["...", "...", "..."],
    "avoid_suggestions": ["...", "..."],
    "portion_tip": "..."
  },
  "next_breakfast_suggestion": {
    "main_option": {
      "name": "...",
      "description": "...",
      "prep_time": "...",
      "key_ingredients": ["...", "...", "..."]
    },
    "alternative_ingredients": ["...", "..."],
    "prep_tips": ["...", "..."],
    "why_recommended": "..."
  },
  "one_line_summary": "...",
  "tags": ["...", "...", "..."],
  "confidence": 0.85
}
''';
  }

  String _cleanJsonResponse(String response) {
    response = response.trim();

    final codeBlockPattern = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```');
    final match = codeBlockPattern.firstMatch(response);

    if (match != null) {
      response = match.group(1) ?? response;
    }

    response = response.replaceAll('\n', ' ').replaceAll('\r', ' ');
    response = response.replaceAll(RegExp(r'\s+'), ' ');

    return response.trim();
  }

  Future<String> _encodeImageToBase64(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw MealAnalysisException(message: 'Image file not found: $imagePath');
    }

    final bytes = await file.readAsBytes();
    final base64 = base64Encode(bytes);
    final mimeType = _getImageMimeType(imagePath);

    return 'data:$mimeType;base64,$base64';
  }

  String _getImageMimeType(String path) {
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

  Future<MealAnalysis> analyzeImage({
    required String imagePath,
    void Function(String)? onProgress,
    void Function()? onCancel,
  }) async {
    try {
      if (onProgress != null) {
        onProgress('Uploading image...');
      }

      final base64Image = await _encodeImageToBase64(imagePath);
      final apiKey = AppEnv().geApiKey;

      if (apiKey.isEmpty) {
        throw MealAnalysisException(
          message: 'API Key is not configured. Please check your app settings.',
        );
      }

      if (onProgress != null) {
        onProgress('Analyzing your food...');
      }

      final prompt = _buildMealAnalysisPrompt();

      final requestData = {
        'model': _model,
        'messages': [
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': prompt},
              {
                'type': 'image_url',
                'image_url': {'url': base64Image}
              }
            ]
          }
        ],
        'temperature': 0.7,
        'max_tokens': 2048,
      };

      final response = await _dio.post(
        '/v1/chat/completions',
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
          },
        ),
      );

      if (onProgress != null) {
        onProgress('Generating results...');
      }

      if (response.statusCode == 200) {
        final data = response.data;
        final content = data['choices']?[0]?['message']?['content'] as String?;

        if (content == null || content.isEmpty) {
          throw MealAnalysisException(
            message: 'Empty response from AI service',
            statusCode: response.statusCode,
          );
        }

        final cleanedJson = _cleanJsonResponse(content);
        final jsonResponse = jsonDecode(cleanedJson) as Map<String, dynamic>;

        final mealAnalysis = MealAnalysis.fromJson(jsonResponse);
        return mealAnalysis.copyWith(assetImg: imagePath);
      } else {
        throw MealAnalysisException(
          message: 'Unexpected response from server',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        if (onCancel != null) {
          onCancel();
        }
        throw MealAnalysisException(message: 'Analysis was cancelled');
      }

      String errorMessage;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please check your internet and try again.';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection. Please check your network.';
          break;
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          if (statusCode == 401) {
            errorMessage = 'Authentication failed. Please check your API key.';
          } else if (statusCode == 429) {
            errorMessage = 'Too many requests. Please try again later.';
          } else if (statusCode != null && statusCode >= 500) {
            errorMessage = 'Server error. Please try again later.';
          } else {
            errorMessage = 'Request failed with status $statusCode';
          }
          break;
        default:
          errorMessage = 'Network error occurred';
      }

      throw MealAnalysisException(
        message: errorMessage,
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    } on FormatException catch (e) {
      throw MealAnalysisException(
        message: 'Failed to parse AI response. Please try again.',
        originalError: e,
      );
    } catch (e) {
      throw MealAnalysisException(
        message: e.toString(),
        originalError: e,
      );
    }
  }

  void dispose() {
    _dio.close(force: true);
  }
}

extension on MealAnalysis {
  MealAnalysis copyWith({
    String? assetImg,
    String? createdAt,
    SceneCard? sceneCard,
    NutritionAnalysis? nutritionAnalysis,
    NextMealSuggestion? nextMealSuggestion,
    NextBreakfastSuggestion? nextBreakfastSuggestion,
    String? oneLineSummary,
    List<String>? tags,
    double? confidence,
  }) {
    return MealAnalysis(
      assetImg: assetImg ?? this.assetImg,
      createdAt: createdAt ?? this.createdAt,
      sceneCard: sceneCard ?? this.sceneCard,
      nutritionAnalysis: nutritionAnalysis ?? this.nutritionAnalysis,
      nextMealSuggestion: nextMealSuggestion ?? this.nextMealSuggestion,
      nextBreakfastSuggestion: nextBreakfastSuggestion ?? this.nextBreakfastSuggestion,
      oneLineSummary: oneLineSummary ?? this.oneLineSummary,
      tags: tags ?? this.tags,
      confidence: confidence ?? this.confidence,
    );
  }
}
