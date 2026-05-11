import 'package:get/get.dart';
import 'package:lurvi/lurvi/app/modules/login/login_binding.dart';
import 'package:lurvi/lurvi/app/modules/login/login_view.dart';

import 'app_routes.dart';

class AppPages {
  static const String initial = AppRoutes.login;

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.login,
      page: () => LoginPage(),
      binding: LoginBinding(),
    ),
  ];
}
