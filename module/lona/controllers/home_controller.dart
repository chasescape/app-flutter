import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../data/models/saved_result_item.dart';
import '../services/storage_service.dart';
import '../services/coins_manager.dart';
import '../routes/app_routes.dart';

class HomeController extends GetxController {
  final StorageService _storage = StorageService.to;
  final CoinsManager _coinsManager = CoinsManager.to;

  final RxList<SavedResultItem> recentResults = <SavedResultItem>[].obs;
  final RxBool isLoading = false.obs;

  ValueNotifier<int> get coinsNotifier => _coinsManager.coinsNotifier;
  ValueNotifier<int> get freeCreditsNotifier =>
      _coinsManager.freeCreditsNotifier;
  bool get canAnalyze => _coinsManager.canAnalyze;
  int get coins => _coinsManager.coins;
  int get freeCredits => _coinsManager.freeCredits;

  @override
  void onInit() {
    super.onInit();
    loadRecentAnalyses();
    _storage.historyVersionNotifier.addListener(_handleHistoryChanged);
  }

  void loadRecentAnalyses() {
    final savedResults = _storage.getSavedResults();
    recentResults.value = savedResults
        .where(_hasVisiblePreviewImage)
        .take(4)
        .toList();
  }

  @override
  void onClose() {
    _storage.historyVersionNotifier.removeListener(_handleHistoryChanged);
    super.onClose();
  }

  @override
  void refresh() {
    _coinsManager.refresh();
    loadRecentAnalyses();
  }

  void _handleHistoryChanged() {
    loadRecentAnalyses();
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

  bool _hasVisiblePreviewImage(SavedResultItem item) {
    final imagePath = item.imagePath.trim();
    if (imagePath.isEmpty) {
      return false;
    }
    return File(imagePath).existsSync();
  }
}
