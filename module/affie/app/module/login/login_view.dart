import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:affie/gen_a/A.dart';
import 'login_logic.dart';
import '../../theme/app_colors.dart';
import '../../../env/app_env.dart';
import '../webview/simple_webview_page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final LoginLogic logic = Get.put(LoginLogic());

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              A.assets_affie_open,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                children: [
                  const Spacer(),
                  Obx(() {
                    final enabled =
                        logic.isAgreed.value && !logic.isLoading.value;
                    final loading = logic.isLoading.value;
                    final baseColor =
                        isDark ? AppColors.primary : AppColors.primaryDark;
                    final bgColor =
                        enabled ? baseColor : baseColor.withValues(alpha: 0.45);
                    final elevation = enabled ? 8.0 : 0.0;

                    return Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: loading
                                ? null
                                : () {
                                    logic.login();
                                  },
                            style: ElevatedButton.styleFrom(
                              elevation: elevation,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              backgroundColor: bgColor,
                              foregroundColor: Colors.white,
                            ),
                            child: loading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    "Let's go",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildAgreeRow(context, isDark),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgreeRow(BuildContext context, bool isDark) {
    return Obx(() {
      final checked = logic.isAgreed.value;
      final borderColor =
          isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

      return Opacity(
        opacity: 0.95,
        child: GestureDetector(
          onTap: () => logic.toggleAgree(),
          behavior: HitTestBehavior.opaque,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: checked
                        ? (isDark ? AppColors.primary : AppColors.primaryDark)
                        : borderColor.withValues(alpha: 0.7),
                    width: 1.4,
                  ),
                  color: checked
                      ? (isDark ? AppColors.primary : AppColors.primaryDark)
                      : Colors.transparent,
                ),
                child: checked
                    ? const Icon(
                        Icons.check,
                        size: 11,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                    children: [
                      const TextSpan(
                        text: 'By using this app you agree with our ',
                      ),
                      TextSpan(
                        text: 'Terms & Conditions',
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _openTerms(context),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _openPrivacy(context),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

void _openTerms(BuildContext context) {
  final url = AppEnv().h5User;
  if (url.isEmpty) return;
  Get.to(() => SimpleWebviewPage(
        title: 'Terms of Service',
        url: url,
      ));
}

void _openPrivacy(BuildContext context) {
  final url = AppEnv().h5Privacy;
  if (url.isEmpty) return;
  Get.to(() => SimpleWebviewPage(
        title: 'Privacy Policy',
        url: url,
      ));
}
