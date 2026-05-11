import 'package:flutter/foundation.dart';
import '../light_handle.dart';

class CoinsManager {
  CoinsManager._();

  static final CoinsManager _instance = CoinsManager._();
  static CoinsManager get instance => _instance;

  static const String _keyCoins = 'user_coins';
  static const int _defaultCoins = 100;

  final ValueNotifier<int> coinsNotifier = ValueNotifier(_defaultCoins);

  int get coins => coinsNotifier.value;

  /// 从持久化加载金币，在 LightHandle.readyToInit 后调用
  void loadFromStorage() {
    final saved = LightHandle.prefs?.getInt(_keyCoins);
    coinsNotifier.value = saved ?? _defaultCoins;
  }

  /// 增加金币
  Future<void> addCoins(int amount) async {
    if (amount <= 0) return;
    coinsNotifier.value += amount;
    await LightHandle.prefs?.setInt(_keyCoins, coinsNotifier.value);
  }

  /// 扣除金币，成功返回 true，余额不足返回 false
  Future<bool> subCoins(int amount) async {
    if (amount <= 0) return true;
    if (coinsNotifier.value < amount) return false;
    coinsNotifier.value -= amount;
    await LightHandle.prefs?.setInt(_keyCoins, coinsNotifier.value);
    return true;
  }

  /// 判断金币是否充足
  bool isEnough(int amount) => coinsNotifier.value >= amount;

  /// 清除金币数据（删除账号时调用）
  Future<void> clear() async {
    coinsNotifier.value = 0;
    await LightHandle.prefs?.remove(_keyCoins);
  }

  /// 格式化金币数字，添加千分位
  String formatCoins() {
    return _formatNumber(coinsNotifier.value);
  }

  static String _formatNumber(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
