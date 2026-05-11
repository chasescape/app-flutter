import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'interface.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'bindings/app_binding.dart';
import 'bindings/page_bindings.dart';
import 'pages/login/login_page.dart';
import 'pages/main/main_page.dart';
import 'pages/record/record_page.dart';
import 'pages/record/record_detail_page.dart';
import 'pages/coin_store/coin_store_page.dart';
import 'pages/agreement/agreement_page.dart';
import 'pages/feedback/feedback_page.dart';

/// Main app widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ScentTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialBinding: AppBinding(),
      initialRoute: _getInitialRoute(),
      getPages: [
        // Login
        GetPage(
          name: AppRoutes.login,
          page: () => const LoginPage(),
        ),

        // Main (with bottom nav - contains all primary pages)
        GetPage(
          name: AppRoutes.main,
          page: () => const MainPage(),
          binding: HomeBinding(),
        ),

        // Record (secondary page)
        GetPage(
          name: AppRoutes.record,
          page: () => const RecordPage(),
          binding: RecordBinding(),
        ),

        GetPage(
          name: AppRoutes.recordDetail,
          page: () => const RecordDetailPage(),
        ),

        // Coin Store (secondary page)
        GetPage(
          name: AppRoutes.coinStore,
          page: () => const CoinStorePage(),
        ),

        // Agreement (secondary page)
        GetPage(
          name: AppRoutes.agreement,
          page: () => const AgreementPage(),
        ),

        // Feedback (secondary page)
        GetPage(
          name: AppRoutes.feedback,
          page: () => FeedbackPage(),
        ),
      ],
    );
  }

  String _getInitialRoute() {
    // Check login status from Interface
    if (Interface().authToken != null) {
      return AppRoutes.main;
    }
    return AppRoutes.login;
  }
}
