import 'package:get/get.dart';
import '../../services/generated_photo_service.dart';

class HistoryLogic extends GetxController {
  final historyPhotos = <Map<String, dynamic>>[].obs;
  late final GeneratedPhotoService _photoService;
  
  // ✅ 性能优化：保存监听器引用，用于正确释放
  Worker? _photosWorker;

  @override
  void onInit() {
    super.onInit();
    // ✅ 性能优化：使用 Get.find 替代 Get.put，避免重复创建服务实例
    _photoService = Get.find<GeneratedPhotoService>();
    _loadHistory();
    
    // ✅ 性能优化：监听生成照片的变化，自动刷新（保存引用以便释放）
    _photosWorker = ever(_photoService.generatedPhotos, (_) => _loadHistory());
  }

  @override
  void onClose() {
    // ✅ 性能优化：正确释放监听器，避免内存泄漏
    _photosWorker?.dispose();
    super.onClose();
  }

  void _loadHistory() {
    // ✅ 性能优化：避免不必要的列表创建，只在数据真正变化时更新
    final newPhotos = _photoService.generatedPhotos.toList();
    // 使用深度比较或长度比较，避免不必要的更新
    if (historyPhotos.length != newPhotos.length) {
      historyPhotos.value = newPhotos;
    } else {
      // 简单比较：如果长度相同，检查第一个和最后一个 ID
      if (newPhotos.isNotEmpty &&
          (historyPhotos.isEmpty ||
              historyPhotos.first['id'] != newPhotos.first['id'] ||
              historyPhotos.last['id'] != newPhotos.last['id'])) {
        historyPhotos.value = newPhotos;
      }
    }
  }

  void refreshHistory() {
    _loadHistory();
  }
  
  void deletePhoto(String id) async {
    await _photoService.deleteGeneratedPhoto(id);
    _loadHistory();
  }
  
  void clearAllHistory() async {
    await _photoService.clearAll();
    _loadHistory();
  }
}
