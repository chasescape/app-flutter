import 'dart:convert';
import 'package:http/http.dart' as http;
import '../env/app_env.dart';

class ApiClient {
  final http.Client client;

  ApiClient(this.client);

  Map<String, String> _getHeaders({bool needsAuth = false}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    return headers;
  }

  Exception _handleError(http.Response response) {
    switch (response.statusCode) {
      case 400:
        return Exception('Invalid request parameters');
      case 401:
        return Exception('Unauthorized, please login again');
      case 403:
        return Exception('No permission to access');
      case 404:
        return Exception('Resource not found');
      case 500:
        return Exception('Server internal error');
      default:
        return Exception('Network request failed: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
    bool needsAuth = false,
  }) async {
    final config = AppEnv();
    final response = await client.post(
      Uri.parse('${config.hostApi}$path'),
      headers: _getHeaders(needsAuth: needsAuth),
      body: data != null ? jsonEncode(data) : null,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw _handleError(response);
    }
  }
}
