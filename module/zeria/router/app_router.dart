import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zeria/zeria/interface.dart';
import 'package:zeria/zeria/constants/app_routes.dart';
import 'package:zeria/zeria/features/splash/splash_page.dart';
import 'package:zeria/zeria/features/login/login_page.dart';
import 'package:zeria/zeria/features/main/main_page.dart';
import 'package:zeria/zeria/features/create/create_page.dart';
import 'package:zeria/zeria/features/history/history_page.dart';
import 'package:zeria/zeria/features/profile/profile_page.dart';
import 'package:zeria/zeria/features/detail/detail_page.dart';
import 'package:zeria/zeria/features/agreement/agreement_page.dart';
import 'package:zeria/zeria/features/coin_store/coin_store_page.dart';
import 'package:zeria/zeria/features/feedback/feedback_page.dart';

// App Router Configuration
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = Interface().authToken != null;
      final isLoginRoute = state.matchedLocation == AppRoutes.login;
      final isSplashRoute = state.matchedLocation == AppRoutes.splash;
      final isAgreementRoute = state.matchedLocation == AppRoutes.agreement;

      // Never stay on the in-app splash. Route immediately to the real entry.
      if (isSplashRoute) {
        return isLoggedIn ? AppRoutes.main : AppRoutes.login;
      }

      // Redirect to login if not logged in
      if (!isLoggedIn && !isLoginRoute && !isAgreementRoute) {
        return AppRoutes.login;
      }

      // Redirect to main if logged in and trying to access login
      if (isLoggedIn && isLoginRoute) {
        return AppRoutes.main;
      }

      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splash,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SplashPage(),
        ),
      ),

      // Login
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.login,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const LoginPage(),
        ),
      ),

      // Main
      GoRoute(
        path: AppRoutes.main,
        name: AppRoutes.main,
        pageBuilder: (context, state) {
          final tabRaw = state.uri.queryParameters[AppRoutes.paramTab];
          final tabIndex = int.tryParse(tabRaw ?? '') ?? 0;
          return MaterialPage(
            key: state.pageKey,
            child: MainPage(initialIndex: tabIndex.clamp(0, 3)),
          );
        },
      ),

      // Create (Standalone)
      GoRoute(
        path: AppRoutes.create,
        name: AppRoutes.create,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const CreatePage(),
        ),
      ),

      // History (Standalone)
      GoRoute(
        path: AppRoutes.history,
        name: AppRoutes.history,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const HistoryPage(),
        ),
      ),

      // Profile (Standalone)
      GoRoute(
        path: AppRoutes.profile,
        name: AppRoutes.profile,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ProfilePage(),
        ),
      ),

      // Detail
      GoRoute(
        path: '/detail/:id',
        name: AppRoutes.detail,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return MaterialPage(
            key: state.pageKey,
            child: DetailPage(id: id),
          );
        },
      ),

      // Agreement
      GoRoute(
        path: AppRoutes.agreement,
        name: AppRoutes.agreement,
        pageBuilder: (context, state) {
          final title = state.uri.queryParameters[AppRoutes.paramTitle] ?? '';
          final url = state.uri.queryParameters[AppRoutes.paramUrl] ?? '';
          return MaterialPage(
            key: state.pageKey,
            child: AgreementPage(title: title, url: url),
          );
        },
      ),

      // Coin Store
      GoRoute(
        path: AppRoutes.coinStore,
        name: AppRoutes.coinStore,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const CoinStorePage(),
        ),
      ),

      // Feedback
      GoRoute(
        path: AppRoutes.feedback,
        name: AppRoutes.feedback,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const FeedbackPage(),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.main),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );

  // Navigation Helpers
  static void go(BuildContext context, String path) {
    context.go(path);
  }

  static void push(BuildContext context, String path) {
    context.push(path);
  }

  static void pop(BuildContext context) {
    context.pop();
  }

  static void popToRoot(BuildContext context) {
    context.go(AppRoutes.main);
  }
}
