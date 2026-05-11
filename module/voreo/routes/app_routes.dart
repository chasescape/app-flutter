import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_tab_controller.dart';
import '../pages/login/login_page.dart';
import '../pages/generate/generate_page.dart';
import '../pages/result/result_page.dart';
import '../pages/history/history_page.dart';
import '../pages/settings/settings_page.dart';
import '../pages/coin_store/coin_store_page.dart';
import '../pages/agreement/agreement_page.dart';
import '../pages/feedback/feedback_page.dart';
import '../pages/detail/hairstyle_detail_page.dart';
import '../pages/main/main_shell_page.dart';
import '../interface.dart';

class AppRoutes {
  AppRoutes._();

  static const String initial = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String generate = '/generate';
  static const String result = '/result';
  static const String history = '/history';
  static const String settings = '/settings';
  static const String coinStore = '/coinStore';
  static const String agreement = '/agreement';
  static const String feedback = '/feedback';
  static const String detail = '/detail';

  static final routes = [
    GetPage(
      name: initial,
      page: () => _getInitialPage(),
    ),
    GetPage(
      name: login,
      page: () => const LoginPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: home,
      page: () => const MainShellPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: generate,
      page: () => const GeneratePage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: result,
      page: () => const ResultPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: history,
      page: () => const HistoryPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: settings,
      page: () => const SettingsPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: coinStore,
      page: () => const CoinStorePage(),
      transition: Transition.upToDown,
    ),
    GetPage(
      name: agreement,
      page: () => const AgreementPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: feedback,
      page: () => const FeedbackPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: detail,
      page: () => const HairstyleDetailPage(),
      transition: Transition.rightToLeft,
    ),
  ];

  static Widget _getInitialPage() {
    final interface = Interface();
    if (interface.authToken != null && interface.authToken!.isNotEmpty) {
      return const MainShellPage();
    }
    return const LoginPage();
  }

  static void toLogin() {
    Get.offAllNamed(login);
  }

  static void toHome() {
    _toMainTab(MainTab.home);
  }

  static void toGenerate() {
    _toMainTab(MainTab.generate);
  }

  static void toResult(String resultId) {
    Get.toNamed(result, arguments: {'resultId': resultId});
  }

  static void toHistory() {
    Get.toNamed(history);
  }

  static void toSettings() {
    _toMainTab(MainTab.profile);
  }

  static void toCoinStore() {
    Get.toNamed(coinStore);
  }

  static void toAgreement(String title, String url) {
    Get.toNamed(agreement, arguments: {'title': title, 'url': url});
  }

  static void toFeedback() {
    Get.toNamed(feedback);
  }

  static void toDetail(Object data) {
    Get.toNamed(detail, arguments: data);
  }

  static void goBack<T>([T? result]) {
    Get.back(result: result);
  }

  static MainTabController get _mainTabController {
    if (Get.isRegistered<MainTabController>()) {
      return Get.find<MainTabController>();
    }
    return Get.put(MainTabController(), permanent: true);
  }

  static void _toMainTab(MainTab tab) {
    _mainTabController.changeTab(tab);
    if (Get.currentRoute != home) {
      Get.offAllNamed(home, arguments: {'tab': tab.name});
    }
  }
}
