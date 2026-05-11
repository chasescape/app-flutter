import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/makeup_analysis.dart';
import '../env/app_env.dart';
import 'ai_request_config.dart';

class MakeupAnalysisException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  MakeupAnalysisException(
    this.message, {
    this.statusCode,
    this.responseBody,
  });

  @override
  String toString() => 'MakeupAnalysisException: $message';
}

class MakeupAiService {
  static MakeupAiService? _instance;
  factory MakeupAiService() => _instance ??= MakeupAiService._internal();

  MakeupAiService._internal() : _dio = _createDio();

  static const Duration _timeout =
      Duration(seconds: AiRequestConfig.timeoutSeconds);
  static const String _model = AiRequestConfig.defaultModel;

  static const String _systemPrompt =
      '''You are GlowCue Makeup Advisor, a professional makeup consultant specializing in face-feature-based makeup recommendations.

Your expertise:
- Analyzing facial features (eye presence, lip presence, overall vibe) to recommend suitable makeup directions
- Generating practical, searchable makeup keywords that help users find tutorials on YouTube, Xiaohongshu, and other platforms
- Providing beginner-friendly "start with" guidance to lower the learning curve
- Suggesting appropriate occasions for specific makeup looks

Core principles:
- Focus on enhancing natural features, not changing them
- Provide actionable keywords users can copy and search directly
- Avoid judging appearance, beauty scores, or attractiveness ratings
- Never give medical skincare advice, age judgments, or plastic surgery suggestions
- Keep responses encouraging and practical

Return ONLY valid JSON (no markdown, no extra text).''';

  static const String _userPromptTemplate =
      '''Analyze this selfie for personalized makeup recommendations.

Allowed enums for facial feature analysis:
- eye_presence: ["soft", "natural", "defined", "dramatic", "unclear"]
- lip_presence: ["soft", "natural", "bold", "unclear"]
- overall_vibe: ["light_and_fresh", "soft_glam", "defined_polished", "unclear"]
- skin_undertone: ["cool", "warm", "neutral", "unclear"]
- face_structure: ["delicate", "balanced", "bold", "unclear"]

Makeup direction enum (primary_style):
- "soft_peach_glow"
- "clean_base_makeup"
- "defined_eye_focus"
- "natural_flush"
- "soft_glam_even"
- "lifted_fresh"
- "muted_rose_vibes"
- "polished_natural"

Occasion enum:
- "daily_commute"
- "date_night"
- "content_shooting"
- "office_work"
- "weekend_brunch"
- "casual_hangout"
- "special_event"
- "gym_activity"

Output schema (return ONLY JSON):
{
  "assetImg": "A.assets_bilra_1",
  "face_analysis": {
    "eye_presence": {"value": "...", "confidence": 0.0, "evidence": "..."},
    "lip_presence": {"value": "...", "confidence": 0.0, "evidence": "..."},
    "overall_vibe": {"value": "...", "confidence": 0.0, "evidence": "..."},
    "skin_undertone": {"value": "...", "confidence": 0.0, "evidence": "..."},
    "face_structure": {"value": "...", "confidence": 0.0, "evidence": "..."}
  },
  "makeup_recommendation": {
    "primary_style": "...",
    "style_tagline": "...",
    "keywords": ["...", "...", "...", "...", "...", "..."],
    "why_it_works": "...",
    "start_with_tip": "..."
  },
  "search_guidance": {
    "tutorial_search_terms": ["...", "..."],
    "copyable_search_phrase": "...",
    "recommended_platforms": ["YouTube", "Xiaohongshu", "Instagram"]
  },
  "occasion_match": {
    "suitable_occasions": ["...", "..."],
    "occasion_notes": "..."
  },
  "quality_check": {
    "is_analyzable": true,
    "retry_reason": "",
    "image_quality_notes": ""
  }
}

Field explanations:
- "evidence": Brief, non-sensitive visual cue (e.g., "visible eye shape definition", "natural lip color visible", "bright even lighting")
- "style_tagline": One catchy phrase summarizing the makeup direction (e.g., "Soft Peach Glow for Everyday Freshness")
- "keywords": 5-8 specific makeup keywords covering base, eyes, brows, blush, lips
- "why_it_works": 1-2 sentences explaining why this direction suits the facial features
- "start_with_tip": Beginner-friendly sequence advice (e.g., "start with base makeup and brow shape first")
- "copyable_search_phrase": A complete, ready-to-copy search sentence in English

Quality check rules:
- If image is too dark, blurry, or face is obstructed: set "is_analyzable": false and provide "retry_reason"
- If angle is too extreme (not front or semi-side face): suggest retaking
- Valid "retry_reason" examples: "lighting too dark", "face covered", "angle too side"

IMPORTANT:
- The selfie image is provided as image input in this request.
- All user-facing text must be in English.
- Do not identify specific people, guess age, or make health/medical claims.''';

