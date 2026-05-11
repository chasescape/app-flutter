import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../data/models/composition_result.dart';
import '../env/app_env.dart';
import '../services/storage_service.dart';

/// CompositionResult AI service exception.
class CompositionResultAiException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  CompositionResultAiException(
    this.message, {
    this.statusCode,
    this.responseBody,
  });

  @override
  String toString() => 'CompositionResultAiException: $message';
}

// *** [do change classname] ***
class CompositionResultAiService {
  static const String _defaultBaseUrl = 'https://api.gpt.ge';
  static const String _model = 'gpt-4o-2024-05-13';
  static const Duration _timeout = Duration(seconds: 60);
  static const int _maxTokens = 4000;
  static const double _temperature = 0.7;

  static const String _systemPrompt = '''
You are an expert mobile photography composition coach.
Analyze a single uploaded photo and provide practical feedback for everyday users.

Priorities:
- Focus on composition, framing, balance, subject emphasis, distractions, edge tension, horizon, and negative space.
- Keep the feedback specific to what is visible in the photo.
- Use concise, encouraging, product-ready English.
- Prefer actionable advice over abstract photography theory.
- Never mention missing metadata, camera EXIF, or technical uncertainty.
''';

  // Supported image types: Portrait, Food, Pet, Object
  // Supported goals: Better Balance, Stronger Subject, Cleaner Frame
  static const String _userPromptTemplate = '''
Analyze the uploaded image for composition guidance.

Return valid JSON only. Do not wrap the response in markdown code fences.
Use exactly this shape:
{
  "summary": "One short overall read of the composition.",
  "issues": ["Issue 1", "Issue 2", "Issue 3"],
  "suggestions": ["Suggestion 1", "Suggestion 2", "Suggestion 3"],
  "retakeSteps": ["Retake step 1", "Retake step 2", "Retake step 3"]
}

Rules:
- Output exactly 3 items in "issues", "suggestions", and "retakeSteps".
- Keep every list item short and user-facing.
- "issues" should describe observable composition problems.
- "suggestions" should explain how to improve the current frame.
- "retakeSteps" should be direct action steps the user can follow while retaking the photo.
- Do not output id, image paths, dates, coins, imageType, or goal.
''';

  final String _baseUrl;
  final String? _apiKeyOverride;
  late final http.Client _client;

  CompositionResultAiService({
    String? apiKey,
    String? baseUrl,
  })  : _apiKeyOverride = apiKey,
        _baseUrl = baseUrl ?? AppEnv().imageEditApiUrl {
    _client = http.Client();
  }

