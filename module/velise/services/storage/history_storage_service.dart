import 'dart:convert';
import 'package:get/get.dart';
import '../../data/models/thingtale_item.dart';
import 'storage_service.dart';

/// History Storage Keys
class HistoryStorageKeys {
  static const String historyList = 'thingtale_history_list';
  static const int maxHistoryItems = 100;
}

/// History Storage Service
/// Manages ThingTaleItem persistence
class HistoryStorageService extends GetxService {
  final StorageService _storage = StorageService.instance;

  Future<List<ThingTaleItem>> getHistory() async {
    try {
      final jsonStr = await _storage.getString(HistoryStorageKeys.historyList);
      if (jsonStr == null || jsonStr.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonStr);
      return jsonList
          .map((json) => ThingTaleItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('[HistoryStorage] Error loading history: $e');
      return [];
    }
  }

  Future<void> saveItem(ThingTaleItem item) async {
    try {
      final history = await getHistory();

      history.insert(0, item);

      if (history.length > HistoryStorageKeys.maxHistoryItems) {
        history.removeRange(
        HistoryStorageKeys.maxHistoryItems,
        history.length > HistoryStorageKeys.maxHistoryItems
            ? history.length
            : HistoryStorageKeys.maxHistoryItems,
      );
      }

      final jsonList = history.map((item) => item.toJson()).toList();
      await _storage.setString(HistoryStorageKeys.historyList, jsonEncode(jsonList));

      print('[HistoryStorage] Item saved. Total items: ${history.length}');
    } catch (e) {
      print('[HistoryStorage] Error saving item: $e');
      rethrow;
    }
  }

  Future<void> deleteItem(String imagePath) async {
    try {
      final history = await getHistory();
      history.removeWhere((item) => item.assetImg == imagePath);

      final jsonList = history.map((item) => item.toJson()).toList();
      await _storage.setString(HistoryStorageKeys.historyList, jsonEncode(jsonList));

      print('[HistoryStorage] Item deleted. Remaining items: ${history.length}');
    } catch (e) {
      print('[HistoryStorage] Error deleting item: $e');
      rethrow;
    }
  }

  Future<void> clear() async {
    await _storage.remove(HistoryStorageKeys.historyList);
    print('[HistoryStorage] History cleared');
  }

  Future<int> get itemCount async {
    final history = await getHistory();
    return history.length;
  }

  @override
  void onInit() {
    super.onInit();
    print('[HistoryStorage] Service initialized');
  }
}
