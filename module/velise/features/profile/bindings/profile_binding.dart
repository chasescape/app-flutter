import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

/// Profile Binding
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileController());
  }
}
