import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../interface.dart';
import '../../features/login/login_page.dart';
import '../../features/home/home_shell.dart';
import '../../features/create/create_page.dart';
import '../../features/coin_store/coin_store_page.dart';
import '../../features/detail/detail_page.dart';
import '../../features/agreement/agreement_page.dart';
import '../../features/feedback/feedback_page.dart';
import '../../data/models/snap_analysis.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final isLoggedIn = Interface().authToken != null;
      final isLoginRoute = state.uri.path == AppRoutes.login;
      final isAgreementRoute = state.uri.path.startsWith(AppRoutes.agreement);

      if (!isLoggedIn && !isLoginRoute && !isAgreementRoute) {
        return AppRoutes.login;
      }
      if (isLoggedIn && isLoginRoute) {
        return AppRoutes.main;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.create,
        builder: (context, state) => const CreatePage(),
      ),
      GoRoute(
        path: AppRoutes.coinStore,
        builder: (context, state) => const CoinStorePage(),
      ),
      GoRoute(
        path: AppRoutes.detail,
        builder: (context, state) {
          final data = state.extra as SnapAnalysis?;
          return DetailPage(data: data!);
        },
      ),
      GoRoute(
        path: '${AppRoutes.agreement}/:title',
        builder: (context, state) {
          final title = state.pathParameters['title'] ?? '';
          final url = state.uri.queryParameters['url'] ?? '';
          return AgreementPage(title: title, url: url);
        },
      ),
      GoRoute(
        path: AppRoutes.main,
        builder: (context, state) => const HomeShell(),
      ),
      GoRoute(
        path: AppRoutes.feedback,
        builder: (context, state) => const FeedbackPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFFF6EC7)),
            const SizedBox(height: 16),
            Text('Page Not Found', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('${state.uri.path}', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.main),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );

  // Helper methods for navigation
  static void toLogin(BuildContext context) {
    context.go(AppRoutes.login);
  }

  static void toMain(BuildContext context) {
    context.go(AppRoutes.main);
  }

  static void toCreate(BuildContext context) {
    context.push(AppRoutes.create);
  }

  static void toCoinStore(BuildContext context) {
    context.push(AppRoutes.coinStore);
  }

  static void toDetail(BuildContext context, {required SnapAnalysis data}) {
    context.push(AppRoutes.detail, extra: data);
  }

  static void toAgreement(BuildContext context, String title, String url) {
    context.push(
      '${AppRoutes.agreement}/$title?url=${Uri.encodeComponent(url)}',
    );
  }

  static void toFeedback(BuildContext context) {
    context.push(AppRoutes.feedback);
  }
}
