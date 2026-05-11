import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/makeup_ai_service.dart';
import '../services/coins_manager.dart';
import '../data/models/makeup_analysis.dart';
import '../utils/image_helper.dart';
import 'history_controller.dart';

enum PostType { look, tutorial, review }

class CreatePromptData {
  const CreatePromptData({
    required this.message,
    this.actionLabel,
    this.opensCoinStore = false,
  });

  final String message;
  final String? actionLabel;
  final bool opensCoinStore;
}

class CreateController extends GetxController {
  final Rx<PostType> selectedType = PostType.look.obs;
  final RxString selectedImagePath = ''.obs;
  final RxString title = ''.obs;
  final RxString description = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<CreatePromptData> prompt = Rxn<CreatePromptData>();

  final int analysisCost = 75;

  final MakeupAiService _aiService = MakeupAiService();
  final CoinsManager _coinsManager = CoinsManager();
  MakeupAnalysis? latestAnalysis;

  @override
  void onInit() {
    super.onInit();
    _coinsManager.initialize();
  }

  void selectPostType(PostType type) {
    selectedType.value = type;
  }

  void _setError(
    String message, {
    String? actionLabel,
    bool opensCoinStore = false,
  }) {
    errorMessage.value = message;
    prompt.value = CreatePromptData(
      message: message,
      actionLabel: actionLabel,
      opensCoinStore: opensCoinStore,
    );
  }

  void clearPrompt() {
    prompt.value = null;
  }

  Future<void> pickImage() async {
    try {
      errorMessage.value = '';
      clearPrompt();
      final path = await ImageHelper.pickImageFromGallery();
      if (path != null) {
        selectedImagePath.value = path;
      }
    } on ImageAccessException catch (e) {
      _setError(e.message);
      if (e.shouldOpenSettings) {
        await openAppSettings();
      }
    } catch (e) {
      _setError('Failed to pick image: $e');
    }
  }

  Future<void> takePhoto() async {
    try {
      errorMessage.value = '';
      clearPrompt();
      final path = await ImageHelper.takePhoto();
      if (path != null) {
        selectedImagePath.value = path;
      }
    } on ImageAccessException catch (e) {
      _setError(e.message);
      if (e.shouldOpenSettings) {
        await openAppSettings();
      }
    } catch (e) {
      _setError('Failed to take photo: $e');
    }
  }

  void clearImage() {
    selectedImagePath.value = '';
    latestAnalysis = null;
  }

  bool get canPublish => selectedImagePath.value.isNotEmpty;

  Future<MakeupAnalysis?> analyzeImage() async {
    if (!canPublish) {
      _setError('Please select an image first');
      return null;
    }

    await _coinsManager.initialize();

    final hasEnoughCoins = _coinsManager.isEnough(analysisCost);
    if (!hasEnoughCoins) {
      _setError(
        'Not enough coins. Each analysis costs $analysisCost coins.',
        actionLabel: 'Go to store',
        opensCoinStore: true,
      );
      return null;
    }

    isLoading.value = true;
    errorMessage.value = '';
    clearPrompt();

    try {
      final analysis = await _aiService.analyzeImage(
        selectedImagePath.value,
        assetImgOverride: selectedImagePath.value,
      );

      latestAnalysis = analysis;

      final historyController = Get.find<HistoryController>();
      await historyController.addAnalysisItem(
          analysis, selectedImagePath.value);
      await _coinsManager.subCoins(analysisCost);

      return analysis;
    } on MakeupAnalysisException catch (e) {
      _setError(e.message);
      return null;
    } catch (e) {
      _setError('Unexpected error: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> publish() async {
    final analysis = await analyzeImage();
    if (analysis == null) {
      return false;
    }

    errorMessage.value = '';
    return true;
  }

  void clearForm() {
    selectedType.value = PostType.look;
    selectedImagePath.value = '';
    title.value = '';
    description.value = '';
    latestAnalysis = null;
    errorMessage.value = '';
    clearPrompt();
  }

  @override
  void onClose() {
    _aiService.dispose();
    super.onClose();
  }
}
