import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pliro/pliro/core/theme/app_theme.dart';
import 'package:pliro/pliro/core/routes/app_routes.dart';
import 'package:pliro/pliro/core/routes/app_pages.dart';
import 'package:pliro/pliro/interface.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BeadShelf Quest',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      initialRoute: _getInitialRoute(),
      getPages: AppPages.pages,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  String _getInitialRoute() {
    if (Interface().authToken != null) {
      return AppRoutes.home;
    }
    return AppRoutes.login;
  }
}
