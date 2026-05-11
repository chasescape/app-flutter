import 'package:get/get.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/coin_service.dart';
import '../../core/services/encrypt_service.dart';
import '../../core/services/purchase_service.dart';
import '../../core/storage/local_storage.dart';
import '../../data/repositories/auth_repository.dart';
import '../../routes/app_pages.dart';
import '../history/history_logic.dart';

class ProfileLogic extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final EncryptService _encryptService = Get.find<EncryptService>();
  final LocalStorage _localStorage = Get.find<LocalStorage>();
  final CoinService _coinService = Get.find<CoinService>();

  RxBool isLoggingOut = false.obs;
  RxBool isDeletingAccount = false.obs;

  // 获取金币数量
  int get coins => _coinService.coins;
  RxInt get coinsRx => _coinService.coinsRx;

  /// 退出登录：调登出接口后跳转登录页
  Future<void> logout() async {
    if (isLoggingOut.value) return;
    isLoggingOut.value = true;
    try {
      // 1. 调用登出接口
      print('ProfileLogic.logout: 开始调用登出接口...');
      await _authService.logout();
      print('ProfileLogic.logout: 登出接口调用成功');
      
      // 2. 跳转登录页
      Get.offAllNamed(Routes.login);
      Get.snackbar('Logged Out', 'You have been logged out successfully', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      print('ProfileLogic.logout: 登出失败: $e');
      Get.snackbar('Logout Failed', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoggingOut.value = false;
    }
  }

  /// 注销账户：调删除账户接口后清除所有数据并跳转登录页
  /// 清除内容：登录状态、历史记录、金币余额、加密配置等所有用户数据
  Future<void> deleteAccount() async {
    if (isDeletingAccount.value) return;
    isDeletingAccount.value = true;
    try {
      // 1. 确保有 encryptKey（删除账户接口需要加密）
      if (_encryptService.needRefreshConfig()) {
        print('ProfileLogic.deleteAccount: encryptKey 不存在，先获取配置...');
        final configOk = await _encryptService.getAppConfig();
        if (!configOk) {
          throw Exception('Failed to get app config');
        }
      }
      
      // 2. 调用删除账户接口
      print('ProfileLogic.deleteAccount: 开始调用删除账户接口...');
      await _authRepository.deleteAccount();
      print('ProfileLogic.deleteAccount: 删除账户接口调用成功');
      
      // 3. 清除所有用户数据
      print('ProfileLogic.deleteAccount: 开始清除所有用户数据...');
      await _localStorage.clearAllUserData();
      print('ProfileLogic.deleteAccount: 用户数据已清除');
      
      // 4. 清理内存中的业务数据
      print('ProfileLogic.deleteAccount: 开始清理内存中的业务数据...');
      
      // 清理历史记录（如果存在）
      if (Get.isRegistered<HistoryLogic>()) {
        final historyLogic = Get.find<HistoryLogic>();
        historyLogic.clearAll();
        print('ProfileLogic.deleteAccount: 历史记录已清理');
      }
      
      // 重置金币服务
      await _coinService.resetCoins();
      print('ProfileLogic.deleteAccount: 金币数据已重置');
      
      // 清除购买状态（如果存在）
      if (Get.isRegistered<PurchaseService>()) {
        final purchaseService = Get.find<PurchaseService>();
        purchaseService.clearPurchaseStatus();
        print('ProfileLogic.deleteAccount: 购买状态已清理');
      }
      
      // 5. 清除认证状态和加密配置
      _authService.clearAuthState();
      _encryptService.clearEncryptConfig();
      print('ProfileLogic.deleteAccount: 认证状态和加密配置已清除');
      
      // 6. 跳转登录页
      Get.offAllNamed(Routes.login);
      Get.snackbar('Account Deleted', 'Account has been deleted, all data cleared', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      print('ProfileLogic.deleteAccount: 注销账户失败: $e');
      Get.snackbar('Delete Failed', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isDeletingAccount.value = false;
    }
  }
}
