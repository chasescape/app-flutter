import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/hairstyle_analysis.dart';
import '../models/hairstyle_result.dart';
import '../scene_ai/hairstyle_analysis_ai_service.dart';
import '../services/storage_service.dart';
import '../services/coins_manager.dart';
import '../services/image_picker_service.dart';
import '../services/image_edit_service.dart';
import 'user_controller.dart';

class GenerateController extends GetxController {
  final ImagePickerService _imagePicker = ImagePickerService.to;
  final StorageService _storage = StorageService.to;
  final CoinsManager _coinsManager = CoinsManager.to;
  final ImageEditService _imageEditService = ImageEditService.instance;
  final UserController _userController = Get.find<UserController>();
  final HairstyleAnalysisAiService _hairstyleAnalysisAiService =
      HairstyleAnalysisAiService();

  final RxList<File> selectedImages = <File>[].obs;
  final RxBool isGenerating = false.obs;
  final Rx<HairstyleResult?> generatedResult = Rx<HairstyleResult?>(null);
  final RxInt coinsCost = 0.obs;
  final RxString errorMessage = ''.obs;
  final RxString editPrompt =
      'Transform this hairstyle according to the description.'.obs;
  static const int maxImages = 1;

  @override
  void onInit() {
    super.onInit();
    _calculateCost();
  }

  void _calculateCost() {
    // Always charge a fixed amount per generation.
    coinsCost.value = 99;
  }

  Future<void> pickImage() async {
    final image = await _imagePicker.pickFromGallery();
    if (image != null) {
      selectedImages.assignAll([image]);
      errorMessage.value = '';
    }
  }

  Future<void> takePhoto() async {
    final photo = await _imagePicker.takePhoto();
    if (photo != null) {
      selectedImages.assignAll([photo]);
      errorMessage.value = '';
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
    }
  }

  bool get canGenerate {
    final coinBalance = _coinsManager.currentBalance;
    final hasImages = selectedImages.isNotEmpty;
    return hasImages && (coinBalance >= coinsCost.value);
  }

  Future<bool> generateHairstyle() async {
    if (selectedImages.isEmpty) {
      errorMessage.value = 'Please select or take at least one photo first';
      return false;
    }

    if (!canGenerate) {
      Get.snackbar(
        'Insufficient Coins',
        'You need at least ${coinsCost.value} coins to generate',
        snackPosition: SnackPosition.BOTTOM,
        mainButton: TextButton(
          onPressed: () => Get.toNamed('/coinStore'),
          child: const Text('Get Coins'),
        ),
      );
      return false;
    }

    isGenerating.value = true;
    errorMessage.value = '';

    try {
      // Verify balance has enough coins (but DO NOT deduct yet)
      final int coinsToUse = coinsCost.value;
      if (!_coinsManager.isEnough(coinsToUse)) {
        errorMessage.value = 'Insufficient coin balance';
        isGenerating.value = false;
        return false;
      }

      // Call AI service FIRST - do NOT deduct anything yet
      final prompt = _buildPromptFromImages();
      HairstyleResult result;

      try {
        result = await _imageEditService.createImageToImageResult(
          sourceImages: selectedImages.toList(),
          prompt: prompt,
          coinsUsed: 0, // Will update after successful deduction
        );
      } catch (serviceError) {
        // Service FAILED - NO deduction of any kind
        errorMessage.value = 'Generation failed: $serviceError';
        isGenerating.value = false;
        return false;
      }

      result = await _applyAiAnalysis(result);

      // Service SUCCEEDED! Now deduct coins.
      final spent = await _coinsManager.subCoins(coinsToUse);
      if (!spent) {
        // Should not happen since we checked balance above
        errorMessage.value =
            'Failed to spend coins after successful generation';
        isGenerating.value = false;
        return false;
      }

      final finalResult = HairstyleResult(
        id: result.id,
        originalImagePath: result.originalImagePath,
        previewImagePath: result.previewImagePath,
        mainStyleName: result.mainStyleName,
        whyItFits: result.whyItFits,
        alternativeSuggestions: result.alternativeSuggestions,
        barberNote: result.barberNote,
        createdAt: result.createdAt,
        coinsUsed: coinsToUse,
        oldImagePaths: result.oldImagePaths,
        editInstructionContext: result.editInstructionContext,
      );

      await _storage.addHistoryItem(finalResult);
      _userController.refreshData();
      generatedResult.value = finalResult;
      isGenerating.value = false;
      return true;
    } catch (e) {
      errorMessage.value = 'Generation failed: $e';
      isGenerating.value = false;
      return false;
    }
  }

