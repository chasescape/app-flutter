import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../singletons/coins_manager.dart';
import '../router/app_routes.dart';

/// Tool Execution Result
class ToolExecutionResult<T> {
  final T? data;
  final bool success;
  final String? errorMessage;

  ToolExecutionResult({
    this.data,
    required this.success,
    this.errorMessage,
  });

  factory ToolExecutionResult.success(T data) {
    return ToolExecutionResult(
      data: data,
      success: true,
    );
  }

  factory ToolExecutionResult.failure(String message) {
    return ToolExecutionResult(
      success: false,
      errorMessage: message,
    );
  }
}

/// Base class for all tool services with coin deduction
/// 工具类服务基类 - 统一扣费逻辑
abstract class ToolService<T> {
  /// Fixed cost per execution - 设置后运行时不可修改
  final int costPerUse;

  /// Tool name for display
  final String toolName;

  ToolService({
    required this.costPerUse,
    required this.toolName,
  });

  /// Get CoinsManager instance
  CoinsManager get _coinsManager => CoinsManager.instance;

  /// Execute tool with coin deduction
  /// 执行工具并处理扣费
  Future<ToolExecutionResult<T>> execute(BuildContext context) async {
    // Step 1: Check balance before execution
    final canExecute = await _checkBalance(context);
    if (!canExecute) {
      return ToolExecutionResult.failure('Insufficient balance');
    }

    // Step 2: Execute the tool logic
    final result = await executeTool();

    // Step 3: Only deduct coins on successful completion
    if (result.success) {
      await _deductCoins();
    }

    return result;
  }

  /// Check if user has enough coins
  /// 检查余额是否足够
  Future<bool> _checkBalance(BuildContext context) async {
    final currentCoins = await _coinsManager.getCoins();

    if (currentCoins < costPerUse) {
      _showInsufficientBalanceDialog(context);
      return false;
    }

    return true;
  }

  /// Show insufficient balance dialog
  /// 显示余额不足对话框
  void _showInsufficientBalanceDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Insufficient Coins'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This tool requires $costPerUse coins per use.'),
            const SizedBox(height: 8),
            const Text('Would you like to purchase more coins?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              AppRoutes.toCoinStore();
            },
            child: const Text('Get Coins'),
          ),
        ],
      ),
    );
  }

  /// Deduct coins after successful execution
  /// 成功后扣费
  Future<void> _deductCoins() async {
    final success = await _coinsManager.subCoins(costPerUse);
    if (!success) {
      debugPrint('[ToolService] Warning: Coin deduction failed but operation completed');
    }
  }

  /// Abstract method: Implement actual tool logic here
  /// 子类实现具体的工具逻辑
  /// @return ToolExecutionResult with success status and data
  Future<ToolExecutionResult<T>> executeTool();

  /// Get cost description for UI display
  /// 获取费用描述文案
  String get costDescription => 'Cost: $costPerUse coins per use';

  /// Check if user can afford the tool
  /// 检查用户是否负担得起（用于UI提前判断）
  Future<bool> canAfford() async {
    final currentCoins = await _coinsManager.getCoins();
    return currentCoins >= costPerUse;
  }

  /// Get current user balance
  /// 获取当前余额（用于UI展示）
  Future<int> getCurrentBalance() async {
    return await _coinsManager.getCoins();
  }
}

/// Example: Image Background Removal Tool Service
/// 示例：图片去背景工具服务
class ImageBackgroundRemovalService extends ToolService<String> {
  ImageBackgroundRemovalService() : super(
    costPerUse: 42, // Fixed cost determined at code generation time
    toolName: 'Background Remover',
  );

  @override
  Future<ToolExecutionResult<String>> executeTool() async {
    try {
      // Simulate API call or processing
      await Future.delayed(const Duration(seconds: 2));

      // Replace with actual tool logic
      // final result = await removeBackgroundApiCall();

      // Success - return processed image path
      return ToolExecutionResult.success('/path/to/processed/image.png');
    } catch (e) {
      // Failure - no coins will be deducted
      return ToolExecutionResult.failure('Processing failed: $e');
    }
  }
}

/// Example: Image Compression Tool Service
/// 示例：图片压缩工具服务
class ImageCompressionService extends ToolService<String> {
  ImageCompressionService() : super(
    costPerUse: 38,
    toolName: 'Image Compressor',
  );

  @override
  Future<ToolExecutionResult<String>> executeTool() async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      // Success
      return ToolExecutionResult.success('/path/to/compressed/image.jpg');
    } catch (e) {
      return ToolExecutionResult.failure('Compression failed: $e');
    }
  }
}

/// Example: Text Summary Tool Service
/// 示例：文本摘要工具服务
class TextSummaryService extends ToolService<String> {
  TextSummaryService() : super(
    costPerUse: 35,
    toolName: 'Text Summarizer',
  );

  @override
  Future<ToolExecutionResult<String>> executeTool() async {
    try {
      await Future.delayed(const Duration(seconds: 3));

      // Success
      return ToolExecutionResult.success('This is the summary text...');
    } catch (e) {
      return ToolExecutionResult.failure('Summary failed: $e');
    }
  }
}
