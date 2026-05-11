import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../core/network/http_client.dart';
import '../data/models/scene_card.dart';

/// AI Analysis Exception
class ImageAnalysisException implements Exception {
  final String message;
  final int? statusCode;

  ImageAnalysisException(this.message, {this.statusCode});

  @override
  String toString() => 'ImageAnalysisException: $message${statusCode != null ? " (Status: $statusCode)" : ""}';
}

/// Image Analysis Service - AI-powered photo to scene card analyzer
///
/// Uses GPT-4o Vision API to analyze photos and generate Scene Cards
/// Supports two-stage analysis: Vision (Scene Card) + Lyric Recommendation
class ImageAnalysisService {
  ImageAnalysisService._();

  static final ImageAnalysisService _instance = ImageAnalysisService._();
  static ImageAnalysisService get I => _instance;

  static const String _visionModel = 'gpt-4o';
  static const String _lyricModel = 'gpt-4o';
  static const int _visionMaxTokens = 1500;
  static const int _lyricMaxTokens = 2000;

  ApiClient? _apiClient;

  /// Initialize with API client
  void init() {
    ApiClient.I.init();
    _apiClient ??= ApiClient.I;
  }

  /// Analyze image file and generate Scene Card (Stage 1: Vision only)
  ///
  /// Returns a SceneCard with all analysis results
  /// Throws [ImageAnalysisException] on failure
  Future<SceneCard> analyzeImage({
    required File imageFile,
    String? assetImgPath,
    ProgressCallback? onProgress,
  }) async {
    try {
      // Validate image file
      if (!await imageFile.exists()) {
        throw ImageAnalysisException('Image file does not exist');
      }

      // Stage 1: Vision Analysis
      onProgress?.call(0.3, 'Analyzing image...');

      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final sceneCardResult = await _analyzeSceneCard(base64Image);

      onProgress?.call(1.0, 'Analysis complete');

      // Combine with image path
      return SceneCard(
        assetImg: assetImgPath ?? 'asset_placeholder',
        sceneCard: sceneCardResult['scene_card'],
        visualStory: sceneCardResult['visual_story'],
        emotionalKeywords: List<String>.from(sceneCardResult['emotional_keywords']),
        suggestedLyricStyles: List<String>.from(sceneCardResult['suggested_lyric_styles']),
        safety: SafetyInfo.fromJson(sceneCardResult['safety']),
      );
    } on ImageAnalysisException {
      rethrow;
    } catch (e, stack) {
      debugPrint('ImageAnalysisService.analyzeImage error: $e\n$stack');
      throw ImageAnalysisException('Analysis failed: ${e.toString()}');
    }
  }

  /// Stage 1: Analyze image and generate Scene Card JSON
  Future<Map<String, dynamic>> _analyzeSceneCard(String base64Image) async {
    final prompt = _getVisionPrompt();

    final requestBody = {
      'model': _visionModel,
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': prompt,
            },
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:image/jpeg;base64,$base64Image',
              },
            },
          ],
        },
      ],
      'max_tokens': _visionMaxTokens,
      'temperature': 0.7,
    };

    debugPrint('ImageAnalysisService: Sending vision analysis request...');

    // Use api-gpt-ge.apifox.cn endpoint from documentation
    final apiClient = _apiClient ?? ApiClient.I..init();
    final response = await apiClient.post(
      '/v1/chat/completions',
      body: requestBody,
    );

    if (!response.success || response.data == null) {
      throw ImageAnalysisException(
        'Vision analysis failed',
        statusCode: response.statusCode,
      );
    }

    return _parseVisionResponse(response.data);
  }

  /// Parse vision analysis response and extract JSON
  Map<String, dynamic> _parseVisionResponse(dynamic responseData) {
    try {
      if (responseData is! Map<String, dynamic>) {
        throw FormatException('Response is not a JSON object');
      }

      final choices = responseData['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        throw FormatException('No choices in response');
      }

      final firstChoice = choices[0] as Map<String, dynamic>;
      final message = firstChoice['message'] as Map<String, dynamic>?;
      if (message == null) {
        throw FormatException('No message in choice');
      }

      String content = message['content'] as String? ?? '';
      content = _cleanJsonContent(content);

      final jsonMap = jsonDecode(content) as Map<String, dynamic>;

      // Validate required fields
      if (!jsonMap.containsKey('scene_card')) {
        throw FormatException('Missing scene_card field');
      }

      return jsonMap;
    } catch (e) {
      debugPrint('ImageAnalysisService._parseVisionResponse error: $e');
      throw ImageAnalysisException('Failed to parse vision response: ${e.toString()}');
    }
  }

  /// Clean JSON content from markdown code blocks or extra text
  String _cleanJsonContent(String content) {
    content = content.trim();

    // Remove markdown code blocks
    if (content.startsWith('```json')) {
      content = content.substring(7);
    } else if (content.startsWith('```')) {
      content = content.substring(3);
    }

    if (content.endsWith('```')) {
      content = content.substring(0, content.length - 3);
    }

    content = content.trim();

    // Find first { and last }
    final firstBrace = content.indexOf('{');
    final lastBrace = content.lastIndexOf('}');

    if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
      content = content.substring(firstBrace, lastBrace + 1);
    }

    return content;
  }

  /// Get vision analysis prompt from ai_analysis_prompt.md
  String _getVisionPrompt() {
    return '''Analyze this photo for LyricSnap and output a Scene Card JSON.

Allowed enums:
- location: ["Cafe","Beach","City Street","Home","Nature","Restaurant","Bar","Park","Office","Concert","Gym","Rooftop","Subway","Library","Unknown"]
- time: ["Morning","Afternoon","Evening","Night","Sunset","Sunrise","Midnight","Unknown"]
- atmosphere: ["Romantic","Cozy","Lonely","Energetic","Peaceful","Nostalgic","Mysterious","Dreamy","Melancholic","Hopeful","Adventurous","Intimate","Chaotic","Serene","Unknown"]
- subject: ["Portrait","Landscape","Food","Crowd","Silhouette","Night View","Pet","Object","Street Scene","Abstract","Unknown"]
- mood: ["Joyful","Contemplative","Romantic","Sad","Energetic","Calm","Excited","Melancholic","Hopeful","Lonely","Determined","Carefree","Unknown"]
- color_tone: ["Warm","Cool","High Saturation","Low Saturation","Monochrome","Pastel","Vibrant","Muted","Unknown"]

Output schema (return ONLY JSON):
{
  "scene_card": {
    "location": {"value": "...", "confidence": 0.0, "evidence": "..."},
    "time": {"value": "...", "confidence": 0.0, "evidence": "..."},
    "atmosphere": {"value": "...", "confidence": 0.0, "evidence": "..."},
    "subject": {"value": "...", "confidence": 0.0, "evidence": "..."},
    "mood": {"value": "...", "confidence": 0.0, "evidence": "..."},
    "color_tone": {"value": "...", "confidence": 0.0, "evidence": "..."}
  },
  "visual_story": "...",
  "emotional_keywords": ["...","...","..."],
  "suggested_lyric_styles": ["...","...","..."],
  "safety": {
    "has_sensitive_content": false,
    "notes": ""
  }
}''';
  }

  /// Dispose resources (if needed)
  void dispose() {
    // No resources to dispose currently
  }
}

/// Progress callback for analysis stages
typedef ProgressCallback = void Function(double progress, String message);
