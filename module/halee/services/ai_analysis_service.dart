import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/snap_analysis.dart';
import 'ai_request_config.dart';
import '../env/app_env.dart';

class AiAnalysisException implements Exception {
  final String message;
  final int? statusCode;

  AiAnalysisException(this.message, {this.statusCode});

  @override
  String toString() =>
      'AiAnalysisException: $message${statusCode != null ? ' (status: $statusCode)' : ''}';
}

class AiAnalysisService {
  static const String _apiPath = AiRequestConfig.endpoint;
  static const String _model = 'claude-sonnet-4-20250514';
  static const String _fallbackModel = AiRequestConfig.defaultModel;
  static const int _maxTokens = 2048;
  static const double _temperature = 0.7;

  GetConnect? _connect;

  GetConnect get _client {
    _connect ??= GetConnect()
      ..baseUrl = AppEnv().hostAi
      ..timeout = const Duration(seconds: AiRequestConfig.timeoutSeconds)
      ..httpClient.addRequestModifier<dynamic>((request) {
        request.headers.addAll(AiRequestConfig.buildHeaders(AppEnv().aiApiKey));
        return request;
      });
    return _connect!;
  }

  Future<SnapAnalysis> analyzeImage(String imagePath) async {
    if (!File(imagePath).existsSync()) {
      throw AiAnalysisException('Image file not found: $imagePath');
    }
    if (AppEnv().hostAi.isEmpty) {
      throw AiAnalysisException('AI host is not configured');
    }
    if (AppEnv().aiApiKey.isEmpty) {
      throw AiAnalysisException(
        'AI API key not configured. Set AppEnv().aiApiKey in ${_configEntryFile()}.',
      );
    }
    if (_looksLikePlaceholder(AppEnv().aiApiKey)) {
      throw AiAnalysisException(
        'AI API key is still a placeholder. Replace it in ${_configEntryFile()}.',
      );
    }

    final base64Image = await _imageToBase64(imagePath);
    final mimeType = _resolveMimeType(imagePath);
    debugPrint('[AiService] base64 length: ${base64Image.length}');

    final response = await _sendWithFallback(
      base64Image: base64Image,
      imageMimeType: mimeType,
    );
    return _parseResponse(response, imagePath: imagePath);
  }

  Future<String> _imageToBase64(String path) async {
    final bytes = await File(path).readAsBytes();
    if (bytes.isEmpty) {
      throw AiAnalysisException('Image file is empty');
    }
    return base64Encode(bytes);
  }

  Map<String, dynamic> _buildRequestBody(
    String base64Image, {
    required String model,
    required String imageMimeType,
  }) {
    return AiRequestConfig.buildRequestBody(
      imageBase64: base64Image,
      imageMimeType: imageMimeType,
      systemPrompt: _systemPrompt,
      userPrompt: _userPrompt,
      model: model,
      maxTokens: _maxTokens,
      temperature: _temperature,
    );
  }

  Future<Map<String, dynamic>> _sendWithFallback({
    required String base64Image,
    required String imageMimeType,
  }) async {
    try {
      final primaryBody = _buildRequestBody(
        base64Image,
        model: _model,
        imageMimeType: imageMimeType,
      );
      return await _sendRequest(primaryBody);
    } on AiAnalysisException catch (e) {
      final shouldRetry =
          _fallbackModel != _model && _isLikelyRequestFormatError(e.message);
      if (!shouldRetry) rethrow;

      debugPrint(
        '[AiService] retry with fallback model: $_fallbackModel, reason: ${e.message}',
      );
      final fallbackBody = _buildRequestBody(
        base64Image,
        model: _fallbackModel,
        imageMimeType: imageMimeType,
      );
      return _sendRequest(fallbackBody);
    }
  }

  Future<Map<String, dynamic>> _sendRequest(Map<String, dynamic> body) async {
    try {
      final response = await _client.post(_apiPath, body);
      debugPrint('[AiService] status: ${response.statusCode}');

      if (response.statusCode != 200) {
        final errorMsg = _extractErrorMessage(
          response.body,
          bodyString: response.bodyString,
          statusCode: response.statusCode,
        );
        throw AiAnalysisException(
          'API error: $errorMsg',
          statusCode: response.statusCode,
        );
      }

      return _responseAsMap(response.body);
    } on AiAnalysisException {
      rethrow;
    } on Exception catch (e) {
      throw AiAnalysisException('Network error: $e');
    } catch (e) {
      if (e is AiAnalysisException) rethrow;
      throw AiAnalysisException('Request failed: $e');
    }
  }

