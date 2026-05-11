import 'package:get/get.dart';
import '../features/login/bindings/login_binding.dart';
import '../features/login/pages/login_page.dart';
import '../features/home/bindings/home_binding.dart';
import '../features/home/pages/home_page.dart';
import '../features/create/bindings/create_binding.dart';
import '../features/create/pages/create_page.dart';
import '../features/detail/bindings/detail_binding.dart';
import '../features/detail/pages/detail_page.dart';
import '../features/history/bindings/history_binding.dart';
import '../features/history/pages/history_page.dart';
import '../features/profile/bindings/profile_binding.dart';
import '../features/profile/pages/profile_page.dart';
import '../features/coin_store/bindings/coin_store_binding.dart';
import '../features/coin_store/pages/coin_store_page.dart';
import '../features/agreement/pages/agreement_page.dart';
import '../features/feedback/bindings/feedback_binding.dart';
import '../features/feedback/pages/feedback_page.dart';

/// App Routes - Navigation Management
class AppRoutes {
  AppRoutes._();

  static const String initial = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String create = '/create';
  static const String detail = '/detail';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String coinStore = '/coin_store';
  static const String agreement = '/agreement';
  static const String feedback = '/feedback';

  static final List<GetPage> routes = [
    GetPage(
      name: initial,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: create,
      page: () => const CreatePage(),
      binding: CreateBinding(),
    ),
    GetPage(
      name: detail,
      page: () => const DetailPage(),
      binding: DetailBinding(),
    ),
    GetPage(
      name: history,
      page: () => const HistoryPage(),
      binding: HistoryBinding(),
    ),
    GetPage(
      name: profile,
      page: () => const ProfilePage(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: coinStore,
      page: () => const CoinStorePage(),
      binding: CoinStoreBinding(),
    ),
    GetPage(
      name: agreement,
      page: () => const AgreementPage(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: feedback,
      page: () => const FeedbackPage(),
      binding: FeedbackBinding(),
      transition: Transition.cupertino,
    ),
  ];

  /// Get agreement title from arguments
  static String? getAgreementTitle() {
    return Get.arguments['title'] as String?;
  }

  /// Get agreement URL from arguments
  static String? getAgreementUrl() {
    return Get.arguments['url'] as String?;
  }

  /// Navigate to login page and remove all previous routes
  static void goToLogin() {
    Get.offAllNamed(login);
  }

  /// Navigate to home page and remove all previous routes
  static void goToHome() {
    Get.offAllNamed(home);
  }

  /// Navigate to agreement page
  static void toAgreement(String title, String url) {
    Get.toNamed(
      agreement,
      arguments: {'title': title, 'url': url},
    );
  }

  /// Navigate to feedback page
  static void toFeedback() {
    Get.toNamed(feedback);
  }
}
