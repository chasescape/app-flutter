import 'package:get/get.dart';

abstract class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String home = '/home';
  static const String create = '/create';
  static const String result = '/result';
  static const String history = '/history';
  static const String settings = '/settings';
  static const String coinStore = '/coinStore';
  static const String agreement = '/agreement';
  static const String feedback = '/feedback';
  static const String composeDetail = '/composeDetail';
  static const String imageEditCreate = '/imageEditCreate';
  static const String imageEditResult = '/imageEditResult';

  static Future<T?>? toAgreement<T>(String title, [String? url]) {
    return Get.toNamed<T>(agreement, arguments: {'title': title, if (url != null) 'url': url});
  }

  static String getAgreementTitle() {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    return args['title'] as String? ?? 'Agreement';
  }

  static String getAgreementUrl() {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    return args['url'] as String? ?? '';
  }
}
