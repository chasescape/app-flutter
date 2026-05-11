import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tanie/tanie/data/models/reflection_entry.dart';
import 'package:tanie/tanie/env/app_env.dart';
import 'package:tanie/tanie/interface.dart';

/// AI Image Analysis Exception
class AiAnalysisException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;
  final Object? originalError;

  AiAnalysisException(
    this.message, {
    this.statusCode,
    this.responseBody,
    this.originalError,
  });

  @override
  String toString() =>
      'AiAnalysisException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// AI Image Analysis Service
///
/// Uses the ReflectLens prompt contract and an OpenAI-compatible vision API
/// to generate a structured [ReflectionEntry] from an image.
class AiImageAnalysisService {
  AiImageAnalysisService._();
  static final AiImageAnalysisService _instance = AiImageAnalysisService._();
  factory AiImageAnalysisService() => _instance;

  static const String _defaultBaseUrl = 'https://api.gpt.ge';
  static const String _endpoint = '/v1/chat/completions';
  static const String _defaultApiKey = 'sk-ji75BVQUrjutcl0rD9AeD9612c1f4f4c818fDf0671685bA1';
  static const String _model = 'gpt-4o-2024-05-13';
  static const Duration _timeout = Duration(seconds: 60);
  static const int _defaultMaxTokens = 4000;
  static const double _defaultTemperature = 0.7;

  static const String _systemPrompt = '''
You are ReflectLens, an empathetic journaling companion that transforms everyday photos into thoughtful reflections. You excel at finding deeper meaning in ordinary moments—whether it's a quiet coffee break, a busy workspace, or a sunset walk. Your reflections are warm, insightful, and action-oriented. You never overwhelm users with heavy concepts; instead, you gently guide them toward self-awareness through the visual stories they share.

Your superpower: turning a single image into three layers of meaningful reflection plus one actionable step—all in warm, conversational language that feels like a wise friend talking to the user.
''';

  static const String _userPromptTemplate = '''
Analyze the uploaded photo and generate a thoughtful reflection following this structure:

### Scene Understanding
First, observe the image and identify:

- **location** (enum): Where does this scene take place?
  - `home` - Inside a residence (bedroom, living room, kitchen, balcony)
  - `workplace` - Office, desk, co-working space
  - `cafe` - Coffee shop, tea house, bakery
  - `outdoor_urban` - City streets, urban settings, buildings
  - `outdoor_nature` - Parks, gardens, beaches, mountains, forests
  - `restaurant` - Dining establishment
  - `transport` - Car, train, bus, plane, station
  - `gym` - Fitness center, yoga studio, sports facility
  - `other` - Any location not listed above

- **time_of_day** (enum): What time period does this scene represent?
  - `early_morning` - Pre-dawn to 9 AM (dawn light, breakfast, fresh start)
  - `morning` - 9 AM to 12 PM (active, productive energy)
  - `afternoon` - 12 PM to 5 PM (midday work, lunch break)
  - `golden_hour` - 5 PM to sunset (warm light, transition time)
  - `evening` - Post-sunset to 10 PM (dinner, relaxation, winding down)
  - `night` - 10 PM onwards (darkness, quiet, rest mode)
  - `unclear` - Cannot determine from image

- **atmosphere** (enum): What emotional tone does the scene convey?
  - `calm` - Peaceful, serene, quiet
  - `energetic` - Dynamic, busy, active
  - `cozy` - Warm, comfortable, intimate
  - `solitary` - Alone, isolated, reflective
  - `social` - With people, connected, shared
  - `chaotic` - Messy, cluttered, overwhelming
  - `melancholic` - Sad, nostalgic, bittersweet
  - `hopeful` - Bright, optimistic, inspiring

- **main_subject** (enum): What is the primary focus of this image?
  - `person` - Selfie, portrait, people in frame
  - `food_drink` - Meal, coffee, beverage, dining
  - `workspace` - Desk, computer, tools, work setup
  - `nature` - Sky, plants, water, landscape
  - `object` - A specific item (book, gift, artwork)
  - `activity` - Action in progress (exercising, cooking, traveling)
  - `empty_scene` - Just the space, no clear subject
  - `other` - Anything not categorized above

- **emotional_cue** (enum): What emotion is hinted at in this moment?
  - `contentment` - Satisfied, at peace, grateful
  - `stress` - Overwhelmed, tired, pressured
  - `excitement` - Happy, celebratory, eager
  - `nostalgia` - Remembering, sentimental, looking back
  - `curiosity` - Wondering, exploring, learning
  - `frustration` - Stuck, annoyed, challenged
  - `tranquility` - Calm, centered, mindful
  - `anticipation` - Waiting, preparing, hopeful
  - `neutral` - No strong emotional signal

### Reflection Generation

Based on your scene understanding, generate:

1. **observation** (2-3 sentences): Describe what you see in the image with sensory detail. Capture the mood and emotional tone. Make the user feel seen and understood.

2. **deeper_thought** (2-3 sentences): Connect this scene to broader life themes. What might this moment represent? Why does it matter? Help the user see patterns or meanings they might miss.

3. **insight** (2-3 sentences): What can be learned or gained from this moment? Offer a fresh perspective or gentle wisdom that leaves the user feeling enriched.

4. **action_prompt** (1 sentence, max 25 words): A specific, achievable action the user can take today. Make it concrete, not abstract. Frame it as an invitation, not a command.

**Tone Guidelines**:
- Warm but not overly sentimental
- Insightful but not preachy
- Brief but not shallow
- Personal (use "you" to speak directly to the user)

Output ONLY valid JSON:
{
  "scene_understanding": {
    "location": "enum_value",
    "time_of_day": "enum_value",
    "atmosphere": "enum_value",
    "main_subject": "enum_value",
    "emotional_cue": "enum_value"
  },
  "reflection": {
    "observation": "text",
    "deeper_thought": "text",
    "insight": "text",
    "action_prompt": "text"
  }
}

No markdown, no explanations, just the JSON.
''';

