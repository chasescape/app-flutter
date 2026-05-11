import 'package:get/get.dart';
import '../../models/diary_model.dart';
import '../../services/diary_storage_service.dart';

class HomeLogic extends GetxController {
  final diaries = <DiaryModel>[].obs;
  final isLoading = false.obs;

  final _storageService = DiaryStorageService();

  @override
  void onInit() {
    super.onInit();
    loadDiaries();
  }

  // 加载日记列表
  Future<void> loadDiaries() async {
    isLoading.value = true;
    try {
      final loadedDiaries = await _storageService.loadDiaries();
      diaries.value = loadedDiaries;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load diaries: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 删除日记
  Future<void> deleteDiary(String id) async {
    try {
      await _storageService.deleteDiary(id);
      diaries.removeWhere((diary) => diary.id == id);
      Get.snackbar(
        'Success',
        'Diary deleted',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete diary: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // 打开新建日记页面
  void openNewDiary() async {
    final result = await Get.toNamed('/diary_edit');
    if (result == true) {
      loadDiaries();
    }
  }

  // 打开编辑日记页面
  void openEditDiary(DiaryModel diary) async {
    final result = await Get.toNamed('/diary_edit', arguments: diary);
    if (result == true) {
      loadDiaries();
    }
  }
}

