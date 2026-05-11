import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../data/models/cherish_moment.dart';
import 'ai_request_config.dart';
import 'ai_service_secrets.dart';

/// CherishMoment AI service exception.
class CherishMomentAiException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  CherishMomentAiException(
    this.message, {
    this.statusCode,
    this.responseBody,
  });

  @override
  String toString() => 'CherishMomentAiException: $message';
}

class CherishMomentAiService {
  static const String _baseUrl = AiRequestConfig.baseUrl;
  static const String _defaultApiKey = AiServiceSecrets.apiKey;
  static const String _model = AiRequestConfig.defaultModel;
  static const Duration _timeout = Duration(
    seconds: AiRequestConfig.timeoutSeconds,
  );

  static const String _sceneSystemPrompt = '''You are CherishLens Moment Weaver - a specialized AI that discovers beauty and meaning in everyday moments.

Your mission: Analyze the given photo and extract a Scene Card that captures the essence of this daily moment. You see the world through a lens of gratitude and emotional awareness.

Return ONLY valid JSON (no markdown, no extra text).

Core Philosophy:
- Every ordinary photo contains a "small happiness" waiting to be discovered
- Focus on emotional value, not just visual description
- Help users notice and appreciate the beauty they might overlook
- Be warm, empathetic, and positive in your analysis

Rules:
- UI copy must be in English.
- Do not identify real people or guess sensitive traits (age, race, religion, health, etc.).
- If a field is uncertain, choose "Unknown" and lower confidence.
- Use only the allowed enum values provided by the user message.
- Do not invent precise location names unless explicitly visible.
- Always look for the emotional warmth in the scene, even in simple settings.''';

  static const String _sceneUserPrompt = '''Analyze this photo for CherishLens and output a Scene Card JSON.

Allowed enums:
- time_of_day: ["Morning","Afternoon","Evening","Night","Unknown"]
- scene_type: ["Home","Outdoor","Workplace","Social","Solitude","Nature","Cafe","Transit","Unknown"]
- main_subject: ["Person","Food","Beverage","Plant","Pet","Object","Scenery","Activity","Workspace","Unknown"]
- emotional_tone: ["Serene","Warm","Energetic","Romantic","Cozy","Nostalgic","Peaceful","Hopeful","Melancholic","Unknown"]
- lighting_quality: ["Natural Bright","Soft Diffused","Warm Golden","Cool Blue","Dim Intimate","Dramatic","Unknown"]

Output schema (return ONLY JSON):
{
  "scene_card": {
    "time_of_day": {"value": "...", "confidence": 0.0, "evidence": "..."},
    "scene_type": {"value": "...", "confidence": 0.0, "evidence": "..."},
    "main_subject": {"value": "...", "confidence": 0.0, "evidence": "..."},
    "emotional_tone": {"value": "...", "confidence": 0.0, "evidence": "..."},
    "lighting_quality": {"value": "...", "confidence": 0.0, "evidence": "..."}
  },
  "one_line_moment": "...",
  "visual_elements": ["...","...","..."],
  "safety": {
    "has_sensitive_content": false,
    "notes": ""
  }
}

Notes:
- "evidence" is a short, non-sensitive visual cue that supports your analysis.
- "one_line_moment" is a poetic, one-line summary that captures the essence of this moment.
- "visual_elements" are 3-7 short English keywords describing notable visual features.
- If the image is too dark or blurred, set more fields to "Unknown".
- Always try to find the emotional warmth even in simple, ordinary scenes.

IMPORTANT:
- The photo is provided as an image input in this request.
- Return ONLY valid JSON, no markdown.''';

  static const String _contentSystemPrompt = '''You are CherishLens Content Creator - a warm, empathetic writer who transforms everyday moments into heartwarming reflections.

Your mission: Given a Scene Card and photo context, create a cherish essay that helps the user feel the emotional value of this moment.

Writing Style:
- Warm, gentle, and conversational
- Focus on emotional resonance, not flowery language
- Be authentic and sincere, avoid clichés
- Length: 150-200 words total
- Structure: 3 paragraphs (Opening -> Feeling -> Gratitude)

Rules:
- UI copy must be in English.
- Be honest about what you can see.
- Focus on genuine emotion, not forced positivity.
- If the scene is simple, celebrate simplicity itself.
- Generate 3-7 mood tags that feel organic and shareable.
- Recommend visual style based on emotional tone.
- Create a short, shareable caption.''';

