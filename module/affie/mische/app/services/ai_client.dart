import 'package:dio/dio.dart' as dio;

class AiClient {
  static const _apiKey = String.fromEnvironment('OPENAI_API_KEY');

  static bool hasApiKey() => _apiKey.isNotEmpty;

  static dio.Dio create() {
    const baseUrl = String.fromEnvironment(
      'OPENAI_BASE_URL',
      defaultValue: 'https://api.openai.com',
    );

    if (_apiKey.isEmpty) {
      throw StateError('Missing OPENAI_API_KEY. Provide it via --dart-define.');
    }

    return dio.Dio(
      dio.BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      ),
    );
  }
}
