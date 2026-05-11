import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

class AiResult {
  final String title;
  final String category;
  final String overview;
  final List<String> steps;
  final String proTips;

  AiResult({
    required this.title,
    required this.category,
    required this.overview,
    required this.steps,
    required this.proTips,
  });

  factory AiResult.fromJson(Map<String, dynamic> json) {
    return AiResult(
      title: json['title'] ?? 'Care Suggestion',
      category: json['category'] ?? 'Care',
      overview: json['overview'] ?? '',
      steps: List<String>.from(json['steps'] ?? []),
      proTips: json['pro_tips'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'overview': overview,
      'steps': steps,
      'pro_tips': proTips,
    };
  }

  /// 降级默认结果
  factory AiResult.fallback() {
    return AiResult(
      title: 'Care Suggestion',
      category: 'Care',
      overview: 'Use gentle cleaning and proper storage to protect the item.',
      steps: [
        'Check the care label before cleaning.',
        'Use mild detergent and cold water.',
        'Air dry and reshape to avoid deformation.',
        'Avoid high heat and harsh chemicals.',
        'Store in a breathable garment bag.'
      ],
      proTips: 'Avoid direct sunlight when drying. Use gentle detergents for delicate fabrics.',
    );
  }
}

class AiService {
  static const String _baseUrl = 'https://api.gpt.ge';
  static const String _apiKey =
      'sk-QaaY8MM8WwiS9eLfC31f0fB08742448bA75b6a7f1b75E61a';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    },
  ));

  Future<AiResult> generateFromImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await _dio.post(
      '/v1/chat/completions',
      data: {
        'model': 'gpt-4o-2024-05-13',
        'messages': [
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': _prompt},
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:image/jpeg;base64,$base64Image',
                },
              },
            ],
          }
        ],
        'max_tokens': 2000,
        'temperature': 0.8,
      },
    );

    final content =
        response.data['choices'][0]['message']['content'] as String;
    return _parseResult(content);
  }

  AiResult _parseResult(String content) {
    try {
      String jsonString = content.trim();

      // 处理 ```json 代码块
      if (jsonString.contains('```json')) {
        final start = jsonString.indexOf('```json') + 7;
        final end = jsonString.indexOf('```', start);
        jsonString = jsonString.substring(start, end).trim();
      } else if (jsonString.contains('```')) {
        final start = jsonString.indexOf('```') + 3;
        final end = jsonString.indexOf('```', start);
        jsonString = jsonString.substring(start, end).trim();
      }

      // 提取 JSON 对象边界
      final objStart = jsonString.indexOf('{');
      final objEnd = jsonString.lastIndexOf('}');
      if (objStart != -1 && objEnd != -1) {
        jsonString = jsonString.substring(objStart, objEnd + 1);
      }

      return AiResult.fromJson(jsonDecode(jsonString));
    } catch (_) {
      return AiResult.fallback();
    }
  }

  static const String _prompt = '''
You are a professional clothing care and wardrobe organization assistant. Analyze the uploaded clothing photo and provide practical care and storage guidance.

Return ONLY a valid JSON object with the following exact structure (no extra text or code blocks):
{
  "title": "Short care title",
  "category": "Care | Storage | Washing | Organization",
  "overview": "1-2 sentence overview",
  "steps": ["Step 1", "Step 2", "Step 3", "Step 4", "Step 5", "Step 6"],
  "pro_tips": "Single paragraph of pro tips"
}

Formatting rules:
- Make sure the copy can be displayed in this layout:
  Title, Category, Overview, Step-by-Step Guide, Pro Tips.
- Provide 5-6 steps, concise and actionable.
- Focus on stain removal, washing, drying, ironing, and storage as applicable.
- If the item looks delicate, emphasize gentle methods.
''';
}
