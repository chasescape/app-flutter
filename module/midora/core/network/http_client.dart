import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../env/app_env.dart';
import '../theme/app_colors.dart';

/// API Response Wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.success(T data, {int? statusCode}) {
    return ApiResponse(
      success: true,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(String error, {int? statusCode}) {
    return ApiResponse(
      success: false,
      error: error,
      statusCode: statusCode,
    );
  }
}

/// HTTP Client Wrapper - Lightweight API client
class ApiClient {
  ApiClient._();

  static final ApiClient _instance = ApiClient._();
  static ApiClient get I => _instance;

  late final String _baseUrl;
  final Duration _timeout = const Duration(seconds: 30);

  /// Initialize with base URL
  void init({String? baseUrl}) {
    _baseUrl = baseUrl ?? AppEnv().hostApi;
  }

  /// GET request
  Future<ApiResponse<dynamic>> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final response = await http
          .get(uri, headers: _buildHeaders(headers))
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// POST request
  Future<ApiResponse<dynamic>> post(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final response = await http
          .post(
            uri,
            headers: _buildHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// PUT request
  Future<ApiResponse<dynamic>> put(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final response = await http
          .put(
            uri,
            headers: _buildHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// DELETE request
  Future<ApiResponse<dynamic>> delete(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final response = await http
          .delete(uri, headers: _buildHeaders(headers))
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Build URI with query parameters
  Uri _buildUri(String path, Map<String, dynamic>? queryParameters) {
    final basePath = path.startsWith('http') ? path : '$_baseUrl$path';
    if (queryParameters == null || queryParameters.isEmpty) {
      return Uri.parse(basePath);
    }

    final queryString = queryParameters.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    return Uri.parse('$basePath?$queryString');
  }

  /// Build headers with auth token
  Map<String, String> _buildHeaders(Map<String, String>? additionalHeaders) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add auth token if available
    // final authToken = Interface().authToken;
    // if (authToken != null) {
    //   headers['Authorization'] = 'Bearer $authToken';
    // }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  /// Handle HTTP response
  ApiResponse<dynamic> _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        try {
          final data = jsonDecode(response.body);
          return ApiResponse.success(data, statusCode: response.statusCode);
        } catch (e) {
          return ApiResponse.success(response.body, statusCode: response.statusCode);
        }
      case 204:
        return ApiResponse.success(null, statusCode: response.statusCode);
      case 400:
        return ApiResponse.error('Bad Request', statusCode: response.statusCode);
      case 401:
        return ApiResponse.error('Unauthorized', statusCode: response.statusCode);
      case 403:
        return ApiResponse.error('Forbidden', statusCode: response.statusCode);
      case 404:
        return ApiResponse.error('Not Found', statusCode: response.statusCode);
      case 500:
        return ApiResponse.error('Server Error', statusCode: response.statusCode);
      default:
        return ApiResponse.error(
          'Request failed with status ${response.statusCode}',
          statusCode: response.statusCode,
        );
    }
  }
}
