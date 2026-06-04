import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../interface.dart';
import '../pages/home/home_page.dart';
import '../pages/editor/editor_page.dart';
import '../pages/detail/detail_page.dart';
import '../pages/library/library_page.dart';
import '../pages/login/login_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/coin_store/coin_store_page.dart';
import '../pages/agreement/agreement_page.dart';
import '../pages/feedback/feedback_page.dart';

class AppRoutes {
  static const String home = '/home';
  static const String editor = '/editor';
  static const String detail = '/detail';
  static const String library = '/library';
  static const String login = '/login';
  static const String profile = '/profile';
  static const String coinStore = '/coinStore';
  static const String agreement = '/agreement';
  static const String feedback = '/feedback';
  static const Set<String> _publicRoutes = {
    login,
    agreement,
  };

  static final GoRouter router = GoRouter(
    initialLocation: Interface().authToken != null ? home : login,
    redirect: (context, state) {
      final isAuthenticated = Interface().authToken != null;
      final matchedLocation = state.matchedLocation;
      final isLoginRoute = matchedLocation == login;
      final isPublicRoute = _publicRoutes.contains(matchedLocation);

      if (!isAuthenticated && !isPublicRoute) {
        return login;
      }
      if (isAuthenticated && isLoginRoute) {
        return home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: login,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: home,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const HomePage(),
        ),
      ),
      GoRoute(
        path: editor,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const EditorPage(),
        ),
      ),
      GoRoute(
        path: detail,
        pageBuilder: (context, state) {
          final recordId = state.uri.queryParameters['id'] ?? '';
          return MaterialPage(
            key: state.pageKey,
            child: DetailPage(recordId: recordId),
          );
        },
      ),
      GoRoute(
        path: library,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const LibraryPage(),
        ),
      ),
      GoRoute(
        path: profile,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ProfilePage(),
        ),
      ),
      GoRoute(
        path: coinStore,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const CoinStorePage(),
        ),
      ),
      GoRoute(
        path: agreement,
        pageBuilder: (context, state) {
          final title = state.uri.queryParameters['title'] ?? 'Agreement';
          final url = state.uri.queryParameters['url'] ?? '';
          return MaterialPage(
            key: state.pageKey,
            child: AgreementPage(title: title, url: url),
          );
        },
      ),
      GoRoute(
        path: feedback,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const FeedbackPage(),
        ),
      ),
    ],
  );

  static void toDetail(BuildContext context, String recordId) {
    final target = Uri(
      path: detail,
      queryParameters: {
        'id': recordId,
      },
    ).toString();
    context.push(target);
  }

  static void toDetailReplacingCurrent(BuildContext context, String recordId) {
    final target = Uri(
      path: detail,
      queryParameters: {
        'id': recordId,
      },
    ).toString();
    context.pushReplacement(target);
  }

  static void toAgreement(BuildContext context, String title, String url) {
    final target = Uri(
      path: agreement,
      queryParameters: {
        'title': title,
        'url': url,
      },
    ).toString();
    context.push(target);
  }
}
