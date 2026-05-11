import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../env/app_env.dart';
import '../features/home/models/lash_history_item.dart';

class ImageEditException implements Exception {
  final String message;
  final int? statusCode;

  ImageEditException(this.message, {this.statusCode});

  @override
  String toString() => 'ImageEditException: $message${statusCode != null ? ' (status: $statusCode)' : ''}';
}

class ImageEditService {
  static const _endpoint = '/v1/images/edits';
  static const _model = 'gemini-3.1-flash-image-preview';
  static const _timeout = Duration(seconds: 60);

  late final Dio _dio;
  final String _baseUrl;

  ImageEditService({String? baseUrl}) : _baseUrl = baseUrl ?? _getDefaultBaseUrl() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: _timeout,
      receiveTimeout: _timeout,
      sendTimeout: _timeout,
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      logPrint: (obj) => print('[ImageEditService] $obj'),
    ));
  }

  static String _getDefaultBaseUrl() {
    final config = AppEnv();
    if (config.hostAiApi.isNotEmpty) {
      return config.hostAiApi;
    }
    return 'https://api.gpt.ge';
  }

  Future<LashHistoryItem> createImageToImageResult({
    required List<File> sourceImages,
    required String prompt,
    required String styleId,
    required String styleName,
    String? size,
    String? aspectRatio,
  }) async {
    if (sourceImages.isEmpty) {
      throw ImageEditException('At least one source image is required');
    }
    if (sourceImages.length > 6) {
      throw ImageEditException('Maximum 6 source images supported');
    }

    final apiKey = AppEnv().geApiKey;
    if (apiKey.isEmpty) {
      throw ImageEditException('AI API key is not configured');
    }

    try {
      final formData = FormData();

      for (int i = 0; i < sourceImages.length; i++) {
        final file = sourceImages[i];
        final fileName = 'image_$i.jpg';
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(
            file.path,
            filename: fileName,
          ),
        ));
      }

      formData.fields.add(MapEntry('prompt', prompt));
      formData.fields.add(MapEntry('model', _model));
      formData.fields.add(MapEntry('response_format', 'url'));
      formData.fields.add(MapEntry('n', '1'));

      if (size != null) {
        formData.fields.add(MapEntry('size', size));
      }
      if (aspectRatio != null) {
        formData.fields.add(MapEntry('aspect_ratio', aspectRatio));
      }

      final response = await _dio.post(
        _endpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        String? resultImageUrl;

        if (data is Map<String, dynamic>) {
          if (data.containsKey('data')) {
            final dataList = data['data'];
            if (dataList is List && dataList.isNotEmpty) {
              resultImageUrl = dataList[0]['url'] as String?;
            }
          } else if (data.containsKey('url')) {
            resultImageUrl = data['url'] as String?;
          }
        }

        if (resultImageUrl == null || resultImageUrl.isEmpty) {
          throw ImageEditException('Invalid response: missing image URL');
        }

        final localImagePath = await _downloadImage(resultImageUrl);

        return LashHistoryItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          originalImageUrl: sourceImages.first.path,
          previewImageUrl: localImagePath,
          resultImageUrl: resultImageUrl,
          styleId: styleId,
          styleName: styleName,
          createdAt: DateTime.now(),
          coinsUsed: 0,
          sourceImagePaths: sourceImages.map((f) => f.path).toList(),
          prompt: prompt,
        );
      } else {
        throw ImageEditException('Request failed', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ImageEditException('Request timeout. Please try again.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw ImageEditException('Network connection error. Please check your internet.');
      } else if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = _parseErrorMessage(e.response!.data);
        throw ImageEditException(message, statusCode: statusCode);
      } else {
        throw ImageEditException('Network error: ${e.message}');
      }
    } catch (e) {
      if (e is ImageEditException) rethrow;
      throw ImageEditException('Unexpected error: $e');
    }
  }

  String _parseErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data.containsKey('error')) {
        final error = data['error'];
        if (error is Map) {
          return error['message'] as String? ?? 'Unknown error';
        }
        return error.toString();
      }
      if (data.containsKey('message')) {
        return data['message'] as String;
      }
    }
    return 'Request failed';
  }

  Future<String> _downloadImage(String url) async {
    try {
      final dio = Dio();
      final tempDir = await getTemporaryDirectory();
      final fileName = 'lash_preview_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${tempDir.path}/$fileName';

      await dio.download(
        url,
        filePath,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      return filePath;
    } catch (e) {
      print('[ImageEditService] Failed to download image: $e');
      return url;
    }
  }

  void dispose() {
    _dio.close(force: true);
  }
}
