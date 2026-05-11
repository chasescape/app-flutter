import 'package:get/get.dart';
import '../data/models/perfume_record.dart';
import '../data/services/storage_service.dart';
import 'main_controller.dart';

/// History controller for browsing and managing records
class HistoryController extends GetxController {
  final StorageService _storage = StorageService.to;
  final MainController _mainController = Get.find<MainController>();
  late final Worker _dataSyncWorker;

  // Observables
  final RxList<PerfumeRecord> records = <PerfumeRecord>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isDeleting = false.obs;

  // Filter observables
  final Rxn<PerfumeNote> filterNote = Rxn<PerfumeNote>();
  final Rxn<UsageScene> filterScene = Rxn<UsageScene>();
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadRecords();
    _dataSyncWorker = ever<int>(
      _mainController.dataVersion,
      (_) => loadRecords(),
    );
  }

  Future<void> loadRecords() async {
    try {
      isLoading.value = true;
      records.value = await _storage.getRecords();
    } finally {
      isLoading.value = false;
    }
  }

  List<PerfumeRecord> get filteredRecords {
    List<PerfumeRecord> result = List.from(records);

    // Apply note filter
    if (filterNote.value != null) {
      result = result.where((r) => r.noteType == filterNote.value).toList();
    }

    // Apply scene filter
    if (filterScene.value != null) {
      result = result.where((r) => r.scene == filterScene.value).toList();
    }

    // Apply search
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result
          .where((r) =>
              r.perfumeName.toLowerCase().contains(query) ||
              r.brand.toLowerCase().contains(query) ||
              (r.notes?.toLowerCase().contains(query) ?? false))
          .toList();
    }

    return result;
  }

  void setNoteFilter(PerfumeNote? note) {
    filterNote.value = note;
  }

  void setSceneFilter(UsageScene? scene) {
    filterScene.value = scene;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void clearFilters() {
    filterNote.value = null;
    filterScene.value = null;
    searchQuery.value = '';
  }

  Future<void> deleteRecord(String recordId) async {
    try {
      isDeleting.value = true;
      await _storage.deleteRecord(recordId);
      records.removeWhere((record) => record.id == recordId);
      _mainController.notifyDataChanged();
      Get.snackbar(
        'Success',
        'Record deleted',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete record',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isDeleting.value = false;
    }
  }

  @override
  Future<void> refresh() async {
    await loadRecords();
  }

  List<PerfumeRecord> getRecordsByDateDescending() {
    final sorted = List<PerfumeRecord>.from(filteredRecords);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  Map<String, List<PerfumeRecord>> get groupedByDate {
    final grouped = <String, List<PerfumeRecord>>{};
    for (final record in getRecordsByDateDescending()) {
      final dateKey = record.formattedDate;
      grouped.putIfAbsent(dateKey, () => []).add(record);
    }
    return grouped;
  }

  @override
  void onClose() {
    _dataSyncWorker.dispose();
    super.onClose();
  }
}
