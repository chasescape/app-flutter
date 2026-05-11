import 'package:get/get.dart';

import 'nav_logic.dart';
import '../home/home_logic.dart';
import '../Listings/listings_logic.dart';
import '../history/history_logic.dart';
import '../../services/generated_photo_service.dart';

class NavBinding extends Bindings {
  @override
  void dependencies() {
    // ✅ 性能优化：先注册全局服务，确保其他 Controller 可以找到
    Get.lazyPut(() => GeneratedPhotoService(), fenix: true);
    Get.lazyPut(() => NavLogic());
    Get.lazyPut(() => HomeLogic()); // 使用 lazyPut，因为 HomePage 在 NavLogic.onInit 中会被立即使用
    Get.lazyPut(() => ListingsLogic()); // ✅ 性能优化：注册 ListingsLogic，因为 ListingsPage 在 NavLogic 中被直接创建
    Get.lazyPut(() => HistoryLogic()); // ✅ 性能优化：注册 HistoryLogic，因为 HistoryPage 在 NavLogic 中被直接创建
  }
}