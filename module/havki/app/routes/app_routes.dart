import 'package:flutter/material.dart';
import 'package:havki/havki/features/auth/login_page.dart';
import 'package:havki/havki/features/home/home_page.dart';
import 'package:havki/havki/features/create/create_page.dart';
import 'package:havki/havki/features/detail/detail_page.dart';
import 'package:havki/havki/features/history/history_page.dart';
import 'package:havki/havki/features/store/coin_store_page.dart';
import 'package:havki/havki/features/profile/profile_page.dart';
import 'package:havki/havki/features/common/agreement_page.dart';
import 'package:havki/havki/features/common/feedback_page.dart';
import 'package:havki/havki/data/models/quote/quote_card_data.dart';

/// Route names constant class
class RoutePaths {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String create = '/create';
  static const String detail = '/detail';
  static const String history = '/history';
  static const String store = '/store';
  static const String profile = '/profile';
  static const String agreement = '/agreement';
  static const String feedback = '/feedback';
}

/// Global navigator manager
class AppNavigator {
  AppNavigator._();

  static final AppNavigator _instance = AppNavigator._();
  static AppNavigator get I => _instance;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Push a new page
  Future<T?> push<T>(Route<T> route) {
    return navigatorKey.currentState!.push(route);
  }

  // Push a named route
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
  }

  // Pop current page
  void pop<T>([T? result]) {
    return navigatorKey.currentState!.pop(result);
  }

  // Replace current page
  Future<T?> pushReplacement<T>(Route<T> route) {
    return navigatorKey.currentState!.pushReplacement(route);
  }

  // Clear stack and push new page
  Future<T?> pushAndRemoveUntil<T>(Route<T> route, RoutePredicate predicate) {
    return navigatorKey.currentState!.pushAndRemoveUntil(route, predicate);
  }

  // ===== Specific page methods =====

  // Navigate to login (clear all previous pages)
  Future<T?> toLogin<T>() {
    return pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  // Navigate to home (clear all previous pages)
  Future<T?> toHome<T>() {
    return pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  // Navigate to create page
  Future<T?> toCreate<T>() {
    return push<T>(MaterialPageRoute(builder: (_) => const CreatePage()));
  }

  // Navigate to detail page with QuoteCardData or QuoteVibeAnalysisData
  Future<T?> toDetail<T>(dynamic quoteData) {
    return push<T>(MaterialPageRoute(
      builder: (_) => DetailPage(quoteData: quoteData),
    ));
  }

  // Navigate to history page
  Future<T?> toHistory<T>() {
    return push<T>(MaterialPageRoute(builder: (_) => const HistoryPage()));
  }

  // Navigate to coin store page
  Future<T?> toStore<T>() {
    return push<T>(MaterialPageRoute(builder: (_) => const CoinStorePage()));
  }

  // Navigate to profile page
  Future<T?> toProfile<T>() {
    return push<T>(MaterialPageRoute(builder: (_) => const ProfilePage()));
  }

  // Navigate to agreement page
  Future<T?> toAgreement<T>(String title, String url) {
    return push<T>(MaterialPageRoute(
      builder: (_) => AgreementPage(title: title, url: url),
    ));
  }

  // Navigate to feedback page
  Future<T?> toFeedback<T>() {
    return push<T>(MaterialPageRoute(builder: (_) => const FeedbackPage()));
  }

  // Logout and navigate to login
  Future<void> logout() async {
    // Clear auth token will be handled by caller
    await toLogin();
  }
}

/// Route builder for MaterialApp
/// Note: detail route requires QuoteCardData argument, use AppNavigator.I.toDetail()
Map<String, WidgetBuilder> buildRoutes() {
  return {
    RoutePaths.login: (_) => const LoginPage(),
    RoutePaths.home: (_) => const HomePage(),
    RoutePaths.create: (_) => const CreatePage(),
    RoutePaths.detail: (_) => DetailPage(quoteData: _fallbackQuoteData),
    RoutePaths.history: (_) => const HistoryPage(),
    RoutePaths.store: (_) => const CoinStorePage(),
    RoutePaths.profile: (_) => const ProfilePage(),
    RoutePaths.agreement: (_) => const AgreementPage(
      title: '',
      url: '',
    ),
    RoutePaths.feedback: (_) => const FeedbackPage(),
  };
}

/// Fallback quote data for route registration (should not be used in practice)
final _fallbackQuoteData = QuoteCardData(
  assetImg: 'assets/placeholder.png',
  quote: 'Fallback quote',
  author: 'Fallback author',
);
