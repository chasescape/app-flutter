import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:havki/havki/data/models/quote/quote_vibe_analysis_data.dart';

/// QuoteVibe AI Service - Image analysis with emotion matched quotes
class QuoteVibeAiService {
  QuoteVibeAiService._();

  static QuoteVibeAiService? _instance;
  static QuoteVibeAiService get instance {
    _instance ??= QuoteVibeAiService._();
    return _instance!;
  }

  static const String _baseUrl = 'https://api.gpt.ge';
  static const String _endpoint = '/v1/chat/completions';
  static const String _defaultApiKey = 'your-api-key-here';
  static const String _model = 'gpt-4o-2024-05-13';
  static const int _maxTokens = 4000;
  static const double _temperature = 0.7;
  static const Duration _timeout = Duration(seconds: 60);

  static const String _systemPrompt = '''
You are QuoteVibe AI, a specialized scene emotion analyst and quote curator. Your expertise lies in:

1. Scene Emotion Detection: Analyzing visual elements in photos to identify the underlying mood, atmosphere, and emotional context
2. Quote Matching: Selecting and crafting quotes that resonate with the detected emotions, creating meaningful connections between imagery and wisdom
3. Interpretive Insight: Providing brief, impactful interpretations that bridge the quote and the user's current emotional state

Your core philosophy: Every moment deserves a quote that captures its essence. You transform ordinary photos into vessels of wisdom, comfort, and inspiration.

Content Guidelines:
- Prioritize public domain quotes and classic wisdom literature
- Avoid religious, political, or controversial content
- Maintain healing, motivational, reflective, or stoic tones
- Keep quotes under 30 words, interpretations under 15 words
- Focus on universal human experiences and emotions
- Return ONLY valid JSON without markdown or additional commentary
''';

  static const String _userPromptTemplate = '''
Analyze this photo and generate matched quote cards.

SELECTED STYLE: {style}

Provide:
1. Scene emotion analysis with mood tags
2. Three quote cards with interpretations that match the detected emotion

Response Format: JSON

Use this JSON structure and field names exactly:
{
  "scene_analysis": {
    "location": "cafe|beach|city|home|nature|workplace|restaurant|gym|outdoor|indoor|street|park|other",
    "time_of_day": "dawn|morning|afternoon|golden_hour|evening|night|late_night",
    "primary_mood": "peaceful|melancholic|anxious|hopeful|energetic|nostalgic|contemplative|joyful|lonely|grateful|confused|determined",
    "mood_tags": ["inner_peace", "self_reflection", "growth"],
    "visual_elements": {
      "subjects": ["person"],
      "actions": ["sitting"],
      "color_tone": "warm|cool|neutral|monochrome|vibrant|pastel|dark",
      "atmosphere": "romantic|healing|lively|solitary|energetic|mysterious|serene|cozy|adventurous|introspective"
    },
    "scene_description": "One-sentence poetic description"
  },
  "quote_cards": [
    {
      "quote": "Quote text",
      "author": "Author",
      "interpretation": "Brief interpretation",
      "resonance_reason": "emotional_validation|perspective_shift|comfort_and_reassurance|call_to_action|reflection_prompt|wisdom_reminder",
      "emotional_intensity": "gentle|moderate|intense"
    }
  ],
  "style_signature": "signature tone for selected style"
}

Create exactly 3 quote_cards.
''';

  String _apiKey = _defaultApiKey;
  String _proxyUrl = _baseUrl;
  Dio? _dio;

