// App Routes Constants
class AppRoutes {
  // Route Names
  static const String splash = '/';
  static const String login = '/login';
  static const String main = '/main';
  static const String home = '/home';
  static const String create = '/create';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String detail = '/detail';
  static const String agreement = '/agreement';
  static const String coinStore = '/coin-store';
  static const String feedback = '/feedback';

  // Route Parameters
  static const String paramId = 'id';
  static const String paramTitle = 'title';
  static const String paramUrl = 'url';
  static const String paramFromRoute = 'fromRoute';
  static const String paramTab = 'tab';

  /// Build main page URL with tab index (keeps bottom navigation visible).
  static String buildMainTabUrl(int tabIndex) {
    return '$main?$paramTab=$tabIndex';
  }

  /// Build agreement page URL with query parameters
  static String buildAgreementUrl(String title, String url) {
    return '$agreement?$paramTitle=${Uri.encodeComponent(title)}&$paramUrl=${Uri.encodeComponent(url)}';
  }
}
