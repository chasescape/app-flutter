import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../env/app_env.dart';
import '../models/ingredient_analysis.dart';
import 'ai_request_config.dart';

class AiServiceException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  AiServiceException(this.message, {this.statusCode, this.responseBody});

  @override
  String toString() => 'AiServiceException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

abstract class AiService {
  static AiService? _instance;

  static AiService get instance {
    _instance ??= RealAiService._();
    return _instance!;
  }

  static void setInstance(AiService service) {
    _instance = service;
  }

  Future<IngredientAnalysis> analyzeImage(String imagePath);
  Future<IngredientAnalysis> analyzeText(String productName, String ingredientText);
}

class RealAiService implements AiService {
  static const String _model = AiRequestConfig.defaultModel;
  static const int _maxTokens = AiRequestConfig.defaultMaxTokens;
  static const double _temperature = AiRequestConfig.defaultTemperature;
  static const Duration _timeout = Duration(seconds: AiRequestConfig.timeoutSeconds);

  static const String _systemPrompt = '''
You are a skincare ingredient analysis expert.
Return only valid JSON.
Use the exact response schema requested by the user prompt.
Do not add markdown explanations outside the JSON payload.
''';

  static const String _imageUserPrompt = '''
Analyze the skincare product shown in the image.

Return a JSON object with this exact structure:
{
  "productName": "Product name identified from image",
  "summary": "2-3 sentence overall summary of the product",
  "ingredients": [
    {
      "name": "INCI ingredient name",
      "commonName": "Common name (e.g., Vitamin B3 for Niacinamide)",
      "category": "Category (Hydrating/Brightening/Exfoliating/Anti-aging/Soothing/Preservative/Fragrance/Base)",
      "safetyRating": 1,
      "description": "Brief 1-sentence description of what it does"
    }
  ],
  "categories": ["Category1 50%", "Category2 25%", "Category3 15%", "Category4 10%"],
  "warnings": [
    {
      "type": "Warning type (e.g., Sensitive Skin, Fragrance Alert, Pregnancy Caution)",
      "message": "Brief warning message",
      "relatedIngredients": ["ingredient1", "ingredient2"]
    }
  ]
}

Guidelines:
- List the top 10-15 ingredients in order of prominence when possible.
- Safety rating: 5 = Very Safe, 4 = Safe, 3 = Use with Caution, 2 = Potential Irritant, 1 = Avoid.
- Focus on ingredients with real skincare impact.
- Highlight potential allergens and acne triggers.
- Categories should sum to 100%.
''';

  final Dio _dio;

  RealAiService._() : _dio = Dio(
          BaseOptions(
            baseUrl: AiRequestConfig.baseUrl,
            connectTimeout: _timeout,
            receiveTimeout: _timeout,
            sendTimeout: _timeout,
          ),
        );

  @override
  Future<IngredientAnalysis> analyzeImage(String imagePath) async {
    try {
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        throw AiServiceException('Image file not found');
      }

      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);
      final requestData = AiRequestConfig.buildRequestBody(
        imageBase64: base64Image,
        systemPrompt: _systemPrompt,
        userPrompt: _imageUserPrompt,
        model: _model,
        maxTokens: _maxTokens,
        temperature: _temperature,
      );

      final response = await _dio.post<Map<String, dynamic>>(
        AiRequestConfig.endpoint,
        data: requestData,
        options: Options(
          headers: _buildHeaders(),
        ),
      );

      final responseData = response.data;
      if (response.statusCode == 200 && responseData != null) {
        return _parseResponse(
          responseData,
          imagePath,
        );
      }

