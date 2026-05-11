import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../data/models/composition_result.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../services/coins_manager.dart';
import '../routes/app_routes.dart';

class CreateController extends GetxController {
  final StorageService _storage = StorageService.to;
  final ApiService _api = ApiService.to;
  final CoinsManager _coinsManager = CoinsManager.to;

  final ImagePicker _picker = ImagePicker();

  final Rx<File?> selectedImage = Rx<File?>(null);
  final Rx<ImageType> selectedType = ImageType.portrait.obs;
  final Rx<AnalysisGoal?> selectedGoal = Rx<AnalysisGoal?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isAnalyzing = false.obs;
  final RxString errorMessage = ''.obs;
  bool _handledInitialSource = false;

  ValueNotifier<int> get coinsNotifier => _coinsManager.coinsNotifier;
  ValueNotifier<int> get freeCreditsNotifier => _coinsManager.freeCreditsNotifier;
  bool get canAnalyze => _coinsManager.canAnalyze;
  int get freeCredits => _coinsManager.freeCredits;
  int get costPerAnalysis => _coinsManager.costPerAnalysis;

  void handleInitialSource(String? source) {
    if (_handledInitialSource || source == null) {
      return;
    }
    _handledInitialSource = true;

    if (source == 'camera') {
      pickImageFromCamera();
    } else if (source == 'gallery') {
      pickImageFromGallery();
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedImage.value = File(image.path);
        errorMessage.value = '';
      }
    } catch (e) {
      errorMessage.value = 'Failed to pick image';
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        selectedImage.value = File(image.path);
        errorMessage.value = '';
      }
    } catch (e) {
      errorMessage.value = 'Failed to take photo';
    }
  }

  void setImageType(ImageType type) {
    selectedType.value = type;
  }

  void setAnalysisGoal(AnalysisGoal goal) {
    selectedGoal.value = goal;
  }

  Future<bool> analyzeComposition() async {
    if (selectedImage.value == null) {
      errorMessage.value = 'Please select an image first';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (!canAnalyze) {
      Get.toNamed(AppRoutes.coinStore);
      return false;
    }

    isAnalyzing.value = true;

    try {
      final bool useFreeCredits = _coinsManager.freeCredits > 0;
      final int cost = useFreeCredits ? 1 : _coinsManager.costPerAnalysis;

      final result = await _api.analyzeComposition(
        imagePath: selectedImage.value!.path,
        imageType: selectedType.value,
        goal: selectedGoal.value,
      );

      if (useFreeCredits) {
        await _coinsManager.decrementFreeCredits();
      } else {
        final success = await _coinsManager.subCoins(cost);
        if (!success) {
          throw Exception('Failed to spend coins');
        }
      }

      await _storage.addHistory(result);

      Get.toNamed(AppRoutes.result, arguments: result);
      return true;
    } catch (e) {
      errorMessage.value = 'Analysis failed: ${e.toString()}';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isAnalyzing.value = false;
    }
  }

  void reset() {
    selectedImage.value = null;
    selectedType.value = ImageType.portrait;
    selectedGoal.value = null;
    errorMessage.value = '';
  }
}
