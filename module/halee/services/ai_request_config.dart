/// AI request core config shared by image analysis services.
///
/// This mirrors the fixed request/response contract from the project skill
/// template so service implementations stay consistent.
class AiRequestConfig {
  AiRequestConfig._();

  static const String endpoint = '/v1/chat/completions';
  static const String defaultModel = 'gpt-4o-2024-05-13';
  static const int defaultMaxTokens = 4000;
  static const double defaultTemperature = 0.7;
  static const int timeoutSeconds = 60;

  static Map<String, String> buildHeaders(String apiKey) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
  }

  static Map<String, dynamic> buildRequestBody({
    required String imageBase64,
    String imageMimeType = 'image/jpeg',
    required String systemPrompt,
    required String userPrompt,
    String? model,
    int? maxTokens,
    double? temperature,
  }) {
    return {
      'model': model ?? defaultModel,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': userPrompt},
            {
              'type': 'image_url',
              'image_url': {'url': buildImageUrl(imageBase64, mimeType: imageMimeType)},
            }
          ]
        }
      ],
      'max_tokens': maxTokens ?? defaultMaxTokens,
      'temperature': temperature ?? defaultTemperature,
    };
  }

  static String? extractContent(Map<String, dynamic> response) {
    return response['choices']?[0]?['message']?['content'] as String?;
  }

  static String cleanJsonResponse(String content) {
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

  static String buildImageUrl(String base64Data,
      {String mimeType = 'image/jpeg'}) {
    return 'data:$mimeType;base64,$base64Data';
  }
}
