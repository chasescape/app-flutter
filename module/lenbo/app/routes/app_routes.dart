import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lenbo/lenbo/features/login/login_page.dart';
import 'package:lenbo/lenbo/features/home/home_page.dart';
import 'package:lenbo/lenbo/features/create/create_page.dart';
import 'package:lenbo/lenbo/features/history/history_page.dart';
import 'package:lenbo/lenbo/features/profile/profile_page.dart';
import 'package:lenbo/lenbo/features/coin_store/coin_store_page.dart';
import 'package:lenbo/lenbo/features/detail/detail_page.dart';
import 'package:lenbo/lenbo/features/agreement/agreement_page.dart';
import 'package:lenbo/lenbo/features/feedback/feedback_page.dart';
import 'package:lenbo/lenbo/interface.dart';
import 'package:lenbo/lenbo/data/models/plant_analysis.dart';

class AppRoutes {
  AppRoutes._();

  static const String main = '/';
  static const String login = '/login';
  static const String create = '/create';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String coinStore = '/coin_store';
  static const String detail = '/detail';
  static const String agreement = '/agreement';
  static const String feedback = '/feedback';

  static void toMain() => Get.offAllNamed(main);

  static void toLogin() => Get.offAllNamed(login);

  static void toCreate() => Get.toNamed(create);

  static void toHistory() => Get.toNamed(history);

  static void toProfile() => Get.toNamed(profile);

  static void toCoinStore() => Get.toNamed(coinStore);

  static void toDetail(PlantAnalysis plant) {
    Get.toNamed(detail, arguments: plant);
  }

  static void toAgreement(String title, String url) {
    Get.to(
      () => AgreementPage(title: title, url: url),
      transition: Transition.cupertino,
    );
  }

  static void toFeedback() => Get.to(
        () => const FeedbackPage(),
        transition: Transition.cupertino,
      );

  static String? getAgreementTitle() {
    return Get.arguments?['title'] as String?;
  }

  static String? getAgreementUrl() {
    return Get.arguments?['url'] as String?;
  }

  static void back() => Get.back();
}

class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (Interface().authToken == null) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}

class AppPages {
  AppPages._();

  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.main,
      page: () => const HomePage(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: AppRoutes.create,
      page: () => const CreatePage(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.history,
      page: () => const HistoryPage(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.coinStore,
      page: () => const CoinStorePage(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.detail,
      page: () => const DetailPage(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.agreement,
      page: () => const AgreementPage(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.feedback,
      page: () => const FeedbackPage(),
      transition: Transition.cupertino,
    ),
  ];
}
