import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../features/main/bindings/main_binding.dart';
import '../features/main/views/main_page.dart';
import '../features/auth/bindings/auth_binding.dart';
import '../features/auth/views/login_page.dart';
import '../features/stats/bindings/stats_binding.dart';
import '../features/stats/views/stats_page.dart';
import '../features/history/bindings/history_binding.dart';
import '../features/history/views/history_page.dart';
import '../features/result/bindings/result_binding.dart';
import '../features/result/views/result_page.dart';
import '../features/settings/bindings/settings_binding.dart';
import '../features/settings/views/settings_page.dart';
import '../features/coin_shop/bindings/coin_shop_binding.dart';
import '../features/coin_shop/views/coin_shop_page.dart';
import '../features/profile/bindings/profile_binding.dart';
import '../features/profile/views/profile_page.dart';
import '../features/agreement/views/agreement_page.dart';
import '../features/feedback/bindings/feedback_binding.dart';
import '../features/feedback/views/feedback_page.dart';

class AppRoutes {
  static const String initial = '/';
  static const String main = '/main';
  static const String login = '/login';
  static const String stats = '/stats';
  static const String history = '/history';
  static const String result = '/result';
  static const String settings = '/settings';
  static const String coinShop = '/coin-shop';
  static const String profile = '/profile';
  static const String agreement = '/agreement';
  static const String feedback = '/feedback';

  static final routes = [
    GetPage(
      name: initial,
      page: () => const SplashPage(),
    ),
    GetPage(
      name: login,
      page: () => const LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: main,
      page: () => const MainPage(),
      binding: MainBinding(),
    ),
    GetPage(
      name: stats,
      page: () => const StatsPage(),
      binding: StatsBinding(),
    ),
    GetPage(
      name: history,
      page: () => const HistoryPage(),
      binding: HistoryBinding(),
    ),
    GetPage(
      name: result,
      page: () => const ResultPage(),
      binding: ResultBinding(),
    ),
    GetPage(
      name: settings,
      page: () => const SettingsPage(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: coinShop,
      page: () => const CoinShopPage(),
      binding: CoinShopBinding(),
    ),
    GetPage(
      name: profile,
      page: () => const ProfilePage(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: agreement,
      page: () => AgreementPage(
        title: Get.parameters['title'] ?? '',
        url: Get.parameters['url'] ?? '',
      ),
    ),
    GetPage(
      name: feedback,
      page: () => const FeedbackPage(),
      binding: FeedbackBinding(),
    ),
  ];

  static void toMain() {
    Get.offAllNamed(main);
  }

  static void toLogin() {
    Get.offAllNamed(login);
  }

  static void toStats() {
    Get.toNamed(stats);
  }

  static void toHistory() {
    Get.toNamed(history);
  }

  static void toResult() {
    Get.toNamed(result);
  }

  static void toSettings() {
    Get.toNamed(settings);
  }

  static void toCoinShop() {
    Get.toNamed(coinShop);
  }

  static void toProfile() {
    Get.toNamed(profile);
  }

  static void toAgreement(String title, String url) {
    Get.toNamed(
      agreement,
      parameters: {'title': title, 'url': url},
    );
  }

  static void toFeedback() {
    Get.toNamed(feedback);
  }
}

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
