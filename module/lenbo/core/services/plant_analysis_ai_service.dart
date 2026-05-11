import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:lenbo/lenbo/data/models/plant_analysis.dart';
import 'package:lenbo/lenbo/core/services/ai_request_config.dart';

/// Plant analysis AI service exception
class PlantAnalysisAiException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  PlantAnalysisAiException(this.message, {this.statusCode, this.responseBody});

  @override
  String toString() => 'PlantAnalysisAiException: $message';
}

/// AI service for plant photo analysis using OpenAI-compatible API.
class PlantAnalysisAiService {
  static const String _baseUrl = AiRequestConfig.baseUrl;
  static const String _endpoint = AiRequestConfig.endpoint;
  static const String _model = AiRequestConfig.defaultModel;
  static const int _maxTokens = AiRequestConfig.defaultMaxTokens;
  static const double _temperature = AiRequestConfig.defaultTemperature;
  static const Duration _timeout = Duration(seconds: AiRequestConfig.timeoutSeconds);

  static const String _systemPrompt = r'''You are VerdiLens Plant Care Expert — a warm, knowledgeable botanist and horticulturist combined into one AI assistant.

Your mission: Analyze a plant photo and produce a comprehensive care guide that helps everyday plant owners understand their green friends and keep them thriving.

Personality:
- Friendly and encouraging, like a knowledgeable plant-loving friend
- Clear and practical — no jargon without explanation
- Honest but optimistic — flag problems gently, always include a solution

Rules:
- UI copy must be in English.
- Do NOT identify real people, faces, or guess personal attributes.
- If uncertain about the plant species, provide your best guess and note the uncertainty.
- Use only the allowed enum values specified in the user message.
- Keep all text fields concise and mobile-friendly (short paragraphs, bullet-ready).
- Do NOT make medical claims about plants being edible/medicinal.
- Do NOT recommend specific commercial products by brand name.
- Return ONLY valid JSON — no markdown fences, no extra text, no explanations outside the JSON.''';

  static const String _userPromptTemplate = r'''Analyze this plant photo for VerdiLens and return a complete Plant Care Guide.

Allowed enums:
- health_status: ["Healthy","Sub-Healthy","Needs Attention","Critical","Unknown"]
- growth_stage: ["Seedling","Young","Mature","Flowering","Fruiting","Dormant","Unknown"]
- light_env: ["Bright Direct","Bright Indirect","Medium Indirect","Low Light","Artificial Light","Outdoor Full Sun","Outdoor Shade","Unknown"]
- soil_moisture_visual: ["Dry","Slightly Dry","Moist","Wet","Waterlogged","Unknown"]
- difficulty_level: ["Beginner-Friendly","Moderate","Advanced","Expert"]
- watering_frequency: ["Daily","Every 2-3 Days","Once a Week","Every 10-14 Days","Every 2-3 Weeks","Monthly","Unknown"]

Output schema (return ONLY JSON):
{
  "plant_id": {
    "common_name": "...",
    "scientific_name": "...",
    "family": "...",
    "other_names": ["...","..."],
    "identification_confidence": 0.0,
    "fun_fact": "..."
  },
  "health_check": {
    "status": "...",
    "confidence": 0.0,
    "visual_evidence": "...",
    "symptoms": ["...","..."],
    "overall_impression": "..."
  },
  "environment_reading": {
    "light_env": "...",
    "soil_moisture_visual": "...",
    "pot_type_guess": "Potted|In Ground|Hanging|Unknown",
    "indoor_or_outdoor": "Indoor|Outdoor|Unknown"
  },
  "growth_info": {
    "stage": "...",
    "difficulty_level": "...",
    "expected_lifespan": "...",
    "max_height": "..."
  },
  "care_guide": {
    "summary": "...",
    "watering": {
      "frequency": "...",
      "method": "...",
      "seasonal_note": "..."
    },
    "light": {
      "ideal_condition": "...",
      "current_assessment": "...",
      "adjustment_tip": "..."
    },
    "fertilizing": {
      "schedule": "...",
      "recommended_type": "...",
      "seasonal_note": "..."
    },
    "temperature": {
      "ideal_range": "...",
      "tolerance": "..."
    },
    "humidity": {
      "ideal_level": "...",
      "boost_methods": ["...","..."]
    }
  },
  "common_issues": [
    {
      "problem": "...",
      "cause": "...",
      "prevention": "...",
      "fix": "..."
    }
  ],
  "pro_tip": "...",
  "plant_personality": "...",
  "safety": {
    "toxicity_note": "...",
    "pet_safe": true,
    "has_sensitive_content": false,
    "notes": ""
  }
}

Field guidelines:
- "fun_fact": One surprising or delightful fact about this plant species (1-2 sentences).
- "visual_evidence": What you see in the photo that supports the health assessment.
- "symptoms": List specific visible symptoms (0-4 items). Empty array if healthy.
- "overall_impression": One warm sentence summarizing the plant's current condition.
- "watering.method": Brief description of HOW to water.
- "pro_tip": One practical, non-obvious care hack.
- "plant_personality": A fun, relatable personality description in 1-2 sentences.
- "toxicity_note": Brief toxicity warning if applicable, or "No known toxicity concerns.".
- "common_issues": Exactly 2-3 items. Focus on issues relevant to the detected health status and growth environment.
- "difficulty_level": Based on how demanding this species is for a typical indoor grower.
- "pet_safe": Boolean. Research-based. When uncertain, default to false and note in toxicity_note.

IMPORTANT:
- The photo is provided as an image input in this request.
- If the image is too dark, blurry, or not a plant, set health_status to "Unknown" and explain in overall_impression.
- Keep every text field concise — this is for a mobile app UI.
- Exactly 2-3 items in "common_issues".
- Exactly 2-3 items in "other_names" (common aliases/varieties, or empty if none).
- Exactly 1-3 items in "humidity.boost_methods".''';

