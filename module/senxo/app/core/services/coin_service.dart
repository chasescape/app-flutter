import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoinService extends GetxController {
  static const String _coinKey = 'user_coins';
  static const int _initialCoins = 100; // Initial coins set to 100
  static const int _analysisPrice = 100; // Coins consumed per analysis

  // Reactive coin count
  final RxInt _coins = _initialCoins.obs;
  
  int get coins => _coins.value;
  RxInt get coinsRx => _coins;

  @override
  void onInit() {
    super.onInit();
    _loadCoins();
  }

  /// Load coin count from local storage
  Future<void> _loadCoins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCoins = prefs.getInt(_coinKey);
      if (savedCoins != null) {
        _coins.value = savedCoins;
        print('CoinService: Loaded coins from storage: $savedCoins');
      } else {
        // First time use, set initial coins
        _coins.value = _initialCoins;
        await _saveCoins();
        print('CoinService: First time use, set initial coins: $_initialCoins');
      }
    } catch (e) {
      print('CoinService: Error loading coins: $e');
      _coins.value = _initialCoins;
    }
  }

  /// Save coin count to local storage
  Future<void> _saveCoins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_coinKey, _coins.value);
      print('CoinService: Saved coins to storage: ${_coins.value}');
    } catch (e) {
      print('CoinService: Error saving coins: $e');
    }
  }

  /// Check if there are enough coins for analysis
  bool canAnalyze() {
    return _coins.value >= _analysisPrice;
  }

  /// Consume coins for analysis
  Future<bool> consumeCoinsForAnalysis() async {
    if (!canAnalyze()) {
      Get.snackbar(
        'Insufficient Coins',
        'You need at least $_analysisPrice coins to perform analysis',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[900],
        mainButton: TextButton(
          onPressed: () {
            Get.back(); // 关闭snackbar
            Get.toNamed('/coins'); // 跳转到充值页面
          },
          child: Text(
            'Recharge',
            style: TextStyle(
              color: Colors.orange[900],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
      return false;
    }

    _coins.value -= _analysisPrice;
    await _saveCoins();
    
    print('CoinService: Consumed $_analysisPrice coins for analysis. Remaining: ${_coins.value}');
    
    Get.snackbar(
      'Analysis Started',
      '$_analysisPrice coins consumed. Remaining: ${_coins.value}',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
    
    return true;
  }

  /// Add coins (after purchase)
  Future<void> addCoins(int amount) async {
    _coins.value += amount;
    await _saveCoins();
    
    print('CoinService: Added $amount coins. Total: ${_coins.value}');
    
    Get.snackbar(
      'Purchase Successful',
      '+$amount coins added. Total: ${_coins.value}',
      snackPosition: SnackPosition.TOP,
    );
  }

  /// Refund coins for failed analysis
  Future<void> refundCoinsForFailedAnalysis() async {
    _coins.value += _analysisPrice;
    await _saveCoins();
    
    print('CoinService: Refunded $_analysisPrice coins for failed analysis. Total: ${_coins.value}');
    
    Get.snackbar(
      'Analysis Failed - Coins Refunded',
      '$_analysisPrice coins have been refunded to your account. Total: ${_coins.value}',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  /// Get analysis price
  int get analysisPrice => _analysisPrice;

  /// Reset coins (for testing)
  Future<void> resetCoins() async {
    _coins.value = _initialCoins;
    await _saveCoins();
    print('CoinService: Reset coins to $_initialCoins');
  }
}