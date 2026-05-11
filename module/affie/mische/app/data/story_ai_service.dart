import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

class StoryAiService {
  static const String baseUrl = 'https://api.gpt.ge';
  static const String apiKey = 'sk-QaaY8MM8WwiS9eLfC31f0fB08742448bA75b6a7f1b75E61a';
  
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    },
  ));

  /// 将图片文件转换为 Base64 编码
  Future<String> imageToBase64(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    return base64Encode(imageBytes);
  }

  /// 生成故事提示词
  String _getStoryPrompt() {
    return '''You are a supportive wellbeing assistant. Analyze the portrait photo and provide brief, actionable emotional wellness suggestions.

**Analysis Guidelines:**
- Study facial expression, posture, and overall mood
- Consider visible context and emotional state
- Provide practical, immediate actions

**Response Requirements:**
- Create a short, catchy title (2-4 words)
- Provide 3-4 brief bullet points (each 10-15 words max)
- Keep tone warm, supportive, and actionable
- Focus on immediate, practical steps

**Response Format:**
Return ONLY valid JSON (no code blocks):
{
  "title": "Short Catchy Title",
  "story": "• First actionable tip here\n\n• Second practical suggestion\n\n• Third helpful insight\n\n• Optional fourth point",
  "character_name": "You",
  "character_traits": ["Trait1", "Trait2", "Trait3"],
  "setting": "Current moment",
  "mood": "Emotional tone",
  "category": "Wellness",
  "read_time": "1 min"
}

**Important:**
- Each bullet point should be ONE clear action or insight
- Keep it concise and scannable
- Base suggestions on visible emotional cues
- Return ONLY valid JSON''';
  }

  /// 调用 GPT-4 Vision API 生成故事
  Future<StoryResult> generateStory(File imageFile) async {
    int retryCount = 0;
    const maxRetries = 2;
    
    while (retryCount <= maxRetries) {
      try {
        // 1. 转换图片为 Base64
        final base64Image = await imageToBase64(imageFile);
        
        // 2. 构建请求体
        final requestData = {
          "model": "gpt-4o-2024-05-13",
          "messages": [
            {
              "role": "user",
              "content": [
                {
                  "type": "text",
                  "text": _getStoryPrompt(),
                },
                {
                  "type": "image_url",
                  "image_url": {
                    "url": "data:image/jpeg;base64,$base64Image",
                  }
                }
              ]
            }
          ],
          "max_tokens": 2000,
          "temperature": 0.8,
        };

        print('📤 Sending request to AI API (attempt ${retryCount + 1}/${maxRetries + 1})...');

        // 3. 发送请求
        final response = await _dio.post(
          '/v1/chat/completions',
          data: requestData,
        );

        // 4. 解析响应
        if (response.statusCode == 200) {
          final content = response.data['choices'][0]['message']['content'] as String;
          print('📥 Received AI response, parsing...');
          return _parseStoryResult(content);
        } else {
          throw Exception('API request failed with status: ${response.statusCode}');
        }
      } on DioException catch (e) {
        print('⚠️ DioException on attempt ${retryCount + 1}: ${e.type} - ${e.message}');
        
        // 502/503 错误重试
        if (e.response?.statusCode == 502 || e.response?.statusCode == 503) {
          if (retryCount < maxRetries) {
            retryCount++;
            await Future.delayed(Duration(seconds: retryCount * 2));
            continue;
          }
        }
        
        if (e.type == DioExceptionType.connectionTimeout) {
          throw Exception('Connection timeout. Please check your network.');
        } else if (e.type == DioExceptionType.receiveTimeout) {
          throw Exception('Request timeout. Please try again.');
        } else if (e.response != null) {
          throw Exception('API error: ${e.response?.statusCode}');
        } else {
          throw Exception('Network error: ${e.message}');
        }
      } catch (e) {
        print('❌ Unexpected error: $e');
        throw Exception('Failed to generate story: $e');
      }
    }
    
    throw Exception('API service unavailable after $maxRetries retries');
  }

  /// 解析 AI 返回的故事结果（支持多种格式）
  StoryResult _parseStoryResult(String content) {
    try {
      String jsonString = content.trim();
      
      // 处理被代码块包围的 JSON
      if (jsonString.contains('```json')) {
        final jsonStart = jsonString.indexOf('```json') + 7;
        final jsonEnd = jsonString.indexOf('```', jsonStart);
        if (jsonEnd != -1) {
          jsonString = jsonString.substring(jsonStart, jsonEnd).trim();
        }
      } else if (jsonString.contains('```')) {
        final jsonStart = jsonString.indexOf('```') + 3;
        final jsonEnd = jsonString.indexOf('```', jsonStart);
        if (jsonEnd != -1) {
          jsonString = jsonString.substring(jsonStart, jsonEnd).trim();
        }
      }
      
      // 智能提取 JSON 对象
      if (!jsonString.startsWith('{')) {
        final jsonStart = jsonString.indexOf('{');
        if (jsonStart != -1) {
          jsonString = jsonString.substring(jsonStart);
        }
      }
      
      if (!jsonString.endsWith('}')) {
        final jsonEnd = jsonString.lastIndexOf('}');
        if (jsonEnd != -1) {
          jsonString = jsonString.substring(0, jsonEnd + 1);
        }
      }

      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      return StoryResult(
        title: jsonData['title'] as String? ?? 'Untitled Story',
        story: jsonData['story'] as String? ?? '',
        characterName: jsonData['character_name'] as String? ?? 'Unknown',
        characterTraits: (jsonData['character_traits'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ?? [],
        setting: jsonData['setting'] as String? ?? '',
        mood: jsonData['mood'] as String? ?? 'Reflective',
        category: jsonData['category'] as String? ?? 'Life',
        readTime: jsonData['read_time'] as String? ?? '3 min',
      );
    } catch (e) {
      // 降级处理：返回默认结果
      print('Failed to parse story result: $e');
      return StoryResult(
        title: 'A Moment Captured',
        story: '• Take a moment to appreciate this feeling\n\n• Share your experience with someone you trust\n\n• Reflect on what brought you here today',
        characterName: 'You',
        characterTraits: ['Unique', 'Thoughtful', 'Inspiring'],
        setting: 'A moment captured',
        mood: 'Reflective',
        category: 'Wellness',
        readTime: '1 min',
      );
    }
  }
}

/// 故事生成结果模型
class StoryResult {
  final String title;
  final String story;
  final String characterName;
  final List<String> characterTraits;
  final String setting;
  final String mood;
  final String category;
  final String readTime;

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

  Map<String, dynamic> toJson() => {
    'title': title,
    'story': story,
    'character_name': characterName,
    'character_traits': characterTraits,
    'setting': setting,
    'mood': mood,
    'category': category,
    'read_time': readTime,
  };

  factory StoryResult.fromJson(Map<String, dynamic> json) => StoryResult(
    title: json['title'] as String,
    story: json['story'] as String,
    characterName: json['character_name'] as String,
    characterTraits: (json['character_traits'] as List<dynamic>)
        .map((e) => e.toString())
        .toList(),
    setting: json['setting'] as String,
    mood: json['mood'] as String,
    category: json['category'] as String,
    readTime: json['read_time'] as String,
  );
}
