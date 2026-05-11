import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tavia/tavia/features/agreement/agreement_page.dart';
import 'package:tavia/tavia/features/auth/login_page.dart';
import 'package:tavia/tavia/features/create/create_page.dart';
import 'package:tavia/tavia/features/detail/detail_page.dart';
import 'package:tavia/tavia/features/feedback/feedback_page.dart';
import 'package:tavia/tavia/features/history/history_page.dart';
import 'package:tavia/tavia/features/home/home_page.dart';
import 'package:tavia/tavia/features/profile/profile_page.dart';
import 'package:tavia/tavia/features/store/store_page.dart';
import 'package:tavia/tavia/interface.dart';

import '../theme/app_colors.dart';
import '../widgets/tavia_ui.dart';
import 'app_routes.dart';

/// GoRouter setup with authentication guard.
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: _redirect,
    routes: _routes,
    errorBuilder: _errorBuilder,
    debugLogDiagnostics: true,
  );

  static String? _redirect(BuildContext context, GoRouterState state) {
    final isLoggedIn = Interface().authToken != null;
    final isGoingToLogin = state.uri.path == AppRoutes.login;
    final isGoingToSplash = state.uri.path == AppRoutes.splash;
    final isGoingToAgreement = state.uri.path == AppRoutes.agreement;

    if (isGoingToSplash) {
      if (isLoggedIn) {
        return AppRoutes.home;
      }
      return AppRoutes.login;
    }

    if (!isLoggedIn && !(isGoingToLogin || isGoingToAgreement)) {
      return AppRoutes.login;
    }

    if (isLoggedIn && isGoingToLogin) {
      return AppRoutes.home;
    }

    return null;
  }

  static final List<RouteBase> _routes = [
    GoRoute(
      path: AppRoutes.splash,
      name: AppRoutes.splashRouteName,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const _SplashScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: AppRoutes.loginRouteName,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const LoginPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: AppRoutes.homeRouteName,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const HomePage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.detail,
      name: AppRoutes.detailRouteName,
      pageBuilder: (context, state) {
        final id = state.uri.queryParameters[AppRoutes.paramId] ?? '';
        return MaterialPage(
          key: state.pageKey,
          child: DetailPage(itemId: id),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.create,
      name: AppRoutes.createRouteName,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const CreatePage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.history,
      name: AppRoutes.historyRouteName,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const HistoryPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.store,
      name: AppRoutes.storeRouteName,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const StorePage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.profile,
      name: AppRoutes.profileRouteName,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const ProfilePage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.agreement,
      name: AppRoutes.agreementRouteName,
      pageBuilder: (context, state) {
        final title = state.uri.queryParameters[AppRoutes.paramTitle] ?? '';
        final url = state.uri.queryParameters[AppRoutes.paramUrl] ?? '';
        return MaterialPage(
          key: state.pageKey,
          child: AgreementPage(title: title, url: url),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.feedback,
      name: AppRoutes.feedbackRouteName,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const FeedbackPage(),
      ),
    ),
  ];

  static Widget _errorBuilder(BuildContext context, GoRouterState state) {
    return Scaffold(
      body: TaviaBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: TaviaPanel(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 56,
                      color: AppColors.semanticError,
                    ),
                    const SizedBox(height: 16),
                    const Text('Page not found'),
                    const SizedBox(height: 8),
                    Text(state.uri.path),
                    const SizedBox(height: 24),
                    TaviaPrimaryButton(
                      label: 'Go Home',
                      onPressed: () => context.go(AppRoutes.home),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TaviaBackground(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TaviaLogoLockup(size: 96),
                SizedBox(height: 24),
                CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
