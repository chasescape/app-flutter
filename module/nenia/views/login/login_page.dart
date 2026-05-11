import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../gen_a/A.dart';
import '../../core/theme/app_theme.dart';
import '../../env/app_env.dart';
import '../../interface.dart';
import '../../routes/app_pages.dart';

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
    _termsRecognizer = TapGestureRecognizer()..onTap = _openTermsOfService;
    _privacyRecognizer = TapGestureRecognizer()..onTap = _openPrivacyPolicy;
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_agreedToTerms) {
      final shouldContinue = await _showAgreementDialog();
      if (shouldContinue != true || !mounted) {
        return;
      }
      setState(() {
        _agreedToTerms = true;
      });
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    Interface().authToken = 'mock_token';

    if (mounted) {
      setState(() => _isLoading = false);
      Routes.toMain();
    }
  }

  Future<bool?> _showAgreementDialog() {
    return Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.surfacePrimary,
        shape: const RoundedRectangleBorder(
          borderRadius: AppBorderRadius.allLg,
        ),
        title: const Text('User Agreement', style: AppTextStyles.h3),
        content: const Text(
          'Please agree to the Terms of Service and Privacy Policy before continuing.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryMain,
            ),
            child: const Text('Agree'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  void _openTermsOfService() {
    Routes.toAgreement('Terms of Service', AppEnv().h5User);
  }

  void _openPrivacyPolicy() {
    Routes.toAgreement('Privacy Policy', AppEnv().h5Privacy);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            A.assets_nenia_NeniaOpen,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 22),
              child: Column(
                children: [
                  const Spacer(flex: 4),
                  Text(
                    'Nenia',
                    style: AppTextStyles.h1.copyWith(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF211620),
                      letterSpacing: -0.8,
                    ),
                  ),
                  const Spacer(flex: 5),
                  _buildPrimaryButton(),
                  const SizedBox(height: 18),
                  _buildAgreementRow(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF170E18),
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppShadows.md,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: _isLoading ? null : _handleLogin,
            child: Center(
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Explore now',
                      style: AppTextStyles.button.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAgreementRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.scale(
          scale: 1.02,
          child: Checkbox(
            value: _agreedToTerms,
            onChanged: (value) =>
                setState(() => _agreedToTerms = value ?? false),
            activeColor: AppColors.primaryMain,
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primaryMain;
              }
              return Colors.white.withValues(alpha: 0.86);
            }),
            side: const BorderSide(color: AppColors.textSecondary, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            visualDensity: VisualDensity.compact,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.small.copyWith(
                  color: const Color(0xFF2A1E2B),
                  height: 1.45,
                ),
                children: [
                  const TextSpan(
                    text: 'By using App you agree with our ',
                  ),
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: AppTextStyles.small.copyWith(
                      color: const Color(0xFF201421),
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: _termsRecognizer,
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: AppTextStyles.small.copyWith(
                      color: const Color(0xFF201421),
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: _privacyRecognizer,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
