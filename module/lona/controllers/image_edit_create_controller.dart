import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../services/storage_service.dart';
import '../services/image_edit_service.dart';
import '../services/coins_manager.dart';
import '../routes/app_routes.dart';

class ImageEditCreateController extends GetxController {
  final StorageService _storage = StorageService.to;
  final ImageEditService _imageEditService = ImageEditService.to;
  final CoinsManager _coinsManager = CoinsManager.to;
  final ImagePicker _picker = ImagePicker();

  final RxList<File> selectedImages = <File>[].obs;
  final RxString prompt = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isProcessing = false.obs;
  final RxString errorMessage = ''.obs;

  static const int costPerCreation = ImageEditService.costPerImageEdit;

  ValueNotifier<int> get coinsNotifier => _coinsManager.coinsNotifier;
  bool get isEnoughCoins => _coinsManager.isEnough(costPerCreation);

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _setSelectedImage(image);
      }
    } catch (e) {
      errorMessage.value = 'Failed to pick image';
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        _setSelectedImage(image);
      }
    } catch (e) {
      errorMessage.value = 'Failed to take photo';
    }
  }

  void _setSelectedImage(XFile image) {
    selectedImages
      ..clear()
      ..add(File(image.path));
    errorMessage.value = '';
  }

  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
    }
  }

  void setPrompt(String value) {
    prompt.value = value;
  }

  void showInsufficientCoinsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Insufficient Coins'),
        content: const Text(
          'You need $costPerCreation coins to create.\nWould you like to top up?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.coinStore);
            },
            child: const Text('Top Up'),
          ),
        ],
      ),
    );
  }

  Future<bool> createImageEdit() async {
    if (selectedImages.isEmpty) {
      errorMessage.value = 'Please select at least one image';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (!isEnoughCoins) {
      showInsufficientCoinsDialog();
      return false;
    }

    isProcessing.value = true;

    try {
      final result = await _imageEditService.createImageToImageResult(
        sourceImages: selectedImages.toList(),
        prompt: prompt.value,
        instructionContext: ImageEditService.defaultInstructionContext,
        subtitle: ImageEditService.defaultSubtitle,
        whyBetter: ImageEditService.defaultWhyBetter,
        howItWorks: ImageEditService.defaultHowItWorks,
        coinsUsed: costPerCreation,
      );

      final success = await _coinsManager.subCoins(costPerCreation);
      if (!success) {
        throw Exception('Failed to spend coins');
      }

      await _storage.addImageEditHistory(result);

      Get.toNamed(AppRoutes.imageEditResult, arguments: result);
      return true;
    } catch (e) {
      errorMessage.value = 'Creation failed: ${e.toString()}';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  void reset() {
    selectedImages.clear();
    prompt.value = '';
    errorMessage.value = '';
  }
}
