import 'dart:io';

import '../models/nail_models.dart';
import '../scene_ai/nail_recommendation_ai_service.dart';
import '../scene_ai/recommendation_result_storage.dart';

class AIServiceException implements Exception {
  final String message;
  final int? statusCode;
  final bool isTimeout;
  final bool isCancelled;

  AIServiceException(
    this.message, {
    this.statusCode,
    this.isTimeout = false,
    this.isCancelled = false,
  });

  @override
  String toString() => 'AIServiceException: $message';
}

class AIService {
  static AIService? _instance;
  NailRecommendationPayloadAiService? _activeService;
  bool _isCancelled = false;

  AIService._internal();

  factory AIService() {
    _instance ??= AIService._internal();
    return _instance!;
  }

  void cancelAnalysis() {
    _isCancelled = true;
    _activeService?.dispose();
    _activeService = null;
  }

  void dispose() {
    cancelAnalysis();
  }

  Future<List<NailStyleCard>> analyzeHandPhoto({
    required String imagePath,
    String? sceneTag,
    String? preference,
  }) async {
    _isCancelled = false;

    final imageFile = File(imagePath);
    if (!await imageFile.exists()) {
      throw AIServiceException('Image file not found');
    }

    final service = NailRecommendationPayloadAiService();
    _activeService = service;

    try {
      final result = await service.analyzeImage(imageFile);
      if (_isCancelled) {
        throw AIServiceException('Request cancelled', isCancelled: true);
      }

      return _mergePromptContext(
        result.styles,
        sceneTag: sceneTag,
        preference: preference,
      );
    } on NailRecommendationPayloadAiException catch (e) {
      if (_isCancelled) {
        throw AIServiceException('Request cancelled', isCancelled: true);
      }
      throw AIServiceException(
        e.message,
        statusCode: e.statusCode,
        isTimeout: e.message.toLowerCase().contains('timed out'),
      );
    } finally {
      if (identical(_activeService, service)) {
        _activeService = null;
      }
      service.dispose();
    }
  }

  List<NailStyleCard> _mergePromptContext(
    List<NailStyleCard> styles, {
    String? sceneTag,
    String? preference,
  }) {
    return styles.map((style) {
      final tags = <String>[
        ...style.styleTags,
        if (sceneTag != null &&
            sceneTag.isNotEmpty &&
            !style.styleTags.contains(sceneTag))
          sceneTag,
        if (preference != null &&
            preference.isNotEmpty &&
            !style.styleTags.contains(preference))
          preference,
      ];

      return NailStyleCard(
        styleName: style.styleName,
        styleTags: tags.take(3).toList(),
        sceneFit: style.sceneFit,
        whyItFits: style.whyItFits,
        visualKeywords: style.visualKeywords,
      );
    }).toList();
  }

  Future<void> saveResult(RecommendationResult result) async {
    await RecommendationResultStorage.save(result);
  }

  Future<List<RecommendationResult>> getHistory() async {
    return RecommendationResultStorage.getList();
  }

  Future<void> deleteResult(String id) async {
    await RecommendationResultStorage.delete(id);
  }

  Future<void> clearHistory() async {
    await RecommendationResultStorage.clear();
  }
}
