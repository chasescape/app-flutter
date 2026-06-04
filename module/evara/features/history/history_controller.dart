import 'dart:convert';
import 'package:signals/signals_flutter.dart';
import 'package:get/get.dart';
import '../../core/singletons/ai_service.dart';
import '../../core/singletons/storage_service.dart';

/// History Page Controller - Signals State Management
class HistoryController extends GetxController {
  final StorageService _storage = StorageService.instance;

  // Signals
  final records = signal<List<MakeupRecord>>([]);
  final filteredRecords = signal<List<MakeupRecord>>([]);
  final isLoading = signal<bool>(true);
  final selectedOccasion = signal<String?>('all');
  final selectedStyle = signal<String?>('all');
  final searchQuery = signal<String>('');

  @override
  void onInit() {
    super.onInit();
    loadRecords();
  }

  Future<void> loadRecords() async {
    isLoading.value = true;

    try {
      final recordsJson = await _storage.loadString(StorageKeys.makeupRecords);
      if (recordsJson != null) {
        final List<dynamic> decoded = jsonDecode(recordsJson);
        final recordList = decoded
            .map((json) => MakeupRecord.fromJson(json as Map<String, dynamic>))
            .toList()
            .reversed
            .toList();
        records.value = recordList;
        filteredRecords.value = recordList;
      } else {
        records.value = [];
        filteredRecords.value = [];
      }
    } catch (e) {
      records.value = [];
      filteredRecords.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  void filterRecords() {
    var filtered = records.value;

    // Filter by occasion
    if (selectedOccasion.value != null && selectedOccasion.value != 'all') {
      filtered = filtered.where((record) {
        return record.analysis.occasionTags.any((tag) =>
          tag.toLowerCase().contains(selectedOccasion.value!.toLowerCase()));
      }).toList();
    }

    // Filter by style
    if (selectedStyle.value != null && selectedStyle.value != 'all') {
      filtered = filtered.where((record) {
        return record.analysis.styleTags.any((tag) =>
          tag.toLowerCase().contains(selectedStyle.value!.toLowerCase()));
      }).toList();
    }

    // Filter by search
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((record) {
        return record.analysis.styleTags.any((tag) =>
          tag.toLowerCase().contains(query)) ||
        record.analysis.occasionTags.any((tag) =>
          tag.toLowerCase().contains(query));
      }).toList();
    }

    filteredRecords.value = filtered;
  }

  void setOccasionFilter(String? occasion) {
    selectedOccasion.value = occasion;
    filterRecords();
  }

  void setStyleFilter(String? style) {
    selectedStyle.value = style;
    filterRecords();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    filterRecords();
  }

  Future<void> deleteRecord(String id) async {
    Get.defaultDialog(
      title: 'Delete Record',
      middleText: 'Are you sure you want to delete this record?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Get.theme.colorScheme.onError,
      buttonColor: Get.theme.colorScheme.error,
      onConfirm: () async {
        Get.back();
        final updated = records.value.where((r) => r.id != id).toList();
        records.value = updated;

        final recordsJson = jsonEncode(updated.map((r) => r.toJson()).toList());
        await _storage.saveString(StorageKeys.makeupRecords, recordsJson);

        filterRecords();
        Get.snackbar(
          'Success',
          'Record deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  Future<void> clearAll() async {
    Get.defaultDialog(
      title: 'Clear All Records',
      middleText: 'Are you sure you want to delete all records? This cannot be undone.',
      textConfirm: 'Clear All',
      textCancel: 'Cancel',
      confirmTextColor: Get.theme.colorScheme.onError,
      buttonColor: Get.theme.colorScheme.error,
      onConfirm: () async {
        Get.back();
        await _storage.remove(StorageKeys.makeupRecords);
        records.value = [];
        filteredRecords.value = [];
        Get.snackbar(
          'Success',
          'All records cleared',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  List<String> getAvailableOccasions() {
    final occasions = <String>{};
    for (final record in records.value) {
      for (final tag in record.analysis.occasionTags) {
        occasions.add(tag);
      }
    }
    return occasions.toList()..sort();
  }

  List<String> getAvailableStyles() {
    final styles = <String>{};
    for (final record in records.value) {
      for (final tag in record.analysis.styleTags) {
        styles.add(tag);
      }
    }
    return styles.toList()..sort();
  }
}
