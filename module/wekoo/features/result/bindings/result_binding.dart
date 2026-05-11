import 'package:get/get.dart';
import '../../../controllers/main_controller.dart';
import '../../../controllers/result_controller.dart';

class ResultBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MainController>()) {
      Get.lazyPut<MainController>(() => MainController());
    }
    Get.lazyPut<ResultController>(() => ResultController());
  }
}
