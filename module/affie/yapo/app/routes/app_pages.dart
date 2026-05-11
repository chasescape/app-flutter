import 'package:get/get.dart';
import 'package:yapo/yapo/app/module/Listings/listings_binding.dart';
import 'package:yapo/yapo/app/module/Listings/listings_view.dart';
import 'package:yapo/yapo/app/module/detail/detail_binding.dart';
import 'package:yapo/yapo/app/module/detail/detail_view.dart';
import 'package:yapo/yapo/app/module/home/home_binding.dart';
import 'package:yapo/yapo/app/module/home/home_view.dart';
import 'package:yapo/yapo/app/module/profile/profile_binding.dart';
import 'package:yapo/yapo/app/module/profile/profile_view.dart';
import 'package:yapo/yapo/app/module/publish/publish_binding.dart';
import 'package:yapo/yapo/app/module/publish/publish_view.dart';
import 'package:yapo/yapo/app/module/nav/nav_binding.dart';
import 'package:yapo/yapo/app/module/nav/nav_view.dart';
import 'package:yapo/yapo/app/module/coins/coins_binding.dart';
import 'package:yapo/yapo/app/module/coins/coins_view.dart';
import 'package:yapo/yapo/app/module/feedback/feedback_binding.dart';
import 'package:yapo/yapo/app/module/feedback/feedback_view.dart';
import 'package:yapo/yapo/app/module/login/login_binding.dart';
import 'package:yapo/yapo/app/module/login/login_view.dart';
import 'package:yapo/yapo/app/module/webview/webview_binding.dart';
import 'package:yapo/yapo/app/module/webview/webview_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.nav;

  static final routes = [
    GetPage(
      name: Routes.nav,
      page: () => const NavPage(),
      binding: NavBinding(),
    ),
    GetPage(
      name: Routes.listings,
      page: () => const ListingsPage(),
      binding: ListingsBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.profile,
      page: () => ProfilePage(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.creation,
      page: () => PublishPage(),
      binding: PublishBinding(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 500),
      fullscreenDialog: true,
    ),
    GetPage(
      name: Routes.details,
      page: () => const DetailPage(),
      binding: DetailBinding(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: Routes.coins,
      page: () => const CoinsPage(),
      binding: CoinsBinding(),
    ),
    GetPage(
      name: Routes.feedback,
      page: () => const FeedbackPage(),
      binding: FeedbackBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.webview,
      page: () => WebViewPage(),
      binding: WebViewBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