  static void initialize({
    String? apiKey,
    String? proxyUrl,
  }) {
    final service = instance;
    service._apiKey = apiKey ?? _defaultApiKey;
    service._proxyUrl = proxyUrl ?? _baseUrl;
    service._initDio();
  }

  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _proxyUrl,
        connectTimeout: _timeout,
        receiveTimeout: _timeout,
        sendTimeout: _timeout,
        headers: _buildHeaders(_apiKey),
      ),
    );
  }

  Future<QuoteVibeAnalysisData> analyzeImage({
    required String imagePath,
    required QuoteVibeStyle style,
  }) async {
    try {
      final imageBase64 = await _readImageAsBase64(imagePath);
      final requestBody = _buildRequestBody(imageBase64, style);

      if (_dio == null) {
        _initDio();
      }

      final response = await _dio!.post(_endpoint, data: requestBody);

      final content = _extractContentFromResponse(response.data);
      final cleanedJson = _cleanJsonResponse(content);
      final jsonData = jsonDecode(cleanedJson) as Map<String, dynamic>;
      final assetImg = _extractAssetImgFromPath(imagePath);

      return QuoteVibeAnalysisData.fromJson({
        ...jsonData,
        'assetImg': assetImg,
      });
    } on QuoteVibeAiException {
      rethrow;
    } catch (e) {
      throw QuoteVibeAiException(
        'Analysis failed: ${e.toString()}',
        type: QuoteVibeAiErrorType.unknown,
      );
    }
  }

  Future<String> _readImageAsBase64(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) {
        throw QuoteVibeAiException(
          'Image file not found: $path',
          type: QuoteVibeAiErrorType.fileNotFound,
        );
      }

      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      if (e is QuoteVibeAiException) {
        rethrow;
      }
      throw QuoteVibeAiException(
        'Failed to read image: ${e.toString()}',
        type: QuoteVibeAiErrorType.fileReadError,
      );
    }
  }

  Map<String, dynamic> _buildRequestBody(
    String imageBase64,
    QuoteVibeStyle style,
  ) {
    return {
      'model': _model,
      'messages': [
        {
          'role': 'system',
          'content': _systemPrompt,
        },
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': _buildPrompt(style),
            },
            {
              'type': 'image_url',
              'image_url': {
                'url': _buildImageUrl(imageBase64),
              },
            },
          ],
        },
      ],
      'max_tokens': _maxTokens,
      'temperature': _temperature,
    };
  }

  String _buildPrompt(QuoteVibeStyle style) {
    return _userPromptTemplate.replaceAll('{style}', style.value);
  }

  Map<String, String> _buildHeaders(String apiKey) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
  }

  String _buildImageUrl(String base64Data, {String mimeType = 'image/jpeg'}) {
    return 'data:$mimeType;base64,$base64Data';
  }

  String _extractContentFromResponse(dynamic responseData) {
    try {
      if (responseData == null) {
        throw QuoteVibeAiException(
          'Empty response from API',
          type: QuoteVibeAiErrorType.emptyResponse,
        );
      }

      if (responseData is! Map<String, dynamic>) {
        throw QuoteVibeAiException(
          'Invalid response format',
          type: QuoteVibeAiErrorType.invalidResponse,
        );
      }

      final choices = responseData['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        throw QuoteVibeAiException(
          'No choices in response',
          type: QuoteVibeAiErrorType.invalidResponse,
        );
      }

      final firstChoice = choices.first as Map<String, dynamic>;
      final message = firstChoice['message'] as Map<String, dynamic>?;
      final content = message?['content'] as String?;
      if (content == null || content.isEmpty) {
        throw QuoteVibeAiException(
          'Empty content in message',
          type: QuoteVibeAiErrorType.emptyResponse,
        );
      }

      return content;
    } catch (e) {
      if (e is QuoteVibeAiException) {
        rethrow;
      }
      throw QuoteVibeAiException(
        'Failed to extract content: ${e.toString()}',
        type: QuoteVibeAiErrorType.parseError,
      );
    }
  }

  String _cleanJsonResponse(String content) {
    var cleaned = content.trim();
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

  String _extractAssetImgFromPath(String imagePath) {
    final normalized = imagePath.replaceAll('\\', '/');
    final assetsIndex = normalized.indexOf('/assets/');
    if (assetsIndex != -1) {
      return normalized.substring(assetsIndex + 1);
    }
    if (normalized.startsWith('assets/')) {
      return normalized;
    }
    return imagePath;
  }
}

enum QuoteVibeAiErrorType {
  fileNotFound,
  fileReadError,
  emptyResponse,
  invalidResponse,
  parseError,
  unknown,
}

class QuoteVibeAiException implements Exception {
  final String message;
  final QuoteVibeAiErrorType type;

  QuoteVibeAiException(this.message, {required this.type});

  @override
  String toString() => message;
}
