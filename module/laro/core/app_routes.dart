import 'package:get/get.dart';
import '../features/auth/pages/login_page.dart';
import '../features/home/pages/create_preview_page.dart';
import '../features/home/pages/home_page.dart';
import '../features/home/models/lash_history_item.dart';
import '../features/result/pages/result_page.dart';
import '../features/history/pages/history_page.dart';
import '../features/profile/pages/profile_page.dart';
import '../features/coin_store/pages/coin_store_page.dart';
import '../features/agreement/pages/agreement_page.dart';
import '../features/feedback/pages/feedback_page.dart';

class AppRoutes {
  static const String initial = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String result = '/result';
  static const String createPreview = '/create-preview';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String coinStore = '/coin-store';
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
      name: home,
      page: () => const HomePage(),
    ),
    GetPage(
      name: result,
      page: () => const ResultPage(),
    ),
    GetPage(
      name: createPreview,
      page: () => const CreatePreviewPage(),
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

  static void toHome() {
    Get.offAllNamed(home);
  }

  static void toLogin() {
    Get.offAllNamed(login);
  }

  static void toResult(String imageUrl, String style,
      {Map<String, dynamic>? extraData}) {
    final args = <String, dynamic>{'imageUrl': imageUrl, 'style': style};
    if (extraData != null) {
      args.addAll(extraData);
    }
    Get.toNamed(result, arguments: args);
  }

  static void toCreatePreview() {
    Get.toNamed(createPreview);
  }

  static void toResultWithItem(LashHistoryItem item) {
    Get.toNamed(result, arguments: {
      'imageUrl': item.previewImageUrl,
      'style': item.styleName,
      'historyItem': item,
    });
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

  static void toGeneratedPreviewDetail(LashHistoryItem item) {
    toResult(item.previewImageUrl, item.styleName, extraData: {
      'historyItem': item,
    });
  }

  static void back() {
    Get.back();
  }
}
