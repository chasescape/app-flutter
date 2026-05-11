import 'package:get/get.dart';
import '../../features/login/login_page.dart';
import '../../features/main/main_page.dart';
import '../../features/result/result_page.dart';
import '../../features/history/history_page.dart';
import '../../features/profile/profile_page.dart';
import '../../features/coin_store/coin_store_page.dart';
import '../../features/agreement/agreement_page.dart';
import '../../features/profile/feedback_page.dart';

class AppRoutes {
  static const String initial = '/';
  static const String login = '/login';
  static const String main = '/main';
  static const String result = '/result';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String coinStore = '/coinStore';
  static const String agreement = '/agreement';
  static const String feedback = '/feedback';

  static final routes = [
    GetPage(
      name: initial,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: login,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: main,
      page: () => const MainPage(),
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
      name: profile,
      page: () => const ProfilePage(),
    ),
    GetPage(
      name: coinStore,
      page: () => const CoinStorePage(),
    ),
    GetPage(
      name: agreement,
      page: () => const AgreementPage(),
    ),
    GetPage(
      name: feedback,
      page: () => const FeedbackPage(),
    ),
  ];

  static void toLogin() {
    Get.offAll(() => const LoginPage(), routeName: login);
  }

  static void toMain() {
    Get.offAllNamed(main);
  }

  static void toResult(Map<String, dynamic> arguments) {
    Get.toNamed(result, arguments: arguments);
  }

  static void toHistory() {
    Get.toNamed(history);
  }

  static void toProfile() {
    Get.toNamed(profile);
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

  static void back<T>([T? result]) {
    Get.back(result: result);
  }
}
