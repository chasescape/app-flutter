import 'package:get/get.dart';
import 'package:pliro/pliro/core/routes/app_routes.dart';
import 'package:pliro/pliro/features/auth/presentation/pages/login_page.dart';
import 'package:pliro/pliro/features/home/presentation/pages/main_page.dart';
import 'package:pliro/pliro/features/records/presentation/pages/record_editor_page.dart';
import 'package:pliro/pliro/features/library/presentation/pages/library_page.dart';
import 'package:pliro/pliro/features/badges/presentation/pages/badges_page.dart';
import 'package:pliro/pliro/features/coins/presentation/pages/coin_store_page.dart';
import 'package:pliro/pliro/features/profile/presentation/pages/profile_page.dart';
import 'package:pliro/pliro/features/shared/presentation/pages/agreement_page.dart';
import 'package:pliro/pliro/features/shared/presentation/pages/feedback_page.dart';
import 'package:pliro/pliro/features/records/presentation/pages/record_detail_page.dart';

/// Application pages configuration
class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const MainPage(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.recordEditor,
      page: () => RecordEditorPage(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.library,
      page: () => const LibraryPage(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.badges,
      page: () => const BadgesPage(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.coinStore,
      page: () => const CoinStorePage(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.agreement,
      page: () => AgreementPage(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.feedback,
      page: () => const FeedbackPage(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.recordDetail,
      page: () => RecordDetailPage(),
      transition: Transition.cupertino,
    ),
  ];
}
