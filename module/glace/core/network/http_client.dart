import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  factory HttpClient() => _instance;
  HttpClient._internal();

  late String baseUrl;

  Map<String, String> _headers({bool auth = false}) {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    return h;
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
    bool auth = false,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: query?.map((k, v) => MapEntry(k, v.toString())),
    );
    final resp = await http.get(uri, headers: _headers(auth: auth));
    return _handle(resp);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
    bool auth = false,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers(auth: auth),
      body: data != null ? jsonEncode(data) : null,
    );
    return _handle(resp);
  }

  Map<String, dynamic> _handle(http.Response resp) {
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Request failed: ${resp.statusCode}');
  }
}
