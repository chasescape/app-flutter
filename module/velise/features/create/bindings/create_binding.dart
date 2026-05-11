import 'package:get/get.dart';
import '../controllers/create_controller.dart';
import '../../../services/global_service.dart';
import '../../../services/ai/thingtale_ai_service.dart';
import '../../../services/storage/history_storage_service.dart';

/// Create Binding
class CreateBinding extends Bindings {
  @override
  void dependencies() {
    final globalService = GlobalService.to;

    Get.put<ThingTaleAIService>(globalService.aiService);
    Get.put<HistoryStorageService>(globalService.historyService);

    Get.lazyPut(() => CreateController());
  }
}
