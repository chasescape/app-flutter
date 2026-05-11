import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../services/coins/coins_manager.dart';
import '../../../services/ai/thingtale_ai_service.dart';
import '../../../services/storage/history_storage_service.dart';

/// Create Controller
class CreateController extends GetxController {
  final RxString imagePath = ''.obs;
  final RxBool isGenerating = false.obs;

  final CoinsManager _coinsManager = CoinsManager.instance;
  final ImagePicker _picker = ImagePicker();
  late final ThingTaleAIService _aiService;
  late final HistoryStorageService _historyService;

  static const int publishCost = 35;

  String get coinBalance => _coinsManager.balanceString;
  bool get hasImage => imagePath.isNotEmpty;
  bool get isBusy => isGenerating.value;

  String get primaryButtonLabel {
    if (!hasImage) {
      return 'Choose a Photo to Start';
    }
    return 'Generate Detail Page · $publishCost Coins';
  }

  IconData get primaryButtonIcon {
    if (!hasImage) {
      return Icons.add_photo_alternate_outlined;
    }
    return Icons.auto_awesome_rounded;
  }

  VoidCallback? get primaryButtonAction {
    if (isBusy) {
      return null;
    }
    if (!hasImage) {
      return pickImage;
    }
    return generateDetailPage;
  }

  @override
  void onInit() {
    super.onInit();
    _aiService = Get.find<ThingTaleAIService>();
    _historyService = Get.find<HistoryStorageService>();
  }

  Future<void> pickImage() async {
    try {
      final hasPermission = await _requestGalleryPermission();
      if (!hasPermission) {
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        imagePath.value = image.path;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image');
    }
  }

  Future<void> generateDetailPage() async {
    if (!hasImage) {
      Get.snackbar('Choose a photo', 'Select an image before generating.');
      return;
    }

    if (!_coinsManager.isEnough(publishCost)) {
      _showInsufficientCoinsDialog();
      return;
    }

    try {
      isGenerating.value = true;

      await Future.delayed(const Duration(milliseconds: 500));

      final item = await _aiService.analyzeImage(imagePath.value);

      final success = await _coinsManager.subCoins(publishCost);
      if (!success) {
        Get.snackbar('Error', 'Failed to deduct coins');
        return;
      }

      await _historyService.saveItem(item);
      await Get.offNamed('/detail', arguments: item);
    } catch (e) {
      debugPrint('[CreateController] Generate error: $e');
      Get.snackbar(
        'Generation Failed',
        e is ThingTaleAIException ? e.message : 'Failed to generate the page',
      );
    } finally {
      isGenerating.value = false;
    }
  }

  void _showInsufficientCoinsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Insufficient Coins'),
        content: Text(
          'You need $publishCost coins to generate this page. Current balance: $coinBalance',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed('/coin_store');
            },
            child: const Text('Get Coins'),
          ),
        ],
      ),
    );
  }

  void removeImage() {
    imagePath.value = '';
  }

  Future<bool> _requestGalleryPermission() async {
    final permission = await _galleryPermission();
    final status = await permission.status;

    if (status.isGranted || status.isLimited) {
      return true;
    }

    final result = await permission.request();

    if (result.isGranted || result.isLimited) {
      return true;
    }

    if (result.isPermanentlyDenied) {
      _showPermissionSettingsDialog();
    }

    return false;
  }

  Future<Permission> _galleryPermission() async {
    if (Platform.isIOS) {
      return Permission.photos;
    }

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt >= 33
          ? Permission.photos
          : Permission.storage;
    }

    return Permission.photos;
  }

  void _showPermissionSettingsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Photo Access Needed'),
        content: const Text(
          'Please allow photo access in Settings before choosing an image.',
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
