import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../env/app_env.dart';

class EncouragementException implements Exception {
  final String message;
  final int? statusCode;

  EncouragementException(this.message, [this.statusCode]);

  @override
  String toString() => 'EncouragementException: $message${statusCode != null ? " (Status: $statusCode)" : ""}';
}

class EncouragementService {
  static EncouragementService? _instance;
  static EncouragementService get instance => _instance ??= EncouragementService._();
  EncouragementService._();

  final String _baseUrl = 'https://api.anthropic.com/v1/messages';
  final String _apiVersion = '2023-06-01';
  final Duration _timeout = const Duration(seconds: 30);

  Future<String> generateEncouragement({
    required int totalAmount,
    required int dailyGoal,
    required int progress,
    required int streak,
  }) async {
    final apiKey = AppEnv().geApiKey;
    if (apiKey.isEmpty) {
      throw EncouragementException('API key not configured');
    }

    final prompt = _buildPrompt(totalAmount, dailyGoal, progress, streak);

    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'x-api-key': apiKey,
              'anthropic-version': _apiVersion,
              'content-type': 'application/json',
            },
            body: jsonEncode({
              'model': 'claude-3-haiku-20240307',
              'max_tokens': 100,
              'messages': [
                {
                  'role': 'user',
                  'content': prompt,
                }
              ],
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['content'] as List;
        if (content.isNotEmpty && content[0] is Map) {
          final text = content[0]['text'] as String?;
          if (text != null && text.isNotEmpty) {
            return text.trim();
          }
        }
        throw EncouragementException('Empty response from AI');
      } else if (response.statusCode == 500) {
        throw EncouragementException('AI service temporarily unavailable', 500);
      } else {
        throw EncouragementException(
          'AI request failed: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on TimeoutException {
      throw EncouragementException('Request timeout');
    } on http.ClientException catch (e) {
      throw EncouragementException('Network error: ${e.message}');
    }
  }

  String _buildPrompt(int totalAmount, int dailyGoal, int progress, int streak) {
    final achievement = progress >= 100 ? 'reached their daily goal' : 'made progress towards their goal';
    final streakText = streak > 1 ? '$streak days in a row' : 'started their journey';

    return '''Generate a short, encouraging message for a water tracking app.

Context:
- The user has drunk ${totalAmount}ml of water today
- Their daily goal is ${dailyGoal}ml
- They are at ${progress}% of their goal ($achievement)
- Current streak: $streakText

Requirements:
- Return ONLY the encouraging message, no quotes or extra text
- Keep it under 15 words
- Make it positive and motivating
- Use emojis occasionally
- Must be in English

Examples:
"Amazing! You crushed your hydration goal! 💪"
"Great progress! Every sip counts! 💧"
"You're on fire! $streak days of staying hydrated! 🔥"''';
  }

  Future<String> generateEncouragementWithRetry({
    required int totalAmount,
    required int dailyGoal,
    required int progress,
    required int streak,
    int maxRetries = 1,
  }) async {
    EncouragementException? lastError;

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        return await generateEncouragement(
          totalAmount: totalAmount,
          dailyGoal: dailyGoal,
          progress: progress,
          streak: streak,
        );
      } on EncouragementException catch (e) {
        lastError = e;
        if (e.statusCode == 500 && attempt < maxRetries) {
          await Future.delayed(const Duration(seconds: 1));
          continue;
        }
        rethrow;
      }
    }

    throw lastError ?? EncouragementException('Unknown error occurred');
  }

  void dispose() {
    _instance = null;
  }
}
