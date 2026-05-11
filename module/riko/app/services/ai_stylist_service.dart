import 'dart:convert';
import 'package:dio/dio.dart';

class AiStylistService {
  AiStylistService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const String _baseUrl = 'https://api.gpt.ge';
  static const String _endpoint = '/v1/chat/completions';

  // TODO: Replace with your secure key provider.
  static const String _apiKey = 'sk-QaaY8MM8WwiS9eLfC31f0fB08742448bA75b6a7f1b75E61a';

  static const String _systemPrompt =
      'You are Riko, an AI fashion stylist. You help users choose outfits and accessories. '
      'Be friendly, concise, and practical. Provide 2-4 outfit ideas and explain why they fit '
      'the occasion, color palette, and body/comfort concerns. If an image is provided, analyze '
      'the visible clothing and suggest matching shoes, outerwear, and accessories.';

  Future<String> chat({required String text, String? imageBase64}) async {
    final content = <Map<String, dynamic>>[
      {
        'type': 'text',
        'text': text,
      },
    ];

    if (imageBase64 != null && imageBase64.isNotEmpty) {
      content.add({
        'type': 'image_url',
        'image_url': {
          'url': 'data:image/jpeg;base64,$imageBase64',
        },
      });
    }

    final payload = {
      'model': 'gpt-4o-2024-05-13',
      'messages': [
        {
          'role': 'system',
          'content': _systemPrompt,
        },
        {
          'role': 'user',
          'content': content,
        },
      ],
      'max_tokens': 800,
      'temperature': 0.7,
    };

    final response = await _dio.post(
      '$_baseUrl$_endpoint',
      data: payload,
      options: Options(
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      ),
    );

    final data = response.data;
    final message = data['choices']?[0]?['message']?['content'];
    if (message is String && message.isNotEmpty) {
      return message.trim();
    }

    return 'Sorry, I could not generate a response. Please try again.';
  }

  static String toBase64(List<int> bytes) => base64Encode(bytes);
}
