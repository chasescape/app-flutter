import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tavia/tavia/env/app_env.dart';
import 'package:tavia/tavia/interface.dart';


/// HTTP Client - Eager Singleton Pattern
/// Lightweight HTTP client wrapper
class HttpClient {
  // Eager initialization
  static final HttpClient _instance = HttpClient._internal();

  late final http.Client _client;

  factory HttpClient() {
    return _instance;
  }

  HttpClient._internal() : _client = http.Client();

  http.Client get client => _client;

  /// Get base URL from environment
  String get _baseUrl => AppEnv().hostApi;

  /// Get default headers
  Map<String, String> _getHeaders({bool needsAuth = false}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (needsAuth) {
      final token = Interface().authToken;
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Handle error response
  Exception _handleError(http.Response response) {
    switch (response.statusCode) {
      case 400:
        return Exception('Request parameter error');
      case 401:
        return Exception('Unauthorized, please login again');
      case 403:
        return Exception('No permission to access');
      case 404:
        return Exception('Resource not found');
      case 500:
        return Exception('Internal server error');
      default:
        return Exception('Network request failed: ${response.statusCode}');
    }
  }

  /// GET request
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool needsAuth = false,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$path').replace(
        queryParameters: queryParameters?.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );

      final response = await _client.get(
        uri,
        headers: _getHeaders(needsAuth: needsAuth),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Request timeout', const Duration(seconds: 10));
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw _handleError(response);
      }
    } on TimeoutException {
      rethrow;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// POST request
  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
    bool needsAuth = false,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl$path'),
            headers: _getHeaders(needsAuth: needsAuth),
            body: data != null ? jsonEncode(data) : null,
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Request timeout', const Duration(seconds: 10));
            },
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw _handleError(response);
      }
    } on TimeoutException {
      rethrow;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// PUT request
  Future<Map<String, dynamic>> put(
    String path, {
    dynamic data,
    bool needsAuth = false,
  }) async {
    try {
      final response = await _client
          .put(
            Uri.parse('$_baseUrl$path'),
            headers: _getHeaders(needsAuth: needsAuth),
            body: data != null ? jsonEncode(data) : null,
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Request timeout', const Duration(seconds: 10));
            },
          );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw _handleError(response);
      }
    } on TimeoutException {
      rethrow;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// DELETE request
  Future<void> delete(String path, {bool needsAuth = false}) async {
    try {
      final response = await _client
          .delete(
            Uri.parse('$_baseUrl$path'),
            headers: _getHeaders(needsAuth: needsAuth),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Request timeout', const Duration(seconds: 10));
            },
          );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw _handleError(response);
      }
    } on TimeoutException {
      rethrow;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// PATCH request
  Future<Map<String, dynamic>> patch(
    String path, {
    dynamic data,
    bool needsAuth = false,
  }) async {
    try {
      final response = await _client
          .patch(
            Uri.parse('$_baseUrl$path'),
            headers: _getHeaders(needsAuth: needsAuth),
            body: data != null ? jsonEncode(data) : null,
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Request timeout', const Duration(seconds: 10));
            },
          );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw _handleError(response);
      }
    } on TimeoutException {
      rethrow;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Multipart file upload
  Future<String> uploadFile(
    String path, {
    required String filePath,
    required String fileName,
    Map<String, String>? fields,
    bool needsAuth = false,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl$path'),
      );

      // Add headers
      final headers = _getHeaders(needsAuth: needsAuth);
      // Remove Content-Type to let multipart set it automatically
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath('file', filePath, filename: fileName),
      );

      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      final response = await _client.send(request).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Upload timeout', const Duration(seconds: 30));
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        final data = jsonDecode(responseBody) as Map<String, dynamic>;
        return data['file_url'] as String? ?? '';
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } on TimeoutException {
      rethrow;
    } catch (e) {
      throw Exception('Upload error: $e');
    }
  }

  /// Dispose client
  void dispose() {
    _client.close();
  }
}
