import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../env/app_env.dart';
import '../interface.dart';

/// AI Novel Analysis Exception
class AiException implements Exception {
  final String message;
  final int? statusCode;

  AiException(this.message, [this.statusCode]);

  @override
  String toString() => 'AiException: $message${statusCode != null ? " (Status: $statusCode)" : ""}';
}

/// API Service
/// Handles HTTP requests to backend
class ApiService {
  ApiService._();

  static late Dio _dio;

  /// Initialize API service
  static void init() {
    _dio = Dio(BaseOptions(
      baseUrl: AppEnv().hostApi,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  static void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add auth token if available
        final authToken = Interface().authToken;
        if (authToken != null) {
          options.headers['Authorization'] = 'Bearer $authToken';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (error, handler) {
        // Handle errors
        if (error.response?.statusCode == 401) {
          // Unauthorized - clear token and navigate to login
          Interface().authToken = null;
          // Navigate to login (needs context)
        }
        return handler.next(error);
      },
    ));
  }

  static Dio get dio => _dio;

  // Example API methods
  static Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  static Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  static Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }

  static Future<Response> delete(String path) {
    return _dio.delete(path);
  }
}

/// AI Service for Novel Analysis
/// Provides AI-powered novel analysis and character extraction
class AiService {
  AiService._();

  static Dio? _aiDio;
  static CancelToken? _cancelToken;

  /// Initialize AI service
  static void init() {
    if (_aiDio != null) return;

    _aiDio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
  }

  /// Cancel ongoing AI requests
  static void cancelRequests() {
    if (_cancelToken != null && !_cancelToken!.isCancelled) {
      _cancelToken!.cancel('Request cancelled by user');
    }
  }

  /// Analyze novel and extract information
  ///
  /// Returns a map containing:
  /// - 'genre': Suggested genre (String)
  /// - 'themes': List of themes (List<String>)
  /// - 'summary': Generated summary (String)
  static Future<Map<String, dynamic>> analyzeNovel(
    String title,
    String author, [
    String? plotSummary,
  ]) async {
    init();
    _cancelToken = CancelToken();

    final apiKey = AppEnv().geApiKey;
    if (apiKey.isEmpty) {
      throw AiException('API Key not configured');
    }

    try {
      // Build prompt for novel analysis
      final prompt = _buildAnalysisPrompt(title, author, plotSummary);

      debugPrint('[AiService] Starting novel analysis for: $title by $author');

      // Call AI API (Claude)
      final response = await _aiDio!.post(
        'https://api.anthropic.com/v1/messages',
        data: {
          'model': 'claude-3-haiku-20240307',
          'max_tokens': 1024,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
        },
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
          },
        ),
        cancelToken: _cancelToken,
      );

