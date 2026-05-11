import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';
import 'controllers/global_controller.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'services/auth_service.dart';
import 'services/coins_manager.dart';
import 'services/purchase_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Bano',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppPages.initialRoute,
      getPages: AppPages.routes,
      defaultTransition: Transition.fadeIn,
      transitionDuration: AppTheme.animationNormal,
    );
  }
}

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(StorageService(), permanent: true);
    Get.put(ApiService(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put(CoinsManager(), permanent: true);
    Get.put(PurchaseService(), permanent: true);
    Get.put(GlobalController(), permanent: true);
  }
}

Future<void> initApp() async {
  Get.put(StorageService(), permanent: true);
  Get.put(ApiService(), permanent: true);
  Get.put(AuthService(), permanent: true);
  Get.put(CoinsManager(), permanent: true);
  Get.put(PurchaseService(), permanent: true);
  Get.put(GlobalController(), permanent: true);
}
