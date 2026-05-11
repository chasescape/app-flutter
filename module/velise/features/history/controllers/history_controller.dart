import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/thingtale_item.dart';
import '../../../services/storage/history_storage_service.dart';

/// History Controller
class HistoryController extends GetxController {
  final RxList<ThingTaleItem> historyItems = <ThingTaleItem>[].obs;
  final RxBool isLoading = false.obs;

  late final HistoryStorageService _historyService;

  @override
  void onInit() {
    super.onInit();
    _historyService = Get.find<HistoryStorageService>();
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      isLoading.value = true;

      await Future.delayed(const Duration(milliseconds: 300));

      historyItems.value = await _historyService.getHistory();

      print('[HistoryController] Loaded ${historyItems.length} items');
    } catch (e) {
      print('[HistoryController] Error loading history: $e');
      Get.snackbar('Error', 'Failed to load history');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteItem(String imagePath, int index) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this archive?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.secondaryDark.withOpacity(0.35),
              foregroundColor: AppColors.textOnSurface,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _historyService.deleteItem(imagePath);
        historyItems.removeAt(index);
        Get.snackbar('Success', 'Archive deleted');
      } catch (e) {
        print('[HistoryController] Error deleting item: $e');
        Get.snackbar('Error', 'Failed to delete item');
      }
    }
  }

  void onItemTap(ThingTaleItem item) {
    Get.toNamed('/detail', arguments: item);
  }

  @override
  Future<void> refresh() async {
    await loadHistory();
  }
}
