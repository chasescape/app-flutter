import 'package:get/get.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../services/image_edit_service.dart';
import '../services/coins_manager.dart';
import '../services/purchase_service.dart';
import '../controllers/home_controller.dart';
import '../controllers/create_controller.dart';
import '../controllers/result_controller.dart';
import '../controllers/history_controller.dart';
import '../controllers/settings_controller.dart';
import '../controllers/coin_store_controller.dart';
import '../controllers/feedback_controller.dart';
import '../controllers/compose_detail_controller.dart';
import '../controllers/image_edit_create_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    _registerCoreServices();
  }

  static Future<void> ensureInitialized() async {
    if (!Get.isRegistered<StorageService>()) {
      await Get.putAsync<StorageService>(
        () => StorageService().init(),
        permanent: true,
      );
    }

    _registerCoreServices();
  }

  static void _registerCoreServices() {
    if (!Get.isRegistered<StorageService>()) {
      Get.putAsync<StorageService>(
        () => StorageService().init(),
        permanent: true,
      );
    }
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    }
    if (!Get.isRegistered<ImageEditService>()) {
      Get.lazyPut<ImageEditService>(() => ImageEditService(), fenix: true);
    }
    if (!Get.isRegistered<CoinsManager>()) {
      Get.lazyPut<CoinsManager>(() => CoinsManager(), fenix: true);
    }
    if (!Get.isRegistered<PurchaseService>()) {
      Get.lazyPut<PurchaseService>(() => PurchaseService(), fenix: true);
    }
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}

class CreateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateController>(() => CreateController());
  }
}

class ResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResultController>(() => ResultController());
  }
}

class HistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HistoryController>(() => HistoryController());
  }
}

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}

class CoinStoreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CoinStoreController>(() => CoinStoreController());
  }
}

class LoginBinding extends Bindings {
  @override
  void dependencies() {}
}

class FeedbackBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FeedbackController>(() => FeedbackController());
  }
}

class ComposeDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ComposeDetailController>(() => ComposeDetailController());
  }
}

class ImageEditCreateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImageEditCreateController>(() => ImageEditCreateController());
  }
}
