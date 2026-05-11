import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:zeria/zeria/interface.dart';
import 'package:zeria/zeria/models/app_models.dart';
import 'package:zeria/zeria/constants/app_constants.dart';
import 'package:zeria/zeria/data/models/spark_result.dart';
import 'package:zeria/zeria/services/coins_manager.dart';
import 'package:zeria/zeria/services/image_store.dart';

// App Service - State Management with GetX
class AppService extends GetxController {
  static AppService get to => Get.find();

  // Observables
  final Rx<User?> currentUser = User.defaultUser.obs;
  final RxList<HistoryItem> historyItems = <HistoryItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  SharedPreferences? _prefs;

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  // Initialize SharedPreferences
  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    // Initialize CoinsManager
    await CoinsManager.instance.init();
    await ImageStore.instance.init();
  }

  // Load user data from storage
  Future<void> _loadUserData() async {
    final prefs = _prefs;
    if (prefs == null) return;
    try {
      final userJson = prefs.getString(AppConstants.keyUserName);
      if (userJson != null) {
        final userData = jsonDecode(userJson);
        final loadedUser = User.fromJson(userData);
        // Migration: older builds used "Inspire User" as the default name.
        if (loadedUser.name == 'Inspire User') {
          currentUser.value = loadedUser.copyWith(name: 'Zeria');
          _saveUserData();
        } else {
          currentUser.value = loadedUser;
        }
      }

      final historyJson = prefs.getString(AppConstants.keyHistory);
      if (historyJson != null) {
        final historyList = jsonDecode(historyJson) as List;
        historyItems.value = historyList
            .map((item) => HistoryItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _bootstrap() async {
    await _initPrefs();
    await _loadUserData();
  }

  // Save user data to storage
  Future<void> _saveUserData() async {
    final prefs = _prefs;
    if (prefs == null) return;
    try {
      await prefs.setString(
        AppConstants.keyUserName,
        jsonEncode(currentUser.value?.toJson()),
      );
      await prefs.setString(
        AppConstants.keyHistory,
        jsonEncode(historyItems.map((item) => item.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Error saving user data: $e');
    }
  }

  // Get current coins from CoinsManager
  int get currentCoins => CoinsManager.instance.currentCoins;

  // Update coins (deprecated - use CoinsManager directly)
  @Deprecated('Use CoinsManager.instance.addCoins() instead')
  void updateCoins(int amount) {
    CoinsManager.instance.addCoins(amount);
  }

  // Check if user has enough coins (deprecated - use CoinsManager directly)
  @Deprecated('Use CoinsManager.instance.isEnough() instead')
  bool hasEnoughCoins(int cost) {
    return CoinsManager.instance.isEnough(cost);
  }

  // Deduct coins (deprecated - use CoinsManager directly)
  @Deprecated('Use CoinsManager.instance.subCoins() instead')
  Future<bool> deductCoins(int cost) {
    return CoinsManager.instance.subCoins(cost);
  }

  // Add history item
  void addHistoryItem(HistoryItem item) {
    historyItems.insert(0, item);
    _saveUserData();
  }

  // Delete history item
  void deleteHistoryItem(String id) {
    final index = historyItems.indexWhere((item) => item.id == id);
    if (index < 0) return;
    final removed = historyItems.removeAt(index);
    ImageStore.instance.deleteIfManaged(removed.imageUrl);
    _saveUserData();
  }

  // Clear all data
  Future<void> clearAllData() async {
    currentUser.value = User.defaultUser;
    for (final item in historyItems) {
      await ImageStore.instance.deleteIfManaged(item.imageUrl);
    }
    historyItems.clear();
    await _prefs?.clear();
    await CoinsManager.instance.clear();
    Interface().authToken = null;
  }

  /// Sign out without clearing local user/history/coins.
  /// "Delete account" should use [clearAllData] instead.
  Future<void> signOut() async {
    Interface().authToken = null;
    // Keep local data as-is.
  }

  // Get history grouped by date
  Map<String, List<HistoryItem>> get groupedHistory {
    final grouped = <String, List<HistoryItem>>{};
    for (final item in historyItems) {
      final group = item.dateGroup;
      grouped[group] = [...grouped[group] ?? [], item];
    }
    return grouped;
  }

  // Generate mock image (simulated AI generation)
  Future<String> generateImage(CreateParams params) async {
    isLoading.value = true;

    // Simulate API call
    await Future.delayed(const Duration(seconds: 3));

    isLoading.value = false;

    // Return mock image URL
    // In real app, this would be the actual generated image URL
    return 'https://picsum.photos/${params.destination.hashCode % 1000}/600/800';
  }

  // Mock API call for create
  Future<HistoryItem?> createInspiration(CreateParams params) async {
    if (!CoinsManager.instance.isEnough(AppConstants.createCostCoins)) {
      errorMessage.value = 'Not enough coins';
      return null;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Deduct coins
      await CoinsManager.instance.subCoins(AppConstants.createCostCoins);

      // Generate image
      final imageUrl = await generateImage(params);

      // Create history item
      final item = HistoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        destination: params.destination,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        params: params,
      );

      // Add to history
      addHistoryItem(item);

      return item;
    } catch (e) {
      errorMessage.value = 'Generation failed: $e';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// 添加 SparkFlow 分析结果到历史记录
  HistoryItem addSparkResult(SparkResult sparkResult) {
    final historyItem = HistoryItem.fromSparkResult(sparkResult);
    addHistoryItem(historyItem);
    return historyItem;
  }

  /// 根据 ID 获取 SparkFlow 数据
  SparkResult? getSparkResultById(String id) {
    final item = historyItems.firstWhereOrNull((i) => i.id == id);
    if (item != null && item.sparkResultData != null) {
      try {
        return SparkResult.fromJson(item.sparkResultData!);
      } catch (e) {
        debugPrint('Error parsing SparkResult: $e');
      }
    }
    return null;
  }

  /// 获取所有包含 SparkFlow 数据的历史记录
  List<HistoryItem> get sparkHistoryItems {
    return historyItems.where((item) => item.hasSparkData).toList();
  }
}
