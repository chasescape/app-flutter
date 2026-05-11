import 'package:get/get.dart';
import 'package:rova/rova/app/modules/coins/coins_binding.dart';
import 'package:rova/rova/app/modules/coins/coins_view.dart';
import 'package:rova/rova/app/modules/details/details_binding.dart';
import 'package:rova/rova/app/modules/details/details_view.dart';
import 'package:rova/rova/app/modules/feedback/feedback_binding.dart';
import 'package:rova/rova/app/modules/feedback/feedback_view.dart';
import 'package:rova/rova/app/modules/generate/generate_binding.dart';
import 'package:rova/rova/app/modules/generate/generate_view.dart';
import 'package:rova/rova/app/modules/history/history_binding.dart';
import 'package:rova/rova/app/modules/history/history_view.dart';
import 'package:rova/rova/app/modules/home/home_binding.dart';
import 'package:rova/rova/app/modules/home/home_view.dart';
import 'package:rova/rova/app/modules/legal/privacy_policy_view.dart';
import 'package:rova/rova/app/modules/legal/terms_of_service_view.dart';
import 'package:rova/rova/app/modules/login/login_binding.dart';
import 'package:rova/rova/app/modules/login/login_view.dart';
import 'package:rova/rova/app/modules/nav/nav_binding.dart';
import 'package:rova/rova/app/modules/nav/nav_view.dart';
import 'package:rova/rova/app/modules/profile/profile_binding.dart';
import 'package:rova/rova/app/modules/profile/profile_view.dart';

import 'app_routes.dart';

class AppPages {
  static const String initial = AppRoutes.nav;

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.nav,
      page: () => const NavPage(),
      binding: NavBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.generate,
      page: () => const GeneratePage(),
      binding: GenerateBinding(),
    ),
    GetPage(
      name: AppRoutes.history,
      page: () => const HistoryPage(),
      binding: HistoryBinding(),
    ),
    GetPage(
      name: AppRoutes.coins,
      page: () => const CoinsPage(),
      binding: CoinsBinding(),
    ),
    GetPage(
      name: AppRoutes.feedback,
      page: () => const FeedbackPage(),
      binding: FeedbackBinding(),
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const PrivacyPolicyPage(),
    ),
    GetPage(
      name: AppRoutes.termsOfService,
      page: () => const TermsOfServicePage(),
    ),
    GetPage(
      name: AppRoutes.details,
      page: () => const DetailsPage(),
      binding: DetailsBinding(),
    ),
  ];
}
