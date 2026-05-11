import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bilra/bilra/interface.dart';
import 'package:bilra/bilra/features/auth/pages/login_page.dart';
import 'package:bilra/bilra/features/home/pages/home_page.dart';
import 'package:bilra/bilra/features/history/pages/history_page.dart';
import 'package:bilra/bilra/features/profile/pages/profile_page.dart';
import 'package:bilra/bilra/features/agreement/pages/agreement_page.dart';
import 'package:bilra/bilra/features/coin/pages/coin_store_page.dart';
import 'package:bilra/bilra/features/create/pages/create_page.dart';
import 'package:bilra/bilra/features/detail/pages/detail_page.dart';
import 'package:bilra/bilra/features/feedback/pages/feedback_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String agreement = '/agreement';
  static const String coinStore = '/coin-store';
  static const String create = '/create';
  static const String detail = '/detail';
  static const String feedback = '/feedback';

  static void pushReplacementNamed(BuildContext context, String routeName) {
    context.go(routeName);
  }

  static void pushNamed(BuildContext context, String routeName) {
    context.push(routeName);
  }

  static void pop(BuildContext context, [dynamic result]) {
    context.pop(result);
  }

  static void toAgreement(
    BuildContext context,
    String title,
    String url, {
    int? returnTab,
  }) {
    final location = Uri(
      path: agreement,
      queryParameters: {
        'title': title,
        'url': url,
        if (returnTab != null) 'returnTab': '$returnTab',
      },
    ).toString();
    context.push(location);
  }

  static void toDetail(BuildContext context, int index) {
    context.push('$detail?index=$index');
  }

  static void toCoinStore(BuildContext context, {int? returnTab}) {
    final location = Uri(
      path: coinStore,
      queryParameters: {
        if (returnTab != null) 'returnTab': '$returnTab',
      },
    ).toString();
    context.push(location);
  }

  static void toFeedback(BuildContext context, {int? returnTab}) {
    final location = Uri(
      path: feedback,
      queryParameters: {
        if (returnTab != null) 'returnTab': '$returnTab',
      },
    ).toString();
    context.push(location);
  }
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  redirect: (context, state) {
    final hasAuthToken = (Interface().authToken ?? '').isNotEmpty;
    final isLoginRoute = state.uri.path == AppRoutes.login;
    final isAgreementRoute = state.uri.path == AppRoutes.agreement;

    if (!hasAuthToken && !isLoginRoute && !isAgreementRoute) {
      return AppRoutes.login;
    }
    if (hasAuthToken && isLoginRoute) {
      return AppRoutes.home;
    }
    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.login,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const LoginPage(),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.home,
      pageBuilder: (context, state) {
        final tabIndex = state.uri.queryParameters.containsKey('tab')
            ? int.tryParse(state.uri.queryParameters['tab'] ?? '')
            : null;
        return CustomTransitionPage(
          key: state.pageKey,
          child: HomePage(initialTabIndex: tabIndex),
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(
      path: AppRoutes.history,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const HistoryPage(),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.profile,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ProfilePage(),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.agreement,
      pageBuilder: (context, state) {
        final title = state.uri.queryParameters['title'] ?? 'Agreement';
        final url = state.uri.queryParameters['url'] ?? '';
        final returnTab =
            int.tryParse(state.uri.queryParameters['returnTab'] ?? '');
        return MaterialPage(
          key: state.pageKey,
          child: AgreementPage(
            title: title,
            url: url,
            returnTab: returnTab,
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.coinStore,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: CoinStorePage(
          returnTab:
              int.tryParse(state.uri.queryParameters['returnTab'] ?? ''),
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.create,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const CreatePage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.detail,
      pageBuilder: (context, state) {
        final index = state.uri.queryParameters['index'];
        return MaterialPage(
          key: state.pageKey,
          child: DetailPage(index: index),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.feedback,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: FeedbackPage(
          returnTab:
              int.tryParse(state.uri.queryParameters['returnTab'] ?? ''),
        ),
      ),
    ),
  ],
);
