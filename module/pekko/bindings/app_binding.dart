import 'package:get/get.dart';
import '../controllers/main_controller.dart';

/// Global app binding for app-wide controllers.
class AppBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MainController>()) {
      Get.put(MainController(), permanent: true);
    }
  }
}
