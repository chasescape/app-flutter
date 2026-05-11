import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import '../data/models/image_edit_result.dart';
import '../env/app_env.dart';

class ImageEditException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  ImageEditException(
    this.message, {
    this.statusCode,
    this.responseBody,
  });

  @override
  String toString() {
    final statusText =
        statusCode != null ? ' (status: $statusCode)' : '';
    final bodyText = responseBody != null && responseBody!.trim().isNotEmpty
        ? ' | response: ${responseBody!.trim()}'
        : '';
    return 'ImageEditException: $message$statusText$bodyText';
  }
}

class ImageEditService extends GetxService {
  static ImageEditService get to => Get.find();

  final String _baseUrl;
  static const int costPerImageEdit = 42;
  static const String defaultAutoPrompt =
      'Transform the uploaded photo into a noticeably improved remake. '
      'Keep the main subject recognizable while improving composition, framing, '
      'subject placement, background cleanliness, visual hierarchy, and lighting. '
      'Generate a genuinely remixed image instead of adding an overlay, border, '
      'grid, or simple filter.';
  static const String defaultInstructionContext = 'Automatic remix preset';
  static const String defaultSubtitle =
      'Generated with the built-in remix preset';
  static const String defaultWhyBetter =
      'The remake uses cleaner framing, stronger subject focus, and more polished '
      'lighting so the image feels more intentional and refined.';
  static const String defaultHowItWorks =
      'We use the built-in remix preset to regenerate the uploaded photo with '
      'better composition and a cleaner final presentation.';

  ImageEditService({String? baseUrl})
      : _baseUrl = baseUrl ?? AppEnv().imageEditApiUrl;

  Future<ImageEditResult> createImageToImageResult({
    required List<File> sourceImages,
    String? prompt,
    String? size,
    String? aspectRatio,
    String? title,
    String? subtitle,
    String? whyBetter,
    String? howItWorks,
    String? instructionContext,
    int? coinsUsed,
  }) async {
    if (sourceImages.isEmpty) {
      throw ImageEditException('At least one source image is required');
    }

    if (sourceImages.length > 6) {
      throw ImageEditException('Maximum 6 source images are supported');
    }

    final apiKey = AppEnv().geApiKey;
    if (apiKey.isEmpty) {
      throw ImageEditException('AI service API key is not configured');
    }

    final resolvedPrompt = _resolvePrompt(prompt);
    final resolvedInstructionContext =
        _resolveInstructionContext(prompt, instructionContext);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/v1/images/edits'),
      );

      request.headers['Authorization'] = 'Bearer $apiKey';

      for (int i = 0; i < sourceImages.length; i++) {
        final imageFile = sourceImages[i];
        final fileName = _fileNameFromPath(imageFile.path);
        request.files.add(await http.MultipartFile.fromPath(
            'image', imageFile.path,
            contentType: _mediaTypeForPath(imageFile.path),
            filename: fileName));
      }

      request.fields['prompt'] =
          _buildEnhancedPrompt(sourceImages, resolvedPrompt);
      request.fields['model'] = 'gemini-3.1-flash-image-preview';
      request.fields['response_format'] = 'b64_json';

      if (size != null) {
        request.fields['size'] = size;
      }
      if (aspectRatio != null) {
        request.fields['aspect_ratio'] = aspectRatio;
      }

      final response = await request.send().timeout(
        const Duration(minutes: 2),
        onTimeout: () {
          throw ImageEditException('Request timeout after 2 minutes');
        },
      );

      if (response.statusCode != 200) {
        final responseBody = await response.stream.bytesToString();
        debugPrint(
          '[ImageEditService] Request failed: '
          'url=$_baseUrl/v1/images/edits, '
          'status=${response.statusCode}, '
          'model=${request.fields['model']}, '
          'body=$responseBody',
        );
        throw ImageEditException(
          'API request failed',
          statusCode: response.statusCode,
          responseBody: responseBody,
        );
      }

      final responseBody = await response.stream.bytesToString();
      final json = jsonDecode(responseBody) as Map<String, dynamic>;

      final resultImagePath = await _saveResultImage(json);

