import 'package:get/get.dart';
import '../features/login/login_page.dart';
import '../features/home/home_page.dart';
import '../features/history/history_page.dart';
import '../features/settings/settings_page.dart';
import '../features/coin_shop/coin_shop_page.dart';
import '../features/agreement/agreement_page.dart';
import '../features/feedback/feedback_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String history = '/history';
  static const String settings = '/settings';
  static const String coinShop = '/coin-shop';
  static const String agreement = '/agreement';
  static const String feedback = '/feedback';

  static final routes = [
    GetPage(
      name: login,
      page: () => const LoginPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: home,
      page: () => const HomePage(),
      transition: Transition.fadeIn,
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
      name: coinShop,
      page: () => const CoinShopPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: agreement,
      page: () => const AgreementPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: feedback,
      page: () => const FeedbackPage(),
      transition: Transition.rightToLeft,
    ),
  ];

  static void toLogin() {
    Get.offAllNamed(login);
  }

  static void toHome() {
    Get.offAllNamed(home);
  }

  static void toHistory() {
    Get.toNamed(history);
  }

  static void toSettings() {
    Get.toNamed(settings);
  }

  static void toCoinShop() {
    Get.toNamed(coinShop);
  }

  static void toAgreement(String title, String url) {
    Get.toNamed(agreement, arguments: {'title': title, 'url': url});
  }

  static void toFeedback() {
    Get.toNamed(feedback);
  }

  static void back<T>([T? result]) {
    Get.back(result: result);
  }
}
