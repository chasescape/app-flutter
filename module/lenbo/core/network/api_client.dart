import 'package:get/get.dart';
import 'package:lenbo/lenbo/env/app_env.dart';

class ApiClient extends GetConnect {
  ApiClient() {
    baseUrl = AppEnv().hostApi;
    timeout = const Duration(seconds: 30);
    httpClient.defaultDecoder = (body) => body;
  }

  Future<Response<T>> getWithAuth<T>(String path) {
    return get<T>(path, headers: _authHeaders());
  }

  Future<Response<T>> postWithAuth<T>(String path, dynamic body) {
    return post<T>(path, body, headers: _authHeaders());
  }

  Map<String, String> _authHeaders() {
    return {
      'Content-Type': 'application/json',
    };
  }
}
