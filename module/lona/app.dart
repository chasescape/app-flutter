import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'bindings/app_binding.dart';
import 'features/login/login_page.dart';
import 'features/home/home_page.dart';
import 'features/create/create_page.dart';
import 'features/result/result_page.dart';
import 'features/history/history_page.dart';
import 'features/settings/settings_page.dart';
import 'features/coin_store/coin_store_page.dart';
import 'features/agreement/agreement_page.dart';
import 'features/feedback/feedback_page.dart';
import 'features/compose_detail/compose_detail_page.dart';
import 'features/image_edit_create/image_edit_create_page.dart';
import 'features/image_edit_result/image_edit_result_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ComposePilot',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      initialBinding: AppBinding(),
      initialRoute: AppRoutes.login,
      getPages: [
        GetPage(
          name: AppRoutes.login,
          page: () => const LoginPage(),
          binding: LoginBinding(),
        ),
        GetPage(
          name: AppRoutes.home,
          page: () => const HomePage(),
          binding: HomeBinding(),
        ),
        GetPage(
          name: AppRoutes.create,
          page: () => const CreatePage(),
          binding: CreateBinding(),
        ),
        GetPage(
          name: AppRoutes.result,
          page: () => const ResultPage(),
          binding: ResultBinding(),
        ),
        GetPage(
          name: AppRoutes.history,
          page: () => const HistoryPage(),
          binding: HistoryBinding(),
        ),
        GetPage(
          name: AppRoutes.settings,
          page: () => const SettingsPage(),
          binding: SettingsBinding(),
        ),
        GetPage(
          name: AppRoutes.coinStore,
          page: () => const CoinStorePage(),
          binding: CoinStoreBinding(),
        ),
        GetPage(
          name: AppRoutes.agreement,
          page: () => const AgreementPage(),
        ),
        GetPage(
          name: AppRoutes.feedback,
          page: () => const FeedbackPage(),
          binding: FeedbackBinding(),
        ),
        GetPage(
          name: AppRoutes.composeDetail,
          page: () => const ComposeDetailPage(),
          binding: ComposeDetailBinding(),
        ),
        GetPage(
          name: AppRoutes.imageEditCreate,
          page: () => const ImageEditCreatePage(),
          binding: ImageEditCreateBinding(),
        ),
        GetPage(
          name: AppRoutes.imageEditResult,
          page: () => const ImageEditResultPage(),
        ),
      ],
    );
  }
}