      throw AiServiceException(
        'API request failed',
        statusCode: response.statusCode,
        responseBody: response.data.toString(),
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    } on AiServiceException {
      rethrow;
    } catch (e) {
      throw AiServiceException('Failed to analyze image: $e');
    }
  }

  @override
  Future<IngredientAnalysis> analyzeText(String productName, String ingredientText) async {
    try {
      if (productName.isEmpty && ingredientText.isEmpty) {
        throw AiServiceException('Product name or ingredient text is required');
      }

      final response = await _dio.post<Map<String, dynamic>>(
        AiRequestConfig.endpoint,
        data: _buildTextRequestBody(productName, ingredientText),
        options: Options(
          headers: _buildHeaders(),
        ),
      );

      final responseData = response.data;
      if (response.statusCode == 200 && responseData != null) {
        return _parseResponse(responseData, '');
      }

      throw AiServiceException(
        'API request failed',
        statusCode: response.statusCode,
        responseBody: response.data.toString(),
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    } on AiServiceException {
      rethrow;
    } catch (e) {
      throw AiServiceException('Failed to analyze text: $e');
    }
  }

  Map<String, String> _buildHeaders() {
    final apiKey = AppEnv().geApiKey;
    if (apiKey.isEmpty) {
      throw AiServiceException('API key is not configured');
    }
    return AiRequestConfig.buildHeaders(apiKey);
  }

  Map<String, dynamic> _buildTextRequestBody(String productName, String ingredientText) {
    return {
      'model': _model,
      'messages': [
        {
          'role': 'system',
          'content': _systemPrompt,
        },
        {
          'role': 'user',
          'content': _buildTextUserPrompt(productName, ingredientText),
        }
      ],
      'max_tokens': _maxTokens,
      'temperature': _temperature,
    };
  }

  String _buildTextUserPrompt(String productName, String ingredientText) {
    return '''
Analyze the following skincare product.

${productName.isNotEmpty ? 'Product Name: $productName' : ''}
${ingredientText.isNotEmpty ? 'Ingredients: $ingredientText' : ''}

Return a JSON object with this exact structure:
{
  "productName": "Product name",
  "summary": "2-3 sentence overall summary of the product",
  "ingredients": [
    {
      "name": "INCI ingredient name",
      "commonName": "Common name",
      "category": "Category (Hydrating/Brightening/Exfoliating/Anti-aging/Soothing/Preservative/Fragrance/Base)",
      "safetyRating": 1,
      "description": "Brief description"
    }
  ],
  "categories": ["Category1 50%", "Category2 25%", "Category3 15%", "Category4 10%"],
  "warnings": [
    {
      "type": "Warning type",
      "message": "Brief warning message",
      "relatedIngredients": ["ingredient1"]
    }
  ]
}

Guidelines:
- Parse the ingredient list if provided; otherwise provide a strong product-type analysis.
- List the top 10-15 ingredients.
- Safety rating: 5 = Very Safe, 4 = Safe, 3 = Use with Caution, 2 = Potential Irritant, 1 = Avoid.
- Highlight allergens and sensitizing ingredients.
''';
  }

  IngredientAnalysis _parseResponse(Map<String, dynamic> responseData, String imageUrl) {
    final content = AiRequestConfig.extractContent(responseData);
    if (content == null || content.isEmpty) {
      throw AiServiceException('AI returned empty content');
    }

    try {
      final cleaned = AiRequestConfig.cleanJsonResponse(content);
      final jsonData = jsonDecode(cleaned) as Map<String, dynamic>;

      final ingredientsList = jsonData['ingredients'] as List<dynamic>? ?? [];
      final categoriesList = jsonData['categories'] as List<dynamic>? ?? [];
      final warningsList = jsonData['warnings'] as List<dynamic>? ?? [];

      return IngredientAnalysis(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productName: jsonData['productName'] as String? ?? 'Unknown Product',
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        ingredients: ingredientsList
            .map((item) => _parseIngredient(item as Map<String, dynamic>))
            .toList(),
        categories: categoriesList.map((item) => item.toString()).toList(),
        warnings: warningsList
            .map((item) => _parseWarning(item as Map<String, dynamic>))
            .toList(),
        summary: jsonData['summary'] as String? ?? '',
      );
    } catch (e) {
      throw AiServiceException(
        'Failed to parse AI response: $e',
        responseBody: content,
      );
    }
  }

  Ingredient _parseIngredient(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] as String? ?? '',
      commonName: json['commonName'] as String? ?? '',
      category: json['category'] as String? ?? 'Base',
      safetyRating: json['safetyRating'] as int? ?? 3,
      description: json['description'] as String? ?? '',
    );
  }

  Warning _parseWarning(Map<String, dynamic> json) {
    final relatedIngredients = json['relatedIngredients'] as List<dynamic>? ?? [];
    return Warning(
      type: json['type'] as String? ?? 'Notice',
      message: json['message'] as String? ?? '',
      relatedIngredients: relatedIngredients.map((e) => e.toString()).toList(),
    );
  }

  AiServiceException _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AiServiceException('Request timeout. Please try again later.');
      case DioExceptionType.connectionError:
        return AiServiceException('Network connection error. Please check your internet.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        return AiServiceException(
          _messageForStatusCode(statusCode),
          statusCode: statusCode,
          responseBody: error.response?.data.toString(),
        );
      default:
        return AiServiceException(
          error.message ?? 'An unknown error occurred',
          statusCode: error.response?.statusCode,
          responseBody: error.response?.data.toString(),
        );
    }
  }

  String _messageForStatusCode(int? statusCode) {
    if (statusCode == 401) {
      return 'Invalid API key. Please check your configuration.';
    }
    if (statusCode == 429) {
      return 'Too many requests. Please try again later.';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'Server error. Please try again later.';
    }
    return 'Request failed with status: $statusCode';
  }

  void dispose() {
    _dio.close();
  }
}
