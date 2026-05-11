import 'dart:io';

import 'package:get/get.dart';
import '../data/models/saved_result_item.dart';
import '../services/storage_service.dart';
import '../routes/app_routes.dart';

class HistoryController extends GetxController {
  final StorageService _storage = StorageService.to;

  final RxList<SavedResultItem> historyItems = <SavedResultItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isEmpty = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
    _storage.historyVersionNotifier.addListener(_handleHistoryChanged);
  }

  Future<void> loadHistory() async {
    isLoading.value = true;
    try {
      final items = _storage.getSavedResults().where(_hasVisiblePreviewImage).toList();
      historyItems.value = items;
      isEmpty.value = items.isEmpty;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() async {
    await loadHistory();
  }

  @override
  void onClose() {
    _storage.historyVersionNotifier.removeListener(_handleHistoryChanged);
    super.onClose();
  }

  Future<void> deleteItem(SavedResultItem item) async {
    await Get.defaultDialog(
      title: 'Delete',
      middleText: 'Are you sure you want to remove this saved result?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      onConfirm: () async {
        if (item.type == SavedResultType.imageEdit) {
          await _storage.deleteImageEditHistoryItem(item.id);
        } else {
          await _storage.deleteHistoryItem(item.id);
        }
        await loadHistory();
        Get.back();
      },
    );
  }

  void openItem(SavedResultItem item) {
    if (item.type == SavedResultType.imageEdit &&
        item.imageEditResult != null) {
      Get.toNamed(AppRoutes.imageEditResult, arguments: item.imageEditResult);
      return;
    }

    if (item.compositionResult != null) {
      Get.toNamed(AppRoutes.result, arguments: item.compositionResult);
    }
  }

  Future<void> clearAll() async {
    await Get.defaultDialog(
      title: 'Clear All',
      middleText: 'Are you sure you want to delete all saved results?',
      textConfirm: 'Clear',
      textCancel: 'Cancel',
      onConfirm: () async {
        await _storage.clearHistory();
        await _storage.clearImageEditHistory();
        await loadHistory();
        Get.back();
      },
    );
  }

  void _handleHistoryChanged() {
    loadHistory();
  }

  bool _hasVisiblePreviewImage(SavedResultItem item) {
    final imagePath = item.imagePath.trim();
    if (imagePath.isEmpty) {
      return false;
    }
    return File(imagePath).existsSync();
  }
}
