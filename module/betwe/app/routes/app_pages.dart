import 'package:betwe/betwe/app/module/login/login_binding.dart';
import 'package:betwe/betwe/app/module/login/login_view.dart';
import 'package:betwe/betwe/app/module/nav/nav_binding.dart';
import 'package:betwe/betwe/app/module/nav/nav_view.dart';
import 'package:get/get.dart';

import 'app_routes.dart';

class AppPages {
  static const String initial = AppRoutes.login;

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.login,
      page: () => LoginPage(),
      binding: LoginBinding(),
    ),    GetPage(
      name: AppRoutes.nav,
      page: () => NavPage(),
      binding: NavBinding(),
    ),
  ];
}
