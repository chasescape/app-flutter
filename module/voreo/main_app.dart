import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'theme/app_theme.dart';
import 'routes/app_pages.dart';
import 'services/storage_service.dart';
import 'services/image_picker_service.dart';
import 'services/media_service.dart';
import 'services/purchase_service.dart';
import 'services/coins_manager.dart';
import 'services/iap_service.dart';
import 'controllers/auth_controller.dart';
import 'controllers/user_controller.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'HaloCut',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

Future<void> initServices() async {
  await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => CoinsManager().init());
  await Get.putAsync(() => PurchaseService().init());
  Get.put(ImagePickerService());
  Get.put(MediaService());
  Get.put(IapService());
}

Future<void> initControllers() async {
  Get.put(AuthController());
  Get.put(UserController());
}
