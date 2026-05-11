import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../../../gen_a/A.dart';
import '../../controllers/app_controller.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/midora_design.dart';
import '../../env/app_env.dart';
import '../../interface.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  bool _agreedToTerms = false;
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => _showAgreement(
            'Terms of Service',
            Interface().authToken != null
                ? AppEnv().h5User
                : 'https://example.com/terms',
          );
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => _showAgreement(
            'Privacy Policy',
            Interface().authToken != null
                ? AppEnv().h5Privacy
                : 'https://example.com/privacy',
          );
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  Future<void> _performLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    await Interface().persistAuthToken('mock_token');
    await AppController.I.login();

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pushReplacementNamed('/main');
  }

  Future<void> _showAgreementDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: AppBorderRadius.shapeXl,
          backgroundColor: AppColors.backgroundSecondary,
          title: const Text('Agreement'),
          content: const Text(
            'Please agree to the Terms of Service and Privacy Policy to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      Navigator.of(context).pop();
                      if (mounted) {
                        setState(() => _agreedToTerms = true);
                      }
                      await _performLogin();
                    },
              child: const Text('Agree'),
            ),
          ],
        );
      },
    );
  }

  void _showAgreement(String title, String url) {
    AppRoutes.toAgreement(context, title, url);
  }

  Future<void> _handleStart() async {
    if (_isLoading) return;
    if (_agreedToTerms) {
      await _performLogin();
      return;
    }
    await _showAgreementDialog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            A.assets_midora_MidoraOpen,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                children: [
                  const Spacer(flex: 4),
                  SizedBox(
                    width: double.infinity,
                    child: MidoraPrimaryButton(
                      label: 'Start',
                      onTap: _handleStart,
                      isLoading: _isLoading,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() => _agreedToTerms = !_agreedToTerms);
                        },
                        child: Container(
                          width: 18,
                          height: 18,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  AppColors.textInverse.withValues(alpha: 0.8),
                            ),
                          ),
                          child: _agreedToTerms
                              ? const Padding(
                                  padding: EdgeInsets.all(3.2),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: AppColors.textInverse,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    'By tapping Start and using Midora, you agree to our ',
                                style: AppTextStyles.small.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              TextSpan(
                                text: 'Terms',
                                style: AppTextStyles.smallMedium.copyWith(
                                  color: AppColors.textInverse,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: _termsRecognizer,
                              ),
                              TextSpan(
                                text: ' and ',
                                style: AppTextStyles.small.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: AppTextStyles.smallMedium.copyWith(
                                  color: AppColors.textInverse,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: _privacyRecognizer,
                              ),
                              TextSpan(
                                text: '.',
                                style: AppTextStyles.small.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