  String _buildPromptFromImages() {
    if (selectedImages.length == 1) {
      return editPrompt.value;
    }

    final buffer = StringBuffer(editPrompt.value);
    buffer.write('\n\nImage editing context:\n');
    buffer
        .write('- First image (primary): Main reference for transformation\n');

    if (selectedImages.length > 1) {
      buffer.write(
          '- Second image: Supporting reference for style and texture\n');
    }
    if (selectedImages.length > 2) {
      buffer.write(
          '- Third image: Additional reference for details and composition\n');
    }

    return buffer.toString();
  }

  Future<HairstyleResult> _applyAiAnalysis(HairstyleResult result) async {
    if (selectedImages.isEmpty) {
      return result;
    }

    try {
      final HairstyleAnalysis analysis =
          await _hairstyleAnalysisAiService.analyzeImage(
        selectedImages.first,
        userContext: editPrompt.value,
      );

      return result.copyWith(
        mainStyleName: analysis.mainStyleName.isNotEmpty
            ? analysis.mainStyleName
            : result.mainStyleName,
        whyItFits: analysis.whyItFits.isNotEmpty
            ? analysis.whyItFits
            : result.whyItFits,
        alternativeSuggestions: analysis.alternativeSuggestions.isNotEmpty
            ? analysis.alternativeSuggestions
            : result.alternativeSuggestions,
        barberNote: analysis.barberNote.isNotEmpty
            ? analysis.barberNote
            : result.barberNote,
      );
    } catch (e) {
      debugPrint('GenerateController: AI analysis fallback triggered: $e');
      return result;
    }
  }

  Future<bool> regenerateHairstyle(String resultId) async {
    final coinBalance = _coinsManager.currentBalance;
    if (coinBalance < coinsCost.value) {
      Get.snackbar(
        'Insufficient Coins',
        'You need at least ${coinsCost.value} coins to regenerate',
        snackPosition: SnackPosition.BOTTOM,
        mainButton: TextButton(
          onPressed: () => Get.toNamed('/coinStore'),
          child: const Text('Get Coins'),
        ),
      );
      return false;
    }

    if (selectedImages.isEmpty) {
      errorMessage.value = 'Please select images again to regenerate';
      return false;
    }

    isGenerating.value = true;

    try {
      final prompt = _buildPromptFromImages();

      // Call AI service FIRST - do NOT deduct yet
      HairstyleResult result;
      try {
        result = await _imageEditService.createImageToImageResult(
          sourceImages: selectedImages.toList(),
          prompt: prompt,
          coinsUsed: 0, // Will update after successful deduction
        );
      } catch (serviceError) {
        // Service FAILED - NO deduction
        errorMessage.value = 'Regeneration failed: $serviceError';
        isGenerating.value = false;
        return false;
      }

      result = await _applyAiAnalysis(result);

      // Service SUCCEEDED! Now deduct coins
      final spent = await _coinsManager.subCoins(coinsCost.value);
      if (!spent) {
        errorMessage.value =
            'Failed to spend coins after successful regeneration';
        isGenerating.value = false;
        return false;
      }

      final finalResult = HairstyleResult(
        id: result.id,
        originalImagePath: result.originalImagePath,
        previewImagePath: result.previewImagePath,
        mainStyleName: result.mainStyleName,
        whyItFits: result.whyItFits,
        alternativeSuggestions: result.alternativeSuggestions,
        barberNote: result.barberNote,
        createdAt: result.createdAt,
        coinsUsed: coinsCost.value,
        oldImagePaths: result.oldImagePaths,
        editInstructionContext: result.editInstructionContext,
      );

      await _storage.addHistoryItem(finalResult);
      _userController.refreshData();
      generatedResult.value = finalResult;
      isGenerating.value = false;
      return true;
    } catch (e) {
      errorMessage.value = 'Regeneration failed: $e';
      isGenerating.value = false;
      return false;
    }
  }

  void reset() {
    selectedImages.clear();
    generatedResult.value = null;
    errorMessage.value = '';
    editPrompt.value = 'Transform this hairstyle according to the description.';
    _calculateCost();
  }

  @override
  void onClose() {
    _hairstyleAnalysisAiService.dispose();
    super.onClose();
  }
}
