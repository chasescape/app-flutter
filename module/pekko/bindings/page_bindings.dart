import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/record_controller.dart';
import '../controllers/analysis_controller.dart';
import '../controllers/collection_controller.dart';
import '../controllers/history_controller.dart';
import '../controllers/settings_controller.dart';

/// Main page binding - initializes all bottom nav page controllers
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Bottom nav page controllers
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => AnalysisController());
    Get.lazyPut(() => CollectionController());
    Get.lazyPut(() => HistoryController());
    Get.lazyPut(() => SettingsController());
  }
}

/// Record page binding (secondary page, independent route)
class RecordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RecordController());
  }
}
