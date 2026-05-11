import 'package:get/get.dart';
import '../controllers/history_controller.dart';
import '../../../services/global_service.dart';
import '../../../services/storage/history_storage_service.dart';

/// History Binding
class HistoryBinding extends Bindings {
  @override
  void dependencies() {
    final globalService = GlobalService.to;

    Get.put<HistoryStorageService>(globalService.historyService);

    Get.lazyPut(() => HistoryController());
  }
}
