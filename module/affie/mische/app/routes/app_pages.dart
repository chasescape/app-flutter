import 'package:get/get.dart';
import 'package:mische/mische/app/modules/emotion/emotion_binding.dart';
import 'package:mische/mische/app/modules/emotion/emotion_detail_view.dart';
import 'package:mische/mische/app/modules/home/home_binding.dart';
import 'package:mische/mische/app/modules/home/home_view.dart';
import 'package:mische/mische/app/modules/insight/insight_detail_view.dart';
import 'package:mische/mische/app/modules/journal/journal_binding.dart';
import 'package:mische/mische/app/modules/journal/journal_view.dart';
import 'package:mische/mische/app/modules/login/login_binding.dart';
import 'package:mische/mische/app/modules/login/login_view.dart';
import 'package:mische/mische/app/modules/nav/nav_binding.dart';
import 'package:mische/mische/app/modules/nav/nav_view.dart';
import 'package:mische/mische/app/modules/profile/profile_binding.dart';
import 'package:mische/mische/app/modules/coins/coins_binding.dart';
import 'package:mische/mische/app/modules/coins/coins_view.dart';
import 'package:mische/mische/app/modules/feedback/feedback_binding.dart';
import 'package:mische/mische/app/modules/feedback/feedback_view.dart';
import 'package:mische/mische/app/modules/profile/profile_view.dart';
import 'package:mische/mische/app/modules/tools/tools_binding.dart';
import 'package:mische/mische/app/modules/tools/tools_view.dart';
import 'package:mische/mische/app/widgets/terms_webview_page.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.nav;
  static final routes = [
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
      name: AppRoutes.journal,
      page: () => JournalPage(),
      binding: JournalBinding(),
    ),
    GetPage(
      name: AppRoutes.tools,
      page: () => ToolsPage(),
      binding: ToolsBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => ProfilePage(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.detail,
      page: () => const EmotionDetailPage(),
      binding: EmotionBinding(),
    ),
    GetPage(
      name: AppRoutes.insightDetail,
      page: () => const InsightDetailPage(),
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
      name: AppRoutes.webview,
      page: () => const TermsWebViewPage(),
    ),
  ];
}
