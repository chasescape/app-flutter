import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';
import 'interface.dart';

/// Main App Widget - Daily Happiness App
/// Integrates GetX routing with custom theme
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Daily Happiness',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: _getInitialRoute(),
      getPages: AppRoutes.routes,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  String _getInitialRoute() {
    // Check login status
    if (Interface().authToken != null) {
      Interface().lightHome = AppRoutes.home;
      return AppRoutes.home;
    } else {
      Interface().loginPage = AppRoutes.login;
      return AppRoutes.login;
    }
  }
}
