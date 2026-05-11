part of 'app_pages.dart';

class Routes {
  Routes._();

  static const String login = '/login';
  static const String main = '/main';
  static const String create = '/create';
  static const String detail = '/detail';
  static const String history = '/history';
  static const String coinStore = '/coin-store';
  static const String profile = '/profile';
  static const String agreement = '/agreement';
  static const String feedback = '/feedback';
  static const String upload = '/upload';
  static const String analysisHistory = '/analysis-history';

  static void toLogin() => Get.offAllNamed(login);

  static void toMain() => Get.offAllNamed(main);

  static void toCreate() => Get.toNamed(create);

  static void toDetail(StyleAnalysis analysis) => Get.toNamed(detail, arguments: analysis);

  static void toHistory() => Get.toNamed(history);

  static void toCoinStore() => Get.toNamed(coinStore);

  static void toProfile() => Get.toNamed(profile);

  static void toAgreement(String title, String url) {
    Get.toNamed(agreement, arguments: {'title': title, 'url': url});
  }

  static void toFeedback() => Get.toNamed(feedback);

  static void toUpload() => Get.toNamed(upload);

  static void toAnalysisHistory() => Get.toNamed(analysisHistory);

  static void back() => Get.back();
}

abstract class AppRoutes {
  static const String login = Routes.login;
  static const String main = Routes.main;
  static const String create = Routes.create;
  static const String detail = Routes.detail;
  static const String history = Routes.history;
  static const String coinStore = Routes.coinStore;
  static const String profile = Routes.profile;
  static const String agreement = Routes.agreement;
  static const String feedback = Routes.feedback;

  static void toAgreement(String title, String url) => Routes.toAgreement(title, url);
}
