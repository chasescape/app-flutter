import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:zeria/zeria/data/models/spark_result.dart';

/// SparkFlow AI 服务异常
class SparkFlowException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  SparkFlowException(
    this.message, {
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() =>
      'SparkFlowException: $message${statusCode != null ? ' (status: $statusCode)' : ''}';
}

/// SparkFlow AI 服务
/// 基于 api.gpt.ge (OpenAI 兼容) 的图片分析服务
class SparkFlowAIService {
  /// API 端点
  static const String defaultBaseUrl = 'https://api.gpt.ge/v1';
  static const String chatEndpoint = '/chat/completions';

  /// 默认模型（可配置）
  static const String defaultModel = 'gpt-4o';

  /// 超时时间
  static const Duration defaultTimeout = Duration(seconds: 60);

  /// 最大重试次数
  static const int maxRetries = 2;

  final String baseUrl;
  final String apiKey;
  final String model;
  final Duration timeout;

  HttpClient? _client;

  SparkFlowAIService({
    required this.apiKey,
    String? baseUrl,
    String? model,
    Duration? timeout,
  })  : baseUrl = baseUrl ?? defaultBaseUrl,
        model = model ?? defaultModel,
        timeout = timeout ?? defaultTimeout {
    _client = HttpClient();
  }

  /// 分析图片（两阶段：Scene Card + Ideas）
  Future<SparkResult> analyzeImage({
    required File imageFile,
    void Function(String stage)? onProgress,
  }) async {
    try {
      // 阶段 1: Scene Card 分析
      onProgress?.call('Analyzing scene...');
      final sceneCardJson = await _analyzeSceneCard(imageFile);

      // 阶段 2: 生成 Ideas
      onProgress?.call('Generating creative ideas...');
      final ideasJson = await _generateIdeas(sceneCardJson);

      // 合并结果
      return _mergeResults(sceneCardJson, ideasJson, imageFile.path);
    } catch (e) {
      if (e is SparkFlowException) rethrow;
      throw SparkFlowException('Failed to analyze image', originalError: e);
    }
  }

  /// 分析 Base64 图片
  Future<SparkResult> analyzeImageBase64({
    required String base64Image,
    String? imagePath,
    void Function(String stage)? onProgress,
  }) async {
    try {
      onProgress?.call('Analyzing scene...');
      final sceneCardJson = await _analyzeSceneCardBase64(base64Image);

      onProgress?.call('Generating creative ideas...');
      final ideasJson = await _generateIdeas(sceneCardJson);

      return _mergeResults(sceneCardJson, ideasJson, imagePath);
    } catch (e) {
      if (e is SparkFlowException) rethrow;
      throw SparkFlowException('Failed to analyze image', originalError: e);
    }
  }

  /// 阶段 1: 分析 Scene Card（从文件）
  Future<Map<String, dynamic>> _analyzeSceneCard(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    return _analyzeSceneCardBase64(base64Image);
  }

  /// 阶段 1: 分析 Scene Card（Base64）
  Future<Map<String, dynamic>> _analyzeSceneCardBase64(
      String base64Image) async {
    final prompt = _buildSceneAnalysisPrompt();

    final requestBody = {
      'model': model,
      'messages': [
        {
          'role': 'system',
          'content':
              'You are SparkFlow Scene Analyzer. Return ONLY valid JSON.',
        },
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': prompt},
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:image/jpeg;base64,$base64Image',
              },
            },
          ],
        },
      ],
      'max_tokens': 2048,
      'temperature': 0.7,
    };

    final response = await _sendRequest(requestBody);
    return _parseSceneCardResponse(response);
  }

  /// 阶段 2: 生成 Ideas
  Future<Map<String, dynamic>> _generateIdeas(
      Map<String, dynamic> sceneCardJson) async {
    final sceneCardString = jsonEncode(sceneCardJson['scene_card']);
    final prompt = _buildIdeasPrompt(sceneCardString);

    final requestBody = {
      'model': model,
      'messages': [
        {
          'role': 'system',
          'content':
              'You are SparkFlow Idea Generator. Return ONLY valid JSON.',
        },
        {
          'role': 'user',
          'content': prompt,
        },
      ],
      'max_tokens': 2048,
      'temperature': 0.8,
    };

    final response = await _sendRequest(requestBody);
    return _parseIdeasResponse(response);
  }

  /// 合并两阶段结果
  SparkResult _mergeResults(
    Map<String, dynamic> sceneCardJson,
    Map<String, dynamic> ideasJson,
    String? imagePath,
  ) {
    return SparkResult(
      sceneCard: SceneCard.fromJson(
          sceneCardJson['scene_card'] as Map<String, dynamic>),
      oneLineSummary: sceneCardJson['one_line_summary'] as String,
      tags: (sceneCardJson['tags'] as List).map((e) => e as String).toList(),
      safety:
          SafetyInfo.fromJson(sceneCardJson['safety'] as Map<String, dynamic>),
      ideas: (ideasJson['ideas'] as List)
          .map((e) => Idea.fromJson(e as Map<String, dynamic>))
          .toList(),
      imagePath: imagePath,
    );
  }

  /// 发送 HTTP 请求
  Future<Map<String, dynamic>> _sendRequest(Map<String, dynamic> body) async {
    int retryCount = 0;

    while (retryCount <= maxRetries) {
      try {
        final request =
            await _client!.postUrl(Uri.parse('$baseUrl$chatEndpoint'));
        request.followRedirects = false;
        request.headers.contentType = ContentType.json;
        request.headers.add('Authorization', 'Bearer $apiKey');
        request.write(jsonEncode(body));

        final response = await request.close().timeout(timeout);

        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseBody = await response.transform(utf8.decoder).join();
          return _parseChatResponse(responseBody);
        } else {
          final errorBody = await response.transform(utf8.decoder).join();
          throw SparkFlowException(
            'API request failed',
            statusCode: response.statusCode,
            originalError: errorBody,
          );
        }
      } on SocketException catch (e) {
        retryCount++;
        if (retryCount > maxRetries) {
          throw SparkFlowException('Network error after $maxRetries retries',
              originalError: e);
        }
        await Future.delayed(Duration(seconds: retryCount));
      } on HttpException catch (e) {
        throw SparkFlowException('HTTP error', originalError: e);
      } on TimeoutException catch (e) {
        throw SparkFlowException('Request timeout', originalError: e);
      }
    }

    throw SparkFlowException('Max retries exceeded');
  }

  /// 解析 Chat Completions 响应
  Map<String, dynamic> _parseChatResponse(String responseBody) {
    try {
      final jsonResponse = jsonDecode(responseBody);

      if (jsonResponse['error'] != null) {
        throw SparkFlowException(
          'API error: ${jsonResponse['error']['message']}',
          statusCode: jsonResponse['error']['code'],
        );
      }

      final content =
          jsonResponse['choices']?[0]?['message']?['content'] as String?;
      if (content == null || content.isEmpty) {
        throw SparkFlowException('Empty response from API');
      }

      // 清理 JSON（移除可能的 markdown 代码块标记）
      final cleanedContent = _cleanJsonResponse(content);
      return jsonDecode(cleanedContent) as Map<String, dynamic>;
    } on FormatException catch (e) {
      throw SparkFlowException('Invalid JSON response', originalError: e);
    }
  }

  /// 解析 Scene Card 响应
  Map<String, dynamic> _parseSceneCardResponse(Map<String, dynamic> response) {
    // 验证必需字段
    _validateSceneCardFields(response);
    return response;
  }

  /// 解析 Ideas 响应
  Map<String, dynamic> _parseIdeasResponse(Map<String, dynamic> response) {
    // 验证必需字段
    final ideas = response['ideas'] as List?;
    if (ideas == null || ideas.isEmpty || ideas.length != 3) {
      throw SparkFlowException('Invalid ideas response: expected 3 ideas');
    }
    return response;
  }

  /// 验证 Scene Card 必需字段
  void _validateSceneCardFields(Map<String, dynamic> response) {
    final required = ['scene_card', 'one_line_summary', 'tags', 'safety'];
    for (final field in required) {
      if (!response.containsKey(field)) {
        throw SparkFlowException('Missing required field: $field');
      }
    }

    final sceneCard = response['scene_card'] as Map<String, dynamic>?;
    if (sceneCard == null) {
      throw SparkFlowException('Missing scene_card');
    }

    final sceneCardFields = [
      'visual_subject',
      'atmosphere',
      'inspiration_dimension'
    ];
    for (final field in sceneCardFields) {
      if (!sceneCard.containsKey(field)) {
        throw SparkFlowException('Missing scene_card field: $field');
      }
    }
  }

  /// 清理 JSON 响应（移除 markdown 代码块）
  String _cleanJsonResponse(String content) {
    String cleaned = content.trim();

    // 移除 ```json 和 ``` 标记
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }

    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }

    return cleaned.trim();
  }

  /// 构建 Scene Analysis Prompt
  String _buildSceneAnalysisPrompt() {
    return '''Analyze this input for SparkFlow and output a Scene Card JSON.

Allowed enums:
- visual_subject: ["Space & Environment", "Product & Object", "People & Activity", "Nature & Landscape", "Abstract & Concept", "Text & Document", "Unknown"]
- atmosphere: ["Warm & Cozy", "Minimal & Clean", "Energetic & Vibrant", "Professional & Serious", "Romantic & Soft", "Mysterious & Dramatic", "Playful & Fun", "Calm & Serene", "Unknown"]
- inspiration_dimension: ["Function Innovation", "Aesthetic Design", "Experience Optimization", "Business Model", "Social Connection", "Learning Growth", "Unknown"]

Output schema (return ONLY JSON):
{
  "scene_card": {
    "visual_subject": {"value": "...", "confidence": 0.0, "evidence": "..."},
    "atmosphere": {"value": "...", "confidence": 0.0, "evidence": "..."},
    "inspiration_dimension": {"value": "...", "confidence": 0.0, "evidence": "..."}
  },
  "one_line_summary": "...",
  "tags": ["...","...","..."],
  "safety": {
    "has_sensitive_content": false,
    "notes": ""
  }
}

Notes:
- "evidence" is a short, non-sensitive visual or textual cue.
- "one_line_summary" should describe the concrete creative opportunity hidden in the image.
- "tags" are short English keywords for UI (3-8 items).
- "visual_subject" should capture the primary focus of the image.
- "atmosphere" should reflect the emotional tone or style conveyed.
- "inspiration_dimension" should identify which type of inspiration this scene could trigger.
- Do not identify real people or guess sensitive traits.''';
  }

  /// 构建 Ideas Prompt
  String _buildIdeasPrompt(String sceneCardJson) {
    return '''Generate 3 actionable inspiration ideas for this Scene Card.
The goal is to help a user break a creative block and turn abstract cues into concrete next moves.

SCENE_CARD_JSON: $sceneCardJson

Output schema (return ONLY JSON):
{
  "ideas": [
    {
      "title": "...",
      "execution_direction": ["...", "..."],
      "application_scenario": "...",
      "dimension": "Function Innovation|Aesthetic Design|Experience Optimization|Business Model|Social Connection|Learning Growth"
    }
  ],
  "spark_note": "..."
}

Constraints:
- Exactly 3 items in "ideas".
- "title" must be a one-line creative summary (under 80 characters).
- "execution_direction" must contain 2-3 specific next actions a user could realistically try first (under 150 characters each).
- "application_scenario" should describe who or what context this idea is best for (under 150 characters).
- "dimension" must use one of the allowed enum values.
- "spark_note" is a 1-sentence bonus insight or connection (under 150 characters).''';
  }

  /// 释放资源
  void dispose() {
    _client?.close();
    _client = null;
  }
}
