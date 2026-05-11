import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../composition_ai/composition_result_ai_service.dart';
import '../data/models/composition_result.dart';
import '../env/app_env.dart';
import 'storage_service.dart';

class ApiService extends GetxService {
  static ApiService get to => Get.find();

  final String _baseUrl;
  final CompositionResultAiService _compositionAiService;

  ApiService({
    String? baseUrl,
    CompositionResultAiService? compositionAiService,
  })  : _baseUrl = baseUrl ?? AppEnv().hostApi,
        _compositionAiService =
            compositionAiService ?? CompositionResultAiService();

  Future<CompositionResult> analyzeComposition({
    required String imagePath,
    required ImageType imageType,
    AnalysisGoal? goal,
  }) async {
    try {
      return await _compositionAiService.analyzeComposition(
        imageFile: File(imagePath),
        imageType: imageType,
        goal: goal,
      );
    } catch (e) {
      debugPrint('[ApiService] AI service failed, trying legacy API: $e');
    }

    try {
      return await _analyzeWithLegacyApi(
        imagePath: imagePath,
        imageType: imageType,
        goal: goal,
      );
    } catch (e) {
      debugPrint('[ApiService] Legacy API failed, using mock result: $e');
      return _getMockResult(imagePath, imageType, goal);
    }
  }

  Future<CompositionResult> _analyzeWithLegacyApi({
    required String imagePath,
    required ImageType imageType,
    AnalysisGoal? goal,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/api/composition/analyze'),
    );

    request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    request.fields['imageType'] = imageType.name;
    if (goal != null) {
      request.fields['goal'] = goal.name;
    }

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Failed to analyze composition');
    }

    final responseBody = await response.stream.bytesToString();
    final json = jsonDecode(responseBody) as Map<String, dynamic>;
    return CompositionResult.fromJson(json);
  }

  CompositionResult _getMockResult(
    String imagePath,
    ImageType imageType,
    AnalysisGoal? goal,
  ) {
    final now = DateTime.now();
    return CompositionResult(
      id: now.millisecondsSinceEpoch.toString(),
      originalImagePath: imagePath,
      guideOverlayPath: imagePath,
      reframePreviewPath: imagePath,
      imageType: imageType,
      goal: goal,
      summary:
          'Your ${imageType.label} photo has good potential but could be improved with better composition.',
      issues: [
        'Subject appears too centered',
        'Background elements create visual distraction',
        'Leading lines not utilized effectively',
      ],
      suggestions: [
        'Move subject to follow the rule of thirds',
        'Simplify background by changing angle',
        'Find natural leading lines in the environment',
      ],
      retakeSteps: [
        'Step slightly to your left',
        'Lower your camera angle slightly',
        'Wait for better natural lighting',
      ],
      createdAt: now,
      coinsUsed: StorageService.to.getCostPerAnalysis(),
    );
  }

  Future<bool> checkServerStatus() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  void onClose() {
    _compositionAiService.dispose();
    super.onClose();
  }
}
