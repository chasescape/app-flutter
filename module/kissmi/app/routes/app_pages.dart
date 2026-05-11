import 'package:get/get.dart';
import 'package:kissmi/kissmi/app/module/feedback/feedback_binding.dart';
import 'package:kissmi/kissmi/app/module/feedback/feedback_view.dart';

import '../module/chat/chat_binding.dart';
import '../module/chat/chat_view.dart';
import '../module/coins/coins_binding.dart';
import '../module/coins/coins_view.dart';
import '../module/date/date_view.dart';
import '../module/home/home_binding.dart';
import '../module/home/home_view.dart';
import '../module/login/login_binding.dart';
import '../module/login/login_view.dart';
import '../module/profile/profile_binding.dart';
import '../module/profile/profile_view.dart';
import '../module/voice/voice_view.dart';
import '../widget/inapp_webview_page.dart';
import 'app_routes.dart';

class AppPages {
  static const String initial = AppRoutes.home;

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
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
      name: AppRoutes.feedback,
      page: () => FeedbackPage(),
      binding: FeedbackBinding(),
    ),
    GetPage(
      name: AppRoutes.coins,
      page: () => CoinsPage(),
      binding: CoinsBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => ProfilePage(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.date,
      page: () => DatePage(),
    ),
    GetPage(
      name: AppRoutes.voice,
      page: () => const VoicePage(),
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => InAppWebViewPage.agreement(isPrivacy: true),
    ),
    GetPage(
      name: AppRoutes.termsOfService,
      page: () => InAppWebViewPage.agreement(isPrivacy: false),
    ),
  ];
}
