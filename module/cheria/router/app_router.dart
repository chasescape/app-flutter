import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../features/login/login_page.dart';
import '../features/home/home_page.dart';
import '../features/library/library_page.dart';
import '../features/editor/editor_page.dart';
import '../features/stats/stats_page.dart';
import '../features/profile/profile_page.dart';
import '../features/coin_store/coin_store_page.dart';
import '../features/agreement/agreement_page.dart';
import '../features/feedback/feedback_page.dart';
import '../interface.dart';
import '../app/state/app_state.dart';
import '../app/theme/theme.dart';
import '../widgets/navigation/custom_bottom_nav_bar.dart';

/// App Routes
class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String library = '/library';
  static const String editor = '/editor';
  static const String stats = '/stats';
  static const String profile = '/profile';
  static const String coinStore = '/coin-store';
  static const String agreement = '/agreement';
  static const String feedback = '/feedback';

  // Route with parameters
  static String editorDetail(String novelId) => '/editor/$novelId';
  static String novelDetail(String novelId) => '/novel/$novelId';
}

/// App Router Configuration
class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Singleton router instance
  static GoRouter? _routerInstance;

  /// Get the singleton router instance
  static GoRouter get router {
    return _routerInstance ??= GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: AppRoutes.home,
      redirect: (context, state) {
        // Check login status
        final isLoggedIn = Interface().authToken != null;
        final isLoginRoute = state.uri.path == AppRoutes.login;
        final isAgreementRoute = state.uri.path == AppRoutes.agreement;
        final isPublicRoute = isLoginRoute || isAgreementRoute;

        if (!isLoggedIn && !isPublicRoute) {
          return AppRoutes.login;
        }

        if (isLoggedIn && isLoginRoute) {
          return AppRoutes.home;
        }

        return null;
      },
      routes: [
        // Login Route
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const LoginPage(),
          ),
        ),

        // Main Shell Route with Bottom Navigation
        ShellRoute(
          builder: (context, state, child) {
            return MainScaffold(child: child);
          },
          routes: [
            // Home Route
            GoRoute(
              path: AppRoutes.home,
              name: 'home',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: HomePage(),
              ),
            ),

            // Library Route
            GoRoute(
              path: AppRoutes.library,
              name: 'library',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: LibraryPage(),
              ),
            ),

            // Stats Route
            GoRoute(
              path: AppRoutes.stats,
              name: 'stats',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: StatsPage(),
              ),
            ),

            // Profile Route
            GoRoute(
              path: AppRoutes.profile,
              name: 'profile',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProfilePage(),
              ),
            ),
          ],
        ),

        // Editor Route (for creating/editing novels)
        GoRoute(
          path: AppRoutes.editor,
          name: 'editor',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const EditorPage(),
          ),
        ),

        // Editor Detail Route (for editing existing novel)
        GoRoute(
          path: '${AppRoutes.editor}/:novelId',
          name: 'editor-detail',
          pageBuilder: (context, state) {
            final novelId = state.pathParameters['novelId'] ?? '';
            return MaterialPage(
              key: state.pageKey,
              child: EditorPage(novelId: novelId),
            );
          },
        ),

        // Coin Store Route
        GoRoute(
          path: AppRoutes.coinStore,
          name: 'coin-store',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const CoinStorePage(),
          ),
        ),

        // Agreement Route
        GoRoute(
          path: AppRoutes.agreement,
          name: 'agreement',
          pageBuilder: (context, state) {
            final title = state.uri.queryParameters['title'] ?? 'Agreement';
            final url = state.uri.queryParameters['url'];
            return MaterialPage(
              key: state.pageKey,
              child: AgreementPage(
                title: title,
                url: url,
              ),
            );
          },
        ),

        // Feedback Route
        GoRoute(
          path: AppRoutes.feedback,
          name: 'feedback',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const FeedbackPage(),
          ),
        ),
      ],

      // Error Handler
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(
          title: const Text('Page Not Found'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Color(AppColors.error),
              ),
              const SizedBox(height: 16),
              Text(
                '404',
                style: AppTypography.getH1TextStyle(
                  const Color(AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Page not found',
                style: AppTypography.getBodyTextStyle(
                  const Color(AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Main Scaffold with Bottom Navigation
class MainScaffold extends StatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
      route: AppRoutes.home,
    ),
    _NavItem(
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book,
      label: 'Library',
      route: AppRoutes.library,
    ),
    _NavItem(
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart,
      label: 'Stats',
      route: AppRoutes.stats,
    ),
    _NavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
      route: AppRoutes.profile,
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateIndexFromRoute();
  }

  void _updateIndexFromRoute() {
    final location = GoRouterState.of(context).uri.path;
    for (var i = 0; i < _navItems.length; i++) {
      if (location == _navItems[i].route) {
        setState(() {
          _currentIndex = i;
        });
        break;
      }
    }
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    context.go(_navItems[index].route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}
