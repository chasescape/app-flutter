import 'package:get/get.dart';
import 'package:pliro/pliro/core/storage/storage_service.dart';
import 'package:pliro/pliro/features/records/domain/models/bead_record.dart';

/// Library page controller
class LibraryController extends GetxController {
  final StorageService _storage = StorageService.instance;

  bool isLoading = true;
  List<BeadRecord> allRecords = [];
  List<BeadRecord> filteredRecords = [];
  bool showFilters = false;

  BeadTheme? filterTheme;
  BeadStatus? filterStatus;

  bool get hasFilters => filterTheme != null || filterStatus != null;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading = true;
    update();

    allRecords = await _storage.getRecords();
    _applyFilters();

    isLoading = false;
    update();
  }

  void toggleFilter() {
    showFilters = !showFilters;
    update();
  }

  void setFilterTheme(BeadTheme? theme) {
    filterTheme = theme;
    _applyFilters();
    update();
  }

  void setFilterStatus(BeadStatus? status) {
    filterStatus = status;
    _applyFilters();
    update();
  }

  void clearFilters() {
    filterTheme = null;
    filterStatus = null;
    _applyFilters();
    update();
  }

  void _applyFilters() {
    filteredRecords = allRecords.where((record) {
      if (filterTheme != null && record.theme != filterTheme) {
        return false;
      }
      if (filterStatus != null && record.status != filterStatus) {
        return false;
      }
      return true;
    }).toList();
  }

  void deleteRecord(String recordId) async {
    await _storage.deleteRecord(recordId);
    await loadData();
  }
}
