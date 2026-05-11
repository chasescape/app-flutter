import 'package:get/get.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const String initial = AppRoutes.initial;

  static final routes = [
    GetPage(
      name: AppRoutes.initial,
      page: () => AppRoutes.routes.first.page(),
    ),
    ...AppRoutes.routes.skip(1),
  ];
}
