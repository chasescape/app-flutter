import 'package:flutter/material.dart';

/// Route path constants definition
abstract class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Auth routes
  static const String login = '/login';
  static const String splash = '/splash';

  // Main routes
  static const String main = '/main';
  static const String home = '/home';
  static const String create = '/create';
  static const String profile = '/profile';

  // Feature routes
  static const String detail = '/detail';
  static const String history = '/history';
  static const String store = '/store';
  static const String feedback = '/feedback';
  static const String agreement = '/agreement';

  /// Navigate to agreement page
  /// [context] BuildContext
  /// [title] Agreement title ('Terms of Service' or 'Privacy Policy')
  /// [url] Agreement URL (optional, falls back to AppEnv URLs)
  static Future<T?> toAgreement<T>(BuildContext context, String title, [String? url]) {
    return Navigator.of(context).pushNamed<T>(
      agreement,
      arguments: {'title': title, if (url != null) 'url': url},
    );
  }

  /// Get agreement title from route arguments
  static String? getAgreementTitle(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return args?['title']?.toString();
  }

  /// Get agreement URL from route arguments
  static String? getAgreementUrl(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return args?['url']?.toString();
  }

  /// Navigate back
  static void back<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop(result);
  }
}
