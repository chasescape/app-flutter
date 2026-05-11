import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' as getx;
import '../data/models/style_analysis.dart';
import '../env/app_env.dart';
import 'storage_service.dart';

/// AI 图片分析异常
class StyleAnalysisException implements Exception {
  final String message;
  final int? statusCode;

  StyleAnalysisException(this.message, {this.statusCode});

  @override
  String toString() => 'StyleAnalysisException: $message${statusCode != null ? " (status: $statusCode)" : ""}';
}

/// AI 图片分析服务
class StyleAnalysisService extends getx.GetxService {
  late Dio _dio;
  final StorageService _storage = getx.Get.find<StorageService>();

  static const String _baseUrl = 'https://api.gpt.ge';
  static const int _connectTimeout = 60000;
  static const int _receiveTimeout = 60000;
  static const String _model = 'gpt-4o';
  static const int _maxTokens = 4096;

  @override
  void onInit() {
    super.onInit();
    _initDio();
  }

  void _initDio() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(milliseconds: _connectTimeout),
      receiveTimeout: const Duration(milliseconds: _receiveTimeout),
      sendTimeout: const Duration(milliseconds: _connectTimeout),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('🔵 [StyleAnalysis] Request: ${options.method} ${options.uri}');
        if (options.data != null) {
          debugPrint('📦 Request data length: ${options.data.toString().length}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('🟢 [StyleAnalysis] Response: ${response.statusCode}');
        return handler.next(response);
      },
      onError: (error, handler) {
        debugPrint('🔴 [StyleAnalysis] Error: ${error.message}');
        return handler.next(error);
      },
    ));
  }

  /// 分析图片风格
  /// [imagePath] 图片本地路径
  /// [imageBytes] 图片字节数据（如果提供，则优先使用）
  Future<StyleAnalysis> analyzeImage({
    String? imagePath,
    List<int>? imageBytes,
  }) async {
    if (imagePath == null && imageBytes == null) {
      throw StyleAnalysisException('Either imagePath or imageBytes must be provided');
    }

    try {
      final apiKey = AppEnv().geApiKey;
      if (apiKey.isEmpty) {
        throw StyleAnalysisException('API Key is not configured. Please set geApiKey in AppEnv.');
      }

      List<int> bytes;
      if (imageBytes != null) {
        bytes = imageBytes;
      } else {
        final file = File(imagePath!);
        if (!await file.exists()) {
          throw StyleAnalysisException('Image file not found: $imagePath');
        }
        bytes = await file.readAsBytes();
      }

      final base64Image = base64Encode(bytes);
      final mimeType = _detectMimeType(bytes);

      final requestData = {
        'model': _model,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': _getSystemPrompt(),
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
        'max_tokens': _maxTokens,
      };

      debugPrint('📤 [StyleAnalysis] Sending request...');

      final response = await _dio.post(
        '/v1/chat/completions',
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
          },
        ),
      );

      if (response.statusCode == 200) {
        return await _parseResponse(response.data);
      } else {
        throw StyleAnalysisException(
          'Request failed with status ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw StyleAnalysisException('Unexpected error: $e');
    }
  }

  /// 解析响应
  Future<StyleAnalysis> _parseResponse(dynamic responseData) async {
    try {
      if (responseData == null) {
        throw StyleAnalysisException('Empty response from server');
      }

      final content = responseData['choices']?[0]?['message']?['content'];
      if (content == null) {
        throw StyleAnalysisException('No content in response');
      }

      debugPrint('📝 [StyleAnalysis] Raw response length: ${content.toString().length}');

      final cleanedJson = _cleanJsonContent(content);
      debugPrint('🧹 [StyleAnalysis] Cleaned JSON: ${cleanedJson.substring(0, cleanedJson.length > 100 ? 100 : cleanedJson.length)}...');

      final jsonMap = jsonDecode(cleanedJson) as Map<String, dynamic>;

      final analysis = StyleAnalysis.fromJson(jsonMap);

      await _saveToHistory(analysis);

      debugPrint('✅ [StyleAnalysis] Analysis completed successfully');
      return analysis;
    } on FormatException catch (e) {
      debugPrint('❌ [StyleAnalysis] JSON parse error: $e');
      throw StyleAnalysisException('Failed to parse response as JSON: ${e.message}');
    } catch (e) {
      debugPrint('❌ [StyleAnalysis] Parse error: $e');
      throw StyleAnalysisException('Failed to parse response: $e');
    }
  }

  /// 清理 JSON 内容
  String _cleanJsonContent(String content) {
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

    final startIdx = cleaned.indexOf('{');
    final endIdx = cleaned.lastIndexOf('}');

    if (startIdx != -1 && endIdx != -1 && endIdx > startIdx) {
      cleaned = cleaned.substring(startIdx, endIdx + 1);
    }

    return cleaned;
  }

  /// 保存到历史记录
  Future<void> _saveToHistory(StyleAnalysis analysis) async {
    try {
      final historyJson = await _storage.getString('style_analysis_history');
      List<Map<String, dynamic>> history;

      if (historyJson != null && historyJson.isNotEmpty) {
        history = List<Map<String, dynamic>>.from(jsonDecode(historyJson));
      } else {
        history = [];
      }

      final analysisJson = analysis.toJson();
      analysisJson['timestamp'] = DateTime.now().toIso8601String();
      analysisJson['id'] = DateTime.now().millisecondsSinceEpoch.toString();

      history.insert(0, analysisJson);

      if (history.length > 100) {
        history = history.sublist(0, 100);
      }

      await _storage.setString('style_analysis_history', jsonEncode(history));
      debugPrint('💾 [StyleAnalysis] Saved to history. Total: ${history.length}');
    } catch (e) {
      debugPrint('⚠️ [StyleAnalysis] Failed to save history: $e');
    }
  }

  /// 获取历史记录
  Future<List<StyleAnalysis>> getHistory() async {
    try {
      final historyJson = await _storage.getString('style_analysis_history');
      if (historyJson == null || historyJson.isEmpty) {
        return [];
      }

      final history = List<Map<String, dynamic>>.from(jsonDecode(historyJson));

      return history.map((item) {
        final analysis = StyleAnalysis.fromJson(item);
        return analysis;
      }).toList();
    } catch (e) {
      debugPrint('⚠️ [StyleAnalysis] Failed to load history: $e');
      return [];
    }
  }

  /// 清除历史记录
  Future<void> clearHistory() async {
    try {
      await _storage.remove('style_analysis_history');
      debugPrint('🗑️ [StyleAnalysis] History cleared');
    } catch (e) {
      debugPrint('⚠️ [StyleAnalysis] Failed to clear history: $e');
    }
  }

  /// 处理 Dio 错误
  StyleAnalysisException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return StyleAnalysisException('Connection timeout. Please check your network and try again.');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400:
            return StyleAnalysisException('Invalid request. Please check your input.', statusCode: statusCode);
          case 401:
            return StyleAnalysisException('Authentication failed. Please check your API Key.', statusCode: statusCode);
          case 403:
            return StyleAnalysisException('Access forbidden. You don\'t have permission.', statusCode: statusCode);
          case 404:
            return StyleAnalysisException('Service not found.', statusCode: statusCode);
          case 429:
            return StyleAnalysisException('Too many requests. Please try again later.', statusCode: statusCode);
          case 500:
            return StyleAnalysisException('Server error. Please try again later.', statusCode: statusCode);
          case 503:
            return StyleAnalysisException('Service unavailable. Please try again later.', statusCode: statusCode);
          default:
            final errorMsg = error.response?.data?['error']?['message'] ?? error.message;
            return StyleAnalysisException('Request failed: $errorMsg', statusCode: statusCode);
        }

      case DioExceptionType.cancel:
        return StyleAnalysisException('Request was cancelled.');

      case DioExceptionType.unknown:
        return StyleAnalysisException('Network error. Please check your connection.');

      default:
        return StyleAnalysisException('An unexpected error occurred: ${error.message}');
    }
  }

  /// 检测图片 MIME 类型
  String _detectMimeType(List<int> bytes) {
    if (bytes.length < 4) return 'image/jpeg';

    final header = bytes.sublist(0, 4);

    if (header[0] == 0x89 && header[1] == 0x50 && header[2] == 0x4E && header[3] == 0x47) {
      return 'image/png';
    }
    if (header[0] == 0xFF && header[1] == 0xD8) {
      return 'image/jpeg';
    }
    if (header[0] == 0x47 && header[1] == 0x49 && header[2] == 0x46) {
      return 'image/gif';
    }
    if (header[0] == 0x52 && header[1] == 0x49 && header[2] == 0x46 && header[3] == 0x46) {
      return 'image/webp';
    }

    return 'image/jpeg';
  }

  /// 获取系统提示词
  String _getSystemPrompt() {
    return r'''You are AestheticStyle MuseMatch Assistant, a professional style reference analyzer.

Your goal is to analyze a selfie photo and extract style reference directions that help users discover relevant content on Instagram and YouTube. You focus on visual style elements, NOT on identifying real people or making "look alike" comparisons.

Core Principles:
- Output style references, not identity matches or celebrity comparisons
- Focus on visible visual elements: overall vibe, hairstyle, makeup style, outfit aesthetic, and photo atmosphere
- Provide actionable search keywords that users can copy-paste into social/video platforms
- Do NOT identify real people, celebrities, or guess sensitive attributes (age, race, body type, etc.)
- If visual elements are unclear, use "Unclear" and lower confidence

Return ONLY valid JSON (no markdown, no extra text).

Analyze this selfie photo for style reference and output a Style Analysis JSON.

Allowed enums:

Style Vibe (choose 1):
["Soft Minimal", "Clean Girl", "Street Casual", "Elegant Chic", "Cozy Aesthetic", "Sporty Active", "Bohemian Free", "Dark Moody", "Preppy Classic", "Y2K Trendy", "Cottage Core", "Urban Edge", "Feminine Romantic", "Minimalist Modern", "Vintage Retro", "Artistic Creative", "Casual Laid-back", "Glam Luxe", "Edgy Bold", "Natural Fresh"]

Hairstyle Category (choose 1):
["Long Straight", "Long Wavy", "Long Curly", "Medium Length", "Short Bob", "Pixie Cut", "Ponytail", "Updo Bun", "Half-up Half-down", "Braids", "Layered", "Bangs with Long Hair", "Unclear"]

Makeup Intensity (choose 1):
["No Visible Makeup", "Natural Minimal", "Soft Glowy", "Medium Coverage", "Bold Statement", "Creative Artistic", "Unclear"]

Outfit Style (choose 1):
["Casual Everyday", "Minimalist Clean", "Streetwear", "Elegant Formal", "Cozy Loungewear", "Sporty Athletic", "Vintage Inspired", "Boho Flowy", "Business Casual", "Edgy Alternative", "Monochrome", "Pattern Mixed", "Unclear"]

Photo Mood (choose 1):
["Bright Airy", "Moody Dramatic", "Warm Cozy", "Cool Fresh", "Natural Sunlit", "Studio Polished", "Candid Candid", "Golden Hour", "Night Vibes", "Indoor Cozy", "Outdoor Scenic", "Unclear"]

Creator Types to Follow (choose 2-3):
["daily vlog creator", "soft makeup creator", "minimal outfit creator", "hairstyle tutorial creator", "skincare routine creator", "outfit inspiration creator", "photo pose creator", "lifestyle aesthetic creator", "wellness selfcare creator", "accessories styling creator", "photography tips creator", "body positivity creator", "budget fashion creator", "thrifting creator", "seasonal transition creator"]

Content Priority (choose 1):
["Start with makeup and hair tutorials", "Start with outfit inspiration", "Start with photo pose tips", "Start with skincare routine", "Start with accessory styling", "Start with color matching", "Start with seasonal wardrobe", "Start with basic capsule wardrobe"]

Output schema (return ONLY JSON):
{
  "style_analysis": {
    "style_vibe": {"value": "...", "confidence": 0.0, "evidence": "..."},
    "hairstyle_category": {"value": "...", "confidence": 0.0, "evidence": "..."},
    "makeup_intensity": {"value": "...", "confidence": 0.0, "evidence": "..."},
    "outfit_style": {"value": "...", "confidence": 0.0, "evidence": "..."},
    "photo_mood": {"value": "...", "confidence": 0.0, "evidence": "..."}
  },
  "style_tags": ["...", "...", "..."],
  "creator_types_to_follow": ["...", "...", "..."],
  "search_keywords": {
    "youtube_search": "...",
    "instagram_search": "...",
    "alternative_search_1": "...",
    "alternative_search_2": "..."
  },
  "style_description": {
    "why_this_fits": "...",
    "key_takeaways": ["...", "...", "..."]
  },
  "quick_action_plan": {
    "start_with": "...",
    "copy_this_search_phrase": "..."
  },
  "visual_notes": {
    "dominant_colors": ["...", "..."],
    "notable_accessories": ["..."],
    "photo_strengths": ["..."],
    "easy_improvements": ["..."]
  },
  "safety_check": {
    "has_quality_issues": false,
    "quality_notes": "",
    "should_reshoot": false
  }
}

Field Guidelines:
- "style_tags": Exactly 3 tags from allowed Style Vibe enums that best match
- "creator_types_to_follow": Exactly 2-3 types from allowed Creator Types
- "search_keywords":
  * "youtube_search": A practical English search phrase (3-8 words) for finding tutorials
  * "instagram_search": A practical English search phrase (3-8 words) for finding inspiration
  * "alternative_search_1/2": Backup search phrases with different angles
- "style_description":
  * "why_this_fits": 2-3 sentences explaining why these style directions work as references
  * "key_takeaways": 3 bullet points of specific style elements to explore
- "quick_action_plan":
  * "start_with": Which content type to explore first
  * "copy_this_search_phrase": One ready-to-copy English search phrase (8-15 words)
- "visual_notes":
  * "dominant_colors": 2-3 visible color tones (e.g., "warm beige", "soft pink", "navy blue")
  * "notable_accessories": 1-3 visible accessories (e.g., "hoop earrings", "delicate necklace")
  * "photo_strengths": 1-2 things done well in this photo
  * "easy_improvements": 1-2 quick improvements for next photos
- "safety_check":
  * "has_quality_issues": true if photo is too dark, blurry, or severely angled
  * "quality_notes": Brief description of issues if any
  * "should_reshoot": true if quality severely impacts analysis

IMPORTANT:
- The selfie photo is provided as an image input in this request.
- If photo angle/quality limits analysis, set more fields to "Unclear" and note in safety_check.
- All search phrases must be in English and practical for copy-pasting.
- Do not mention specific real people, brands, or identifiable locations.
- Return ONLY the JSON object, no additional text.''';
  }

  @override
  void onClose() {
    _dio.close();
    super.onClose();
  }
}
