import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voreo/gen_a/A.dart';

import '../../controllers/auth_controller.dart';
import '../../env/app_env.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthController _authController = Get.put(AuthController());
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => _openAgreement('terms');
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => _openAgreement('privacy');
  }

  Future<void> _handleLogin() async {
    if (!_agreedToTerms) {
      final bool agreed = await _showAgreementDialog();
      if (!agreed) return;
      setState(() => _agreedToTerms = true);
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    await _authController.login();
    setState(() => _isLoading = false);
    AppRoutes.toHome();
  }

  void _openAgreement(String type) {
    final bool isTerms = type == 'terms';
    AppRoutes.toAgreement(
      isTerms ? 'Terms of Service' : 'Privacy Policy',
      isTerms ? AppEnv().h5User : AppEnv().h5Privacy,
    );
  }

  Future<bool> _showAgreementDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Agreement Required'),
            content: const Text(
              'Please agree to the Terms of Service and Privacy Policy to continue.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Agree'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              A.assets_voreo_VoreoOpen,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                children: [
                  const Spacer(flex: 6),
                  SizedBox(
                    width: 235,
                    height: 54,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF43BEE),
                        borderRadius: BorderRadius.circular(27),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x40FF47E9),
                            blurRadius: 24,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(27),
                          onTap: _isLoading ? null : _handleLogin,
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    "Let's go",
                                    style: AppTypography.button.copyWith(
                                      color: AppColors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () =>
                            setState(() => _agreedToTerms = !_agreedToTerms),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            _agreedToTerms
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined,
                            size: 18,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            style: AppTypography.small.copyWith(
                              color: AppColors.white,
                              height: 1.55,
                            ),
                            children: [
                              const TextSpan(
                                text:
                                    "By tapping Let's go and using Voreo, you agree to our ",
                              ),
                              TextSpan(
                                text: 'Terms',
                                recognizer: _termsRecognizer,
                                style: AppTypography.small.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                  height: 1.55,
                                ),
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy.',
                                recognizer: _privacyRecognizer,
                                style: AppTypography.small.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                  height: 1.55,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
