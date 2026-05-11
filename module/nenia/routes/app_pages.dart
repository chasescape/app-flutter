import 'package:get/get.dart';
import '../data/models/style_analysis.dart';
import '../views/login/login_page.dart';
import '../views/home/home_page.dart';
import '../views/create/create_page.dart';
import '../views/detail/detail_page.dart';
import '../views/history/history_page.dart';
import '../views/coin_store/coin_store_page.dart';
import '../views/profile/profile_page.dart';
import '../views/agreement/agreement_page.dart';
import '../views/feedback/feedback_page.dart';
import '../views/upload/upload_page.dart';
import '../views/analysis_history/analysis_history_page.dart';
import '../core/theme/app_theme.dart';
import '../services/auth_service.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: Routes.login,
      page: () => const LoginPage(),
      transition: Transition.fadeIn,
      transitionDuration: AppTheme.animationNormal,
    ),

    GetPage(
      name: Routes.main,
      page: () => const HomePage(),
      transition: Transition.fadeIn,
      transitionDuration: AppTheme.animationNormal,
    ),

    GetPage(
      name: Routes.create,
      page: () => const CreatePage(),
      transition: Transition.rightToLeft,
      transitionDuration: AppTheme.animationNormal,
    ),

    GetPage(
      name: Routes.detail,
      page: () => DetailPage(),
      transition: Transition.rightToLeft,
      transitionDuration: AppTheme.animationNormal,
    ),

    GetPage(
      name: Routes.history,
      page: () => const HistoryPage(),
      transition: Transition.rightToLeft,
      transitionDuration: AppTheme.animationNormal,
    ),

    GetPage(
      name: Routes.coinStore,
      page: () => const CoinStorePage(),
      transition: Transition.rightToLeft,
      transitionDuration: AppTheme.animationNormal,
    ),

    GetPage(
      name: Routes.profile,
      page: () => const ProfilePage(),
      transition: Transition.rightToLeft,
      transitionDuration: AppTheme.animationNormal,
    ),

    GetPage(
      name: Routes.agreement,
      page: () => const AgreementPage(),
      transition: Transition.rightToLeft,
      transitionDuration: AppTheme.animationNormal,
    ),

    GetPage(
      name: Routes.feedback,
      page: () => const FeedbackPage(),
      transition: Transition.rightToLeft,
      transitionDuration: AppTheme.animationNormal,
    ),

    GetPage(
      name: Routes.upload,
      page: () => const UploadPage(),
      transition: Transition.rightToLeft,
      transitionDuration: AppTheme.animationNormal,
    ),

    GetPage(
      name: Routes.analysisHistory,
      page: () => const AnalysisHistoryPage(),
      transition: Transition.rightToLeft,
      transitionDuration: AppTheme.animationNormal,
    ),
  ];

  static String get initialRoute {
    return AuthService.to.isLoggedIn ? Routes.main : Routes.login;
  }
}
