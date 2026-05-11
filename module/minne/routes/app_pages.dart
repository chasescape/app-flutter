import 'package:get/get.dart';
import '../features/login/login_page.dart';
import '../features/main/main_shell_page.dart';
import '../features/shop/shop_page.dart';
import '../features/detail/detail_page.dart';
import '../features/agreement/agreement_page.dart';
import '../features/feedback/feedback_page.dart';
import '../data/models/cherish_card.dart';

/// App Routes - Daily Happiness App
class AppRoutes {
  AppRoutes._();

  static const String initial = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String create = '/create';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String shop = '/shop';
  static const String detail = '/detail';
  static const String agreement = '/agreement';
  static const String feedback = '/feedback';

  static final List<GetPage> routes = [
    GetPage(
      name: initial,
      page: () => const MainShellPage(initialIndex: 0),
    ),
    GetPage(
      name: login,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: home,
      page: () => const MainShellPage(initialIndex: 0),
    ),
    GetPage(
      name: create,
      page: () => const MainShellPage(initialIndex: 1),
    ),
    GetPage(
      name: history,
      page: () => const MainShellPage(initialIndex: 2),
    ),
    GetPage(
      name: profile,
      page: () => const MainShellPage(initialIndex: 3),
    ),
    GetPage(
      name: shop,
      page: () => const ShopPage(),
    ),
    GetPage(
      name: detail,
      page: () => DetailPage(),
    ),
    GetPage(
      name: agreement,
      page: () => AgreementPage(),
    ),
    GetPage(
      name: feedback,
      page: () => const FeedbackPage(),
    ),
  ];

  // Navigation Helpers
  static void toLogin() {
    Get.offAllNamed(login);
  }

  static void toHome() {
    if (_canSwitchMainTab) {
      Get.find<MainShellController>().setIndex(0);
      return;
    }
    Get.offAllNamed(home);
  }

  static void toCreate() {
    if (_canSwitchMainTab) {
      Get.find<MainShellController>().setIndex(1);
      return;
    }
    Get.offAllNamed(create);
  }

  static void toHistory() {
    if (_canSwitchMainTab) {
      Get.find<MainShellController>().setIndex(2);
      return;
    }
    Get.offAllNamed(history);
  }

  static void toProfile() {
    if (_canSwitchMainTab) {
      Get.find<MainShellController>().setIndex(3);
      return;
    }
    Get.offAllNamed(profile);
  }

  static void toShop() {
    Get.toNamed(shop);
  }

  static Future<T?> toDetail<T>(CherishCard card, {String? imagePath}) {
    if (imagePath == null || imagePath.isEmpty) {
      return Get.toNamed<T>(detail, arguments: card) ?? Future.value(null);
    }
    return Get.toNamed<T>(detail, arguments: {'card': card, 'imagePath': imagePath}) ??
        Future.value(null);
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

  static bool get _canSwitchMainTab {
    const mainRoutes = <String>{initial, home, create, history, profile};
    return Get.isRegistered<MainShellController>() &&
        mainRoutes.contains(Get.currentRoute);
  }
}
