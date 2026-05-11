import 'package:get/get.dart';
import '../controllers/detail_controller.dart';
import '../../../services/global_service.dart';
import '../../../services/storage/history_storage_service.dart';

/// Detail Binding
class DetailBinding extends Bindings {
  @override
  void dependencies() {
    final globalService = GlobalService.to;

    Get.put<HistoryStorageService>(globalService.historyService);

    Get.lazyPut(() => DetailController());
  }
}
