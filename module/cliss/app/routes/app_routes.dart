import 'package:flutter/material.dart';
import 'package:cliss/cliss/data/models/meal_analysis.dart';
import 'package:cliss/cliss/features/agreement/agreement_page.dart';
import 'package:cliss/cliss/features/coin_store/coin_store_page.dart';
import 'package:cliss/cliss/features/create/create_page.dart';
import 'package:cliss/cliss/features/detail/detail_page.dart';
import 'package:cliss/cliss/features/feedback/feedback_page.dart';
import 'package:cliss/cliss/features/history/history_page.dart';
import 'package:cliss/cliss/features/home/home_page.dart';
import 'package:cliss/cliss/features/login/login_page.dart';
import 'package:cliss/cliss/features/profile/profile_page.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String main = '/main';
  static const String home = '/home';
  static const String create = '/create';
  static const String history = '/history';
  static const String detail = '/detail';
  static const String coinStore = '/coin_store';
  static const String profile = '/profile';
  static const String agreement = '/agreement';
  static const String feedback = '/feedback';

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Route<T> _getRoute<T>(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage(), settings: settings);
      case main:
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage(), settings: settings);
      case create:
        return MaterialPageRoute(builder: (_) => const CreatePage(), settings: settings);
      case history:
        return MaterialPageRoute(builder: (_) => const HistoryPage(), settings: settings);
      case coinStore:
        return MaterialPageRoute(builder: (_) => const CoinStorePage(), settings: settings);
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage(), settings: settings);
      case feedback:
        return MaterialPageRoute(builder: (_) => const FeedbackPage(), settings: settings);
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
          settings: settings,
        );
    }
  }

  static Route<T>? onGenerateRoute<T>(RouteSettings settings) {
    if (settings.name == detail) {
      final args = settings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        builder: (_) => DetailPage(
          meal: args?['meal'] as MealAnalysis?,
          returnToHomeOnExit: args?['returnToHomeOnExit'] == true,
        ),
        settings: settings,
      );
    }
    if (settings.name == agreement) {
      final args = settings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        builder: (_) => AgreementPage(
          title: args?['title'] ?? '',
          url: args?['url'] ?? '',
        ),
        settings: settings,
      );
    }
    return _getRoute(settings);
  }

  static Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?> push<T>(Route<T> route) {
    return navigatorKey.currentState!.push(route);
  }

  static void pop<T>([T? result]) {
    return navigatorKey.currentState!.pop(result);
  }

  static Future<T?> pushReplacementNamed<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed<T, Object?>(routeName, arguments: arguments);
  }

  static Future<T?> pushNamedAndRemoveUntil<T>(String routeName, RoutePredicate predicate) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(routeName, predicate);
  }

  static Future<T?> toLogin<T>() {
    return pushNamedAndRemoveUntil<T>(login, (route) => false);
  }

  static Future<T?> toMain<T>() {
    return pushNamedAndRemoveUntil<T>(main, (route) => false);
  }

  static Future<T?> toCreate<T>() {
    return pushNamed<T>(create);
  }

  static Future<T?> toHistory<T>() {
    return pushNamed<T>(history);
  }

  static Future<T?> toDetail<T>(MealAnalysis meal, {bool returnToHomeOnExit = false}) {
    return pushNamed<T>(
      detail,
      arguments: {
        'meal': meal,
        'returnToHomeOnExit': returnToHomeOnExit,
      },
    );
  }

  static Future<T?> toCoinStore<T>() {
    return pushNamed<T>(coinStore);
  }

  static Future<T?> toProfile<T>() {
    return pushNamed<T>(profile);
  }

  static Future<T?> toAgreement<T>(String title, String url) {
    return pushNamed<T>(agreement, arguments: {'title': title, 'url': url});
  }

  static Future<T?> toFeedback<T>() {
    return pushNamed<T>(feedback);
  }
}
