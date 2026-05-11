import 'package:go_router/go_router.dart';
import '../interface.dart';
import '../features/login/login_page.dart';
import '../features/create/create_page.dart';
import '../features/result/result_page.dart';
import '../features/history/history_page.dart';
import '../features/settings/settings_page.dart';
import '../features/coins/coins_page.dart';
import '../features/agreement/agreement_page.dart';
import '../features/feedback/feedback_page.dart';
import '../models/nail_models.dart';
import '../widgets/main_layout.dart';

class AppRoutes {
  static const login = '/login';
  static const create = '/create';
  static const result = '/result';
  static const history = '/history';
  static const settings = '/settings';
  static const coins = '/coins';
  static const agreement = '/agreement';
  static const feedback = '/feedback';

  static final GoRouter router = GoRouter(
    initialLocation: login,
    redirect: (context, state) {
      final isLoggedIn = Interface().authToken != null;
      final isLoginRoute = state.matchedLocation == login;
      final isAgreementRoute = state.matchedLocation == agreement;

      if (!isLoggedIn && !isLoginRoute && !isAgreementRoute) return login;
      return null;
    },
    routes: [
      GoRoute(
        path: login,
        builder: (context, state) => const LoginPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainLayout(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: create,
                builder: (context, state) => const CreatePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: history,
                builder: (context, state) => const HistoryPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: settings,
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: result,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ResultPage(
            imagePath: extra['imagePath'] as String? ?? '',
            styles: (extra['styles'] as List<NailStyleCard>?) ?? [],
            sceneTag: extra['sceneTag'] as String?,
          );
        },
      ),
      GoRoute(
        path: coins,
        builder: (context, state) => const CoinsPage(),
      ),
      GoRoute(
        path: agreement,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return AgreementPage(
            title: extra['title'] as String? ?? 'Agreement',
            url: extra['url'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: feedback,
        builder: (context, state) => const FeedbackPage(),
      ),
    ],
  );

  static void toAgreement(String title, String url) {
    router.push(agreement, extra: {'title': title, 'url': url});
  }
}
