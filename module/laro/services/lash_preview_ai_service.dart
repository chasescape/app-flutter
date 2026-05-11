
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../env/app_env.dart';

/// LashPreview AI service exception.
class LashPreviewAiException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  LashPreviewAiException(
    this.message, {
    this.statusCode,
    this.responseBody,
  });

  @override
  String toString() => 'LashPreviewAiException: $message';
}

class LashPreviewAiService {
  static const String _defaultBaseUrl = 'https://api.gpt.ge';
  static const String _model = 'gpt-4o-2024-05-13';
  static const Duration _timeout = Duration(seconds: 60);
  static const int _maxTokens = 4000;
  static const double _temperature = 0.7;

  static const String _systemPrompt = '''
You are a beauty analysis assistant for an eyelash preview app.

Analyze the uploaded eye photo and recommend the single most flattering lash preview concept for this user. The recommendation must feel realistic, commercially useful, and aligned with one of these style families:

- Natural
- Glamour
- Doll

Return only valid JSON. Do not wrap the response in Markdown. Do not add explanation outside the JSON.

The JSON must use this exact schema and key naming:
{
  "id": "string",
  "asset_img": "string",
  "old_asset_imgs": ["string"],
  "title": "string",
  "subtitle": "string",
  "why_better": "string",
  "how_it_works": "string",
  "style_mood": "string",
  "best_for": "string",
  "new_image_description": "string",
  "edit_instruction_context": "string"
}

Field requirements:
- id: lowercase snake_case identifier for the recommendation.
- asset_img: return an empty string.
- old_asset_imgs: return an empty array.
- title: a short marketing-style lash recommendation title.
- subtitle: one concise sentence describing lash length, curl, and effect.
- why_better: explain why this look suits the eye shape, mood, or likely use case.
- how_it_works: explain how the AI lash placement or curl choice enhances the eyes.
- style_mood: 3 to 6 descriptive words, comma-separated.
- best_for: short phrase describing who or what situation this style fits.
- new_image_description: vivid but practical image-generation description of the final lash look.
- edit_instruction_context: direct instruction for an image editing model to apply the lash style.

Quality rules:
- Base the recommendation on visible eye shape, openness, balance, and softness or drama potential.
- Keep the tone polished, mobile-app friendly, and easy to understand.
- Avoid medical claims.
- Prefer concise, high-signal wording.
- Ensure the recommendation could be used immediately in a lash preview product.
''';

  static const String _userPromptTemplate = '''
Analyze this uploaded eye photo and generate the best lash preview recommendation.

Important constraints:
- Return JSON only.
- Use the exact keys required by the schema.
- Choose the single strongest recommendation rather than multiple options.
- Keep asset_img as "".
- Keep old_asset_imgs as [].
- Make the recommendation feel aligned with one of these three app styles: Natural, Glamour, or Doll.
''';

  late final http.Client _client;
  late final Map<String, String> _headers;
  late final String _baseUrl;

  LashPreviewAiService({String? apiKey, String? baseUrl}) {
    final config = AppEnv();
    final resolvedApiKey = apiKey ?? config.geApiKey;
    if (resolvedApiKey.isEmpty) {
      throw LashPreviewAiException('AI API key is not configured');
    }

    _client = http.Client();
    _headers = _buildHeaders(resolvedApiKey);
    _baseUrl = baseUrl ??
        (config.hostAiApi.isNotEmpty ? config.hostAiApi : _defaultBaseUrl);
  }

  /// Analyze an uploaded eye image and return a structured lash recommendation.

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
    String? model,
    int? maxTokens,
    double? temperature,
  }) {
    return {
      'model': model ?? _model,
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
      'max_tokens': maxTokens ?? _maxTokens,
      'temperature': temperature ?? _temperature,
    };
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

  String _buildImageUrl(String base64Data, {String mimeType = 'image/jpeg'}) {
    return 'data:$mimeType;base64,$base64Data';
  }

  void _logResponse(http.Response response) {
    debugPrint(
        '[LashPreviewAiService] Response Status: ${response.statusCode}');
  }

  void _logContent(String content) {
    debugPrint('[LashPreviewAiService] Response Content:');
    debugPrint(content);
  }

  void dispose() {
    _client.close();
  }
}
