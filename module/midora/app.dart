import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/app_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'features/auth/login_page.dart';
import 'features/home/main_page.dart';
import 'features/agreement/agreement_page.dart';
import 'features/feedback/feedback_page.dart';
import 'features/store/store_page.dart';
import 'features/history/history_page.dart';

/// Main App Widget
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Get.put(AppController());
  }

  Widget _getDefaultPageChild() {
    // Always start on the login page.
    // Navigation to MainPage should happen only after an explicit login flow.
    return const LoginPage();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Midora',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      // Use simple routing for now
      home: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: _getDefaultPageChild(),
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(
              builder: (_) => const LoginPage(),
              settings: settings,
            );
          case '/main':
            return MaterialPageRoute(
              builder: (_) => const MainPage(),
              settings: settings,
            );
          case '/agreement':
            return MaterialPageRoute(
              builder: (_) => const AgreementPage(),
              settings: settings,
            );
          case '/feedback':
            return MaterialPageRoute(
              builder: (_) => const FeedbackPage(),
              settings: settings,
            );
          case '/store':
            return MaterialPageRoute(
              builder: (_) => const StorePage(),
              settings: settings,
            );
          case '/history':
            return MaterialPageRoute(
              builder: (_) => const HistoryPage(),
              settings: settings,
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const LoginPage(),
              settings: settings,
            );
        }
      },
    );
  }
}
