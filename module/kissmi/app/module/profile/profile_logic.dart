import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../interface.dart';
import '../../network/api/auth_api.dart';
import '../../network/core/app_env_config_adapter.dart';
import '../../network/core_services.dart';
import '../../routes/app_routes.dart';
import '../../widget/loading_overlay.dart';
import '../../data/coin_store.dart';
import '../../data/chat_store.dart';
import '../../data/daily_tip_store.dart';
import '../../data/mood_store.dart';
import '../coins/coins_logic.dart';

class ProfileLogic extends GetxController {
  late final AppEnvConfigAdapter _config;
  late final AuthApi _authApi;
  final RxInt balance = 0.obs;

  @override
  void onInit() {
    final core = CoreServices.instance;
    _config = core.config as AppEnvConfigAdapter;
    _authApi = core.authApi;
    _loadBalance();
    _listenToCoinsChanges();
    super.onInit();
  }

  Future<void> _loadBalance() async {
    final int stored = await CoinStore.loadBalance();
    balance.value = stored;
  }

  void _listenToCoinsChanges() {
    try {
      final coinsLogic = Get.find<CoinsLogic>();
      ever(coinsLogic.balance, (int newBalance) {
        balance.value = newBalance;
      });
    } catch (_) {
      // CoinsLogic not yet initialized, will load balance on demand
    }
  }

  void confirmLogout() {
    _showConfirmDialog(
      title: 'Logout',
      message: 'Are you sure you want to log out?',
      confirmText: 'Logout',
      icon: Icons.logout_rounded,
      onConfirm: _logout,
    );
  }

  void confirmDeleteAccount() {
    _showConfirmDialog(
      title: 'Delete Account',
      message: 'This will permanently remove your account. Continue?',
      confirmText: 'Delete',
      icon: Icons.delete_outline_rounded,
      onConfirm: _deleteAccount,
    );
  }

  Future<void> _logout() async {
    LoadingOverlay.show();
    try {
      await _authApi.logout();
    } catch (_) {
      // Ignore API error and still clear local auth state.
    } finally {
      _clearAuthState();
      LoadingOverlay.hide();
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<void> _deleteAccount() async {
    LoadingOverlay.show();
    try {
      await _authApi.deleteAccount();
    } catch (_) {
      // Ignore API error and still clear local auth state.
    } finally {
      await _clearLocalData();
      _clearAuthState();
      LoadingOverlay.hide();
      Get.offAllNamed(AppRoutes.login);
    }
  }

  void _clearAuthState() {
    _config.authToken = null;
    Interface().authToken = null;
    Interface().onAuthTokenRemoved();
  }

  Future<void> _clearLocalData() async {
    await ChatStore.clear();
    await CoinStore.clear();
    await DailyTipStore.clear();
    await MoodStore.clear();
  }

  void _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    required IconData icon,
    required Future<void> Function() onConfirm,
  }) {
    final ctx = Get.context;
    if (ctx == null) {
      Get.defaultDialog<void>(
        title: title,
        middleText: message,
        textCancel: 'Cancel',
        textConfirm: confirmText,
        confirmTextColor: const Color(0xFFFFFFFF),
        onConfirm: () {
          Get.back<void>();
          onConfirm();
        },
      );
      return;
    }

    final theme = Theme.of(ctx);

    showDialog<void>(
      context: ctx,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          titlePadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.fromLTRB(24, 22, 24, 16),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 4),
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[Color(0xFFEED0F2), Color(0xFFFE2D70)],
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Color(0x338F6AD8),
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 26,
                    color: const Color(0xFF4A2741),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7C7785),
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 6),
              DefaultTextStyle(
                style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 14,
                      color: const Color(0xFF7C7785),
                      height: 1.4,
                      decoration: TextDecoration.none,
                    ) ??
                    const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7C7785),
                      height: 1.4,
                      decoration: TextDecoration.none,
                    ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFFE6E0EF),
                        width: 1,
                      ),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF242129),
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFE2D70),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(dialogCtx).pop();
                      onConfirm();
                    },
                    child: Text(confirmText),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

}
