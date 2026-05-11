import 'package:flira/flira/app/network/core_services.dart';
import 'package:flira/flira/app/modules/nav/flira_state.dart';
import 'package:get/get.dart';

class ProfileLogic extends GetxController {
  int get coins => FliraState.coins.value;

  void addCoins(int amount) {
    FliraState.addCoins(amount);
  }

  Future<void> logout() async {
    try {
      await CoreServices.instance.authApi.logout();
    } catch (_) {
      // ignore
    }
  }

  Future<void> deleteAccount() async {
    await CoreServices.instance.authApi.deleteAccount();

    // 仅注销账号时清理本地业务数据
    FliraState.clearUserDataForDeleteAccount();

    // 清除本地登录态
    CoreServices.instance.config.authToken = null;
  }
}
