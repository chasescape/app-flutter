import 'package:get/get.dart';
import 'package:mimiu/mimiu/app/models/photo_models.dart';
import 'package:mimiu/mimiu/app/ai/photo_scene/photo_scene_storage.dart';

class HomeLogic extends GetxController {
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final PhotoSceneStorage _storage = PhotoSceneStorage();

  @override
  void onInit() {
    super.onInit();
    refreshFromStorage();
  }

  Future<void> refreshFromStorage() async {
    final items = await _storage.loadAll();
    if (items.isEmpty) {
      categories.assignAll(const []);
      return;
    }

    final grouped = <String, List<dynamic>>{};
    for (final it in items) {
      (grouped[it.analysis.category.name] ??= <dynamic>[]).add(it);
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final list = grouped.entries.map((e) {
      final cover = (e.value.first as dynamic).path as String;
      return CategoryModel(
        id: e.key,
        name: _labelForId(e.key),
        photoCount: e.value.length,
        lastUpdated: now,
        coverPhoto: cover,
      );
    }).toList()
      ..sort((a, b) => b.photoCount.compareTo(a.photoCount));

    categories.assignAll(list);
  }

  String _labelForId(String id) {
    switch (id) {
      case 'food':
        return 'Food';
      case 'landscape':
        return 'Landscape';
      case 'portrait':
        return 'Portrait';
      case 'pets':
        return 'Pets';
      default:
        return 'Other';
    }
  }
}
