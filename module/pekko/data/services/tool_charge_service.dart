import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/user_data.dart';
import 'storage_service.dart';
import 'coins_manager.dart';

/// Tool charge service for managing tool execution fees
///
/// This service handles:
/// - Balance checking before tool execution
/// - Coin deduction after successful tool completion
/// - Insufficient balance handling
class ToolChargeService extends GetxService {
  static ToolChargeService get to => Get.find();

  final StorageService _storage = StorageService.to;
  final CoinsManager _coinsManager = CoinsManager.to;

  /// User data cache
  UserData? _cachedUserData;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  /// Load user data from storage
  Future<void> _loadUserData() async {
    _cachedUserData = await _storage.getUserData();
  }

  /// Refresh cached user data
  Future<void> refreshUserData() async {
    await _loadUserData();
  }

  /// Get current user data
  Future<UserData> getUserData() async {
    if (_cachedUserData == null) {
      await _loadUserData();
    }
    return _cachedUserData!;
  }

  /// Check if user has enough coins for tool execution
  ///
  /// [cost] The fixed cost in coins for using this tool
  /// Returns true if user has sufficient balance
  Future<bool> hasEnoughCoins(int cost) async {
    if (cost <= 0) return true;

    await _loadUserData();
    return _cachedUserData!.coins >= cost;
  }

  /// Get current coin balance
  ///
  /// Returns the current number of coins the user has
  Future<int> getCurrentBalance() async {
    await _loadUserData();
    return _cachedUserData!.coins;
  }

  /// Deduct coins after successful tool execution
  ///
  /// [cost] The fixed cost in coins to deduct
  /// Returns true if deduction was successful, false if insufficient coins
  ///
  /// Important: Only call this AFTER the tool has successfully completed
  /// and the result has been saved/processed
  Future<bool> deductCoins(int cost) async {
    if (cost <= 0) return true;

    // Check balance first
    if (!await hasEnoughCoins(cost)) {
      debugPrint('ToolChargeService: Insufficient coins for deduction');
      return false;
    }

    // Perform deduction
    final success = await _coinsManager.subCoins(cost);

    if (success) {
      // Refresh cache after deduction
      await _loadUserData();
      debugPrint('ToolChargeService: Successfully deducted $cost coins');
    } else {
      debugPrint('ToolChargeService: Failed to deduct $cost coins');
    }

    return success;
  }

  /// Execute tool with automatic charge handling
  ///
  /// This is a convenience method that combines balance checking,
  /// tool execution, and coin deduction in one call.
  ///
  /// [cost] The fixed cost in coins
  /// [toolExecutor] The async function that executes the tool logic
  /// [onInsufficientBalance] Callback when balance is insufficient
  ///
  /// Returns the result from [toolExecutor] if successful, null if failed
  ///
  /// Usage example:
  /// ```dart
  /// final result = await ToolChargeService.to.executeTool(
  ///   cost: 50,
  ///   toolExecutor: () async {
  ///     // Your tool logic here
  ///     return await someAsyncOperation();
  ///   },
  ///   onInsufficientBalance: () {
  ///     _showInsufficientBalanceDialog();
  ///   },
  /// );
  /// ```
  Future<T?> executeTool<T>({
    required int cost,
    required Future<T> Function() toolExecutor,
    VoidCallback? onInsufficientBalance,
  }) async {
    // Check balance first
    if (!await hasEnoughCoins(cost)) {
      onInsufficientBalance?.call();
      return null;
    }

    try {
      // Execute the tool
      final result = await toolExecutor();

      // Only deduct coins if tool execution succeeded
      // and result is not null (if T is nullable)
      if (result != null || !isNull<T>()) {
        final deducted = await deductCoins(cost);
        if (!deducted) {
          debugPrint('ToolChargeService: Tool succeeded but deduction failed');
          // This shouldn't happen since we checked balance above
          // but handle it gracefully
        }
      }

      return result;
    } catch (e) {
      // Tool execution failed - do NOT deduct coins
      debugPrint('ToolChargeService: Tool execution failed: $e');
      return null;
    }
  }

  /// Check if type T is nullable
  bool isNull<T>() {
    return null is T;
  }

  /// Calculate if user can afford tool cost
  ///
  /// [cost] The cost to check against
  /// Returns true if user can afford the tool
  Future<bool> canAfford(int cost) async {
    return await hasEnoughCoins(cost);
  }
}
