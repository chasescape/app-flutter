import 'package:get/get.dart';
import 'package:mimiu/mimiu/app/modules/coins/coins_binding.dart';
import 'package:mimiu/mimiu/app/modules/coins/coins_view.dart';
import 'package:mimiu/mimiu/app/modules/details/details_binding.dart';
import 'package:mimiu/mimiu/app/modules/details/details_view.dart';
import 'package:mimiu/mimiu/app/modules/feedback/feedback_binding.dart';
import 'package:mimiu/mimiu/app/modules/feedback/feedback_view.dart';
import 'package:mimiu/mimiu/app/modules/home/home_binding.dart';
import 'package:mimiu/mimiu/app/modules/home/home_view.dart';
import 'package:mimiu/mimiu/app/modules/login/login_binding.dart';
import 'package:mimiu/mimiu/app/modules/login/login_view.dart';
import 'package:mimiu/mimiu/app/modules/nav/nav_binding.dart';
import 'package:mimiu/mimiu/app/modules/nav/nav_view.dart';
import 'package:mimiu/mimiu/app/modules/upload/upload_binding.dart';
import 'package:mimiu/mimiu/app/modules/upload/upload_view.dart';
import 'package:mimiu/mimiu/app/modules/agreement/agreement_view.dart';
import 'package:mimiu/mimiu/app/modules/category_photos/category_photos_view.dart';

import 'app_routes.dart';

class AppPages {
  static const String initial = AppRoutes.login;

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
      page: () => HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.upload,
      page: () => const UploadPage(),
      binding: UploadBinding(),
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
      name: AppRoutes.details,
      page: () => DetailsPage(),
      binding: DetailsBinding(),
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const AgreementPage(),
    ),
    GetPage(
      name: AppRoutes.termsOfService,
      page: () => const AgreementPage(),
    ),
    GetPage(
      name: AppRoutes.categoryPhotos,
      page: () => const CategoryPhotosPage(),
    ),
  ];
}
