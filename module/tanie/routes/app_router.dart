import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tanie/tanie/interface.dart';
import 'package:tanie/tanie/features/auth/login_page.dart';
import 'package:tanie/tanie/features/home/home_page.dart';
import 'package:tanie/tanie/features/history/history_page.dart';
import 'package:tanie/tanie/features/profile/profile_page.dart';
import 'package:tanie/tanie/features/agreement/agreement_page.dart';
import 'package:tanie/tanie/features/coin_store/coin_store_page.dart';
import 'package:tanie/tanie/features/creation/creation_page.dart';
import 'package:tanie/tanie/features/detail/detail_page.dart';
import 'package:tanie/tanie/features/feedback/feedback_page.dart';
import 'package:tanie/tanie/theme/app_colors.dart';
import 'package:tanie/tanie/theme/app_shadows.dart';
import 'package:tanie/tanie/theme/app_text_styles.dart';
import 'app_routes.dart';

/// App Router Configuration with go_router
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,
    redirect: _redirect,
    routes: _routes,
    errorBuilder: _errorBuilder,
  );

  static String? _redirect(BuildContext context, GoRouterState state) {
    final isLoggedIn = (Interface().authToken?.trim().isNotEmpty ?? false);
    final isGoingToLogin = state.uri.path == AppRoutes.login;
    final isGoingToDiscover = state.uri.path == AppRoutes.discover;
    final isGoingToAgreement = state.uri.path == AppRoutes.agreement;

    if (isGoingToAgreement) {
      return null;
    }

    if (isGoingToDiscover) {
      return AppRoutes.home;
    }

    // Not logged in and not going to login page
    if (!isLoggedIn && !isGoingToLogin) {
      return AppRoutes.login;
    }

    // Already logged in and going to login page
    if (isLoggedIn && isGoingToLogin) {
      return AppRoutes.home;
    }

    return null;
  }

  static final List<RouteBase> _routes = [
    // Login Route
    GoRoute(
      path: AppRoutes.login,
      name: AppRoutes.loginRouteName,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const LoginPage(),
      ),
    ),

    // Main Navigation with Shell Route
    ShellRoute(
      builder: (context, state, child) {
        return MainNavigationPage(child: child);
      },
      routes: [
        // Home Tab
        GoRoute(
          path: AppRoutes.home,
          name: AppRoutes.homeRouteName,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomePage(),
          ),
        ),

        // Create Tab
        GoRoute(
          path: AppRoutes.create,
          name: 'create',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CreationPage(showBackButton: false),
          ),
        ),

        // History Tab
        GoRoute(
          path: AppRoutes.history,
          name: AppRoutes.historyRouteName,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HistoryPage(),
          ),
        ),

        // Profile Tab
        GoRoute(
          path: AppRoutes.profile,
          name: AppRoutes.profileRouteName,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ProfilePage(),
          ),
        ),
      ],
    ),

    // Agreement Page
    GoRoute(
      path: AppRoutes.agreement,
      name: AppRoutes.agreementRouteName,
      pageBuilder: (context, state) {
        final title = state.uri.queryParameters['title'] ?? 'Agreement';
        final url = state.uri.queryParameters['url'] ?? '';
        return MaterialPage(
          key: state.pageKey,
          child: AgreementPage(
            title: title,
            url: url,
          ),
        );
      },
    ),

    // Coin Store Page
    GoRoute(
      path: AppRoutes.coinStore,
      name: AppRoutes.coinStoreRouteName,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const CoinStorePage(),
      ),
    ),

    // Creation Page
    GoRoute(
      path: AppRoutes.creation,
      name: AppRoutes.creationRouteName,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const CreationPage(),
      ),
    ),

    // Detail Page
    GoRoute(
      path: AppRoutes.detail,
      name: AppRoutes.detailRouteName,
      pageBuilder: (context, state) {
        return MaterialPage(
          key: state.pageKey,
          child: const DetailPage(),
        );
      },
    ),

    // Feedback Page
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
      backgroundColor: AppColors.backgroundPrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 24),
            const Text(
              'Page Not Found',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: 8),
            Text(
              'The page "${state.uri.path}" does not exist.',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Main Navigation Page with Bottom Navigation Bar
class MainNavigationPage extends StatelessWidget {
  final Widget child;

  const MainNavigationPage({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(child: child),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomNavigation(),
          ),
        ],
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: AppShadows.card,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.home_rounded,
                  selectedIcon: Icons.home_rounded,
                  label: 'Home',
                  index: 0,
                  currentIndex: currentIndex,
                  route: AppRoutes.home,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.add_circle_rounded,
                  selectedIcon: Icons.add_circle_rounded,
                  label: 'Create',
                  index: 1,
                  currentIndex: currentIndex,
                  route: AppRoutes.create,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.history_rounded,
                  selectedIcon: Icons.history_rounded,
                  label: 'History',
                  index: 2,
                  currentIndex: currentIndex,
                  route: AppRoutes.history,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.person_rounded,
                  selectedIcon: Icons.person_rounded,
                  label: 'Profile',
                  index: 3,
                  currentIndex: currentIndex,
                  route: AppRoutes.profile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required int currentIndex,
    required String route,
  }) {
    final isSelected = currentIndex == index;

    return InkWell(
      onTap: () => context.go(route),
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryMain : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? AppColors.white : AppColors.textTertiary,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.small.copyWith(
                color: isSelected ? AppColors.white : AppColors.textTertiary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith(AppRoutes.home)) return 0;
    if (location.startsWith(AppRoutes.create)) return 1;
    if (location.startsWith(AppRoutes.history)) return 2;
    if (location.startsWith(AppRoutes.profile)) return 3;
    return 0;
  }
}
