import 'package:get/get.dart';
import 'package:paech/paech/app/module/deposit/deposit_binding.dart';
import 'package:paech/paech/app/module/deposit/deposit_view.dart';
import 'package:paech/paech/app/module/details/details_binding.dart';
import 'package:paech/paech/app/module/details/details_view.dart';
import 'package:paech/paech/app/module/feedback/feedback_binding.dart';
import 'package:paech/paech/app/module/feedback/feedback_view.dart';
import 'package:paech/paech/app/module/generate/generate_binding.dart';
import 'package:paech/paech/app/module/generate/generate_view.dart';
import 'package:paech/paech/app/module/history/history_binding.dart';
import 'package:paech/paech/app/module/history/history_view.dart';
import 'package:paech/paech/app/module/home/home_binding.dart';
import 'package:paech/paech/app/module/login/login_binding.dart';
import 'package:paech/paech/app/module/login/login_view.dart';
import 'package:paech/paech/app/module/nav/nav_binding.dart';
import 'package:paech/paech/app/module/nav/nav_view.dart';
import 'package:paech/paech/app/module/profile/profile_binding.dart';
import 'package:paech/paech/app/module/profile/profile_view.dart';
import 'package:paech/paech/app/module/protocol/protocol_binding.dart';
import 'package:paech/paech/app/module/protocol/protocol_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.login;

  static final routes = [
    GetPage(
      name: Routes.home,
      page: () => NavPage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.nav,
      page: () => NavPage(),
      binding: NavBinding(),
    ),
    GetPage(
      name: Routes.generate,
      page: () => GeneratePage(),
      binding: GenerateBinding(),
    ),
    GetPage(
      name: Routes.profile,
      page: () => ProfilePage(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.details,
      page: () => DetailsPage(),
      binding: DetailsBinding(),
    ),
    GetPage(
      name: Routes.feedback,
      page: () => FeedbackPage(),
      binding: FeedbackBinding(),
    ),
    GetPage(
      name: Routes.history,
      page: () => HistoryPage(),
      binding: HistoryBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.deposit,
      page: () => DepositPage(),
      binding: DepositBinding(),
    ),
    GetPage(
      name: Routes.protocol,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        final url = args?['url'] as String? ?? '';
        final title = args?['title'] as String?;
        return ProtocolPage(url: url, title: title);
      },
      binding: ProtocolBinding(),
    ),
  ];
}
