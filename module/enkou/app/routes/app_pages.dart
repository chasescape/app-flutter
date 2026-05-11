import 'package:enkou/enkou/app/module/calendar/calendar_binding.dart';
import 'package:enkou/enkou/app/module/calendar/calendar_view.dart';
import 'package:enkou/enkou/app/module/coins/coins_binding.dart';
import 'package:enkou/enkou/app/module/coins/coins_view.dart';
import 'package:enkou/enkou/app/module/day_journal/day_journal_binding.dart';
import 'package:enkou/enkou/app/module/day_journal/day_journal_view.dart';
import 'package:enkou/enkou/app/module/guides/guides_binding.dart';
import 'package:enkou/enkou/app/module/guides/guides_view.dart';
import 'package:enkou/enkou/app/module/history/history_binding.dart';
import 'package:enkou/enkou/app/module/history/history_view.dart';
import 'package:enkou/enkou/app/module/home/home_view.dart';
import 'package:enkou/enkou/app/module/detail/detail_binding.dart';
import 'package:enkou/enkou/app/module/detail/detail_view.dart';
import 'package:enkou/enkou/app/module/profile/profile_binding.dart';
import 'package:enkou/enkou/app/module/profile/profile_view.dart';
import 'package:enkou/enkou/app/module/feedback/feedback_binding.dart';
import 'package:enkou/enkou/app/module/feedback/feedback_view.dart';
import 'package:enkou/enkou/app/module/login/login_binding.dart';
import 'package:enkou/enkou/app/module/login/login_view.dart';
import 'package:enkou/enkou/app/module/nav/nav_binding.dart';
import 'package:enkou/enkou/app/module/nav/nav_view.dart';
import 'package:get/get.dart';

import 'package:enkou/enkou/interface.dart';

import 'app_routes.dart';

class AppPages {
  /// 已登录 -> nav(home)，未登录 -> login
  static String get initial {
    final token = Interface().authToken;
    return (token != null && token.isNotEmpty)
        ? AppRoutes.nav
        : AppRoutes.login;
  }

  static final routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => HomePage(),
    ),
    GetPage(
      name: AppRoutes.dayJournal,
      page: () => const DayJournalPage(),
      binding: DayJournalBinding(),
    ),
    GetPage(
      name: AppRoutes.calendar,
      page: () => CalendarPage(),
      binding: CalendarBinding(),
    ),
    GetPage(
      name: AppRoutes.guides,
      page: () => GuidesPage(),
      binding: GuidesBinding(),
    ),
    GetPage(
      name: AppRoutes.detail,
      page: () => DetailPage(),
      binding: DetailBinding(),
    ),
    GetPage(
      name: AppRoutes.feedback,
      page: () => FeedbackPage(),
      binding: FeedbackBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.coins,
      page: () => const CoinsPage(),
      binding: CoinsBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.nav,
      page: () => const NavPage(),
      binding: NavBinding(),
    ),    GetPage(
      name: AppRoutes.history,
      page: () => HistoryPage(),
      binding: HistoryBinding(),
    ),
  ];
}
