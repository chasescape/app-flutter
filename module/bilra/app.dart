import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bilra/bilra/routes/app_router.dart';
import 'package:bilra/bilra/theme/app_theme.dart';
import 'package:bilra/bilra/controllers/user_controller.dart';
import 'package:bilra/bilra/controllers/history_controller.dart';
import 'package:bilra/bilra/network/api_client.dart';
import 'package:bilra/bilra/services/purchase_service.dart';
import 'package:bilra/bilra/services/coins_manager.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Beauty Inspiration',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }

  static Future<void> init() async {
    Get.put(UserController());
    Get.put(HistoryController());
    apiClient.init();

    await PurchaseService().initialize();
    await CoinsManager().initialize();
  }
}
