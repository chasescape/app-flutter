import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../data/models/scene_card.dart';
import 'scene_ai_config.dart';

class SceneCardAiException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  SceneCardAiException(this.message, {this.statusCode, this.responseBody});

  @override
  String toString() => 'SceneCardAiException: $message';
}

class SceneCardAiService {
  SceneCardAiService._();

  static final SceneCardAiService I = SceneCardAiService._();

  static const Duration _timeout =
      Duration(seconds: SceneAiConfig.timeoutSeconds);

  static const String _systemPrompt = '''
You are LyricSnap Scene Analyzer, an AI specialized in understanding visual scenes for lyric matching.

Goal: Analyze the given photo and extract a Scene Card that captures the emotional and visual essence of the moment.
Return ONLY valid JSON (no markdown, no extra text).

Rules:
- Focus on emotional resonance: what feelings does this image evoke?
- Look beyond surface details to capture the mood and atmosphere.
- Do not identify real people or guess sensitive traits (age, race, religion, health, relationships).
- If a field is uncertain, choose "Unknown" and lower confidence.
- Use only the allowed enum values provided by the user message.
- Do not invent precise location names (no specific venues/addresses).
- Pay special attention to lighting, colors, and composition as emotional cues.
''';

  static const String _userPrompt = '''
Analyze this photo for LyricSnap and output a Scene Card JSON.

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
}

Notes:
- "evidence" is a short visual or emotional cue (e.g., "warm golden hour lighting", "solitary figure on bench", "faint smile in eyes").
- "visual_story" is a 1-2 sentence narrative that captures the emotional essence of the scene.
- "emotional_keywords" are 3-8 feeling words that resonate with this image.
- "suggested_lyric_styles" are 2-4 styles that would fit this moment (e.g., "romantic ballad", "upbeat pop", "melancholic acoustic").

IMPORTANT:
- The photo is provided as an image input in this request.
- Prioritize emotional accuracy over technical perfection.
''';

  Future<SceneCard> analyzeImage(
    File imageFile, {
    String? assetImgPath,
    String? apiKey,
  }) async {
    if (!await imageFile.exists()) {
      throw SceneCardAiException('Image file does not exist');
    }

    final effectiveApiKey = apiKey ?? SceneAiConfig.defaultApiKey;
    if (effectiveApiKey == 'YOUR_AI_API_KEY_HERE') {
      throw SceneCardAiException(
        'Please set your API key in lib/midora/scene_ai/scene_ai_config.dart',
      );
    }

    final imageBytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);
    final client = http.Client();

    try {
      final response = await client
          .post(
            Uri.parse('${SceneAiConfig.baseUrl}/v1/chat/completions'),
            headers: _buildHeaders(effectiveApiKey),
            body: jsonEncode(_buildRequestBody(base64Image)),
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw SceneCardAiException(
          'API request failed',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }

      return _parseResponse(
        response.body,
        assetImgPath: assetImgPath ?? 'asset_placeholder',
      );
    } on SocketException {
      throw SceneCardAiException('Network connection failed');
    } on TimeoutException {
      throw SceneCardAiException('Request timed out');
    } on SceneCardAiException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('SceneCardAiService error: $e\n$stackTrace');
      throw SceneCardAiException('Analysis failed: $e');
    } finally {
      client.close();
    }
  }

  Map<String, String> _buildHeaders(String apiKey) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
  }

  Map<String, dynamic> _buildRequestBody(String imageBase64) {
    return {
      'model': SceneAiConfig.model,
      'messages': [
        {'role': 'system', 'content': _systemPrompt},
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': _userPrompt},
            {
              'type': 'image_url',
              'image_url': {'url': 'data:image/jpeg;base64,$imageBase64'}
            }
          ]
        }
      ],
      'max_tokens': SceneAiConfig.maxTokens,
      'temperature': SceneAiConfig.temperature,
    };
  }

  SceneCard _parseResponse(
    String responseBody, {
    required String assetImgPath,
  }) {
    final responseData = jsonDecode(responseBody) as Map<String, dynamic>;
    final content = responseData['choices']?[0]?['message']?['content'];

    if (content is! String || content.isEmpty) {
      throw SceneCardAiException('AI returned empty content');
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
    jsonData['assetImg'] = assetImgPath;
    return SceneCard.fromJson(jsonData);
  }
}
