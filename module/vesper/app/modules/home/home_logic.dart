import 'package:get/get.dart';
import 'package:vesper/vesper/app/modules/nav/nav_logic.dart';

class HomeLogic extends GetxController {
  void onStartTraining() {
    if (Get.isRegistered<NavLogic>()) {
      Get.find<NavLogic>().changePage(2);
    }
  }

  void onViewAll() {
    if (Get.isRegistered<NavLogic>()) {
      Get.find<NavLogic>().changePage(1);
    }
  }
}
