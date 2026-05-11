import 'package:get/get.dart';
import 'package:mimiu/mimiu/app/ai/photo_scene/photo_scene_models.dart';
import 'package:mimiu/mimiu/app/ai/photo_scene/photo_scene_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryPhotosArgs {
  const CategoryPhotosArgs({
    required this.categoryId,
    required this.title,
  });

  final String categoryId;
  final String title;
}

class CategoryPhotosLogic extends GetxController {
  final PhotoSceneStorage _storage = PhotoSceneStorage();
  static const String _tipKey = 'album_multi_select_tip_v1';

  final RxString title = ''.obs;
  final RxString categoryId = ''.obs;
  final RxList<AnalyzedPhoto> photos = <AnalyzedPhoto>[].obs;
  final RxBool selectionMode = false.obs;
  final RxSet<String> selected = <String>{}.obs;
  final RxBool showMultiSelectTip = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is CategoryPhotosArgs) {
      title.value = args.title;
      categoryId.value = args.categoryId;
    }
    _loadTip();
    reload();
  }

  Future<void> _loadTip() async {
    final prefs = await SharedPreferences.getInstance();
    final dismissed = prefs.getBool(_tipKey) ?? false;
    showMultiSelectTip.value = !dismissed;
  }

  Future<void> dismissTip() async {
    showMultiSelectTip.value = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tipKey, true);
  }

  Future<void> reload() async {
    final all = await _storage.loadAll();
    if (categoryId.value.isEmpty) {
      photos.assignAll(const []);
      return;
    }
    final filtered = all
        .where((p) => p.analysis.category.name == categoryId.value)
        .toList()
      ..sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));
    photos.assignAll(filtered);
  }

  void enterSelection(String path) {
    selectionMode.value = true;
    selected.add(path);
    selected.refresh();
    if (showMultiSelectTip.value) {
      // First time usage: hide the hint after the user actually long-presses.
      dismissTip();
    }
  }

  void toggleSelect(String path) {
    if (selected.contains(path)) {
      selected.remove(path);
    } else {
      selected.add(path);
    }
    selected.refresh();
    if (selected.isEmpty) selectionMode.value = false;
  }

  void clearSelection() {
    selected.clear();
    selected.refresh();
    selectionMode.value = false;
  }

  Future<void> deleteSelected() async {
    final paths = selected.toList(growable: false);
    if (paths.isEmpty) return;
    await _storage.removePaths(paths, deleteFiles: true);
    clearSelection();
    await reload();
  }
}
