import 'package:get/get.dart';
import 'package:vesper/vesper/app/modules/history/history_binding.dart';
import 'package:vesper/vesper/app/modules/history/history_view.dart';
import 'package:vesper/vesper/app/modules/generate/generate_binding.dart';
import 'package:vesper/vesper/app/modules/generate/generate_view.dart';
import 'package:vesper/vesper/app/modules/details/details_binding.dart';
import 'package:vesper/vesper/app/modules/details/details_view.dart';
import 'package:vesper/vesper/app/modules/home/home_binding.dart';
import 'package:vesper/vesper/app/modules/home/home_view.dart';
import 'package:vesper/vesper/app/modules/login/login_binding.dart';
import 'package:vesper/vesper/app/modules/login/login_view.dart';
import 'package:vesper/vesper/app/modules/nav/nav_binding.dart';
import 'package:vesper/vesper/app/modules/nav/nav_view.dart';
import 'package:vesper/vesper/app/modules/coins/coins_binding.dart';
import 'package:vesper/vesper/app/modules/coins/coins_view.dart';
import 'package:vesper/vesper/app/modules/feedback/feedback_binding.dart';
import 'package:vesper/vesper/app/modules/feedback/feedback_view.dart';
import 'package:vesper/vesper/app/modules/profile/profile_binding.dart';
import 'package:vesper/vesper/app/modules/profile/profile_view.dart';
import 'package:vesper/vesper/app/modules/agreement/agreement_page.dart';

import 'app_routes.dart';

class AppPages {
  static const String initial = AppRoutes.login;

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.login,
      page: () => LoginPage(),
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
      name: AppRoutes.history,
      page: () => HistoryPage(),
      binding: HistoryBinding(),
    ),
    GetPage(
      name: AppRoutes.generate,
      page: () => GeneratePage(),
      binding: GenerateBinding(),
    ),
    GetPage(
      name: AppRoutes.details,
      page: () => DetailsPage(),
      binding: DetailsBinding(),
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
      name: AppRoutes.profile,
      page: () => ProfilePage(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: '${AppRoutes.privacyPolicy}/:type',
      page: () => const AgreementPage(),
    ),
  ];
}
