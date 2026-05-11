import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'services/storage_service.dart';
import 'services/coins_manager.dart';
import 'interface.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Wekoo',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.initial,
      getPages: AppRoutes.routes,
      defaultTransition: Transition.cupertino,
      transitionDuration: Duration(milliseconds: 300),
      debugShowCheckedModeBanner: false,
      onInit: () async {
        await Get.putAsync(() => StorageService().init());
        CoinsManager.instance.init();
        _checkAuthAndNavigate();
      },
    );
  }

  void _checkAuthAndNavigate() {
    if (Interface().authToken != null) {
      Future.delayed(Duration(milliseconds: 500), () {
        Get.offAllNamed(AppRoutes.main);
      });
    } else {
      Future.delayed(Duration(milliseconds: 500), () {
        Get.offAllNamed(AppRoutes.login);
      });
    }
  }
}
