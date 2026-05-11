import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vesper/vesper/app/data/cheer_history_store.dart';
import 'package:vesper/vesper/app/data/coins_wallet_store.dart';
import 'package:vesper/vesper/app/network/auth_service.dart';
import 'package:vesper/vesper/app/routes/app_routes.dart';

class ProfileLogic extends GetxController {
  final RxBool isLoading = false.obs;

  void onRecharge() {
    Get.toNamed(AppRoutes.coins);
  }

  void onPrivacy() {
    Get.toNamed('${AppRoutes.privacyPolicy}/privacy');
  }

  void onTerms() {
    Get.toNamed('${AppRoutes.privacyPolicy}/terms');
  }

  /// 退出登录
  Future<void> onLogout() async {
    try {
      isLoading.value = true;
      final result = await AuthService.ins.logout();
      
      if (result['code'] == 0) {
        Get.snackbar('Success', 'Logged out successfully');
        // 跳转到登录页
        Get.offAllNamed(AppRoutes.login);
      } else {
        final msg = result['msg'] ?? 'Logout failed';
        Get.snackbar('Error', msg);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// 注销账户
  Future<void> onDeleteAccount() async {
    final confirmed = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Delete Account'),
            content: const Text(
              'This will remove your local coins and training history. Continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Color(0xFFFF4FA5)),
                ),
              ),
            ],
          ),
          barrierDismissible: false,
        ) ??
        false;
    if (!confirmed) return;
    try {
      isLoading.value = true;
      final result = await AuthService.ins.deleteAccount();
      
      if (result['code'] == 0) {
        Get.snackbar('Success', 'Account deleted successfully');
        final wallet = Get.isRegistered<CoinsWalletStore>()
            ? Get.find<CoinsWalletStore>()
            : Get.put(CoinsWalletStore(), permanent: true);
        final history = Get.isRegistered<CheerHistoryStore>()
            ? Get.find<CheerHistoryStore>()
            : Get.put(CheerHistoryStore(), permanent: true);
        await wallet.clear();
        await history.clear();
        // 跳转到登录页
        Get.offAllNamed(AppRoutes.login);
      } else {
        final msg = result['msg'] ?? 'Delete account failed';
        Get.snackbar('Error', msg);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onFeedback() {
    Get.toNamed(AppRoutes.feedback);
  }
}
