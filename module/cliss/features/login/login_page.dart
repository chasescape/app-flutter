import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cliss/cliss/a.dart';
import 'package:cliss/cliss/app/routes/app_routes.dart';
import 'package:cliss/cliss/app/theme/app_theme.dart';
import 'package:cliss/cliss/app/widgets/app_button.dart';
import 'package:cliss/cliss/interface.dart';
import 'package:cliss/cliss/env/app_env.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _agreedToTerms = true;
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () {
        AppRoutes.toAgreement(
          'Terms of Service',
          AppEnv().h5User,
        );
      };
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () {
        AppRoutes.toAgreement(
          'Privacy Policy',
          AppEnv().h5Privacy,
        );
      };
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_agreedToTerms) {
      final agreed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Terms Agreement'),
          content: const Text(
            'You need to agree to the Terms of Service and Privacy Policy to continue.',
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Agree'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
      if (agreed != true) return;
      setState(() => _agreedToTerms = true);
    }

    await Interface().doSignInAction();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(A.assets_cliss_Clissopen),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    const Spacer(flex: 7),
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                      child: Column(
                        children: [
                          AppButton(
                            text: 'Enter',
                            onPressed: _handleLogin,
                            width: double.infinity,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _agreedToTerms = !_agreedToTerms;
                                  });
                                },
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  margin: const EdgeInsets.only(top: 2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(
                                      color: _agreedToTerms
                                          ? AppColors.primaryMain
                                          : AppColors.textTertiary,
                                      width: 1.4,
                                    ),
                                  ),
                                  child: _agreedToTerms
                                      ? const Center(
                                          child: Icon(
                                            Icons.check_circle,
                                            size: 14,
                                            color: AppColors.primaryMain,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    style: AppTextStyles.small.copyWith(
                                      color: AppColors.textSecondary,
                                      height: 1.45,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text:
                                            'By tapping Sign in and using Cliss, you agree to our ',
                                      ),
                                      TextSpan(
                                        text: 'Terms',
                                        style: AppTextStyles.small.copyWith(
                                          color: AppColors.primaryMain,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        recognizer: _termsRecognizer,
                                      ),
                                      const TextSpan(text: ' and '),
                                      TextSpan(
                                        text: 'Privacy Policy.',
                                        style: AppTextStyles.small.copyWith(
                                          color: AppColors.primaryMain,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        recognizer: _privacyRecognizer,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
