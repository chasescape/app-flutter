import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../env/app_env.dart';
import '../models/hairstyle_analysis.dart';
import 'ai_request_config.dart';

class HairstyleAnalysisAiException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  HairstyleAnalysisAiException(
    this.message, {
    this.statusCode,
    this.responseBody,
  });

  @override
  String toString() => 'HairstyleAnalysisAiException: $message';
}

class HairstyleAnalysisAiService {
  HairstyleAnalysisAiService({
    String? apiKey,
    Dio? dio,
  })  : _apiKey = (apiKey ?? AppEnv().geApiKey).trim(),
        _baseUrl = AppEnv().aiApiBaseUrl.trim().isEmpty
            ? AiRequestConfig.baseUrl
            : AppEnv().aiApiBaseUrl.trim(),
        _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: _timeout,
                receiveTimeout: _timeout,
                sendTimeout: _timeout,
              ),
            );

  final Dio _dio;
  final String _apiKey;
  final String _baseUrl;

  static const String _model = 'gpt-4o-2024-05-13';
  static const Duration _timeout = Duration(
    seconds: AiRequestConfig.timeoutSeconds,
  );

  static const String _systemPrompt = '''
You are a professional hairstyle consultant for a selfie-based hairstyle preview app.

Analyze only what is visible in the selfie. Focus on face shape, forehead exposure, hairline, current length, density impression, visible texture, and how a recommended hairstyle would frame the face.

Return strict JSON only. Do not include markdown, comments, or extra text.

Use this schema exactly:
{
  "mainStyleName": "string",
  "whyItFits": "string",
  "alternativeSuggestions": [
    {
      "styleName": "string",
      "description": "string"
    }
  ],
  "barberNote": "string"
}

Rules:
- Recommend one best-fit hairstyle direction for this person.
- Keep "whyItFits" personalized, concise, and practical.
- Provide 2 to 3 alternative suggestions.
- Write "barberNote" like a clear salon communication brief that can be shown directly to a barber or stylist.
- Do not mention image quality, safety policy, or uncertainty unless the face or hair is truly not visible.
- Keep all text in English.
''';

  static const String _userPromptTemplate = '''
This app helps users try a new hairstyle from one selfie.

Analyze the uploaded selfie and produce:
1. One best-fit hairstyle name.
2. A short explanation of why it suits the visible face shape and hair traits.
3. Two or three alternative hairstyle suggestions.
4. A practical barber communication note.

The hairstyle recommendation should feel modern, flattering, and realistic for a lightweight AI hairstyle preview product.
''';

  Future<HairstyleAnalysis> analyzeImage(
    File imageFile, {
    String? userContext,
  }) async {
    if (_apiKey.isEmpty) {
      throw HairstyleAnalysisAiException('Missing AI API key');
    }

    try {
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);
      final requestData = AiRequestConfig.buildRequestBody(
        imageBase64: base64Image,
        systemPrompt: _systemPrompt,
        userPrompt: _buildUserPrompt(userContext),
        model: _model,
        maxTokens: 1400,
        temperature: 0.5,
      );

      final response = await _dio.post<Map<String, dynamic>>(
        '$_baseUrl${AiRequestConfig.endpoint}',
        data: requestData,
        options: Options(
          headers: AiRequestConfig.buildHeaders(_apiKey),
          responseType: ResponseType.json,
        ),
      );

      _logResponse(response);

      if (response.statusCode == 200) {
        return _parseResponse(response.data ?? <String, dynamic>{});
      }

      throw HairstyleAnalysisAiException(
        'AI analysis request failed',
        statusCode: response.statusCode,
        responseBody: response.data?.toString(),
      );
    } on DioException catch (e) {
      throw HairstyleAnalysisAiException(
        e.message ?? 'AI analysis request failed',
        statusCode: e.response?.statusCode,
        responseBody: e.response?.data?.toString(),
      );
    } on SocketException {
      throw HairstyleAnalysisAiException('Network connection failed');
    } on TimeoutException {
      throw HairstyleAnalysisAiException('AI analysis timed out');
    } on HairstyleAnalysisAiException {
      rethrow;
    } catch (e) {
      throw HairstyleAnalysisAiException('Failed to analyze image: $e');
    }
  }

  HairstyleAnalysis _parseResponse(Map<String, dynamic> responseData) {
    final content = AiRequestConfig.extractContent(responseData);

    if (content == null || content.trim().isEmpty) {
      throw HairstyleAnalysisAiException('AI returned empty content');
    }

    _logContent(content);

    final cleaned = AiRequestConfig.cleanJsonResponse(content);
    final jsonData = jsonDecode(cleaned) as Map<String, dynamic>;
    return HairstyleAnalysis.fromJson(jsonData);
  }

  String _buildUserPrompt(String? userContext) {
    final cleanedContext = userContext?.trim();
    if (cleanedContext == null || cleanedContext.isEmpty) {
      return _userPromptTemplate;
    }

    return '$_userPromptTemplate\n\nUser hairstyle request context:\n$cleanedContext';
  }

  void _logResponse(Response<dynamic> response) {
    debugPrint(
      '[HairstyleAnalysisAiService] Response Status: ${response.statusCode}',
    );
  }

  void _logContent(String content) {
    debugPrint('[HairstyleAnalysisAiService] Response Content:');
    debugPrint(content);
  }

  void dispose() {
    _dio.close(force: true);
  }
}