  /// Analyze the uploaded image and build a CompositionResult.
  Future<CompositionResult> analyzeComposition({
    required File imageFile,
    required ImageType imageType,
    AnalysisGoal? goal,
  }) async {
    final apiKey = _resolveApiKey();
    if (!_hasConfiguredApiKey(apiKey)) {
      throw CompositionResultAiException(
        'AI service API key is not configured',
      );
    }

    try {
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);
      final requestData = _buildRequestData(
        imageBase64: base64Image,
        imageMimeType: _detectMimeType(imageFile.path),
        userPrompt: _buildUserPrompt(imageType: imageType, goal: goal),
      );

      final response = await _client
          .post(
            Uri.parse('${_resolvedBaseUrl()}/v1/chat/completions'),
            headers: _buildHeaders(apiKey),
            body: jsonEncode(requestData),
          )
          .timeout(_timeout);

      _logResponse(response);

      if (response.statusCode == 200) {
        return _parseResponse(
          responseBody: response.body,
          imageFile: imageFile,
          imageType: imageType,
          goal: goal,
        );
      }

      throw CompositionResultAiException(
        'API request failed',
        statusCode: response.statusCode,
        responseBody: response.body,
      );
    } on SocketException {
      throw CompositionResultAiException('Network connection failed');
    } on TimeoutException {
      throw CompositionResultAiException('Request timeout, please try again');
    } on CompositionResultAiException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint(
        '[CompositionResultAiService] Analysis error: $e\n$stackTrace',
      );
      throw CompositionResultAiException('Analysis failed: $e');
    }
  }

  Map<String, String> _buildHeaders(String apiKey) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
  }

  Map<String, dynamic> _buildRequestData({
    required String imageBase64,
    required String imageMimeType,
    required String userPrompt,
  }) {
    return {
      'model': _model,
      'messages': [
        {'role': 'system', 'content': _systemPrompt},
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': userPrompt},
            {
              'type': 'image_url',
              'image_url': {
                'url': _buildImageUrl(
                  imageBase64,
                  mimeType: imageMimeType,
                ),
              },
            },
          ],
        },
      ],
      'max_tokens': _maxTokens,
      'temperature': _temperature,
    };
  }

  CompositionResult _parseResponse({
    required String responseBody,
    required File imageFile,
    required ImageType imageType,
    AnalysisGoal? goal,
  }) {
    final dynamic decoded = jsonDecode(responseBody);
    if (decoded is! Map) {
      throw CompositionResultAiException('Unexpected AI response shape');
    }

    final responseData = Map<String, dynamic>.from(decoded);
    final content = responseData['choices']?[0]?['message']?['content'];

    if (content is! String || content.trim().isEmpty) {
      throw CompositionResultAiException('AI returned empty content');
    }

    _logContent(content);

    final cleaned = _cleanJsonResponse(content);
    final dynamic jsonData = jsonDecode(cleaned);
    if (jsonData is! Map) {
      throw CompositionResultAiException('AI JSON payload is not an object');
    }

    final payload = Map<String, dynamic>.from(jsonData);
    final now = DateTime.now();

    return CompositionResult(
      id: now.millisecondsSinceEpoch.toString(),
      originalImagePath: imageFile.path,
      guideOverlayPath: imageFile.path,
      reframePreviewPath: imageFile.path,
      imageType: imageType,
      goal: goal,
      summary: _readSummary(payload, imageType, goal),
      issues: _readStringList(
        payload,
        keys: const ['issues', 'problems'],
        fallback: _defaultIssues(imageType),
      ),
      suggestions: _readStringList(
        payload,
        keys: const ['suggestions', 'recommendations'],
        fallback: _defaultSuggestions(goal),
      ),
      retakeSteps: _readStringList(
        payload,
        keys: const ['retakeSteps', 'retake_steps', 'steps'],
        fallback: _defaultRetakeSteps(),
      ),
      createdAt: now,
      coinsUsed: StorageService.to.getCostPerAnalysis(),
    );
  }

  String _buildUserPrompt({
    required ImageType imageType,
    AnalysisGoal? goal,
  }) {
    final buffer = StringBuffer(_userPromptTemplate);
    buffer.writeln();
    buffer.writeln();
    buffer.writeln('Selected image type: ${imageType.label}');
    buffer.writeln('Selected goal: ${goal?.label ?? 'Not specified'}');
    buffer.writeln(
      'Focus your critique on framing, subject placement, balance, distractions, and visual hierarchy.',
    );
    return buffer.toString().trim();
  }

  String _readSummary(
    Map<String, dynamic> payload,
    ImageType imageType,
    AnalysisGoal? goal,
  ) {
    final raw = payload['summary'];
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.trim();
    }

    final goalText = goal?.label.toLowerCase() ?? 'stronger composition';
    return 'Your ${imageType.label.toLowerCase()} photo has a solid base and can be improved with $goalText.';
  }

  List<String> _readStringList(
    Map<String, dynamic> payload, {
    required List<String> keys,
    required List<String> fallback,
  }) {
    for (final key in keys) {
      final value = payload[key];
      if (value is List) {
        final items = value
            .map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty)
            .take(3)
            .toList();
        if (items.isNotEmpty) {
          return _fillList(items, fallback);
        }
      }
    }

    return fallback;
  }

  List<String> _fillList(List<String> items, List<String> fallback) {
    if (items.length >= 3) {
      return items.take(3).toList();
    }

    final filled = <String>[...items];
    for (final item in fallback) {
      if (filled.length >= 3) {
        break;
      }
      if (!filled.contains(item)) {
        filled.add(item);
      }
    }
    return filled.take(3).toList();
  }

  List<String> _defaultIssues(ImageType imageType) {
    return <String>[
      'The ${imageType.label.toLowerCase()} lacks a clear focal emphasis.',
      'Background details are competing with the subject.',
      'The frame balance could feel more intentional.',
    ];
  }

  List<String> _defaultSuggestions(AnalysisGoal? goal) {
    final goalLabel = goal?.label ?? 'overall balance';
    return <String>[
      'Adjust the framing to support $goalLabel.',
      'Remove or avoid edge distractions around the subject.',
      'Use cleaner spacing so the main subject reads faster.',
    ];
  }

  List<String> _defaultRetakeSteps() {
    return const <String>[
      'Take one step sideways to simplify the background.',
      'Raise or lower the camera until the subject sits more cleanly in frame.',
      'Retake after trimming edge distractions before you tap the shutter.',
    ];
  }

  String _resolveApiKey() {
    return _apiKeyOverride ?? AppEnv().geApiKey;
  }

  bool _hasConfiguredApiKey(String apiKey) {
    final normalized = apiKey.trim().toLowerCase();
    return normalized.isNotEmpty && normalized != 'n/a';
  }

  String _resolvedBaseUrl() {
    if (_baseUrl.trim().isNotEmpty) {
      return _baseUrl;
    }
    return _defaultBaseUrl;
  }

  String _cleanJsonResponse(String content) {
    String cleaned = content.trim();

    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7).trim();
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3).trim();
    }

    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3).trim();
    }

    return cleaned;
  }

  String _buildImageUrl(String base64Data, {String mimeType = 'image/jpeg'}) {
    return 'data:$mimeType;base64,$base64Data';
  }

  String _detectMimeType(String filePath) {
    final dotIndex = filePath.lastIndexOf('.');
    final extension =
        dotIndex >= 0 ? filePath.substring(dotIndex).toLowerCase() : '';

    switch (extension) {
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }

  void _logResponse(http.Response response) {
    debugPrint(
      '[CompositionResultAiService] Response status: ${response.statusCode}',
    );
  }

  void _logContent(String content) {
    debugPrint('[CompositionResultAiService] Response content: $content');
  }

  void dispose() {
    _client.close();
  }
}
