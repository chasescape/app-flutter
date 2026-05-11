import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 统一提示样式（透光玻璃感 + App 配色）
class AppToast {
  AppToast._();

  // 与 App Lunar Whisper 配色一致
  static const Color _lunarPink = Color(0xFFEED0F2);
  static const Color _lunarLavender = Color(0xFF9EBAEB);
  static const Color _surface = Color(0xFFFDFBFF);
  static const Color _titleColor = Color(0xFF242129);
  static const Color _messageColor = Color(0xFF7C7785);
  static const Color _accent = Color(0xFF8F6AD8);
  static const Color _errorTint = Color(0xFFFFE5E8);

  /// 显示普通提示（标题 + 正文）
  static void show(
    String title,
    String message, {
    Duration duration = const Duration(seconds: 2),
    bool isError = false,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? _errorTint.withValues(alpha: 0.75) : _surface.withValues(alpha: 0.72),
      colorText: _titleColor,
      borderRadius: 20,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      duration: duration,
      overlayBlur: 4,
      barBlur: 8,
      borderColor: isError ? const Color(0x40B00020) : _lunarLavender.withValues(alpha: 0.35),
      borderWidth: 1,
      boxShadows: [
        BoxShadow(
          color: (isError ? _errorTint : _lunarPink).withValues(alpha: 0.15),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
      titleText: title.isEmpty
          ? const SizedBox.shrink()
          : Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _titleColor,
              ),
            ),
      messageText: Text(
        message,
        style: const TextStyle(
          fontSize: 13,
          height: 1.35,
          color: _messageColor,
        ),
      ),
      icon: Icon(
        isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
        color: isError ? const Color(0xFFB00020) : _accent,
        size: 22,
      ),
    );
  }

  /// 仅显示一行短提示（无标题）
  static void short(String message, {bool isError = false}) {
    show('', message, duration: const Duration(seconds: 2), isError: isError);
  }
}
