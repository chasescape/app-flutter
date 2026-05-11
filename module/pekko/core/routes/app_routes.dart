/// App route names constants
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String main = '/main';
  static const String record = '/record';
  static const String coinStore = '/coin-store';
  static const String agreement = '/agreement';
  static const String feedback = '/feedback';
  static const String recordDetail = '/record-detail';
}

/// Route navigation helper class
class RouteHelper {
  RouteHelper._();

  /// Navigate to login page
  static String toLogin() => AppRoutes.login;

  /// Navigate to main page (with bottom nav)
  static String toMain() => AppRoutes.main;

  /// Navigate to record page
  static String toRecord() => AppRoutes.record;

  /// Navigate to coin store page
  static String toCoinStore() => AppRoutes.coinStore;

  /// Navigate to agreement page with title and URL
  static String toAgreement(String title, String url) =>
      '${AppRoutes.agreement}?title=$title&url=$url';

  /// Navigate to feedback page
  static String toFeedback() => AppRoutes.feedback;

  /// Navigate to record detail page
  static String toRecordDetail(String recordId) =>
      '${AppRoutes.recordDetail}?id=$recordId';
}
