import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class UploadLogic extends GetxController {
  final RxInt remainingQuota = 72.obs;
  final RxInt processedCount = 28.obs;

  final RxBool uploading = false.obs;
  final RxBool uploadComplete = false.obs;
  final RxInt selectedCount = 0.obs;
  final RxList<XFile> selectedPhotos = <XFile>[].obs;

  final ImagePicker _picker = ImagePicker();

  Future<void> simulatePickPhotos({int count = 24}) async {
    if (uploading.value) return;
    selectedCount.value = count;
    uploading.value = true;
    uploadComplete.value = false;
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    uploading.value = false;
    uploadComplete.value = true;
  }

  Future<bool> _ensurePhotoPermission() async {
    // iOS privacy prompt is shown by requesting permission.
    // Prefer full library access; fall back to limited/add-only if applicable.
    final status = await Permission.photos.request();
    if (status.isGranted || status.isLimited) return true;

    // Some iOS versions expose add-only.
    final addOnly = await Permission.photosAddOnly.request();
    return addOnly.isGranted;
  }

  Future<void> pickAndUploadPhotos() async {
    if (uploading.value) return;

    final allowed = await _ensurePhotoPermission();
    if (!allowed) {
      Get.snackbar(
        'Permission required',
        'Please allow photo access to pick images.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final files = await _picker.pickMultiImage(
      imageQuality: 92,
    );
    if (files.isEmpty) return;

    selectedPhotos.assignAll(files);
    selectedCount.value = files.length;

    uploading.value = true;
    uploadComplete.value = false;
    // TODO: Replace with real upload call.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    uploading.value = false;
    uploadComplete.value = true;
  }

  void dismissComplete() => uploadComplete.value = false;

  void addQuota() {
    remainingQuota.value += 100;
  }
}
