import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../env/app_env.dart';
import '../models/nail_models.dart';

/// NailRecommendationPayload AI 服务异常
class NailRecommendationPayloadAiException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  NailRecommendationPayloadAiException(
    this.message, {
    this.statusCode,
    this.responseBody,
  });

  @override
  String toString() => 'NailRecommendationPayloadAiException: $message';
}

class NailRecommendationPayloadAiService {
  static const String _baseUrl = 'https://api.gpt.ge';
  static const String _defaultApiKey = '';
  static const String _model = 'gpt-4o-2024-05-13';
  static const Duration _timeout = Duration(seconds: 60);
  static const int _maxTokens = 4000;
  static const double _temperature = 0.7;

  static const String _systemPrompt = '''
You are Rosa "Glow" Valentine, a senior nail style director with 9 years of experience.
You create polished, modern nail recommendations based on the uploaded hand photo.

Output policy:
- Every value in the JSON must be written in natural English only.
- Do not use Chinese, pinyin, bilingual phrasing, or translated leftovers.
- Keep wording concise, elegant, and salon-friendly.
''';

  static const String _userPromptTemplate = '''
Task:
Review the uploaded hand photo and recommend exactly 3 nail styles.
Base the recommendations on the image mood, skin tone, nail shape, and overall vibe.

Return a JSON object with this structure:
{
  "styles": [
    {
      "styleName": "string",
      "styleTags": ["string", "string"],
      "sceneFit": "string",
      "whyItFits": "string",
      "visualKeywords": ["string", "string", "string"]
    }
  ]
}

Rules:
- Return JSON only. No markdown.
- styles must contain exactly 3 items.
- styleTags must contain 2 to 3 short English tags.
- visualKeywords must contain 3 to 5 short English keywords.
- sceneFit must be exactly 1 sentence in English.
- whyItFits must be exactly 1 sentence in English.
- styleName must be in English only.
- Every string in the JSON must be English only.
- Avoid Chinese wording, Chinese punctuation, or mixed-language output.
''';

  final http.Client _client;
  late final Map<String, String> _headers;

  NailRecommendationPayloadAiService({
    String? apiKey,
    http.Client? client,
  }) : _client = client ?? http.Client() {
    final effectiveApiKey = apiKey ?? AppEnv().geApiKey;
    _headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${effectiveApiKey.isEmpty ? _defaultApiKey : effectiveApiKey}',
    };
  }

  /// 分析图片并生成美甲风格推荐
  Future<NailRecommendationPayload> analyzeImage(File imageFile) async {
    final authHeader = _headers['Authorization'] ?? '';
    if (authHeader == 'Bearer ') {
      throw NailRecommendationPayloadAiException('API key not configured');
    }

    try {
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final requestData = {
        "model": _model,
        "messages": [
          {"role": "system", "content": _systemPrompt},
          {
            "role": "user",
            "content": [
              {"type": "text", "text": _userPromptTemplate},
              {
                "type": "image_url",
                "image_url": {"url": "data:image/jpeg;base64,$base64Image"}
              }
            ]
          }
        ],
        "max_tokens": _maxTokens,
        "temperature": _temperature,
      };

      final response = await _client
          .post(
            Uri.parse('$_baseUrl/v1/chat/completions'),
            headers: _headers,
            body: jsonEncode(requestData),
          )
          .timeout(_timeout);

      _logResponse(response);

      if (response.statusCode == 200) {
        return _parseResponse(response.body);
      }

      throw NailRecommendationPayloadAiException(
        'API request failed',
        statusCode: response.statusCode,
        responseBody: response.body,
      );
    } on SocketException {
      throw NailRecommendationPayloadAiException('Network connection failed');
    } on TimeoutException {
      throw NailRecommendationPayloadAiException(
          'Request timed out, please try again');
    } on NailRecommendationPayloadAiException {
      rethrow;
    } catch (e) {
      throw NailRecommendationPayloadAiException('Analysis failed: $e');
    }
  }

  NailRecommendationPayload _parseResponse(String responseBody) {
    final responseData = jsonDecode(responseBody) as Map<String, dynamic>;
    final content =
        responseData['choices']?[0]?['message']?['content'] as String?;

    if (content == null || content.isEmpty) {
      throw NailRecommendationPayloadAiException('AI returned empty content');
    }

    _logContent(content);

    String cleaned = content.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7).trim();
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3).trim();
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3).trim();
    }

    final jsonData = jsonDecode(cleaned) as Map<String, dynamic>;
    return NailRecommendationPayload.fromJson(jsonData);
  }

  void _logResponse(http.Response response) {
    debugPrint(
      '[NailRecommendationPayloadAiService] Response Status: ${response.statusCode}',
    );
  }

  void _logContent(String content) {
    debugPrint('[NailRecommendationPayloadAiService] Response Content:');
    debugPrint(content);
  }

  void dispose() {
    _client.close();
  }
}
