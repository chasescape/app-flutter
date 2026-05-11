import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class CheerAiService {
  CheerAiService({
    required this.apiKey,
    Dio? dio,
    this.baseUrl = 'https://api.gpt.ge',
  }) : _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
    );
  }

  final Dio _dio;
  final String apiKey;
  final String baseUrl;

  Future<CheerAnalysisResult> analyzePoseFile(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return analyzePoseBytes(bytes);
  }

  Future<CheerAnalysisResult> analyzePoseBytes(Uint8List bytes) async {
    final base64Image = base64Encode(bytes);
    return analyzePoseBase64(base64Image);
  }

  Future<CheerAnalysisResult> analyzePoseBase64(String base64Image) async {
    if (apiKey.trim().isEmpty) {
      throw StateError('CheerAiService requires a non-empty apiKey.');
    }

    final requestData = {
      "model": "gpt-4o-2024-05-13",
      "messages": [
        {
          "role": "user",
          "content": [
            {"type": "text", "text": _prompt()},
            {
              "type": "image_url",
              "image_url": {
                "url": "data:image/jpeg;base64,$base64Image"
              }
            }
          ]
        }
      ],
      "max_tokens": 1200,
      "temperature": 0.6
    };

    final response = await _dio.post(
      '/v1/chat/completions',
      data: jsonEncode(requestData),
    );

    final status = response.statusCode ?? 0;
    if (status < 200 || status >= 300) {
      throw Exception('AI request failed: $status ${response.data}');
    }

    final content = response.data?['choices']?[0]?['message']?['content']
            ?.toString() ??
        '';

    final jsonMap = _parseJsonSafely(content);
    return CheerAnalysisResult.fromJson(jsonMap);
  }

  String _prompt() {
    return '''
You are a professional cheerleading coach and motion analyst. Analyze the uploaded cheerleading pose photo and provide structured feedback.

Requirements:
- Evaluate alignment, technique, body lines, stability, and execution quality
- Identify 3-5 strengths
- Identify 3-5 improvements with concrete corrections
- Provide a short summary (1-2 sentences)
- Provide an overall score 0-100
- Keep feedback actionable and supportive

Response format:
Return ONLY a valid JSON object with this exact structure:
{
  "score": 88,
  "summary": "Short, supportive summary.",
  "strengths": ["...", "..."],
  "improvements": ["...", "..."],
  "tips": ["...", "..."]
}
''';
  }

  Map<String, dynamic> _parseJsonSafely(String content) {
    String jsonString = content.trim();

    if (jsonString.contains('```json')) {
      final start = jsonString.indexOf('```json') + 7;
      final end = jsonString.indexOf('```', start);
      if (end > start) {
        jsonString = jsonString.substring(start, end).trim();
      }
    } else if (jsonString.contains('```')) {
      final start = jsonString.indexOf('```') + 3;
      final end = jsonString.indexOf('```', start);
      if (end > start) {
        jsonString = jsonString.substring(start, end).trim();
      }
    }

    final firstBrace = jsonString.indexOf('{');
    final lastBrace = jsonString.lastIndexOf('}');
    if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
      jsonString = jsonString.substring(firstBrace, lastBrace + 1);
    }

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}

    return {
      "score": 0,
      "summary": "Unable to parse AI response.",
      "strengths": [],
      "improvements": [],
      "tips": [],
    };
  }
}

class CheerAnalysisResult {
  final int score;
  final String summary;
  final List<String> strengths;
  final List<String> improvements;
  final List<String> tips;

  CheerAnalysisResult({
    required this.score,
    required this.summary,
    required this.strengths,
    required this.improvements,
    required this.tips,
  });

  factory CheerAnalysisResult.fromJson(Map<String, dynamic> json) {
    return CheerAnalysisResult(
      score: (json['score'] is num) ? (json['score'] as num).round() : 0,
      summary: (json['summary'] ?? '').toString(),
      strengths: _toStringList(json['strengths']),
      improvements: _toStringList(json['improvements']),
      tips: _toStringList(json['tips']),
    );
  }

  static List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'summary': summary,
      'strengths': strengths,
      'improvements': improvements,
      'tips': tips,
    };
  }
}
