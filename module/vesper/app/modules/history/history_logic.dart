import 'package:get/get.dart';
import 'package:vesper/vesper/app/modules/nav/nav_logic.dart';
import 'package:vesper/vesper/app/routes/app_routes.dart';

class HistoryLogic extends GetxController {
  void onStartTraining() {
    // 跳转到 nav 页面
    Get.offAllNamed(AppRoutes.nav);
    
    // 切换到 Train 标签页（索引 2）
    Future.delayed(const Duration(milliseconds: 100), () {
      final navLogic = Get.find<NavLogic>();
      navLogic.changePage(2);
    });
  }
}
