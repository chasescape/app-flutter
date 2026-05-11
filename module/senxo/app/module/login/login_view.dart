import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:senxo/gen_a/A.dart';
import 'package:senxo/senxo/env/app_env.dart';
import '../../routes/app_pages.dart';
import 'login_logic.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final LoginLogic logic = Get.put(LoginLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            A.assets_senxo_open,
            fit: BoxFit.cover,
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                SizedBox(height: 80.h),

                // Explore Button (点击进入，调登录接口后进入首页)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: Obx(() {
                    final loading = logic.isLoggingIn.value;
                    return GestureDetector(
                      onTap: loading
                          ? null
                          : () {
                              if (!logic.isAgreed.value) {
                                _showAgreementDialog(context);
                                return;
                              }
                              logic.doLogin();
                            },
                      child: Container(
                        width: double.infinity,
                        height: 56.h,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFE1BEE7),
                              Color(0xFFCE93D8),
                              Color(0xFFBA68C8),
                            ],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(28.r),
                            topRight: Radius.circular(8.r),
                            bottomLeft: Radius.circular(8.r),
                            bottomRight: Radius.circular(28.r),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFBA68C8).withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: loading
                              ? SizedBox(
                                  width: 24.w,
                                  height: 24.w,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Explore now',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                      ),
                    );
                  }),
                ),

                SizedBox(height: 24.h),
                
                // Terms and Privacy
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(() => GestureDetector(
                        onTap: () => logic.toggleAgreement(),
                        child: Container(
                          width: 20.w,
                          height: 20.w,
                          decoration: BoxDecoration(
                            color: logic.isAgreed.value 
                                ? const Color(0xFF9575CD) 
                                : Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4.r),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                          child: logic.isAgreed.value
                              ? Icon(
                                  LucideIcons.check,
                                  size: 14.sp,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      )),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: 'By using App you agree with our ',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF616161),
                            ),
                            children: [
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () => _showTermsDialog(context),
                                  child: Text(
                                    'Terms & Conditions',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF212121),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                              TextSpan(text: ' and '),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () => _showPrivacyDialog(context),
                                  child: Text(
                                    'Privacy Policy',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF212121),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 40.h),
              ],
            ),
          ),

          // 进入登录页 / 登录请求中 全屏 loading 动画
          Obx(() => (logic.isPageLoading.value || logic.isLoggingIn.value) ? _buildLoadingOverlay() : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black26,
      alignment: Alignment.center,
      child: Lottie.asset(
        A.assets_loading_loading,
        width: 120.w,
        height: 120.w,
        fit: BoxFit.contain,
      ),
    );
  }

  // Agreement Dialog
  void _showAgreementDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32.r),
            topRight: Radius.circular(8.r),
            bottomLeft: Radius.circular(8.r),
            bottomRight: Radius.circular(32.r),
          ),
        ),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32.r),
              topRight: Radius.circular(8.r),
              bottomLeft: Radius.circular(8.r),
              bottomRight: Radius.circular(32.r),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 64.w,
                height: 64.w,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFFF9FB),
                      Color(0xFFFFDAE0),
                      Color(0xFFFFF4DC),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.shield_check,
                  size: 32.sp,
                  color: const Color(0xFF9575CD),
                ),
              ),
              SizedBox(height: 20.h),
              
              // Title
              Text(
                'Terms & Privacy',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF212121),
                ),
              ),
              SizedBox(height: 12.h),
              
              // Message with clickable links
              Text.rich(
                TextSpan(
                  text: 'Please read and accept our ',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF616161),
                    height: 1.6,
                  ),
                  children: [
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () => _showTermsDialog(context),
                        child: Text(
                          'Terms & Conditions',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF9575CD),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                    TextSpan(text: ' and '),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () => _showPrivacyDialog(context),
                        child: Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF9575CD),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                    TextSpan(text: ' to continue using Senxo.'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 28.h),
              
              // Buttons Row
              Row(
                children: [
                  // Decline Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.r),
                            topRight: Radius.circular(6.r),
                            bottomLeft: Radius.circular(6.r),
                            bottomRight: Radius.circular(20.r),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Decline',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF616161),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Accept Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        logic.toggleAgreement();
                        Get.back();
                        // 同意后直接调用登录接口进入主页
                        logic.doLogin();
                      },
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFE1BEE7),
                              Color(0xFFCE93D8),
                              Color(0xFFBA68C8),
                            ],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.r),
                            topRight: Radius.circular(6.r),
                            bottomLeft: Radius.circular(6.r),
                            bottomRight: Radius.circular(20.r),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFBA68C8).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Accept',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
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
    );
  }

  // Terms & Conditions Dialog
  void _showTermsDialog(BuildContext context) {
    final appEnv = AppEnv();
    Get.toNamed(
      Routes.webview,
      arguments: {
        'url': appEnv.h5User,
        'title': 'Terms & Conditions',
      },
    );
  }

  // Privacy Policy Dialog
  void _showPrivacyDialog(BuildContext context) {
    final appEnv = AppEnv();
    Get.toNamed(
      Routes.webview,
      arguments: {
        'url': appEnv.h5Privacy,
        'title': 'Privacy Policy',
      },
    );
  }
}
