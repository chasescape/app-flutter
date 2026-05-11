
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paech/interface.dart';

import '../../../light_handle.dart';

/// 个人页逻辑：退出登录、删除账号等
class ProfileLogic extends GetxController {
  /// 是否正在执行删除账号（全屏 Loading、禁止交互）
  final RxBool isDeleting = false.obs;

  /// 执行退出登录（由视图在「确认弹窗」后调用）
  /// 流程：
  /// 1. 调用 API /security/logout
  /// 2. 延迟 300ms
  /// 3. 清除本地数据（token、encryptKey、用户信息等）
  /// 4. 跳转到登录页
  Future<void> performLogout() async {
    
    try {
      await LightHandle.logout();
      // LightHandle.toLogin();
    } catch (e) {
      // LightHandle.toLogin();
    }
  }

  /// 删除账号接口
  /// 成功：res['code'] == 0

  /// 执行删除账号（由视图在「二次确认弹窗」后调用）
  /// 流程：全屏 Loading → 调删除账号接口 → 成功则本地全量清理并跳登录页，失败则关 Loading 并提示错误
  /// 成功判断与文档一致：res['code'] == 0（兼容 int 与字符串 "0"）
  Future<void> performDeleteAccount() async {
    isDeleting.value = true;
    try {
      final isSuccess = await LightHandle.deleteAccount();
      if (isSuccess) {
        await LightHandle.clearAllData();
        Combing154AwesomeInterface().onAuthTokenRemoved();
        // Get.offAllNamed(Routes.login);
      } else {
        // final msg = res['msg'] ?? res['message'] ?? 'Failed to delete account';
        // throw Exception(msg is String ? msg : '$msg');
      }
    } catch (e) {
      Get.snackbar(
        'Failed to delete account',
        e is Exception ? e.toString().replaceFirst('Exception: ', '') : '$e',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF2D2A26),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isDeleting.value = false;
    }
  }
}
