import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../interface.dart';
import '../../features/login/login_page.dart';
import '../../features/main_shell/main_shell.dart';
import '../../features/home/home_page.dart';
import '../../features/record/record_page.dart';
import '../../features/record/record_detail_page.dart';
import '../../features/history/history_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/coin_store/coin_store_page.dart';
import '../../features/agreement/agreement_page.dart';
import '../../features/feedback/feedback_page.dart';
import 'routes.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: Routes.home,
    redirect: _redirect,
    routes: [
      GoRoute(
        path: Routes.login,
        builder: (_, __) => const LoginPage(),
      ),
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            pageBuilder: (_, __) => const NoTransitionPage(
              child: HomePage(),
            ),
          ),
          GoRoute(
            path: Routes.record,
            pageBuilder: (_, __) => const NoTransitionPage(
              child: RecordPage(),
            ),
          ),
          GoRoute(
            path: Routes.settings,
            pageBuilder: (_, __) => const NoTransitionPage(
              child: SettingsPage(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: Routes.recordDetail,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>;
          return RecordDetailPage(
            record: extra['record'],
            heroTag: extra['heroTag'],
          );
        },
      ),
      GoRoute(
        path: Routes.coinStore,
        builder: (_, __) => const CoinStorePage(),
      ),
      GoRoute(
        path: Routes.history,
        builder: (_, __) => const HistoryPage(),
      ),
      GoRoute(
        path: Routes.agreement,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return AgreementPage(
            title: extra?['title'] ?? '',
            url: extra?['url'] ?? '',
          );
        },
      ),
      GoRoute(
        path: Routes.feedback,
        builder: (_, __) => const FeedbackPage(),
      ),
    ],
  );

  static String? _redirect(BuildContext context, GoRouterState state) {
    final isLoggedIn = Interface().authToken != null;
    final path = state.uri.path;
    final isLoginRoute = path == Routes.login;
    final isPublicRoute = isLoginRoute || path == Routes.agreement;

    if (!isLoggedIn && !isPublicRoute) return Routes.login;
    if (isLoggedIn && isLoginRoute) return Routes.home;
    return null;
  }
}

extension AppRouterExtension on BuildContext {
  void toHistory() => push(Routes.history);

  void toAgreement(String title, String url) {
    push(Routes.agreement, extra: {'title': title, 'url': url});
  }

  void toFeedback() => push(Routes.feedback);
}
