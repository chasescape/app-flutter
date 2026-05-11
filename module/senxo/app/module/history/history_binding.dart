import 'package:get/get.dart';

import 'history_logic.dart';

class HistoryBinding extends Bindings {
  @override
  void dependencies() {
    // 使用永久实例，防止被自动删除
    if (!Get.isRegistered<HistoryLogic>()) {
      Get.put(HistoryLogic(), permanent: true);
    }
  }
}