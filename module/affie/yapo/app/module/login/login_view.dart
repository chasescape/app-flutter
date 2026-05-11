import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:yapo/gen_a/A.dart';
import 'login_logic.dart';
import 'widgets/agreement_dialog.dart';
import 'widgets/login_background.dart';
import 'widgets/login_logo.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(LoginLogic(), tag: 'login_page');

    logic.showAgreementDialog = () => AgreementDialog.show(
          onTermsTap: logic.openTerms,
          onPrivacyTap: logic.openPrivacy,
        );

    return Scaffold(
      body: Obx(() {
        final isLoading = logic.isLoading.value;
        return Stack(
          children: [
            const LoginBackground(),
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  RepaintBoundary(
                    child: AnimatedBuilder(
                      animation: logic.logoScale,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: logic.logoScale.value,
                          child: child,
                        );
                      },
                      child: const LoginLogo(),
                    ),
                  ),
                  const Spacer(flex: 3),
                  RepaintBoundary(
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: logic.animationController,
                        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                      )),
                      child: FadeTransition(
                        opacity: logic.buttonFade,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            children: [
                              _buildStartButton(logic),
                              const SizedBox(height: 24),
                              _buildAgreement(logic),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  child: Center(
                    child: Lottie.asset(
                      A.assets_loading_loading,
                      width: 140,
                      height: 140,
                      fit: BoxFit.contain,
                      repeat: true,
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildStartButton(LoginLogic logic) {
    return RepaintBoundary(
      child: InkWell(
        onTap: () {
          if (!logic.isLoading.value) {
            logic.onStartTap();
          }
        },
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFec4899),
                Color(0xFFa855f7),
                Color(0xFFec4899),
              ],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x80ec4899),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Obx(() {
              final isLoading = logic.isLoading.value;
              return Opacity(
                opacity: isLoading ? 0.7 : 1.0,
                child: const Text(
                  'Start',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildAgreement(LoginLogic logic) {
    return InkWell(
      onTap: () => logic.toggleAgreement(),
      child: Row(
        children: [
          Obx(() {
            final agreed = logic.agreedToTerms.value;
            return Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: agreed
                      ? const Color(0xFFec4899)
                      : const Color(0x4Dd8b4fe),
                  width: 2,
                ),
                color: agreed ? const Color(0xFFec4899) : Colors.transparent,
              ),
              child: agreed
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            );
          }),
          const SizedBox(width: 12),
          Expanded(
            // ✅ 使用缓存的 TapGestureRecognizer，避免内存泄漏
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xB3d8b4fe),
                  height: 1.4,
                ),
                children: [
                  const TextSpan(
                    text: 'By tapping Start and using Yapo, you agree to our ',
                  ),
                  TextSpan(
                    text: 'Terms',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFf9a8d4),
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: logic.termsRecognizer,
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFf9a8d4),
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: logic.privacyRecognizer,
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
