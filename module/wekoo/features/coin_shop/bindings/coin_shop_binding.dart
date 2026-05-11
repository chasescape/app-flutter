import 'package:get/get.dart';
import '../../../controllers/coin_controller.dart';

class CoinShopBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CoinController>()) {
      Get.lazyPut<CoinController>(() => CoinController());
    }
  }
}
