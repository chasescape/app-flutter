import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'services/global_service.dart';
import 'routes/app_pages.dart';
import 'core/theme/app_theme.dart';

/// Main App Widget - Integrated with GetX Routing
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Archive',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute:
          GlobalService.to.isLoggedIn ? AppRoutes.home : AppRoutes.login,
      getPages: AppRoutes.routes,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
