import 'package:get/get.dart';
import '../controllers/login_controller.dart';

/// Login Binding
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController());
  }
}
