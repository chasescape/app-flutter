import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../data/models/cherish_card.dart';

/// CherishCard AI 服务异常
class CherishCardAiException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  CherishCardAiException(this.message, {this.statusCode, this.responseBody});

  @override
  String toString() => 'CherishCardAiException: $message';
}

class CherishCardAiService {
  static const String _baseUrl = 'https://api.gpt.ge';
  static const String _defaultApiKey = 'sk-qVDgJ0IYpJrp1sFBD1A555513501444eB6BcFe5758A28fCe';
  static const String _placeholderApiKey = 'YOUR_API_KEY';
  static const String _model = 'gpt-4o-2024-05-13';
  static const Duration _timeout = Duration(seconds: 60);
  static const int _maxTokens = 4000;
  static const double _temperature = 0.7;

  static const String _systemPrompt = '''You are CherishLens Image Analyzer — a gentle, poetic observer of everyday life.

Your mission: Help users discover and articulate the small, beautiful moments in their daily photographs. You have a talent for finding warmth in ordinary scenes and translating visual details into comforting words.

Core Philosophy:
- Every ordinary moment contains beauty waiting to be noticed
- Your words should feel like a warm conversation with a thoughtful friend
- Be specific about visual details, but interpret them through an emotional lens
- Avoid clichés and over-dramatic language — genuine simplicity resonates most

Output Rules:
- Return ONLY valid JSON (no markdown, no extra text)
- All user-facing content must be in English
- Do not identify real people or guess sensitive traits (age, identity, location, etc.)
- If uncertain, use "Unknown" and lower confidence
- Use only the allowed enum values provided
- Keep tone warm, gentle, and sincere — never clinical or overly dramatic''';

  static const String _userPromptTemplate = '''Analyze this photo for CherishLens and extract a Scene Card + healing content.

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
    "short_healing_text": "...",
    "daily_affirmation": "...",
    "cherish_tags": ["...", "...", "...", "..."]
  },
  "meta": {
    "one_line_moment": "...",
    "safety": {
      "has_sensitive_content": false,
      "notes": ""
    }
  }
}

Guidelines for "short_healing_text":
- Length: 150-200 characters (2-4 sentences)
- Style: Warm, poetic, but grounded — avoid excessive adjectives
- Structure: Open with a concrete visual detail → connect to an emotional insight → gentle closing
- Voice: Like a friend sending a thoughtful message

Guidelines for "daily_affirmation":
- Length: 60-120 characters (1 sentence)
- Content: Original or public-domain short phrase that resonates with the image mood
- Avoid: Clichés, overly motivational language, religious references

Guidelines for "cherish_tags":
- Exactly 3-5 tags
- Mix of: mood keywords + scene elements + emotional qualities
- Format: CamelCase without spaces (e.g., #GoldenHour, #QuietMoments, #CoffeeTime)

Notes for "evidence" fields:
- Keep descriptions short and focused on visible, non-sensitive cues
- Avoid interpretive human judgments

IMPORTANT:
- The photo is provided as an image input in this request.
- Prioritize emotional resonance over exhaustive detail.
- If the image is too dark/blurred/unclear, set more fields to "Unknown" and adjust content to be more universal.''';

  late final http.Client _client;
  late final Map<String, String> _headers;
  late final String _apiKey;

  CherishCardAiService({String? apiKey}) {
    _client = http.Client();
    _apiKey = apiKey ?? _defaultApiKey;
    _headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    };
  }

  /// 分析图片并返回 CherishCard
  Future<CherishCard> analyzeImage(
    File imageFile, {
    required String imagePath,
    String? language,
    String? style,
  }) async {
    try {
      // Treat empty or obvious placeholder as missing. Some projects may ship a
      // real default key for development, so don't block on equality to default.
      if (_apiKey.trim().isEmpty || _apiKey == _placeholderApiKey) {
        throw CherishCardAiException('Missing API key');
      }
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final requestData = {
        "model": _model,
        "messages": [
          {"role": "system", "content": _systemPrompt},
          {
            "role": "user",
            "content": [
              {"type": "text", "text": _buildUserPrompt(language: language, style: style)},
              {
                "type": "image_url",
                "image_url": {"url": _buildImageUrl(base64Image, mimeType: _detectMimeType(imagePath))}
              }
            ]
          }
        ],
        "max_tokens": _maxTokens,
        "temperature": _temperature
      };

      final response = await _client
          .post(
            Uri.parse('$_baseUrl/v1/chat/completions'),
            headers: _headers,
            body: jsonEncode(requestData),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return _parseResponse(response.body, imagePath: imagePath);
      } else {
        throw CherishCardAiException(
          'API request failed (${response.statusCode})',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } on SocketException {
      throw CherishCardAiException('Network connection failed');
    } on TimeoutException {
      throw CherishCardAiException('Request timeout, please try again later');
    } on CherishCardAiException {
      rethrow;
    } catch (e) {
      throw CherishCardAiException('Analysis failed: $e');
    }
  }

  CherishCard _parseResponse(String responseBody, {required String imagePath}) {
    final responseData = jsonDecode(responseBody) as Map<String, dynamic>;
    final content = responseData['choices']?[0]?['message']?['content'] as String?;

    if (content == null || content.isEmpty) {
      throw CherishCardAiException('AI returned empty content');
    }

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
    return CherishCard.fromJson(jsonData, assetImg: imagePath);
  }

  String _buildUserPrompt({String? language, String? style}) {
    final preferences = <String>[];
    if (language != null && language.isNotEmpty) {
      preferences.add('Preferred response language style target: $language.');
    }
    if (style != null && style.isNotEmpty) {
      preferences.add('Requested emotional style emphasis: $style.');
    }
    if (preferences.isEmpty) {
      return _userPromptTemplate;
    }
    return '$_userPromptTemplate\n\nAdditional preferences:\n${preferences.join('\n')}';
  }

  String _buildImageUrl(String base64Data, {String mimeType = 'image/jpeg'}) {
    return 'data:$mimeType;base64,$base64Data';
  }

  String _detectMimeType(String path) {
    final extension = path.toLowerCase().split('.').last;
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  void dispose() {
    _client.close();
  }
}
