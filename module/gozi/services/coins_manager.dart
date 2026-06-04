import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Coins Manager - Global coin balance management with ValueNotifier
///
/// Key Features:
/// - Unified coin balance access point
/// - ValueNotifier for reactive updates
/// - SharedPreferences persistence
/// - Free uses management for achievement creation
class CoinsManager {
  CoinsManager._();

  static CoinsManager? _instance;
  static CoinsManager get instance {
    _instance ??= CoinsManager._();
    return _instance!;
  }

  /// Coin balance value notifier - listen for real-time updates
  final ValueNotifier<int> _balanceNotifier = ValueNotifier<int>(0);

  /// Free uses value notifier
  final ValueNotifier<int> _freeUsesNotifier = ValueNotifier<int>(3);

  /// Get balance value notifier
  ValueNotifier<int> get balanceNotifier => _balanceNotifier;

  /// Get free uses value notifier
  ValueNotifier<int> get freeUsesNotifier => _freeUsesNotifier;

  /// Get current balance
  int get balance => _balanceNotifier.value;

  /// Get free uses remaining
  int get freeUses => _freeUsesNotifier.value;

  /// Storage keys
  static const String _balanceKey = 'coin_balance';
  static const String _freeUsesKey = 'free_uses';

  /// Is initialized
  bool _isInitialized = false;

  /// Achievement creation cost
  static const int _creationCost = 50;

  /// Initialize manager - load from persistence
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedBalance = prefs.getInt(_balanceKey) ?? 100; // Default 100 coins
      final savedFreeUses = prefs.getInt(_freeUsesKey) ?? 3; // Default 3 free uses

      _balanceNotifier.value = savedBalance;
      _freeUsesNotifier.value = savedFreeUses;
      _isInitialized = true;
      print('CoinsManager: Initialized with balance: $savedBalance, free uses: $savedFreeUses');
    } catch (e) {
      print('CoinsManager: Initialization failed - $e');
      _balanceNotifier.value = 100; // Fallback default
      _freeUsesNotifier.value = 3;
      _isInitialized = true;
    }
  }

  /// Save data to persistence
  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_balanceKey, _balanceNotifier.value);
      await prefs.setInt(_freeUsesKey, _freeUsesNotifier.value);
      print('CoinsManager: Data saved - balance: ${_balanceNotifier.value}, free uses: ${_freeUsesNotifier.value}');
    } catch (e) {
      print('CoinsManager: Failed to save data - $e');
    }
  }

  /// Add coins - update balance and notify listeners
  ///
  /// This is called by PurchaseService after successful purchase
  Future<void> addCoins(int amount) async {
    if (amount <= 0) return;

    final oldValue = _balanceNotifier.value;
    _balanceNotifier.value += amount;
    await _saveData();

    print('CoinsManager: Added $amount coins ($oldValue -> ${_balanceNotifier.value})');
  }

  /// Subtract coins - deduct from balance
  ///
  /// Returns true if successful, false if insufficient balance
  Future<bool> subCoins(int amount) async {
    if (amount <= 0) return true;
    if (_balanceNotifier.value < amount) return false;

    final oldValue = _balanceNotifier.value;
    _balanceNotifier.value -= amount;
    await _saveData();

    print('CoinsManager: Subtracted $amount coins ($oldValue -> ${_balanceNotifier.value})');
    return true;
  }

  /// Check if has enough coins
  bool isEnough(int amount) {
    return _balanceNotifier.value >= amount;
  }

  /// Use free use - decrement free uses count
  ///
  /// Returns true if successful, false if no free uses remaining
  Future<bool> useFreeUse() async {
    if (_freeUsesNotifier.value <= 0) return false;

    final oldValue = _freeUsesNotifier.value;
    _freeUsesNotifier.value--;
    await _saveData();

    print('CoinsManager: Used free use ($oldValue -> ${_freeUsesNotifier.value})');
    return true;
  }

  /// Check if can create achievement (has coins or free uses)
  bool canCreateAchievement() {
    return _balanceNotifier.value >= _creationCost || _freeUsesNotifier.value > 0;
  }

  /// Get cost to create achievement (0 if has free uses, otherwise _creationCost)
  int getCreationCost() {
    return _freeUsesNotifier.value > 0 ? 0 : _creationCost;
  }

  /// Set balance directly (for testing or special cases)
  Future<void> setBalance(int amount) async {
    final oldValue = _balanceNotifier.value;
    _balanceNotifier.value = amount;
    await _saveData();

    print('CoinsManager: Balance set ($oldValue -> $amount)');
  }

  /// Set free uses directly (for testing or special cases)
  Future<void> setFreeUses(int amount) async {
    final oldValue = _freeUsesNotifier.value;
    _freeUsesNotifier.value = amount;
    await _saveData();

    print('CoinsManager: Free uses set ($oldValue -> $amount)');
  }

  /// Reset data to defaults (for testing)
  Future<void> resetData() async {
    _balanceNotifier.value = 100;
    _freeUsesNotifier.value = 3;
    await _saveData();

    print('CoinsManager: Data reset to defaults');
  }

  /// Clear all data - called when account is deleted
  ///
  /// This should be called when user deletes account or logs out
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_balanceKey);
      await prefs.remove(_freeUsesKey);
      _balanceNotifier.value = 100; // Reset to default
      _freeUsesNotifier.value = 3;
      print('CoinsManager: Data cleared');
    } catch (e) {
      print('CoinsManager: Failed to clear data - $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _balanceNotifier.dispose();
    _freeUsesNotifier.dispose();
    _isInitialized = false;
    print('CoinsManager: Disposed');
  }
}
