import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// App Routes - Route Path Constants
class AppRoutes {
  AppRoutes._();

  // Authentication Routes
  static const String login = '/login';
  static const String splash = '/splash';

  // Main Routes (with Bottom Navigation)
  static const String home = '/home';
  static const String discover = '/discover';
  static const String create = '/create';
  static const String history = '/history';
  static const String profile = '/profile';

  // Feature Routes
  static const String agreement = '/agreement';
  static const String coinStore = '/coin-store';
  static const String creation = '/creation';
  static const String detail = '/detail';
  static const String feedback = '/feedback';

  // Route Names for Navigation
  static const String splashRouteName = 'splash';
  static const String loginRouteName = 'login';
  static const String homeRouteName = 'home';
  static const String agreementRouteName = 'agreement';
  static const String coinStoreRouteName = 'coinStore';
  static const String creationRouteName = 'creation';
  static const String detailRouteName = 'detail';
  static const String feedbackRouteName = 'feedback';
  static const String historyRouteName = 'history';
  static const String profileRouteName = 'profile';

  /// Navigate to Agreement Page
  static void toAgreement(BuildContext context, String title, String url) {
    // Build URL with query parameters
    final uri = Uri(
      path: agreement,
      queryParameters: {
        'title': title,
        'url': url,
      },
    );
    context.push(uri.toString());
  }
}