  final Dio _dio;

  static Dio _createDio() {
    return Dio(
      BaseOptions(
        baseUrl: AiRequestConfig.baseUrl,
        connectTimeout: _timeout,
        receiveTimeout: _timeout,
        sendTimeout: _timeout,
      ),
    );
  }

  Future<MakeupAnalysis> analyzeImage(
    String imagePath, {
    String? assetImgOverride,
  }) async {
    final apiKey = AppEnv().geApiKey;
    if (apiKey.isEmpty) {
      throw MakeupAnalysisException('API Key not configured');
    }

    try {
      final imageBase64 = await _readImageBase64(imagePath);
      final requestData = AiRequestConfig.buildRequestBody(
        imageBase64: imageBase64,
        systemPrompt: _systemPrompt,
        userPrompt: _userPromptTemplate,
        model: _model,
      );

      final response = await _dio
          .post(
            AiRequestConfig.endpoint,
            data: requestData,
            options: Options(
              headers: AiRequestConfig.buildHeaders(apiKey),
            ),
          )
          .timeout(_timeout);

      _logResponse(response);

      if (response.statusCode != 200) {
        throw MakeupAnalysisException(
          'API request failed',
          statusCode: response.statusCode,
          responseBody: response.data?.toString(),
        );
      }

      final responseData = _normalizeResponseData(response.data);
      final content = AiRequestConfig.extractContent(responseData);
      if (content == null || content.isEmpty) {
        throw MakeupAnalysisException('AI returned empty content');
      }

      _logContent(content);

      final cleanedJson = AiRequestConfig.cleanJsonResponse(content);
      final jsonData = jsonDecode(cleanedJson) as Map<String, dynamic>;

      if (assetImgOverride != null && assetImgOverride.isNotEmpty) {
        jsonData['assetImg'] = assetImgOverride;
      }

      final qualityCheck = jsonData['quality_check'] as Map<String, dynamic>?;
      if (qualityCheck != null && qualityCheck['is_analyzable'] == false) {
        final retryReason = qualityCheck['retry_reason'] as String? ??
            'Image cannot be analyzed';
        final imageQualityNotes =
            qualityCheck['image_quality_notes'] as String? ?? '';
        throw MakeupAnalysisException(
          imageQualityNotes.isNotEmpty
              ? '$retryReason. $imageQualityNotes'
              : retryReason,
        );
      }

      return MakeupAnalysis.fromJson(jsonData);
    } on SocketException {
      throw MakeupAnalysisException('Network connection failed');
    } on TimeoutException {
      throw MakeupAnalysisException('Request timed out, please try again');
    } on DioException catch (e) {
      throw MakeupAnalysisException(
        'Network error: ${e.message}',
        statusCode: e.response?.statusCode,
        responseBody: e.response?.data?.toString(),
      );
    } on FormatException catch (e) {
      throw MakeupAnalysisException(
        'Failed to parse AI response: ${e.message}',
      );
    } on MakeupAnalysisException {
      rethrow;
    } catch (e) {
      throw MakeupAnalysisException('Unexpected error: $e');
    }
  }

  Future<String> _readImageBase64(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw MakeupAnalysisException('Image file not found: $imagePath');
    }

    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  Map<String, dynamic> _normalizeResponseData(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is String) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    throw const FormatException('Invalid API response format');
  }

  void _logResponse(Response<dynamic> response) {
    debugPrint('[MakeupAiService] Response Status: ${response.statusCode}');
  }

  void _logContent(String content) {
    debugPrint('[MakeupAiService] Response Content:');
    debugPrint(content);
  }

  void dispose() {
    _dio.close(force: true);
  }
}
