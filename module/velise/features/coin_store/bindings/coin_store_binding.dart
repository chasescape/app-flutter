import 'package:get/get.dart';
import '../controllers/coin_store_controller.dart';

/// Coin Store Binding
class CoinStoreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CoinStoreController());
  }
}