  Dio? _dio;
  bool _isInitialized = false;
  String? _configuredBaseUrl;
  String? _configuredApiKey;

  /// Initialize the service.
  ///
  /// When [apiKey] is omitted, the service will try to use the current auth
  /// token. This keeps the current project wiring compatible while still
  /// supporting OpenAI-compatible endpoints that expect a bearer key.
  void init({String? apiKey, String? baseUrl}) {
    final resolvedBaseUrl = _resolveBaseUrl(baseUrl);
    final resolvedApiKey = _resolveApiKey(apiKey);

    if (_isInitialized &&
        _configuredBaseUrl == resolvedBaseUrl &&
        _configuredApiKey == resolvedApiKey) {
      return;
    }

    _dio?.close(force: true);
    _dio = Dio(
      BaseOptions(
        baseUrl: resolvedBaseUrl,
        connectTimeout: _timeout,
        receiveTimeout: _timeout,
        sendTimeout: _timeout,
      ),
    );

    _configuredBaseUrl = resolvedBaseUrl;
    _configuredApiKey = resolvedApiKey;
    _isInitialized = true;
  }

  /// Analyze an image and return a [ReflectionEntry].
  Future<ReflectionEntry> analyzeImage({
    required String imagePath,
    String? customPrompt,
    int maxTokens = _defaultMaxTokens,
    double temperature = _defaultTemperature,
    String? apiKey,
    String? baseUrl,
  }) async {
    if (imagePath.trim().isEmpty) {
      throw AiAnalysisException('Image path cannot be empty');
    }

    init(apiKey: apiKey, baseUrl: baseUrl);
    final dio = _dio;
    if (dio == null) {
      throw AiAnalysisException('AI service has not been initialized');
    }

    try {
      final imageBytes = await _loadImageBytes(imagePath);
      final imageBase64 = base64Encode(imageBytes);
      final requestData = _buildRequestBody(
        imageBase64: imageBase64,
        systemPrompt: _systemPrompt,
        userPrompt: _buildUserPrompt(customPrompt),
        maxTokens: maxTokens,
        temperature: temperature,
      );

      final response = await dio
          .post<Map<String, dynamic>>(
            _endpoint,
            data: requestData,
            options: Options(
              headers: _buildHeaders(_configuredApiKey ?? _defaultApiKey),
              responseType: ResponseType.json,
            ),
          )
          .timeout(_timeout);

      _logResponse(response);

      final parsed = _parseReflectionEntry(
        response.data,
        fallbackResponseBody: response.data == null ? null : jsonEncode(response.data),
      );

      return ReflectionEntry(
        assetImg: imagePath,
        sceneUnderstanding: parsed.sceneUnderstanding,
        reflection: parsed.reflection,
      );
    } on SocketException {
      throw AiAnalysisException('Network connection failed. Please check your network.');
    } on TimeoutException {
      throw AiAnalysisException('Request timed out. Please try again later.');
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final responseBody = _responseBodyToString(e.response?.data);
      final errorMessage = [
        if ((e.message ?? '').trim().isNotEmpty) e.message!.trim(),
        if (statusCode != null) 'HTTP $statusCode',
        if (responseBody != null && responseBody.trim().isNotEmpty)
          responseBody.length > 180
              ? '${responseBody.substring(0, 180)}...'
              : responseBody,
      ].join(' | ');

      throw AiAnalysisException(
        errorMessage.isEmpty ? 'AI request failed' : errorMessage,
        statusCode: statusCode,
        responseBody: responseBody,
        originalError: e,
      );
    } on AiAnalysisException {
      rethrow;
    } catch (e) {
      throw AiAnalysisException('Analysis failed: $e', originalError: e);
    }
  }

