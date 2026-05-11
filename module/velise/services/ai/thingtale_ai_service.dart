import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../env/app_env.dart';
import '../../data/models/thingtale_item.dart';

/// ThingTale AI Service Exception
class ThingTaleAIException implements Exception {
  final String message;
  final int? statusCode;

  ThingTaleAIException(this.message, [this.statusCode]);

  @override
  String toString() => 'ThingTaleAIException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// ThingTale AI Service
/// Analyzes images using GPT-4o Vision API
class ThingTaleAIService extends GetxService {
  late final Dio _dio;
  static const String _baseUrl = 'https://api.gpt.ge';

  ThingTaleAIService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('[ThingTaleAI] Request: ${options.method} ${options.uri}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('[ThingTaleAI] Response: ${response.statusCode}');
        handler.next(response);
      },
      onError: (error, handler) {
        print('[ThingTaleAI] Error: ${error.message}');
        handler.next(error);
      },
    ));
  }

  /// Analyze image from File path
  Future<ThingTaleItem> analyzeImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw ThingTaleAIException('Image file not found: $imagePath');
      }

      final bytes = await file.readAsBytes();
      return analyzeImageBytes(bytes, imagePath);
    } catch (e) {
      if (e is ThingTaleAIException) rethrow;
      throw ThingTaleAIException('Failed to read image: $e');
    }
  }

  /// Analyze image from bytes
  Future<ThingTaleItem> analyzeImageBytes(Uint8List imageBytes, String imagePath) async {
    final apiKey = AppEnv().geApiKey;
    if (apiKey.isEmpty) {
      throw ThingTaleAIException('API Key not configured. Please set geApiKey in AppEnv.');
    }

    try {
      final base64Image = base64Encode(imageBytes);
      final mimeType = _detectMimeType(imageBytes);

      final response = await _dio.post(
        '/v1/chat/completions',
        data: {
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': _buildPrompt(),
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:$mimeType;base64,$base64Image',
                  },
                },
              ],
            },
          ],
          'max_tokens': 2000,
          'temperature': 0.7,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw ThingTaleAIException('API request failed', response.statusCode);
      }

      final content = response.data['choices']?[0]?['message']?['content'] as String?;
      if (content == null || content.isEmpty) {
        throw ThingTaleAIException('Empty response from AI');
      }

      final jsonData = _extractJson(content);
      final item = ThingTaleItem.fromJson(jsonData);

      item.assetImg = imagePath;

      return item;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ThingTaleAIException('Request timeout. Please check your connection and try again.');
      }
      if (e.type == DioExceptionType.badResponse) {
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          throw ThingTaleAIException('Invalid API Key. Please check your geApiKey configuration.', statusCode);
        } else if (statusCode == 429) {
          throw ThingTaleAIException('Rate limit exceeded. Please try again later.', statusCode);
        }
        throw ThingTaleAIException('API Error: ${e.message}', statusCode);
      }
      throw ThingTaleAIException('Network error: ${e.message}');
    } catch (e) {
      if (e is ThingTaleAIException) rethrow;
      throw ThingTaleAIException('Analysis failed: $e');
    }
  }

  String _buildPrompt() {
    return r'''You are ThingTale AI - a specialized storytelling assistant for everyday objects and personal collections.

Analyze the uploaded image and extract item details following this JSON schema exactly:

{
  "assetImg": "string (image path)",
  "scene_card": {
    "location": "string (enum: desk|display_case|bookshelf|travel_bag|drawer|workspace|window_sill|shelf|other)",
    "time_context": "string (enum: daily_use|collection_display|packing|organizing|gift_ready|stored|in_transit)",
    "mood": "string (enum: nostalgic|tidy|playful|minimalistic|cozy|proud|sentimental|cluttered|artistic)",
    "lighting": "string (enum: natural_bright|warm_indoor|soft_diffused|dramatic|moody|fluorescent)"
  },
  "primary_item": {
    "category": "string (enum: figure|stationery|mug_cup|notebook|pen|keychain|plush|memorabilia|decor|plant_pot|accessory|toy|book|other)",
    "name_hint": "string (brief descriptive name)",
    "quantity": 1,
    "colors": ["string", "max 3 colors"],
    "materials": ["string", "enum: plastic|metal|ceramic|wood|paper|fabric|glass|rubber|resin|other, max 3"],
    "style": "string (enum: cute|vintage|modern|minimalist|anime|retro|handmade|luxury|industrial|whimsical)",
    "condition": "string (enum: new|excellent|good|well_loved|vintage|damaged)",
    "craftsmanship_notes": "string (brief quality observation)"
  },
  "description": {
    "appearance": "string (2-3 sentences describing physical appearance)",
    "character": "string (1-2 sentences capturing personality)",
    "story_feeling": "string (1 sentence about emotional resonance)"
  },
  "tags": ["string", "3-5 tags"],
  "memory_reflection": {
    "opening": "string (enum: this_reminds_me_of|i_bought_this_because|every_time_i_see_this|this_has_been_with_me|this_makes_me_feel|i_always_associate_this_with)",
    "reflection": "string (gentle 1-2 sentence reflection, max 200 chars)"
  },
  "discovery": {
    "special_details": ["string", "1-3 interesting details"],
    "possible_origin": "string (inference about source)",
    "companion_items": ["string", "related items"]
  }
}

CRITICAL: Respond ONLY with valid JSON, no markdown formatting, no explanations, no code blocks.''';
  }

  String _detectMimeType(Uint8List bytes) {
    if (bytes.length < 4) return 'image/jpeg';

    final signature = bytes.sublist(0, 4);

    if (signature[0] == 0x89 && signature[1] == 0x50 && signature[2] == 0x4E && signature[3] == 0x47) {
      return 'image/png';
    }
    if (signature[0] == 0xFF && signature[1] == 0xD8 && signature[2] == 0xFF) {
      return 'image/jpeg';
    }
    if (signature[0] == 0x47 && signature[1] == 0x49 && signature[2] == 0x46) {
      return 'image/gif';
    }
    if (signature[0] == 0x52 && signature[1] == 0x49 && signature[2] == 0x46 && signature[3] == 0x46) {
      return 'image/webp';
    }

    return 'image/jpeg';
  }

  Map<String, dynamic> _extractJson(String content) {
    String cleaned = content.trim();

    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }

    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }

    cleaned = cleaned.trim();

    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(cleaned);
    if (jsonMatch != null) {
      cleaned = jsonMatch.group(0) ?? cleaned;
    }

    try {
      return jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (e) {
      throw ThingTaleAIException('Failed to parse JSON response: $e. Cleaned content: $cleaned');
    }
  }

  @override
  void onInit() {
    super.onInit();
    print('[ThingTaleAI] Service initialized');
  }
}
