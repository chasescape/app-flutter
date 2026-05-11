import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 本地存储服务
/// 封装SharedPreferences，提供统一的本地存储接口
class LocalStorage extends GetxService {
  SharedPreferences? _prefs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initPrefs();
  }

  /// 初始化 SharedPreferences
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 确保 _prefs 已初始化
  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('LocalStorage not initialized. Call onInit() first.');
    }
    return _prefs!;
  }

  // ==================== 字符串存储 ====================
  
  /// 保存字符串
  Future<bool> setString(String key, String value) async {
    return await prefs.setString(key, value);
  }

  /// 获取字符串
  String? getString(String key) {
    return prefs.getString(key);
  }

  // ==================== 布尔值存储 ====================
  
  /// 保存布尔值
  Future<bool> setBool(String key, bool value) async {
    return await prefs.setBool(key, value);
  }

  /// 获取布尔值
  bool getBool(String key, {bool defaultValue = false}) {
    return prefs.getBool(key) ?? defaultValue;
  }

  // ==================== 整数存储 ====================
  
  /// 保存整数
  Future<bool> setInt(String key, int value) async {
    return await prefs.setInt(key, value);
  }

  /// 获取整数
  int getInt(String key, {int defaultValue = 0}) {
    return prefs.getInt(key) ?? defaultValue;
  }

  // ==================== 双精度存储 ====================
  
  /// 保存双精度数
  Future<bool> setDouble(String key, double value) async {
    return await prefs.setDouble(key, value);
  }

  /// 获取双精度数
  double getDouble(String key, {double defaultValue = 0.0}) {
    return prefs.getDouble(key) ?? defaultValue;
  }

  // ==================== 列表存储 ====================
  
  /// 保存字符串列表
  Future<bool> setStringList(String key, List<String> value) async {
    return await prefs.setStringList(key, value);
  }

  /// 获取字符串列表
  List<String> getStringList(String key) {
    return prefs.getStringList(key) ?? [];
  }

  // ==================== 通用操作 ====================
  
  /// 删除指定key的数据
  Future<bool> remove(String key) async {
    return await prefs.remove(key);
  }

  /// 清除所有数据
  Future<bool> clear() async {
    return await prefs.clear();
  }

  /// 检查key是否存在
  bool containsKey(String key) {
    return prefs.containsKey(key);
  }

  /// 获取所有key
  Set<String> getKeys() {
    return prefs.getKeys();
  }

  // ==================== 业务相关的便捷方法 ====================
  
  /// 保存用户token
  Future<bool> saveToken(String token) async {
    return await setString('user_token', token);
  }

  /// 获取用户token
  String? getToken() {
    return getString('user_token');
  }

  /// 删除用户token
  Future<bool> removeToken() async {
    return await remove('user_token');
  }

  /// 保存用户信息
  Future<bool> saveUserInfo(String userInfo) async {
    return await setString('user_info', userInfo);
  }

  /// 获取用户信息
  String? getUserInfo() {
    return getString('user_info');
  }

  /// 删除用户信息
  Future<bool> removeUserInfo() async {
    return await remove('user_info');
  }

  // ==================== 业务数据清除 ====================

  /// 保存历史记录列表
  Future<bool> saveHistoryList(List<String> historyJsonList) async {
    return await setStringList('user_history_list', historyJsonList);
  }

  /// 获取历史记录列表
  List<String> getHistoryList() {
    return getStringList('user_history_list');
  }

  /// 删除历史记录
  Future<bool> removeHistoryList() async {
    return await remove('user_history_list');
  }

  /// 保存金币余额
  Future<bool> saveCoinsBalance(int coins) async {
    return await setInt('user_coins_balance', coins);
  }

  /// 获取金币余额
  int getCoinsBalance({int defaultValue = 0}) {
    return getInt('user_coins_balance', defaultValue: defaultValue);
  }

  /// 删除金币余额
  Future<bool> removeCoinsBalance() async {
    return await remove('user_coins_balance');
  }

  /// 清除所有用户数据（注销账户时使用）
  /// 包括：token、用户信息、历史记录、金币余额等
  Future<bool> clearAllUserData() async {
    try {
      // 清除用户认证相关
      await removeToken();
      await removeUserInfo();
      
      // 清除业务数据
      await removeHistoryList();
      await removeCoinsBalance();
      
      // 清除其他可能的用户数据 key（可根据需要扩展）
      final keysToRemove = <String>[
        'user_history_list',
        'user_coins_balance',
        'user_coins',  // CoinService使用的key
        'user_preferences',
        'user_settings',
        'is_premium',  // PurchaseService使用的key
        'encrypt_key', // 加密相关
        'app_config',  // 应用配置
        'last_analysis_time', // 分析相关
        'user_feedback_data', // 反馈数据
      ];
      
      for (final key in keysToRemove) {
        if (containsKey(key)) {
          await remove(key);
        }
      }
      
      // 清除所有以 'user_' 开头的key（兜底清理）
      final allKeys = getKeys();
      for (final key in allKeys) {
        if (key.startsWith('user_') || key.startsWith('app_') || key.startsWith('cache_')) {
          await remove(key);
        }
      }
      
      return true;
    } catch (e) {
      print('清除用户数据失败: $e');
      return false;
    }
  }
}