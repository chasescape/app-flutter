import 'package:get/get.dart';

import '../home/home_logic.dart';
import '../../services/openai_image_service.dart';

class DetailsLogic extends GetxController {
  late final String generatedImagePath;
  late final String? outfitImagePath;
  late final String initialAiCopy;
  late final String outfitNotes;
  late final String preferredColors;
  late final String preferredStyle;
  late final String preferredElements;
  late final String customPrompt;

  final RxString description = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      generatedImagePath = (args['generatedImagePath'] as String?) ?? '';
      outfitImagePath = (args['outfitImagePath'] as String?)?.trim();
      initialAiCopy = (args['aiCopy'] as String?)?.trim() ?? '';
      outfitNotes = (args['outfitNotes'] as String?) ?? '';
      preferredColors = (args['preferredColors'] as String?) ?? '';
      preferredStyle = (args['preferredStyle'] as String?) ?? '';
      preferredElements = (args['preferredElements'] as String?) ?? '';
      customPrompt = (args['customPrompt'] as String?) ?? '';
    } else {
      generatedImagePath = '';
      outfitImagePath = null;
      initialAiCopy = '';
      outfitNotes = '';
      preferredColors = '';
      preferredStyle = '';
      preferredElements = '';
      customPrompt = '';
    }

    description.value = initialAiCopy;
    if (description.value.isEmpty) {
      _generateCopy();
    }
  }

  Future<void> _generateCopy() async {
    try {
      final service = OpenAIImageService();
      final copy = await service.generateNailCopy(
        outfitNotes: outfitNotes,
        preferredColors: preferredColors,
        preferredStyle: preferredStyle,
        preferredElements: preferredElements,
        customPrompt: customPrompt,
      );
      description.value = copy.description.trim();
      try {
        final homeLogic = Get.find<HomeLogic>();
        await homeLogic.updateGeneratedCopy(
          generatedImagePath,
          copy.description,
        );
      } catch (_) {
        // ignore
      }
    } catch (_) {
      description.value = '';
    }
  }
}
