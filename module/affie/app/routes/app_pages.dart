import 'package:affie/affie/app/module/nav/nav_binding.dart';
import 'package:affie/affie/app/module/nav/nav_view.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../interface.dart';
import 'app_routes.dart';
import '../module/login/login_view.dart';
import '../module/login/login_binding.dart';
import '../module/home/home_view.dart';
import '../module/home/home_binding.dart';
import '../module/generate/generate_view.dart';
import '../module/generate/generate_binding.dart';
import '../module/detail/detail_view.dart';
import '../module/detail/detail_binding.dart';
import '../module/history/history_view.dart';
import '../module/history/history_binding.dart';
import '../module/profile/profile_view.dart';
import '../module/profile/profile_binding.dart';
import '../module/coins/coins_view.dart';
import '../module/coins/coins_binding.dart';
import '../module/feedback/feedback_view.dart';
import '../module/feedback/feedback_binding.dart';

class AppPages {
  static const initial = AppRoutes.nav;

  static final _authRequired = [AuthGuardMiddleware()];
  static final _redirectIfLoggedIn = [LoginRedirectMiddleware()];

  static final routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => LoginPage(),
      binding: LoginBinding(),
      middlewares: _redirectIfLoggedIn,
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => HomePage(),
      binding: HomeBinding(),
      middlewares: _authRequired,
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.generate,
      page: () => GeneratePage(),
      binding: GenerateBinding(),
      middlewares: _authRequired,
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.detail,
      page: () => DetailPage(),
      binding: DetailBinding(),
      middlewares: _authRequired,
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.history,
      page: () => HistoryPage(),
      binding: HistoryBinding(),
      middlewares: _authRequired,
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => ProfilePage(),
      binding: ProfileBinding(),
      middlewares: _authRequired,
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.coins,
      page: () => CoinsPage(),
      binding: CoinsBinding(),
      middlewares: _authRequired,
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.feedback,
      page: () => FeedbackPage(),
      binding: FeedbackBinding(),
      middlewares: _authRequired,
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.nav,
      page: () => NavPage(),
      binding: NavBinding(),
      middlewares: _authRequired,
      transition: Transition.rightToLeft,
    ),
  ];
}

class AuthGuardMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final token = Interface().authToken;
    final isLoggedIn = token != null && token.isNotEmpty;
    if (!isLoggedIn) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}

class LoginRedirectMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final token = Interface().authToken;
    final isLoggedIn = token != null && token.isNotEmpty;
    if (isLoggedIn) {
      return const RouteSettings(name: AppRoutes.nav);
    }
    return null;
  }
}
