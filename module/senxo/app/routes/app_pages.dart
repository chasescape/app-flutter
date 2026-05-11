import 'package:get/get.dart';
import 'package:senxo/senxo/app/module/coins/coins_binding.dart';
import 'package:senxo/senxo/app/module/coins/coins_view.dart';
import 'package:senxo/senxo/app/module/detail/detail_binding.dart';
import 'package:senxo/senxo/app/module/detail/detail_view.dart';
import 'package:senxo/senxo/app/module/feedback/feedback_binding.dart';
import 'package:senxo/senxo/app/module/feedback/feedback_view.dart';
import 'package:senxo/senxo/app/module/generate/generate_binding.dart';
import 'package:senxo/senxo/app/module/generate/generate_view.dart';
import 'package:senxo/senxo/app/module/history/history_binding.dart';
import 'package:senxo/senxo/app/module/history/history_view.dart';
import 'package:senxo/senxo/app/module/home/home_binding.dart';
import 'package:senxo/senxo/app/module/home/home_view.dart';
import 'package:senxo/senxo/app/module/nav/nav_binding.dart';
import 'package:senxo/senxo/app/module/login/login_binding.dart';
import 'package:senxo/senxo/app/module/login/login_view.dart';
import 'package:senxo/senxo/app/module/nav/nav_view.dart';
import 'package:senxo/senxo/app/module/profile/profile_binding.dart';
import 'package:senxo/senxo/app/module/profile/profile_view.dart';
import 'package:senxo/senxo/app/module/webview/webview_binding.dart';
import 'package:senxo/senxo/app/module/webview/webview_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.home;

  static final routes = [
    GetPage(
      name: Routes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: Routes.login,
      page: () => LoginPage(),
      binding: LoginBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: Routes.profile,
      page: () => ProfilePage(),
      binding: ProfileBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: Routes.generate,
      page: () => GeneratePage(),
      binding: GenerateBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: Routes.nav,
      page: () => const NavPage(),
      binding: NavBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: Routes.coins,
      page: () => CoinsPage(),
      binding: CoinsBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: Routes.feedback,
      page: () => FeedbackPage(),
      binding: FeedbackBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: Routes.detail,
      page: () => DetailPage(),
      binding: DetailBinding(),
      transition: Transition.native,
    ),
    GetPage(
      name: Routes.history,
      page: () => HistoryPage(),
      binding: HistoryBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: Routes.webview,
      page: () => WebviewPage(),
      binding: WebviewBinding(),
      transition: Transition.noTransition,
    ),
  ];
}
