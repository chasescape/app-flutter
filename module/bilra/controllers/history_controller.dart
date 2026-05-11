import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../data/models/makeup_analysis.dart';
import '../services/storage_service.dart';

class HistoryController extends GetxController {
  final RxList<MakeupAnalysis> historyItems = <MakeupAnalysis>[].obs;
  final RxBool isLoading = false.obs;
  final StorageService _storage = StorageService();

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  Future<void> loadHistory() async {
    isLoading.value = true;
    try {
      final history = await _storage.getMakeupHistory();
      historyItems.assignAll(history);
    } catch (e) {
      debugPrint('Error loading history: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addAnalysisItem(
      MakeupAnalysis analysis, String imagePath) async {
    try {
      await _storage.saveMakeupAnalysis(analysis, imagePath);
      await loadHistory();
    } catch (e) {
      debugPrint('Error saving analysis: $e');
    }
  }

  Future<void> removeHistoryItem(int index) async {
    if (index >= 0 && index < historyItems.length) {
      try {
        await _storage.deleteMakeupAnalysis(index);
        await loadHistory();
      } catch (e) {
        debugPrint('Error deleting item: $e');
      }
    }
  }

  Future<void> clearHistory() async {
    try {
      await _storage.clearMakeupHistory();
      historyItems.clear();
    } catch (e) {
      debugPrint('Error clearing history: $e');
    }
  }

  bool get hasHistory => historyItems.isNotEmpty;
}
