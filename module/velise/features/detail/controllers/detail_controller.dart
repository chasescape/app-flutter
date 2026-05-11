import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/thingtale_item.dart';
import '../../../services/storage/history_storage_service.dart';

/// Detail Controller
class DetailController extends GetxController {
  final Rx<ThingTaleItem?> itemData = Rx<ThingTaleItem?>(null);

  late final HistoryStorageService _historyService;

  @override
  void onInit() {
    super.onInit();
    _historyService = Get.find<HistoryStorageService>();

    if (Get.arguments != null) {
      if (Get.arguments is ThingTaleItem) {
        itemData.value = Get.arguments as ThingTaleItem;
      } else if (Get.arguments is Map<String, dynamic>) {
        try {
          itemData.value =
              ThingTaleItem.fromJson(Get.arguments as Map<String, dynamic>);
        } catch (e) {
          debugPrint('[DetailController] Error parsing arguments: $e');
        }
      }
    }
  }

  Future<void> onShare() async {
    final item = itemData.value;
    if (item == null) {
      return;
    }

    final shareText = [
      item.primaryItem.nameHint,
      item.description.storyFeeling,
      'Shared from Velise',
    ].join('\n\n');

    try {
      await Share.share(
        shareText,
        subject: item.primaryItem.nameHint,
      );
    } catch (e) {
      debugPrint('[DetailController] Error sharing item: $e');
      Get.snackbar('Error', 'Failed to open share panel');
    }
  }

  Future<void> deleteItem() async {
    if (itemData.value == null) return;

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this archive?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.secondaryDark.withValues(alpha: 0.35),
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
        await _historyService.deleteItem(itemData.value!.assetImg);
        Get.back(result: 'deleted');
        Get.snackbar('Success', 'Archive deleted');
      } catch (e) {
        debugPrint('[DetailController] Error deleting item: $e');
        Get.snackbar('Error', 'Failed to delete item');
      }
    }
  }
}