  late final GetConnect _client;
  final String _apiKey;
  bool _disposed = false;

  PlantAnalysisAiService({String apiKey = ''}) : _apiKey = apiKey {
    _client = GetConnect();
    _client.baseUrl = _baseUrl;
    _client.timeout = _timeout;
    _client.httpClient.defaultDecoder = (body) => body;
  }

  /// Analyze a plant image and return a [PlantAnalysis] result.
  Future<PlantAnalysis> analyzePlant(
    Uint8List imageBytes, {
    String? apiKey,
    String mimeType = 'image/jpeg',
  }) async {
    if (_disposed) {
      throw PlantAnalysisAiException('Service has been disposed');
    }

    try {
      final base64Image = base64Encode(imageBytes);
      final requestBody = AiRequestConfig.buildRequestBody(
        imageBase64: base64Image,
        systemPrompt: _systemPrompt,
        userPrompt: _userPromptTemplate,
        model: _model,
        maxTokens: _maxTokens,
        temperature: _temperature,
      );

      final resolvedApiKey = (apiKey != null && apiKey.isNotEmpty) ? apiKey : _apiKey;
      final headers = resolvedApiKey.isNotEmpty
          ? AiRequestConfig.buildHeaders(resolvedApiKey)
          : <String, String>{
              'Content-Type': 'application/json',
            };

      print('[PlantAnalysisAiService] Sending request to $_baseUrl$_endpoint');
      print('[PlantAnalysisAiService] Model: $_model, Image size: ${imageBytes.length} bytes');

      final response = await _client.post(
        _endpoint,
        requestBody,
        headers: headers,
      );

      print('[PlantAnalysisAiService] Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return _parseResponse(response.body);
      } else {
        final bodyStr = response.body is String
            ? response.body.toString()
            : jsonEncode(response.body);
        throw PlantAnalysisAiException(
          'API request failed with status ${response.statusCode}',
          statusCode: response.statusCode,
          responseBody: bodyStr,
        );
      }
    } on SocketException {
      throw PlantAnalysisAiException(
        'Network connection failed, please check your network',
      );
    } on TimeoutException {
      throw PlantAnalysisAiException(
        'Request timed out, please try again later',
      );
    } on PlantAnalysisAiException {
      rethrow;
    } catch (e) {
      throw PlantAnalysisAiException('Analysis failed: $e');
    }
  }

  /// Parse the API response into a [PlantAnalysis] model.
  PlantAnalysis _parseResponse(dynamic responseBody) {
    try {
      final data = responseBody is String
          ? jsonDecode(responseBody)
          : responseBody as Map<String, dynamic>;

      final content = AiRequestConfig.extractContent(data);

      if (content == null || content.isEmpty) {
        throw PlantAnalysisAiException('AI returned empty content');
      }

      print('[PlantAnalysisAiService] AI Content (first 200 chars):');
      final preview =
          content.length > 200 ? '${content.substring(0, 200)}...' : content;
      print(preview);

      final cleaned = AiRequestConfig.cleanJsonResponse(content);
      final jsonData = jsonDecode(cleaned) as Map<String, dynamic>;
      return PlantAnalysis.fromJson(jsonData);
    } on FormatException catch (e) {
      throw PlantAnalysisAiException(
        'Failed to parse AI response as JSON: $e',
      );
    } catch (e) {
      if (e is PlantAnalysisAiException) rethrow;
      throw PlantAnalysisAiException('Failed to parse analysis result: $e');
    }
  }

  void dispose() {
    _disposed = true;
  }
}
