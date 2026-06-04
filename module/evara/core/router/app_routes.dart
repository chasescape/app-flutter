import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../pages/login/login_page.dart';
import '../../pages/home/home_page.dart';
import '../../pages/create/create_page.dart';
import '../../pages/result/result_page.dart';
import '../../pages/history/history_page.dart';
import '../../pages/settings/settings_page.dart';
import '../../pages/agreement/agreement_page.dart';
import '../../pages/coin_store/coin_store_page.dart';
import '../../pages/feedback/feedback_page.dart';
import '../../pages/tool/tool_page.dart';

/// App Routes Configuration
class AppRoutes {
  // Route names
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String create = '/create';
  static const String result = '/result';
  static const String history = '/history';
  static const String settings = '/settings';
  static const String agreement = '/agreement';
  static const String coinStore = '/coinStore';
  static const String feedback = '/feedback';
  static const String bgRemoval = '/tools/bgRemoval';
  static const String textSummary = '/tools/textSummary';

  // Route pages
  static final routes = [
    GetPage(
      name: splash,
      page: () => const _SplashPlaceholder(),
    ),
    GetPage(
      name: login,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: home,
      page: () => const HomePage(),
    ),
    GetPage(
      name: create,
      page: () => const CreatePage(),
    ),
    GetPage(
      name: result,
      page: () => const ResultPage(),
    ),
    GetPage(
      name: history,
      page: () => const HistoryPage(),
    ),
    GetPage(
      name: settings,
      page: () => const SettingsPage(),
    ),
    GetPage(
      name: agreement,
      page: () => const AgreementPage(),
    ),
    GetPage(
      name: coinStore,
      page: () => const CoinStorePage(),
    ),
    GetPage(
      name: feedback,
      page: () => const FeedbackPage(),
    ),
    GetPage(
      name: bgRemoval,
      page: () => const ImageBackgroundRemovalPage(),
    ),
    GetPage(
      name: textSummary,
      page: () => const TextSummaryPage(),
    ),
  ];

  // Navigation helpers
  static void toLogin() {
    Get.offAllNamed(login);
  }

  static void toHome() {
    Get.offAllNamed(home);
  }

  static Future<T?> toCreate<T>() {
    return Get.toNamed<T>(create) ?? Future.value();
  }

  static Future<T?> toResult<T>(dynamic arguments) {
    return Get.toNamed<T>(result, arguments: arguments) ?? Future.value();
  }

  static Future<T?> toHistory<T>() {
    return Get.toNamed<T>(history) ?? Future.value();
  }

  static Future<T?> toSettings<T>() {
    return Get.toNamed<T>(settings) ?? Future.value();
  }

  static Future<T?> toAgreement<T>(String title, String url) {
    return Get.toNamed<T>(
      agreement,
      arguments: {'title': title, 'url': url},
    ) ?? Future.value();
  }

  static Future<T?> toCoinStore<T>() {
    return Get.toNamed<T>(coinStore) ?? Future.value();
  }

  static Future<T?> toFeedback<T>() {
    return Get.toNamed<T>(feedback) ?? Future.value();
  }

  static Future<T?> toBgRemoval<T>() {
    return Get.toNamed<T>(bgRemoval) ?? Future.value();
  }

  static Future<T?> toTextSummary<T>() {
    return Get.toNamed<T>(textSummary) ?? Future.value();
  }

  static void back<T>([T? result]) {
    Get.back(result: result);
  }
}

// Placeholder widgets
class _SplashPlaceholder extends StatelessWidget {
  const _SplashPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
