import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../env/app_env.dart';
import '../models/hairstyle_result.dart';

class ImageEditException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ImageEditException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => 'ImageEditException: $message (statusCode: $statusCode)';
}

class ImageEditService {
  static ImageEditService? _instance;
  static ImageEditService get instance {
    _instance ??= ImageEditService._internal();
    return _instance!;
  }

  late final Dio _dio;
  final String _baseUrl;
  final String _apiKey;

  ImageEditService._internal()
      : _baseUrl = AppEnv().aiApiBaseUrl,
        _apiKey = AppEnv().geApiKey {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('[ImageEditService] Request: ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('[ImageEditService] Response: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('[ImageEditService] Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  Future<HairstyleResult> createImageToImageResult({
    required List<File> sourceImages,
    required String prompt,
    String? size,
    String? aspectRatio,
    int coinsUsed = 0,
  }) async {
    if (sourceImages.isEmpty) {
      throw ImageEditException(message: 'At least one source image is required');
    }
    if (sourceImages.length > 6) {
      throw ImageEditException(message: 'Maximum 6 source images allowed');
    }

    try {
      final formData = FormData();

      for (int i = 0; i < sourceImages.length; i++) {
        final file = sourceImages[i];
        final fileExtension = path.extension(file.path).replaceAll('.', '');
        final fileName = 'image_$i.$fileExtension';

        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(
              file.path,
              filename: fileName,
            ),
          ),
        );
      }

      formData.fields.add(MapEntry('prompt', prompt));
      formData.fields.add(const MapEntry('model', 'gemini-3.1-flash-image-preview'));
      formData.fields.add(const MapEntry('response_format', 'b64_json'));

      if (size != null && size.isNotEmpty) {
        formData.fields.add(MapEntry('size', size));
      }

      if (aspectRatio != null && aspectRatio.isNotEmpty) {
        formData.fields.add(MapEntry('aspect_ratio', aspectRatio));
      }

      final response = await _dio.post(
        '/v1/images/edits',
        data: formData,
      );

      if (response.statusCode == 200) {
        return await _processResponse(response.data, sourceImages, prompt, coinsUsed);
      } else {
        throw ImageEditException(
          message: 'Unexpected response status',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ImageEditException(
        message: e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    } catch (e) {
      throw ImageEditException(
        message: 'Failed to generate image: $e',
        originalError: e,
      );
    }
  }

  Future<HairstyleResult> _processResponse(
    Map<String, dynamic> responseData,
    List<File> sourceImages,
    String prompt,
    int coinsUsed,
  ) async {
    try {
      final dataList = responseData['data'] as List<dynamic>;
      if (dataList.isEmpty) {
        throw ImageEditException(message: 'No image data in response');
      }

      final firstData = dataList[0] as Map<String, dynamic>;

      String? localImagePath;

      if (firstData.containsKey('b64_json')) {
        final b64Data = firstData['b64_json'] as String;
        localImagePath = await _saveBase64Image(b64Data);
      } else if (firstData.containsKey('url')) {
        final imageUrl = firstData['url'] as String;
        localImagePath = await _downloadImage(imageUrl);
      } else {
        throw ImageEditException(message: 'Unsupported response format');
      }

      final oldImagePaths = sourceImages.map((f) => f.path).toList();

      return HairstyleResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        originalImagePath: oldImagePaths.first,
        previewImagePath: localImagePath,
        mainStyleName: _extractStyleName(prompt),
        whyItFits: _generateWhyItFits(prompt),
        alternativeSuggestions: _generateSuggestions(),
        barberNote: prompt,
        createdAt: DateTime.now(),
        coinsUsed: coinsUsed,
        oldImagePaths: oldImagePaths,
        editInstructionContext: prompt,
      );
    } catch (e) {
      throw ImageEditException(
        message: 'Failed to process response: $e',
        originalError: e,
      );
    }
  }

  Future<String> _saveBase64Image(String base64String) async {
    try {
      final bytes = base64Decode(base64String);
      final tempDir = await getTemporaryDirectory();
      final fileName = 'img_edit_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      throw ImageEditException(
        message: 'Failed to save base64 image: $e',
        originalError: e,
      );
    }
  }

  Future<String> _downloadImage(String imageUrl) async {
    try {
      final response = await _dio.get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.data == null) {
        throw ImageEditException(message: 'Empty image data');
      }

      final tempDir = await getTemporaryDirectory();
      final fileName = 'img_edit_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(response.data as List<int>);
      return file.path;
    } catch (e) {
      throw ImageEditException(
        message: 'Failed to download image: $e',
        originalError: e,
      );
    }
  }

  String _extractStyleName(String prompt) {
    final lowerPrompt = prompt.toLowerCase();
    if (lowerPrompt.contains('bob')) return 'Bob Style';
    if (lowerPrompt.contains('bangs')) return 'Bangs Style';
    if (lowerPrompt.contains('layer')) return 'Layered Style';
    if (lowerPrompt.contains('pixie')) return 'Pixie Cut';
    if (lowerPrompt.contains('wave')) return 'Wavy Style';
    if (lowerPrompt.contains('curly')) return 'Curly Style';
    if (lowerPrompt.contains('straight')) return 'Straight Style';
    return 'AI Generated Style';
  }

  String _generateWhyItFits(String prompt) {
    return 'Based on your uploaded photo and the transformation request: $prompt. '
        'AI analysis suggests this style complements your features.';
  }

  List<StyleSuggestion> _generateSuggestions() {
    return [
      StyleSuggestion(
        styleName: 'Textured Layers',
        description: 'Adds dimension and movement for a casual look',
      ),
      StyleSuggestion(
        styleName: 'Side Swept Bangs',
        description: 'Frames the face while adding softness',
      ),
    ];
  }

  void dispose() {
    _dio.close();
  }
}
