import 'dart:convert';
import 'package:dio/dio.dart' as dio;

class StoryResult {
  StoryResult({
    required this.title,
    required this.story,
    required this.characterName,
    required this.characterTraits,
    required this.setting,
    required this.mood,
    required this.category,
    required this.readTime,
  });

  final String title;
  final String story;
  final String characterName;
  final List<String> characterTraits;
  final String setting;
  final String mood;
  final String category;
  final String readTime;

  factory StoryResult.fromJson(Map<String, dynamic> json) {
    return StoryResult(
      title: (json['title'] ?? '').toString(),
      story: (json['story'] ?? '').toString(),
      characterName: (json['character_name'] ?? '').toString(),
      characterTraits: (json['character_traits'] is List)
          ? (json['character_traits'] as List).map((e) => e.toString()).toList()
          : <String>[],
      setting: (json['setting'] ?? '').toString(),
      mood: (json['mood'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      readTime: (json['read_time'] ?? '').toString(),
    );
  }
}

class AiService {
  final dio.Dio _dio;

  AiService(this._dio);

  /// =========================
  /// 通用 POST 请求（带 retry）
  /// =========================
  Future<dynamic> _postJson(
    String path, {
    dynamic data,
    Duration sendTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 60),
    int retry = 1,
  }) async {
    int attempt = 0;

    while (true) {
      try {
        final response = await _dio.post(
          path,
          data: data,
          options: dio.Options(
            sendTimeout: sendTimeout,
            receiveTimeout: receiveTimeout,
          ),
        );

        if (response.statusCode != 200) {
          throw Exception('API failed: ${response.statusCode}');
        }

        return _parseJson(response.data);
      } catch (e) {
        attempt++;

        if (attempt > retry) {
          rethrow;
        }

        await Future.delayed(const Duration(milliseconds: 800));
      }
    }
  }

  /// =========================
  /// JSON 解析
  /// =========================
  dynamic _parseJson(dynamic data) {
    if (data is String) {
      return jsonDecode(data);
    }
    return data;
  }

  /// =========================
  /// GPT返回内容提取
  /// =========================
  String _extractContent(dynamic data) {
    if (data is Map &&
        data['choices'] is List &&
        (data['choices'] as List).isNotEmpty) {
      final choice = (data['choices'] as List).first;

      if (choice is Map &&
          choice['message'] is Map &&
          choice['message']['content'] != null) {
        return choice['message']['content'].toString().trim();
      }
    }

    throw Exception('Invalid AI response format');
  }

  /// =========================
  /// 图片编辑
  /// =========================
  Future<String> generateEditedImage({
    required String imagePath,
    required String prompt,
    String model = 'flux-kontext-pro',
    String size = '1024x1024',
  }) async {
    final formData = dio.FormData.fromMap({
      'image': await dio.MultipartFile.fromFile(
        imagePath,
        filename: 'image.jpg',
      ),
      'model': model,
      'prompt': prompt,
      'n': '1',
      'size': size,
      'response_format': 'url',
    });

    final data = await _postJson(
      '/v1/images/edits',
      data: formData,
      sendTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      retry: 2,
    );

    if (data is Map &&
        data['data'] is List &&
        (data['data'] as List).isNotEmpty) {
      final first = (data['data'] as List).first;

      if (first is Map && first['url'] is String) {
        return first['url'];
      }
    }

    throw Exception('Invalid AI image response format');
  }

  /// =========================
  /// 文本生成
  /// =========================
  Future<String> generateStory({
    required String prompt,
    required String model,
    String? systemPrompt,
    double temperature = 0.7,
    int maxTokens = 200,
  }) async {
    final messages = <Map<String, dynamic>>[];
    if (systemPrompt != null && systemPrompt.trim().isNotEmpty) {
      messages.add({'role': 'system', 'content': systemPrompt});
    }
    messages.add({'role': 'user', 'content': prompt});

    final data = await _postJson(
      '/v1/chat/completions',
      data: {
        'model': model,
        'messages': messages,
        'temperature': temperature,
        'max_tokens': maxTokens,
      },
      retry: 2,
    );

    return _extractContent(data);
  }

  /// =========================
  /// Vision（图 + 文）
  /// =========================
  Future<String> generateVisionStory({
    required String base64Image,
    required String prompt,
    String model = 'gpt-4o-2024-05-13',
    int maxTokens = 2000,
    double temperature = 0.8,
  }) async {
    final data = await _postJson(
      '/v1/chat/completions',
      data: {
        'model': model,
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
                }
              }
            ]
          }
        ],
        'max_tokens': maxTokens,
        'temperature': temperature,
      },
      sendTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 120),
      retry: 2,
    );

    return _extractContent(data);
  }

  /// =========================
  /// Portrait Story (Vision JSON)
  /// =========================
  Future<StoryResult> generatePortraitStory({
    required String base64Image,
    String model = 'gpt-4o-2024-05-13',
    int maxTokens = 2000,
    double temperature = 0.8,
  }) async {
    final data = await _postJson(
      '/v1/chat/completions',
      data: {
        'model': model,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': _portraitPrompt,
              },
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:image/jpeg;base64,$base64Image',
                }
              }
            ]
          }
        ],
        'max_tokens': maxTokens,
        'temperature': temperature,
      },
      sendTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 120),
      retry: 2,
    );

    final content = _extractContent(data);
    final jsonMap = _parseStoryJson(content);
    return StoryResult.fromJson(jsonMap);
  }

  Map<String, dynamic> _parseStoryJson(String raw) {
    var jsonString = raw.trim();

    if (jsonString.contains('```json')) {
      final jsonStart = jsonString.indexOf('```json') + 7;
      final jsonEnd = jsonString.indexOf('```', jsonStart);
      if (jsonEnd > jsonStart) {
        jsonString = jsonString.substring(jsonStart, jsonEnd).trim();
      }
    } else if (jsonString.contains('```')) {
      final jsonStart = jsonString.indexOf('```') + 3;
      final jsonEnd = jsonString.indexOf('```', jsonStart);
      if (jsonEnd > jsonStart) {
        jsonString = jsonString.substring(jsonStart, jsonEnd).trim();
      }
    }

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      // fallthrough to smart extract
    }

    final start = jsonString.indexOf('{');
    final end = jsonString.lastIndexOf('}');
    if (start >= 0 && end > start) {
      final sliced = jsonString.substring(start, end + 1);
      final decoded = jsonDecode(sliced);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    }

    return {
      'title': 'A Quiet Strength',
      'story':
          'A gentle story begins here, but the full response was unavailable. Please try again.',
      'character_name': 'Unknown',
      'character_traits': ['Thoughtful', 'Resilient', 'Warm'],
      'setting': 'A familiar place',
      'mood': 'Reflective',
      'category': 'Life',
      'read_time': '3 min',
    };
  }
}

