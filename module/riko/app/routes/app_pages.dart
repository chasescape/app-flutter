import 'package:get/get.dart';
import 'package:riko/riko/app/modules/chat/chat_binding.dart';
import 'package:riko/riko/app/modules/chat/chat_view.dart';
import 'package:riko/riko/app/modules/coins/coins_binding.dart';
import 'package:riko/riko/app/modules/coins/coins_view.dart';
import 'package:riko/riko/app/modules/details/details_binding.dart';
import 'package:riko/riko/app/modules/details/details_view.dart';
import 'package:riko/riko/app/modules/feedback/feedback_binding.dart';
import 'package:riko/riko/app/modules/feedback/feedback_view.dart';
import 'package:riko/riko/app/modules/history/history_view.dart';
import 'package:riko/riko/app/modules/home/home_binding.dart';
import 'package:riko/riko/app/modules/home/home_view.dart';
import 'package:riko/riko/app/modules/login/login_binding.dart';
import 'package:riko/riko/app/modules/login/login_view.dart';
import 'package:riko/riko/app/modules/nav/nav_binding.dart';
import 'package:riko/riko/app/modules/nav/nav_view.dart';
import 'package:riko/riko/app/modules/profile/profile_binding.dart';
import 'package:riko/riko/app/modules/profile/profile_view.dart';
import 'package:riko/riko/app/modules/agreement/agreement_view.dart';

import 'app_routes.dart';

class AppPages {
  static const String initial = AppRoutes.nav;

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.login,
      page: () => LoginPage(),
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
      name: AppRoutes.chat,
      page: () => const ChatPage(),
      binding: ChatBinding(),
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
      name: AppRoutes.feedback,
      page: () => const FeedbackPage(),
      binding: FeedbackBinding(),
    ),
    GetPage(
      name: AppRoutes.history,
      page: () => const HistoryPage(),
    ),
    GetPage(
      name: AppRoutes.details,
      page: () => DetailsPage(),
      binding: DetailsBinding(),
    ),
    GetPage(
      name: AppRoutes.termsOfService,
      page: () => const AgreementPage(type: AgreementType.user),
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const AgreementPage(type: AgreementType.privacy),
    ),
  ];
}