  final http.Client _client;
  final String _apiKey;

  CherishMomentAiService({
    String? apiKey,
    http.Client? client,
  })  : _client = client ?? http.Client(),
        _apiKey = (apiKey ?? _defaultApiKey).trim();

  bool get hasApiKey => _apiKey.isNotEmpty;

  Future<CherishMoment> analyzeImage(File imageFile) async {
    if (!hasApiKey) {
      throw CherishMomentAiException(
        'AI API key not configured. Fill lib/tavia/cherish_ai/ai_service_secrets.dart first.',
      );
    }

    try {
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final scenePayload = await _requestJson(
        imageBase64: base64Image,
        systemPrompt: _sceneSystemPrompt,
        userPrompt: _sceneUserPrompt,
        maxTokens: 1000,
        temperature: 0.7,
      );

      final contentPayload = await _requestJson(
        imageBase64: base64Image,
        systemPrompt: _contentSystemPrompt,
        userPrompt: _buildContentUserPrompt(scenePayload),
        maxTokens: 2000,
        temperature: 0.8,
      );

      final merged = <String, dynamic>{
        ...scenePayload,
        ...contentPayload,
        'asset_img': imageFile.path,
      };

      return CherishMoment.fromJson(merged);
    } on SocketException {
      throw CherishMomentAiException('Network connection failed.');
    } on TimeoutException {
      throw CherishMomentAiException('Request timed out. Please try again.');
    } on CherishMomentAiException {
      rethrow;
    } catch (e) {
      throw CherishMomentAiException('Image analysis failed: $e');
    }
  }

  Future<Map<String, dynamic>> _requestJson({
    required String imageBase64,
    required String systemPrompt,
    required String userPrompt,
    required int maxTokens,
    required double temperature,
  }) async {
    final requestData = AiRequestConfig.buildRequestBody(
      imageBase64: imageBase64,
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      model: _model,
      maxTokens: maxTokens,
      temperature: temperature,
    );

    final response = await _client
        .post(
          Uri.parse('$_baseUrl${AiRequestConfig.endpoint}'),
          headers: AiRequestConfig.buildHeaders(_apiKey),
          body: jsonEncode(requestData),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw CherishMomentAiException(
        'API request failed.',
        statusCode: response.statusCode,
        responseBody: response.body,
      );
    }

    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    final content = AiRequestConfig.extractContent(responseData);

    if (content == null || content.trim().isEmpty) {
      throw CherishMomentAiException('AI returned empty content.');
    }

    final cleaned = AiRequestConfig.cleanJsonResponse(content);
    final jsonData = jsonDecode(cleaned);
    if (jsonData is! Map<String, dynamic>) {
      throw CherishMomentAiException('AI response is not a valid JSON object.');
    }
    return jsonData;
  }

  String _buildContentUserPrompt(Map<String, dynamic> scenePayload) {
    final sceneCardJson = jsonEncode(scenePayload['scene_card']);
    final oneLineMoment = scenePayload['one_line_moment'] as String? ?? '';
    final visualElements = jsonEncode(
      (scenePayload['visual_elements'] as List<dynamic>? ?? const []),
    );

    return '''Generate cherish content for this Scene Card:

SCENE_CARD_JSON: $sceneCardJson

ONE_LINE_MOMENT: $oneLineMoment

VISUAL_ELEMENTS: $visualElements

Output schema (return ONLY JSON):
{
  "cherish_essay": {
    "opening": "...",
    "feeling": "...",
    "gratitude": "..."
  },
  "mood_tags": ["#...","#...","#..."],
  "visual_style_recommendation": "Minimal White|Warm Beige|Soft Pastel|Dark Mood|Photo Overlay",
  "shareable_caption": "...",
  "card_title": "..."
}

Content Guidelines:
- Keep total essay length between 150-200 words.
- Be authentic. If the scene is simple, say so.
- Avoid exclamation marks. Use periods for a calm, reflective tone.
- If scene values are "Unknown", make the content more general but still warm.

Return ONLY valid JSON, no markdown.''';
  }

  void dispose() {
    _client.close();
  }
}