      // Parse response
      final result = _parseAnalysisResponse(response.data);
      debugPrint('[AiService] Novel analysis completed: ${result['genre']}');
      return result;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        debugPrint('[AiService] Request cancelled');
        throw AiException('Request cancelled');
      }
      if (e.response != null) {
        debugPrint('[AiService] API error: ${e.response?.statusCode}');
        throw AiException(
          'API request failed: ${e.message}',
          e.response?.statusCode,
        );
      }
      debugPrint('[AiService] Network error: ${e.message}');
      throw AiException('Network error: ${e.message}');
    } catch (e) {
      debugPrint('[AiService] Analysis error: $e');
      throw AiException('Analysis failed: $e');
    }
  }

  /// Extract characters from plot summary
  ///
  /// Returns a list of character maps:
  /// - 'name': Character name (String)
  /// - 'role': Character role (String?)
  /// - 'notes': Character notes (String?)
  static Future<List<Map<String, dynamic>>> extractCharacters(
    String plotSummary, {
    String? title,
    String? author,
  }) async {
    init();
    _cancelToken = CancelToken();

    final apiKey = AppEnv().geApiKey;
    if (apiKey.isEmpty) {
      throw AiException('API Key not configured');
    }

    try {
      // Build prompt for character extraction
      final prompt = _buildCharacterExtractionPrompt(plotSummary, title, author);

      debugPrint('[AiService] Starting character extraction');

      // Call AI API
      final response = await _aiDio!.post(
        'https://api.anthropic.com/v1/messages',
        data: {
          'model': 'claude-3-haiku-20240307',
          'max_tokens': 1024,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
        },
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
          },
        ),
        cancelToken: _cancelToken,
      );

      // Parse response
      final result = _parseCharacterResponse(response.data);
      debugPrint('[AiService] Character extraction completed: ${result.length} characters');
      return result;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        debugPrint('[AiService] Request cancelled');
        throw AiException('Request cancelled');
      }
      if (e.response != null) {
        debugPrint('[AiService] API error: ${e.response?.statusCode}');
        throw AiException(
          'API request failed: ${e.message}',
          e.response?.statusCode,
        );
      }
      debugPrint('[AiService] Network error: ${e.message}');
      throw AiException('Network error: ${e.message}');
    } catch (e) {
      debugPrint('[AiService] Character extraction error: $e');
      throw AiException('Character extraction failed: $e');
    }
  }

  /// Build prompt for novel analysis
  static String _buildAnalysisPrompt(
    String title,
    String author,
    String? plotSummary,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('You are a literary analysis assistant. Analyze the following novel:');
    buffer.writeln();
    buffer.writeln('Title: $title');
    buffer.writeln('Author: $author');
    if (plotSummary != null && plotSummary.isNotEmpty) {
      buffer.writeln('Plot Summary: $plotSummary');
    }
    buffer.writeln();
    buffer.writeln('Provide analysis in JSON format:');
    buffer.writeln('```json');
    buffer.writeln('{');
    buffer.writeln('  "genre": "suggested genre (Fantasy/Romance/Sci-Fi/Mystery/Horror/Thriller/Literary/Historical/Other)",');
    buffer.writeln('  "themes": ["theme1", "theme2", "theme3"],');
    buffer.writeln('  "summary": "brief 2-3 sentence summary of the story"');
    buffer.writeln('}');
    buffer.writeln('```');
    return buffer.toString();
  }

  /// Build prompt for character extraction
  static String _buildCharacterExtractionPrompt(
    String plotSummary,
    String? title,
    String? author,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('Extract main characters from the following novel information:');
    buffer.writeln();
    if (title != null) buffer.writeln('Title: $title');
    if (author != null) buffer.writeln('Author: $author');
    buffer.writeln('Plot Summary: $plotSummary');
    buffer.writeln();
    buffer.writeln('List main characters in JSON format:');
    buffer.writeln('```json');
    buffer.writeln('[');
    buffer.writeln('  {');
    buffer.writeln('    "name": "character name",');
    buffer.writeln('    "role": "character role (Protagonist/Antagonist/Supporting)",');
    buffer.writeln('    "notes": "brief description or significance"');
    buffer.writeln('  }');
    buffer.writeln(']');
    buffer.writeln('```');
    buffer.writeln('Return only the JSON array, no other text.');
    return buffer.toString();
  }

  /// Parse novel analysis response
  static Map<String, dynamic> _parseAnalysisResponse(dynamic responseData) {
    try {
      final content = responseData['content'] as List?;
      if (content == null || content.isEmpty) {
        throw AiException('Empty response from AI');
      }

      final text = content[0]['text'] as String?;
      if (text == null) {
        throw AiException('No text in response');
      }

      // Extract JSON from markdown code blocks
      final jsonMatch = RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(text);
      if (jsonMatch == null) {
        throw AiException('Could not extract JSON from response');
      }

      final jsonString = jsonMatch.group(1) ?? '';
      final parsed = jsonDecode(jsonString) as Map<String, dynamic>;

      return {
        'genre': parsed['genre'] ?? 'Other',
        'themes': List<String>.from(parsed['themes'] ?? []),
        'summary': parsed['summary'] ?? '',
      };
    } catch (e) {
      throw AiException('Failed to parse analysis response: $e');
    }
  }

  /// Parse character extraction response
  static List<Map<String, dynamic>> _parseCharacterResponse(dynamic responseData) {
    try {
      final content = responseData['content'] as List?;
      if (content == null || content.isEmpty) {
        throw AiException('Empty response from AI');
      }

      final text = content[0]['text'] as String?;
      if (text == null) {
        throw AiException('No text in response');
      }

      // Extract JSON array from markdown code blocks
      final jsonMatch = RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(text);
      if (jsonMatch == null) {
        throw AiException('Could not extract JSON from response');
      }

      final jsonString = jsonMatch.group(1) ?? '';
      final parsed = jsonDecode(jsonString) as List;

      return parsed.map((item) {
        return {
          'name': item['name'] as String? ?? '',
          'role': item['role'] as String?,
          'notes': item['notes'] as String?,
        };
      }).toList();
    } catch (e) {
      throw AiException('Failed to parse character response: $e');
    }
  }

  /// Dispose resources
  static void dispose() {
    cancelRequests();
    _aiDio?.close();
    _aiDio = null;
    _cancelToken = null;
  }
}
