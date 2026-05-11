import 'package:flutter/material.dart';
import 'package:crushi/crushi/core/router/app_routes.dart';
import 'package:crushi/crushi/core/router/router_state_manager.dart';
import 'package:crushi/crushi/data/models/stoic_card.dart';
import 'package:crushi/crushi/features/agreement/agreement_page.dart';
import 'package:crushi/crushi/features/coins/coins_page.dart';
import 'package:crushi/crushi/features/create/create_page.dart';
import 'package:crushi/crushi/features/detail/detail_page.dart';
import 'package:crushi/crushi/features/feedback/feedback_page.dart';
import 'package:crushi/crushi/features/history/history_page.dart';
import 'package:crushi/crushi/features/home/home_page.dart';
import 'package:crushi/crushi/features/login/login_page.dart';
import 'package:crushi/crushi/features/profile/profile_page.dart';

class GlobalRouter {
  GlobalRouter._();

  static final GlobalRouter _instance = GlobalRouter._();

  static GlobalRouter get I => _instance;

  RouterStateManager? _manager;

  void setRouterStateManager(RouterStateManager manager) {
    _manager = manager;
  }

  MaterialPage getLoginPage() {
    return const MaterialPage(
      key: ValueKey(Routes.login),
      child: LoginPage(),
    );
  }

  MaterialPage getHomePage() {
    return const MaterialPage(
      key: ValueKey(Routes.home),
      child: HomePage(),
    );
  }

  void goToDetail({required StoicCard card}) {
    _manager?.push(
      MaterialPage(
        key: ValueKey('${Routes.detail}_${card.hashCode}'),
        child: DetailPage(card: card),
      ),
    );
  }

  void goToProfile() {
    _manager?.push(
      const MaterialPage(
        key: ValueKey(Routes.profile),
        child: ProfilePage(),
      ),
    );
  }

  void goToHistory() {
    _manager?.push(
      const MaterialPage(
        key: ValueKey(Routes.history),
        child: HistoryPage(),
      ),
    );
  }

  void goToCreate() {
    _manager?.push(
      const MaterialPage(
        key: ValueKey(Routes.create),
        child: CreatePage(),
      ),
    );
  }

  void goToCoins() {
    _manager?.push(
      const MaterialPage(
        key: ValueKey(Routes.coins),
        child: CoinsPage(),
      ),
    );
  }

  void goToAgreement({required String url, required String title}) {
    _manager?.push(
      MaterialPage(
        key: ValueKey('${Routes.agreement}_$url'),
        child: AgreementPage(url: url, title: title),
      ),
    );
  }

  void goToFeedback() {
    _manager?.push(
      const MaterialPage(
        key: ValueKey(Routes.feedback),
        child: FeedbackPage(),
      ),
    );
  }

  void goToHome() {
    _manager?.to(getHomePage());
  }

  void goToLogin() {
    _manager?.to(getLoginPage());
  }

  void goBack() {
    _manager?.goBack();
  }

  void popToHome() {
    _manager?.popToHome();
  }
}
