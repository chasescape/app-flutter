import 'package:dio/dio.dart';
import 'api_client.dart';

/// API Service - API Endpoints
class ApiService {
  final Dio _dio = ApiClient.dio;

  // Auth Endpoints
  Future<Response> login(Map<String, dynamic> data) async {
    return await _dio.post('/auth/login', data: data);
  }

  Future<Response> logout() async {
    return await _dio.post('/auth/logout');
  }

  Future<Response> deleteAccount() async {
    return await _dio.delete('/auth/account');
  }

  // User Endpoints
  Future<Response> getUserProfile() async {
    return await _dio.get('/user/profile');
  }

  Future<Response> updateProfile(Map<String, dynamic> data) async {
    return await _dio.put('/user/profile', data: data);
  }

  // Content Endpoints
  Future<Response> getContentList({Map<String, dynamic>? queryParameters}) async {
    return await _dio.get('/content', queryParameters: queryParameters);
  }

  Future<Response> getContentDetail(String id) async {
    return await _dio.get('/content/$id');
  }

  Future<Response> createContent(Map<String, dynamic> data) async {
    return await _dio.post('/content', data: data);
  }

  Future<Response> deleteContent(String id) async {
    return await _dio.delete('/content/$id');
  }

  Future<Response> likeContent(String id) async {
    return await _dio.post('/content/$id/like');
  }

  // Coin Endpoints
  Future<Response> getCoinBalance() async {
    return await _dio.get('/coins/balance');
  }

  Future<Response> purchaseCoins(Map<String, dynamic> data) async {
    return await _dio.post('/coins/purchase', data: data);
  }

  Future<Response> spendCoins(int amount, String reason) async {
    return await _dio.post('/coins/spend', data: {
      'amount': amount,
      'reason': reason,
    });
  }

  // AI Analysis Endpoints - V-API GPT-4o Vision
  Future<Response> analyzeImageWithVision({
    required String base64Image,
    String prompt = 'Analyze this image',
    int maxTokens = 1024,
  }) async {
    return await _dio.post(
      '/v1/chat/completions',
      data: {
        'model': 'gpt-4o',
        'messages': [
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': prompt},
              {
                'type': 'image_url',
                'image_url': {'url': base64Image}
              },
            ],
          },
        ],
        'max_tokens': maxTokens,
      },
    );
  }

  // Legacy endpoint (kept for compatibility)
  Future<Response> analyzeImage(String imagePath) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imagePath),
    });
    return await _dio.post('/ai/analyze', data: formData);
  }

  // Feedback Endpoints
  Future<Response> submitFeedback(Map<String, dynamic> data) async {
    return await _dio.post('/feedback', data: data);
  }
}

/// Global API Service Instance
final apiService = ApiService();