      final now = DateTime.now();
      return ImageEditResult(
        id: now.millisecondsSinceEpoch.toString(),
        oldImagePaths: sourceImages.map((f) => f.path).toList(),
        resultImagePath: resultImagePath,
        title: title ?? 'AI Image Edit',
        subtitle: subtitle ?? defaultSubtitle,
        whyBetter: whyBetter ?? defaultWhyBetter,
        howItWorks: howItWorks ?? defaultHowItWorks,
        editInstructionContext: resolvedInstructionContext,
        createdAt: now,
        coinsUsed: coinsUsed ?? 0,
      );
    } on ImageEditException {
      rethrow;
    } catch (e) {
      throw ImageEditException(
          'Failed to create image edit result: ${e.toString()}');
    }
  }

  String _buildEnhancedPrompt(List<File> sourceImages, String userPrompt) {
    if (sourceImages.length == 1) {
      return userPrompt;
    }

    final buffer = StringBuffer();
    buffer.writeln('Image editing task with multiple source images:');
    buffer.writeln(
        '- Primary anchor image: the first image serves as the main reference');
    buffer.writeln(
        '- Supporting images: the remaining ${sourceImages.length - 1} images provide supplementary context, texture references, or compositional elements');
    buffer.writeln('');
    buffer.writeln('User instruction: $userPrompt');
    buffer.writeln('');
    buffer.writeln(
        'Please transform the primary image according to the user instruction while incorporating stylistic or contextual elements from the supporting images where appropriate. Maintain the core subject and identity of the primary image.');
    buffer.writeln('');
    buffer.writeln(
        'Additional notes for the second and third supporting images: they may serve as background layers, atmospheric overlays, decorative fragments, or auxiliary visual references.');

    return buffer.toString().trim();
  }

  String _resolvePrompt(String? prompt) {
    final trimmed = prompt?.trim() ?? '';
    return trimmed.isEmpty ? defaultAutoPrompt : trimmed;
  }

  String _resolveInstructionContext(
    String? prompt,
    String? instructionContext,
  ) {
    final explicitContext = instructionContext?.trim() ?? '';
    if (explicitContext.isNotEmpty) {
      return explicitContext;
    }

    final trimmedPrompt = prompt?.trim() ?? '';
    return trimmedPrompt.isEmpty ? defaultInstructionContext : trimmedPrompt;
  }

  Future<String> _saveResultImage(Map<String, dynamic> json) async {
    final dataList = json['data'] as List?;
    if (dataList == null || dataList.isEmpty) {
      throw ImageEditException('No image data in response');
    }

    final firstItem = dataList.first as Map<String, dynamic>;
    final b64Json = firstItem['b64_json'] as String?;
    final url = firstItem['url'] as String?;

    if (b64Json != null && b64Json.isNotEmpty) {
      return await _saveBase64Image(b64Json);
    } else if (url != null && url.isNotEmpty) {
      return await _downloadImage(url);
    } else {
      throw ImageEditException(
          'No valid image data (b64_json or url) in response');
    }
  }

  Future<String> _saveBase64Image(String b64Json) async {
    try {
      final bytes = base64Decode(b64Json);
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = _joinPath(directory.path, 'image_edit_$timestamp.png');
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      return filePath;
    } catch (e) {
      throw ImageEditException('Failed to save base64 image: ${e.toString()}');
    }
  }

  Future<String> _downloadImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl)).timeout(
            const Duration(minutes: 1),
          );
      if (response.statusCode != 200) {
        throw ImageEditException(
            'Failed to download image: status ${response.statusCode}');
      }

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath =
          _joinPath(directory.path, 'image_edit_url_$timestamp.png');
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return filePath;
    } catch (e) {
      throw ImageEditException('Failed to download image: ${e.toString()}');
    }
  }

  String _fileNameFromPath(String filePath) {
    return filePath.split(Platform.pathSeparator).last;
  }

  MediaType _mediaTypeForPath(String filePath) {
    final normalizedPath = filePath.toLowerCase();
    if (normalizedPath.endsWith('.png')) {
      return MediaType('image', 'png');
    }
    if (normalizedPath.endsWith('.webp')) {
      return MediaType('image', 'webp');
    }
    if (normalizedPath.endsWith('.gif')) {
      return MediaType('image', 'gif');
    }
    return MediaType('image', 'jpeg');
  }

  String _joinPath(String basePath, String fileName) {
    return '$basePath${Platform.pathSeparator}$fileName';
  }

  void dispose() {}
}
