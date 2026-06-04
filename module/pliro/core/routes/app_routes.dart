import 'package:get/get.dart';

/// Application route names
class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String recordEditor = '/record-editor';
  static const String library = '/library';
  static const String badges = '/badges';
  static const String coinStore = '/coin-store';
  static const String profile = '/profile';
  static const String agreement = '/agreement';
  static const String feedback = '/feedback';
  static const String recordDetail = '/record-detail';

  /// Navigate to agreement page
  ///
  /// Parameters:
  /// - [title]: The title of the agreement (e.g., "Terms of Service", "Privacy Policy")
  /// - [url]: The URL to load (optional, will use AppEnv based on title if not provided)
  static Future<void> toAgreement(String title, [String? url]) {
    return Get.toNamed(
      agreement,
      arguments: {'title': title, if (url != null) 'url': url},
    )!;
  }

  /// Get agreement title from arguments
  static String getAgreementTitle() {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    return args['title'] as String? ?? 'Agreement';
  }

  /// Get agreement URL from arguments
  static String getAgreementUrl() {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    return args['url'] as String? ?? '';
  }
}
