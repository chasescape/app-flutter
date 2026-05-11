import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:crushi/crushi/data/models/stoic_card.dart';

class StoicAiCardResult {
  final StoicCard card;

  const StoicAiCardResult({
    required this.card,
  });
}

class StoryAiService {
  StoryAiService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const String _baseUrl = 'https://api.gpt.ge';

  // NOTE: user requested to inline the API key directly in code for simplicity.
  static const String _apiKey =
      'sk-QaaY8MM8WwiS9eLfC31f0fB08742448bA75b6a7f1b75E61a';

  static const String _model = 'gpt-4o-2024-05-13';

  static const String _prompt = '''
You are a Stoic-inspired scene analyst for an app called "StoicLens".
The user uploads an everyday photo. Produce a structured "StoicCard" JSON (matching the schema below) that can be rendered in the app UI.

**Tone**
- Stoic philosophy: self-discipline, acceptance, action.
- Gentle, grounded, non-academic, no therapy/diagnosis language.
- Philosophical inspiration, not professional advice.

**Return ONLY valid JSON** (no extra text, no code fences) with this exact structure:
{
  "scene_card": {
    "setting": { "value": "...", "confidence": 0.0-1.0, "evidence": "..." },
    "time_of_day": { "value": "...", "confidence": 0.0-1.0, "evidence": "..." },
    "visual_mood": { "value": "...", "confidence": 0.0-1.0, "evidence": "..." },
    "stoic_virtue": { "value": "Wisdom|Courage|Justice|Temperance", "confidence": 0.0-1.0, "evidence": "..." },
    "human_presence": { "value": "...", "confidence": 0.0-1.0, "evidence": "..." },
    "nature_ratio": { "value": "...", "confidence": 0.0-1.0, "evidence": "..." },
    "key_objects": ["...","...","..."],
    "dominant_colors": ["...","...","..."],
    "light_quality": "..."
  },
  "one_line_capture": "One concise stoic insight sentence (<= 26 words).",
  "tags": ["Tag1","Tag2","Tag3","Tag4","Tag5","Tag6"],
  "safety": { "has_sensitive_content": false, "notes": "" }
}

**Notes**
- Keep tags short, TitleCase, no spaces if possible (e.g. GoldenHour).
- If unsure, still fill fields with best-effort and reasonable confidence.
''';

  Future<StoicAiCardResult> generateStoicCardFromImagePath({
    required String imagePath,
  }) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);

    final requestData = <String, dynamic>{
      'model': _model,
      'messages': [
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': _prompt},
            {
              'type': 'image_url',
              'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
            },
          ],
        },
      ],
      'max_tokens': 2000,
      'temperature': 0.8,
    };

    final res = await _dio.post(
      '$_baseUrl/v1/chat/completions',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
      ),
      data: requestData,
    );

    final data = res.data;
    if (data is! Map) {
      throw const FormatException('Unexpected response');
    }

    final content = (((data['choices'] as List?)?.firstOrNull as Map?)?['message']
            as Map?)?['content'] ??
        '';
    final contentStr = content is String ? content : content.toString();

    final jsonMap = _extractJsonObject(contentStr);
    final card = StoicCard.fromJson(
      jsonMap,
      assetImg: imagePath,
    );
    return StoicAiCardResult(card: card);
  }

  Map<String, dynamic> _extractJsonObject(String content) {
    var jsonString = content.trim();

    final jsonFence = RegExp(r'```json([\s\S]*?)```', multiLine: true);
    final anyFence = RegExp(r'```([\s\S]*?)```', multiLine: true);
    final m1 = jsonFence.firstMatch(jsonString);
    if (m1 != null) {
      jsonString = (m1.group(1) ?? '').trim();
    } else {
      final m2 = anyFence.firstMatch(jsonString);
      if (m2 != null) {
        jsonString = (m2.group(1) ?? '').trim();
      }
    }

    final start = jsonString.indexOf('{');
    final end = jsonString.lastIndexOf('}');
    if (start >= 0 && end > start) {
      jsonString = jsonString.substring(start, end + 1).trim();
    }

    final decoded = jsonDecode(jsonString);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return decoded.cast<String, dynamic>();
    throw const FormatException('Invalid JSON payload');
  }
}

extension on List {
  Object? get firstOrNull => isEmpty ? null : first;
}