const _portraitPrompt = '''
You are a creative storyteller and character analyst with expertise in crafting compelling narratives. Analyze the uploaded portrait photo and create an engaging character story based on the person's appearance, expression, and overall vibe.

**Analysis Guidelines:**
- Study the facial features, expression, posture, and overall demeanor
- Consider the setting, clothing, and any contextual elements visible
- Imagine the person's personality, dreams, and life experiences
- Create a narrative that feels authentic and emotionally resonant

**Story Requirements:**
- Write a rich, immersive 3-4 paragraph story (300-500 words)
- Include vivid sensory details and atmospheric descriptions
- Show character depth through actions and inner thoughts
- Create an emotional arc with a meaningful resolution
- Make the story inspiring, relatable, and memorable

**Response Format:**
Return ONLY a valid JSON object with the following exact structure (no additional text or code blocks):
{
  "title": "A Creative, Evocative Title",
  "story": "The complete story text with multiple paragraphs separated by \\n\\n...",
  "character_name": "A fitting name for the character",
  "character_traits": ["Trait1", "Trait2", "Trait3"],
  "setting": "Brief description of story setting",
  "mood": "The overall emotional tone (e.g., Inspiring, Nostalgic, Hopeful)",
  "category": "Story category (e.g., Dreams, Adventure, Art, Life, Love, Family)",
  "read_time": "Estimated read time (e.g., 3 min)"
}

**Style Guidelines:**
- Use literary prose that paints vivid pictures
- Balance action with introspection
- Include dialogue or inner monologue when appropriate
- End with a meaningful insight or hopeful note
- Make each story unique and character-specific

**Important:**
- Base the story on visible characteristics in the photo
- Create original, thoughtful narratives
- Avoid clichés and generic descriptions
- Return ONLY valid JSON - no descriptive text or formatting
''';
