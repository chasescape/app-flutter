import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/theme/app_theme.dart';
import 'app/router/app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp.router(
      title: 'Composition Advisor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerDelegate: AppRouter.router.routerDelegate,
      routeInformationParser: AppRouter.router.routeInformationParser,
      routeInformationProvider: AppRouter.router.routeInformationProvider,
    );
  }
}
