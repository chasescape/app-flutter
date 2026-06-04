import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../env/app_env.dart';

/// AI Service Abstract - Singleton Pattern
abstract class AIService {
  static AIService? _instance;

  static void setInstance(AIService service) {
    _instance = service;
  }

  static AIService get instance {
    _instance ??= _RealAIService._();
    return _instance!;
  }

  @visibleForTesting
  static void reset() {
    _instance = null;
  }

  // Abstract methods
  Future<MakeupAnalysisResult> analyzeMakeup(String imagePath, {VoidCallback? onProgress});
  Future<List<MakeupTrend>> analyzeTrends(List<MakeupRecord> records);
}

/// Data Models
class MakeupAnalysisResult {
  final String imagePath;
  final List<String> styleTags;
  final List<String> occasionTags;
  final String recordNote;
  final String shotType;
  final String focusArea;
  final String lighting;
  final String occasion;
  final String season;
  final String timeOfDay;
  final DateTime createdAt;

  MakeupAnalysisResult({
    required this.imagePath,
    required this.styleTags,
    required this.occasionTags,
    required this.recordNote,
    required this.shotType,
    required this.focusArea,
    required this.lighting,
    required this.occasion,
    required this.season,
    required this.timeOfDay,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'imagePath': imagePath,
      'styleTags': styleTags,
      'occasionTags': occasionTags,
      'recordNote': recordNote,
      'shotType': shotType,
      'focusArea': focusArea,
      'lighting': lighting,
      'occasion': occasion,
      'season': season,
      'timeOfDay': timeOfDay,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MakeupAnalysisResult.fromJson(Map<String, dynamic> json) {
    return MakeupAnalysisResult(
      imagePath: json['imagePath'] as String,
      styleTags: List<String>.from(json['styleTags'] as List),
      occasionTags: List<String>.from(json['occasionTags'] as List),
      recordNote: (json['recordNote'] as String?) ?? '',
      shotType: json['shotType'] as String,
      focusArea: json['focusArea'] as String,
      lighting: json['lighting'] as String,
      occasion: json['occasion'] as String,
      season: json['season'] as String,
      timeOfDay: json['timeOfDay'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class MakeupRecord {
  final String id;
  final String imagePath;
  final MakeupAnalysisResult analysis;

  MakeupRecord({
    required this.id,
    required this.imagePath,
    required this.analysis,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'analysis': analysis.toJson(),
    };
  }

  factory MakeupRecord.fromJson(Map<String, dynamic> json) {
    return MakeupRecord(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      analysis: MakeupAnalysisResult.fromJson(
        json['analysis'] as Map<String, dynamic>,
      ),
    );
  }
}

class MakeupTrend {
  final String title;
  final String description;
  final Map<String, int> styleDistribution;
  final Map<String, int> occasionDistribution;
  final List<String> topStyles;

  MakeupTrend({
    required this.title,
    required this.description,
    required this.styleDistribution,
    required this.occasionDistribution,
    required this.topStyles,
  });
}

/// AI Service Exception
class MakeupAiException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  MakeupAiException(this.message, {this.statusCode, this.responseBody});

  @override
  String toString() => 'MakeupAiException: $message';
}

/// Real AI Service Implementation
class _RealAIService implements AIService {
  _RealAIService._();

  static const String _baseUrl = 'https://api.gpt.ge';
  static const String _endpoint = '/v1/chat/completions';
  static const String _model = 'gpt-4o-2024-05-13';
  static const Duration _timeout = Duration(seconds: 60);

  late final http.Client _client;
  bool _isDisposed = false;

  http.Client get _clientInstance {
    if (_isDisposed) {
      _client = http.Client();
      _isDisposed = false;
    }
    return _client;
  }

  Map<String, String> _buildHeaders() {
    final apiKey = AppEnv().geApiKey;
    if (apiKey.isEmpty) {
      throw MakeupAiException('API Key not configured. Please set geApiKey in AppEnv.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
  }

  @override
  Future<MakeupAnalysisResult> analyzeMakeup(String imagePath, {VoidCallback? onProgress}) async {
    if (_isDisposed) {
      _client = http.Client();
      _isDisposed = false;
    }

    try {
      final imageFile = File(imagePath);
      if (!imageFile.existsSync()) {
        throw MakeupAiException('Image file not found: $imagePath');
      }

      onProgress?.call();
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final requestData = _buildRequestBody(base64Image);

      print('[MakeupAiService] Sending request to $_baseUrl$_endpoint');
      print('[MakeupAiService] Model: $_model');

      final response = await _clientInstance.post(
        Uri.parse('$_baseUrl$_endpoint'),
        headers: _buildHeaders(),
        body: jsonEncode(requestData),
      ).timeout(_timeout);

      print('[MakeupAiService] Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return _parseResponse(response.body);
      } else {
        print('[MakeupAiService] Error Response: ${response.body}');
        throw MakeupAiException(
          'API request failed with status ${response.statusCode}',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } on SocketException {
      throw MakeupAiException('Network connection failed. Please check your internet connection.');
    } on TimeoutException {
      throw MakeupAiException('Request timeout. Please try again later.');
    } on MakeupAiException {
      rethrow;
    } catch (e) {
      print('[MakeupAiService] Unexpected error: $e');
      throw MakeupAiException('Analysis failed: $e');
    }
  }

  Map<String, dynamic> _buildRequestBody(String base64Image) {
    return {
      "model": _model,
      "messages": [
        {
          "role": "system",
          "content": _systemPrompt
        },
        {
          "role": "user",
          "content": [
            {"type": "text", "text": _userPrompt},
            {
              "type": "image_url",
              "image_url": {"url": "data:image/jpeg;base64,$base64Image"}
            }
          ]
        }
      ],
      "max_tokens": 2000,
      "temperature": 0.7,
    };
  }

  static const String _systemPrompt = '''You are a professional makeup style analyst. Analyze the makeup photo and provide detailed insights about the style, occasion, and scene characteristics.

Your task:
1. Identify the makeup style (3-5 tags)
2. Identify suitable occasions (1-2 tags)
3. Analyze scene details

Response format (strict JSON):
```json
{
  "style_tags": ["Natural Nude", "Fresh Sweet", "Warm Tone", "Professional"],
  "occasion_tags": ["Daily Commute", "Daytime Fresh"],
  "shot_type": "Selfie",
  "focus_area": "Full Face",
  "lighting": "Natural Light",
  "occasion": "Daily",
  "season": "All Season",
  "time_of_day": "Day"
}
```

Style tag options (choose 3-5):
- Makeup intensity: Natural Nude, Light Glam, Full Glam
- Style keywords: Fresh Sweet, Professional, Retro Vintage, Atmospheric, Minimalist Premium
- Color tone: Warm Tone, Cool Tone, Neutral Tone

Occasion tag options (choose 1-2):
- Daily Commute, Date Night, Workplace, Party Night, Casual Daily
- Time: Daytime Fresh, Nighttime Charming

Shot type options: Selfie, Others Shooting, Close-up Shot
Focus area options: Full Face, Eye Makeup, Lip Makeup, Base Makeup
Lighting options: Natural Light, Indoor Light, Strong Light
Occasion options: Daily, Date, Workplace, Party, Event
Season options: Spring/Summer, Fall/Winter, All Season
Time of day options: Day, Night

IMPORTANT: Return ONLY the JSON object, no additional text.''';

  static const String _userPrompt = '''Analyze this makeup photo and provide:
1. 3-5 style tags describing the makeup look
2. 1-2 occasion tags where this makeup would be suitable
3. Scene details including shot type, focus area, lighting, occasion, season, and time of day

Return the result as a JSON object following the exact format specified in the system prompt.''';

  MakeupAnalysisResult _parseResponse(String responseBody) {
    final responseData = jsonDecode(responseBody);
    final content = responseData['choices']?[0]?['message']?['content'] as String?;

    if (content == null || content.isEmpty) {
      throw MakeupAiException('AI returned empty content');
    }

    print('[MakeupAiService] Response Content: $content');

    String cleaned = content.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7).trim();
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3).trim();
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3).trim();
    }

    final jsonData = jsonDecode(cleaned);

    return MakeupAnalysisResult(
      imagePath: '',
      styleTags: List<String>.from(jsonData['style_tags'] as List),
      occasionTags: List<String>.from(jsonData['occasion_tags'] as List),
      recordNote: '',
      shotType: jsonData['shot_type'] as String,
      focusArea: jsonData['focus_area'] as String,
      lighting: jsonData['lighting'] as String,
      occasion: jsonData['occasion'] as String,
      season: jsonData['season'] as String,
      timeOfDay: jsonData['time_of_day'] as String,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<MakeupTrend>> analyzeTrends(List<MakeupRecord> records) async {
    await Future.delayed(const Duration(seconds: 1));

    if (records.isEmpty) return [];

    final styleMap = <String, int>{};
    final occasionMap = <String, int>{};

    for (final record in records) {
      for (final style in record.analysis.styleTags) {
        styleMap[style] = (styleMap[style] ?? 0) + 1;
      }
      for (final occasion in record.analysis.occasionTags) {
        occasionMap[occasion] = (occasionMap[occasion] ?? 0) + 1;
      }
    }

    final topStyles = styleMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return [
      MakeupTrend(
        title: 'Your Makeup Style',
        description: 'Based on ${records.length} records',
        styleDistribution: styleMap,
        occasionDistribution: occasionMap,
        topStyles: topStyles.take(3).map((e) => e.key).toList(),
      ),
    ];
  }

  void dispose() {
    if (!_isDisposed) {
      _client.close();
      _isDisposed = true;
    }
  }
}
