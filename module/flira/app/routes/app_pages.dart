import 'package:flira/flira/app/modules/chat/chat_binding.dart';
import 'package:flira/flira/app/modules/chat/chat_view.dart';
import 'package:flira/flira/app/modules/coins/coins_binding.dart';
import 'package:flira/flira/app/modules/coins/coins_view.dart';
import 'package:flira/flira/app/modules/detail/detail_binding.dart';
import 'package:flira/flira/app/modules/detail/detail_view.dart';
import 'package:flira/flira/app/modules/feedback/feedback_binding.dart';
import 'package:flira/flira/app/modules/feedback/feedback_view.dart';
import 'package:flira/flira/app/modules/history/history_binding.dart';
import 'package:flira/flira/app/modules/history/history_view.dart';
import 'package:flira/flira/app/modules/home/home_binding.dart';
import 'package:flira/flira/app/modules/home/home_view.dart';
import 'package:flira/flira/app/modules/login/login_binding.dart';
import 'package:flira/flira/app/modules/login/login_view.dart';
import 'package:flira/flira/app/modules/nav/nav_binding.dart';
import 'package:flira/flira/app/modules/nav/nav_view.dart';
import 'package:flira/flira/app/modules/profile/profile_binding.dart';
import 'package:flira/flira/app/modules/profile/profile_view.dart';
import 'package:get/get.dart';

import 'app_routes.dart';

class AppPages {
  static const String initial = AppRoutes.login;

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.nav,
      page: () => NavPage(),
      binding: NavBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => ChatPage(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => ProfilePage(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.coins,
      page: () => CoinsPage(),
      binding: CoinsBinding(),
    ),
    GetPage(
      name: AppRoutes.feedback,
      page: () => FeedbackPage(),
      binding: FeedbackBinding(),
    ),
    GetPage(
      name: AppRoutes.history,
      page: () => HistoryPage(),
      binding: HistoryBinding(),
    ),
    GetPage(
      name: AppRoutes.detail,
      page: () => DetailPage(),
      binding: DetailBinding(),
    ),
  ];
}
