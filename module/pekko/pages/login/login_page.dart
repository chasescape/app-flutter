import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../gen_a/A.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../../interface.dart';
import '../../env/app_env.dart';
import '../widgets/common_widgets.dart';

/// Login page - Full screen background with single button
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final RxBool _isAgreed = false.obs;

  Future<void> _handleLogin() async {
    if (!_isAgreed.value) {
      final agreed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Agreement Required'),
          content: const Text(
            'Please agree to the Terms Conditions and Privacy Policy to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Agree'),
            ),
          ],
        ),
      );

      if (agreed != true) return;
      _isAgreed.value = true;
    }

    AppLoading.show();

    try {
      await Future.delayed(const Duration(seconds: 1));
      await Interface().doSignInAction();
    } finally {
      AppLoading.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7E8F1),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              A.assets_pekko_open,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                children: [
                  const Spacer(),
                  _LoginButton(
                    onLogin: _handleLogin,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _AgreementSection(isAgreed: _isAgreed),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final Future<void> Function() onLogin;

  const _LoginButton({
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: onLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE1007B),
          foregroundColor: AppColors.textInverse,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          'Enter',
          style: AppTextStyles.button.copyWith(
            color: AppColors.textInverse,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _AgreementSection extends StatelessWidget {
  final RxBool isAgreed;

  const _AgreementSection({
    required this.isAgreed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(
          () => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: isAgreed.value,
                  onChanged: (value) => isAgreed.value = value ?? false,
                  fillColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const Color(0xFFE1007B);
                    }
                    return Colors.white.withValues(alpha: 0.88);
                  }),
                  checkColor: AppColors.textInverse,
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.95),
                    width: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.textPrimary.withValues(alpha: 0.82),
                    ),
                    children: [
                      const TextSpan(text: 'By using App you agree with our '),
                      TextSpan(
                        text: 'Terms Conditions',
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.textPrimary,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Get.toNamed(RouteHelper.toAgreement(
                              'Terms Conditions',
                              AppEnv().h5User,
                            ));
                          },
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.textPrimary,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Get.toNamed(RouteHelper.toAgreement(
                              'Privacy Policy',
                              AppEnv().h5Privacy,
                            ));
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