  Future<Uint8List> _loadImageBytes(String imagePath) async {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      final response = await Dio().get<List<int>>(
        imagePath,
        options: Options(responseType: ResponseType.bytes),
      );
      final data = response.data;
      if (data == null) {
        throw AiAnalysisException('Failed to download image bytes');
      }
      return Uint8List.fromList(data);
    }

    if (imagePath.startsWith('assets/')) {
      final byteData = await rootBundle.load(imagePath);
      return byteData.buffer.asUint8List();
    }

    final file = File(imagePath);
    if (!await file.exists()) {
      throw AiAnalysisException('Image file not found: $imagePath');
    }
    return file.readAsBytes();
  }

  Map<String, String> _buildHeaders(String apiKey) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
  }

  Map<String, dynamic> _buildRequestBody({
    required String imageBase64,
    required String systemPrompt,
    required String userPrompt,
    int? maxTokens,
    double? temperature,
  }) {
    return {
      'model': _model,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': userPrompt},
            {
              'type': 'image_url',
              'image_url': {'url': _buildImageUrl(imageBase64)},
            },
          ],
        },
      ],
      'max_tokens': maxTokens ?? _defaultMaxTokens,
      'temperature': temperature ?? _defaultTemperature,
    };
  }

  String _buildImageUrl(String base64Data, {String mimeType = 'image/jpeg'}) {
    return 'data:$mimeType;base64,$base64Data';
  }

  ReflectionEntry _parseReflectionEntry(
    Map<String, dynamic>? responseData, {
    String? fallbackResponseBody,
  }) {
    if (responseData == null) {
      throw AiAnalysisException(
        'Empty response from AI service',
        responseBody: fallbackResponseBody,
      );
    }

    final content = _extractContent(responseData);
    if (content == null || content.isEmpty) {
      throw AiAnalysisException(
        'AI returned empty content',
        responseBody: fallbackResponseBody,
      );
    }

    _logContent(content);

    final cleanedJson = _cleanJsonResponse(content);
    try {
      final jsonData = jsonDecode(cleanedJson) as Map<String, dynamic>;
      return ReflectionEntry.fromJson({
        'assetImg': '',
        ...jsonData,
      });
    } catch (e) {
      throw AiAnalysisException(
        'Failed to parse AI response JSON',
        responseBody: cleanedJson,
        originalError: e,
      );
    }
  }

  String? _extractContent(Map<String, dynamic> response) {
    return response['choices']?[0]?['message']?['content'] as String?;
  }

  String _cleanJsonResponse(String content) {
    String cleaned = content.trim();

    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7).trim();
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3).trim();
    }

    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3).trim();
    }

    return cleaned;
  }

  String _buildUserPrompt(String? customPrompt) {
    final prompt = customPrompt?.trim();
    if (prompt == null || prompt.isEmpty) {
      return _userPromptTemplate;
    }

    return '$_userPromptTemplate\n\nAdditional user context:\n$prompt';
  }

  String _resolveBaseUrl(String? overrideBaseUrl) {
    final baseUrl = overrideBaseUrl?.trim();
    if (baseUrl != null && baseUrl.isNotEmpty) {
      return baseUrl;
    }

    if (_defaultBaseUrl.trim().isNotEmpty) {
      return _defaultBaseUrl.trim();
    }

    final envBaseUrl = AppEnv().hostApi.trim();
    if (envBaseUrl.isNotEmpty) {
      return envBaseUrl;
    }

    return _defaultBaseUrl;
  }

  String _resolveApiKey(String? overrideApiKey) {
    final apiKey = overrideApiKey?.trim();
    if (apiKey != null && apiKey.isNotEmpty) {
      return apiKey;
    }

    if (_defaultApiKey.trim().isNotEmpty) {
      return _defaultApiKey.trim();
    }

    final authToken = Interface().authToken?.trim();
    if (authToken != null && authToken.isNotEmpty) {
      return authToken;
    }

    return _defaultApiKey;
  }

  String? _responseBodyToString(dynamic data) {
    if (data == null) {
      return null;
    }
    if (data is String) {
      return data;
    }
    try {
      return jsonEncode(data);
    } catch (_) {
      return data.toString();
    }
  }

  void _logResponse(Response<dynamic> response) {
    debugPrint('[AiImageAnalysisService] Response Status: ${response.statusCode}');
  }

  void _logContent(String content) {
    debugPrint('[AiImageAnalysisService] Response Content:');
    debugPrint(content);
  }

  void dispose() {
    _dio?.close(force: true);
    _dio = null;
    _isInitialized = false;
    _configuredBaseUrl = null;
    _configuredApiKey = null;
  }
}

/// Global instance
final aiImageAnalysisService = AiImageAnalysisService();
