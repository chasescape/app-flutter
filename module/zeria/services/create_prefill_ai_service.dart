import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:zeria/zeria/models/create_prefill.dart';

class CreatePrefillAiException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  CreatePrefillAiException(this.message, {this.statusCode, this.responseBody});

  @override
  String toString() => 'CreatePrefillAiException: $message';
}

class CreatePrefillAiService {
  static const String defaultBaseUrl = 'https://api.gpt.ge/v1';
  static const String chatEndpoint = '/chat/completions';
  static const String defaultModel = 'gpt-4o';
  static const Duration defaultTimeout = Duration(seconds: 60);

  final String apiKey;
  final String baseUrl;
  final String model;
  final Duration timeout;
  final HttpClient _client;

  CreatePrefillAiService({
    required this.apiKey,
    String? baseUrl,
    String? model,
    Duration? timeout,
  })  : baseUrl = baseUrl ?? defaultBaseUrl,
        model = model ?? defaultModel,
        timeout = timeout ?? defaultTimeout,
        _client = HttpClient();

  Future<CreatePrefill> analyzeImageToPrefill({
    required File imageFile,
    required List<String> seasons,
    required List<String> times,
    required List<String> styles,
    required List<String> landmarks,
    required List<String> moods,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final prompt = _buildPrompt(
        seasons: seasons,
        times: times,
        styles: styles,
        landmarks: landmarks,
        moods: moods,
      );

      final requestBody = {
        'model': model,
        'messages': [
          {
            'role': 'system',
            'content':
                'You analyze a photo and return ONLY valid JSON with fields used to prefill a form.',
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
        'max_tokens': 800,
        'temperature': 0.2,
      };

      final response = await _sendRequest(requestBody);
      return _parseResponse(response);
    } on SocketException {
      throw CreatePrefillAiException('Network connection failed');
    } on TimeoutException {
      throw CreatePrefillAiException('Request timeout');
    } on CreatePrefillAiException {
      rethrow;
    } catch (e) {
      throw CreatePrefillAiException('Analyze failed: $e');
    }
  }

  String _buildPrompt({
    required List<String> seasons,
    required List<String> times,
    required List<String> styles,
    required List<String> landmarks,
    required List<String> moods,
  }) {
    final seasonsList = seasons.map((e) => '"$e"').join(', ');
    final timesList = times.map((e) => '"$e"').join(', ');
    final stylesList = styles.map((e) => '"$e"').join(', ');
    final landmarksList = landmarks.map((e) => '"$e"').join(', ');
    final moodsList = moods.map((e) => '"$e"').join(', ');

    return '''
Analyze the photo and infer the best values to prefill a travel poster creation form.

Return ONLY JSON. Do NOT wrap in markdown. Do NOT add extra keys.

Schema:
{
  "destination": string,
  "season": string|null,
  "time": string|null,
  "style": string|null,
  "landmark": string|null,
  "mood": string|null,
  "local_people": boolean|null
}

Rules:
- "destination" should be a short place name inferred from the image (city/country/region). If unsure, use a generic place like "Paris" or "Tokyo" based on visual cues.
- For season/time/style/landmark/mood, you MUST choose from the allowed lists below; if not sure, return null.
- Keep destination under 30 characters.

Allowed values:
- season: [$seasonsList]
- time: [$timesList]
- style: [$stylesList]
- landmark: [$landmarksList]
- mood: [$moodsList]
''';
  }

  Future<Map<String, dynamic>> _sendRequest(Map<String, dynamic> body) async {
    final request = await _client.postUrl(Uri.parse('$baseUrl$chatEndpoint'));
    request.headers.contentType = ContentType.json;
    request.headers.add('Authorization', 'Bearer $apiKey');
    request.write(jsonEncode(body));

    final response = await request.close().timeout(timeout);
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(responseBody) as Map<String, dynamic>;
    }

    throw CreatePrefillAiException(
      'API request failed',
      statusCode: response.statusCode,
      responseBody: responseBody,
    );
  }

  CreatePrefill _parseResponse(Map<String, dynamic> responseData) {
    final content = responseData['choices']?[0]?['message']?['content'];
    if (content == null || content.toString().trim().isEmpty) {
      throw CreatePrefillAiException('AI returned empty content');
    }

    String cleaned = content.toString().trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7).trim();
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3).trim();
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3).trim();
    }

    final jsonData = jsonDecode(cleaned) as Map<String, dynamic>;
    return CreatePrefill.fromJson(jsonData);
  }

  void dispose() {
    _client.close(force: true);
  }
}
