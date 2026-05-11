import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../data/models/style_analysis.dart';
import '../env/app_env.dart';

/// AI image analysis error.
class StyleAnalysisAiException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  StyleAnalysisAiException(
    this.message, {
    this.statusCode,
    this.responseBody,
  });

  @override
  String toString() => 'StyleAnalysisAiException: $message';
}

class StyleAnalysisAiService {
  static const String _baseUrl = 'https://api.gpt.ge';
  static const String _model = 'gpt-4o-2024-05-13';
  static const Duration _timeout = Duration(seconds: 60);
  static const int _maxTokens = 4000;
  static const double _temperature = 0.7;

  static const String _systemPrompt = r'''
You are AestheticStyle MuseMatch Assistant, a professional style reference analyzer.

Your goal is to analyze a selfie photo and extract style reference directions that help users discover relevant content on Instagram and YouTube. You focus on visual style elements, NOT on identifying real people or making "look alike" comparisons.

Core Principles:
- Output style references, not identity matches or celebrity comparisons
- Focus on visible visual elements: overall vibe, hairstyle, makeup style, outfit aesthetic, and photo atmosphere
- Provide actionable search keywords that users can copy-paste into social/video platforms
- Do NOT identify real people, celebrities, or guess sensitive attributes (age, race, body type, etc.)
- If visual elements are unclear, use "Unclear" and lower confidence

Return ONLY valid JSON (no markdown, no extra text).
''';

  static const String _userPromptTemplate = r'''
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
''';

  final http.Client _client;
  final bool _ownsClient;
  final String _apiKey;

  StyleAnalysisAiService({
    String? apiKey,
    http.Client? client,
  })  : _client = client ?? http.Client(),
        _ownsClient = client == null,
        _apiKey = apiKey ?? AppEnv().geApiKey;

  /// Analyze one portrait image and return structured style data.
  Future<StyleAnalysis> analyzeImage(File imageFile) async {
    if (_apiKey.isEmpty) {
      throw StyleAnalysisAiException(
        'API Key is not configured. Please set geApiKey in AppEnv.',
      );
    }

    if (!await imageFile.exists()) {
      throw StyleAnalysisAiException(
        'Image file not found: ${imageFile.path}',
      );
    }

    try {
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);
      final mimeType = _detectMimeType(imageBytes);

      final response = await _client
          .post(
            Uri.parse('$_baseUrl/v1/chat/completions'),
            headers: _buildHeaders(_apiKey),
            body: jsonEncode(
              _buildRequestBody(
                imageBase64: base64Image,
                mimeType: mimeType,
                systemPrompt: _systemPrompt,
                userPrompt: _userPromptTemplate,
                model: _model,
                maxTokens: _maxTokens,
                temperature: _temperature,
              ),
            ),
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw StyleAnalysisAiException(
          'API request failed',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }

      return _parseResponse(response.body);
    } on SocketException {
      throw StyleAnalysisAiException('Network connection failed.');
    } on TimeoutException {
      throw StyleAnalysisAiException('Request timed out. Please try again.');
    } on StyleAnalysisAiException {
      rethrow;
    } catch (e) {
      throw StyleAnalysisAiException('Analysis failed: $e');
    }
  }

  Map<String, String> _buildHeaders(String apiKey) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
  }

  Map<String, dynamic> _buildRequestBody({
    required String imageBase64,
    required String mimeType,
    required String systemPrompt,
    required String userPrompt,
    String? model,
    int? maxTokens,
    double? temperature,
  }) {
    return {
      'model': model ?? _model,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': userPrompt},
            {
              'type': 'image_url',
              'image_url': {
                'url': _buildImageUrl(imageBase64, mimeType: mimeType),
              },
            },
          ],
        },
      ],
      'max_tokens': maxTokens ?? _maxTokens,
      'temperature': temperature ?? _temperature,
    };
  }

  StyleAnalysis _parseResponse(String responseBody) {
    final responseData = jsonDecode(responseBody) as Map<String, dynamic>;
    final content = _extractContent(responseData);

    if (content == null || content.isEmpty) {
      throw StyleAnalysisAiException('AI returned empty content.');
    }

    final cleaned = _cleanJsonResponse(content);
    final jsonData = jsonDecode(cleaned) as Map<String, dynamic>;
    return StyleAnalysis.fromJson(jsonData);
  }

  String? _extractContent(Map<String, dynamic> response) {
    return response['choices']?[0]?['message']?['content'] as String?;
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

  String _detectMimeType(List<int> bytes) {
    if (bytes.length < 4) return 'image/jpeg';

    final header = bytes.sublist(0, 4);
    if (header[0] == 0x89 &&
        header[1] == 0x50 &&
        header[2] == 0x4E &&
        header[3] == 0x47) {
      return 'image/png';
    }
    if (header[0] == 0xFF && header[1] == 0xD8) {
      return 'image/jpeg';
    }
    if (header[0] == 0x47 && header[1] == 0x49 && header[2] == 0x46) {
      return 'image/gif';
    }
    if (header[0] == 0x52 &&
        header[1] == 0x49 &&
        header[2] == 0x46 &&
        header[3] == 0x46) {
      return 'image/webp';
    }

    return 'image/jpeg';
  }

  void dispose() {
    if (_ownsClient) {
      _client.close();
    }
  }
}
