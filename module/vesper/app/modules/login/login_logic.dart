import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vesper/vesper/app/network/app_config_service.dart';
import 'package:vesper/vesper/app/network/auth_service.dart';
import 'package:vesper/vesper/app/routes/app_routes.dart';

class LoginLogic extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isAgreed = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 初始化时加载本地存储的配置
    _initConfig();
  }

  /// 初始化配置（从本地存储加载）
  Future<void> _initConfig() async {
    try {
      await AppConfigService.loadFromStorage();
    } catch (e) {
      print('加载配置失败: $e');
    }
  }

  /// 切换协议同意状态
  void toggleAgreement() {
    isAgreed.value = !isAgreed.value;
  }

  /// 显示协议确认弹窗
  Future<bool> showAgreementDialog() async {
    final result = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 图标
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3F8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.description_outlined,
                  size: 28,
                  color: Color(0xFFFF4FA5),
                ),
              ),
              const SizedBox(height: 20),
              
              // 标题
              const Text(
                'Terms & Privacy',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2B1A2B),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),
              
              // 内容
              const Text(
                'Please read and agree to continue',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6E5B6F),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // 协议链接
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9FC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFFE3F0),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    _buildAgreementLink(
                      icon: Icons.receipt_long_rounded,
                      title: 'Terms & Conditions',
                      onTap: () {
                        Get.toNamed('${AppRoutes.privacyPolicy}/terms');
                      },
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 1,
                      color: const Color(0xFFFFE3F0),
                    ),
                    const SizedBox(height: 12),
                    _buildAgreementLink(
                      icon: Icons.shield_outlined,
                      title: 'Privacy Policy',
                      onTap: () {
                        Get.toNamed('${AppRoutes.privacyPolicy}/privacy');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // 按钮
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(result: false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: const Color(0xFFF5F5F5),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6E5B6F),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        isAgreed.value = true;
                        Get.back(result: true);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: const Color(0xFFFF4FA5),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Agree',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  /// 构建协议链接项
  Widget _buildAgreementLink({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: const Color(0xFFFF4FA5),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2B1A2B),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Color(0xFF6E5B6F),
            ),
          ],
        ),
      ),
    );
  }

  /// 设备登录
  Future<void> signInWithDevice() async {
    if (isLoading.value) {
      return;
    }
    try {
      isLoading.value = true;
      
      // 步骤1: 获取或创建设备ID (UUID)
      print('步骤1: 获取设备ID...');
      final deviceId = await AppConfigService.getOrCreateDeviceId();
      print('设备ID: $deviceId');
      
      // 步骤2: 获取加密密钥 (从config接口)
      print('步骤2: 获取加密密钥...');
      final encryptKey = await AppConfigService.ensureEncryptKey()
          .timeout(const Duration(seconds: 15));
      if (encryptKey == null || encryptKey.isEmpty) {
        // Get.snackbar('Error', 'Failed to get encryption key');
        return;
      }
      print('加密密钥已获取');
      
      // 步骤3: 调用登录接口
      print('步骤3: 调用登录接口...');
      final result = await AuthService.ins.signInWithDevice()
          .timeout(const Duration(seconds: 15));
      
      if (result['code'] == 0) {
        // 登录成功，跳转到导航页面
        print('登录成功');
        Get.offAllNamed(AppRoutes.nav);
        Get.snackbar('Success', 'Welcome back');
      } else {
        final msg = result['msg'] ?? 'Login failed';
        print('登录失败: $msg');
        // Get.snackbar('Error', msg);
      }
    } catch (e) {
      print('登录错误: $e');
      // Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onLetGoPressed() async {
    // 检查是否已同意协议
    if (!isAgreed.value) {
      final agreed = await showAgreementDialog();
      if (!agreed) {
        return;
      }
    }
    
    // 调用设备登录
    await signInWithDevice();
  }
}