  SnapAnalysis _parseResponse(
    Map<String, dynamic> responseData, {
    required String imagePath,
  }) {
    try {
      final content = AiRequestConfig.extractContent(responseData);
      if (content == null || content.isEmpty) {
        throw AiAnalysisException('Empty content in response');
      }

      _logContent(content);
      debugPrint('[AiService] content length: ${content.length}');

      final cleaned = AiRequestConfig.cleanJsonResponse(content);
      final start = cleaned.indexOf('{');
      final end = cleaned.lastIndexOf('}');
      if (start == -1 || end == -1 || end < start) {
        throw AiAnalysisException('No valid JSON found in response');
      }

      final jsonStr = cleaned.substring(start, end + 1);
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return SnapAnalysis.fromJson(
        json,
        assetImg: imagePath,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      if (e is AiAnalysisException) {
        rethrow;
      }
      throw AiAnalysisException('Failed to parse AI response: $e');
    }
  }

  Map<String, dynamic> _responseAsMap(dynamic body) {
    if (body is Map<String, dynamic>) {
      return body;
    }
    if (body is String && body.isNotEmpty) {
      return jsonDecode(body) as Map<String, dynamic>;
    }
    throw AiAnalysisException('Unexpected API response format');
  }

  String _extractErrorMessage(
    dynamic body, {
    String? bodyString,
    int? statusCode,
  }) {
    final messageFromBody = _extractMessageFromDynamic(body);
    if (messageFromBody != null && messageFromBody.isNotEmpty) {
      return messageFromBody;
    }

    if (bodyString != null && bodyString.trim().isNotEmpty) {
      final messageFromString = _extractMessageFromString(bodyString);
      if (messageFromString != null && messageFromString.isNotEmpty) {
        return messageFromString;
      }
      return 'HTTP ${statusCode ?? '-'}: ${_truncate(bodyString.trim())}';
    }

    return 'HTTP ${statusCode ?? '-'} with empty error body';
  }

  String? _extractMessageFromDynamic(dynamic body) {
    if (body is Map<String, dynamic>) {
      final error = body['error'];
      if (error is Map<String, dynamic>) {
        final nestedMessage = error['message'];
        if (nestedMessage is String && nestedMessage.trim().isNotEmpty) {
          return nestedMessage.trim();
        }
      }

      for (final key in ['message', 'msg', 'detail', 'error_description']) {
        final value = body[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }

      return null;
    }

    if (body is String && body.trim().isNotEmpty) {
      return _extractMessageFromString(body.trim()) ?? body.trim();
    }

    return null;
  }

  String? _extractMessageFromString(String bodyString) {
    try {
      final decoded = jsonDecode(bodyString);
      return _extractMessageFromDynamic(decoded);
    } catch (_) {
      return null;
    }
  }

  String _truncate(String value, {int maxLength = 180}) {
    if (value.length <= maxLength) {
      return value;
    }
    return '${value.substring(0, maxLength)}...';
  }

  bool _isLikelyRequestFormatError(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('improperly formed request') ||
        normalized.contains('invalid_request_error') ||
        normalized.contains('malformed') ||
        normalized.contains('unsupported model');
  }

  String _resolveMimeType(String imagePath) {
    final lower = imagePath.toLowerCase();
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    if (lower.endsWith('.webp')) {
      return 'image/webp';
    }
    if (lower.endsWith('.heic')) {
      return 'image/heic';
    }
    return 'image/jpeg';
  }

  bool _looksLikePlaceholder(String value) {
    final normalized = value.trim().toUpperCase();
    return normalized.isEmpty ||
        normalized == 'YOUR_VAPI_KEY' ||
        normalized == 'YOUR_API_KEY' ||
        normalized.contains('YOUR_') ||
        normalized.contains('PLACEHOLDER');
  }

  String _configEntryFile() {
    return AppEnv().env == AppEnvType.product
        ? 'lib/main_prod.dart'
        : 'lib/main_dev.dart';
  }

  void _logContent(String content) {
    debugPrint('[AiService] response content:');
    debugPrint(content);
  }

  void dispose() {
    _connect?.dispose();
    _connect = null;
  }

  static const String _systemPrompt =
      '''You are NextSnap Creative Director — a practical, encouraging photography advisor embedded in a mobile app called NextSnap.

Your mission: When a user uploads a photo, analyze it and return actionable creative direction — not abstract art criticism, but concrete "move here, wait for this light, try this angle" advice that the user can immediately act on for their NEXT shot.

Your personality:
- Encouraging and specific — like a knowledgeable friend who happens to be a great photographer
- Forward-looking — always frame advice around "what to do next", not just "what went wrong"
- Practical — use everyday language, explain technical terms when they appear
- Concise — every sentence should earn its place on a mobile screen

Non-negotiable rules:
- UI-facing text must be in English.
- Never identify real people or guess sensitive attributes (age, race, identity, relationships, health, location specifics).
- Never fabricate specific venue names, addresses, or brand/model names.
- If a field is uncertain, use "Unknown" and lower the confidence value.
- Only use enum values provided in the user message.
- Do not give medical, legal, or safety advice.
- Return ONLY valid JSON. No markdown wrapping, no extra text, no code fences.''';

  static const String _userPrompt =
      '''Analyze this photo for NextSnap and output a full creative direction analysis.

Allowed enums:
- subject_type: ["Portrait","Landscape","Architecture","Food","Nature","Street","Still Life","Abstract","Animal","Vehicle","Night Scene","Unknown"]
- scene: ["Indoor","Outdoor","Urban","Nature","Beach","Mountain","Studio","Cafe","Home","Rooftop","Unknown"]
- lighting: ["Natural Soft","Natural Hard","Golden Hour","Blue Hour","Backlit","Side Lit","Overcast","Artificial Warm","Artificial Cool","Mixed","Low Light","Unknown"]
- composition: ["Center Framed","Rule of Thirds","Symmetrical","Leading Lines","Diagonal","Frame within Frame","Minimalist","Layered","Unknown"]
- color_tone: ["Warm","Cool","Neutral","High Contrast","Low Saturation","Monochrome","Vibrant","Pastel","Dark & Moody","Bright & Airy","Unknown"]
- atmosphere: ["Serene","Dramatic","Playful","Mysterious","Cozy","Energetic","Melancholic","Nostalgic","Romantic","Raw","Fresh","Unknown"]
- improvement_category: ["Angle & Perspective","Lighting","Composition","Timing","Framing","Color & Tone","Subject Placement","Background","Foreground Interest","Camera Settings","Unknown"]
- variant_style: ["Minimalist","Cinematic","Documentary","Fine Art","Storytelling","Abstract","Vintage Film","High Fashion","Street Photography","Macro","Symmetrical","Negative Space","Motion Blur","Silhouette","Reflection","Unknown"]

Output schema (return ONLY JSON):
{
  "scene_card": {
    "subject_type": {"value": "...", "confidence": 0.0, "evidence": "..."},
    "scene": {"value": "...", "confidence": 0.0, "evidence": "..."},
    "lighting": {"value": "...", "confidence": 0.0, "evidence": "..."},
    "composition": {"value": "...", "confidence": 0.0, "evidence": "..."},
    "color_tone": {"value": "...", "confidence": 0.0, "evidence": "..."},
    "atmosphere": {"value": "...", "confidence": 0.0, "evidence": "..."}
  },
  "diagnosis": {
    "one_line_summary": "...",
    "strengths": ["...", "..."],
    "top_improvement": "..."
  },
  "improvement_tips": [
    {
      "category": "...",
      "title": "...",
      "action": "...",
      "expected_result": "..."
    }
  ],
  "creative_variants": [
    {
      "style": "...",
      "description": "...",
      "execution_tip": "..."
    }
  ],
  "fun_fact": "...",
  "share_caption": "...",
  "tags": ["...", "...", "..."],
  "safety": {
    "has_sensitive_content": false,
    "notes": ""
  }
}

Field guidelines:
- scene_card: Identify what is in the photo. "evidence" is a short visual cue (e.g., "person standing center", "warm sunset glow", "buildings in background").
- diagnosis.one_line_summary: 1-2 sentences summarizing the photo current state in a friendly tone.
- diagnosis.strengths: 2-3 short bullets about what works well (e.g., "Beautiful warm color palette", "Strong leading lines").
- diagnosis.top_improvement: 1 sentence about the single most impactful change to make.
- improvement_tips: Exactly 3 items. Each must be a CONCRETE, ACTIONABLE suggestion a user can follow for their next shot.
  - "title": Short direction name (e.g., "Lower your angle", "Wait for golden hour", "Simplify the background").
  - "action": 1-2 sentences explaining exactly what to do (move, wait, adjust, etc.). Be physical and specific.
  - "expected_result": 1 sentence describing the visual outcome (e.g., "Creates a more intimate connection with the subject").
- creative_variants: Exactly 3 items. Each suggests a different creative direction for the SAME scene.
  - "style": One of the allowed variant_style enum values.
  - "description": 1 sentence painting the picture of what this version would look like.
  - "execution_tip": 1 sentence on how to achieve it.
- fun_fact: 1 short photography tip or fun knowledge related to the scene. Keep it surprising and useful.
- share_caption: A catchy 1-2 sentence caption the user could post with their photo on social media. Make it engaging and natural.
- tags: 5-10 short English hashtags related to the photo and photography.
- safety: If the image contains faces, license plates, IDs, or children, set has_sensitive_content to true and describe what should be masked before sharing.

IMPORTANT:
- The photo is provided as an image input in this request.
- Be encouraging. Frame everything as "try this" not "you did this wrong".
- If the image is too dark, blurry, or low quality, still provide analysis but note the quality constraint in diagnosis.top_improvement.''';
}
