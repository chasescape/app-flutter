import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../gen_a/A.dart';
import '../../core/constants/app_border_radius.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_shadows.dart';
import '../../core/constants/app_text_styles.dart';
import '../../env/app_env.dart';
import '../../interface.dart';
import '../../routes/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  bool _agreedToTerms = false;

  Future<void> _handleLogin() async {
    if (!_agreedToTerms) {
      final agreed = await _showAgreementDialog();
      if (!agreed) {
        return;
      }
      setState(() => _agreedToTerms = true);
    }

    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    Interface().authToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
    if (!mounted) {
      return;
    }
    Get.offAllNamed(AppRoutes.home);
  }

  Future<bool> _showAgreementDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
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
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            A.assets_lona_LonaOpen,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(),
                  _buildStartButton(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTermsRow(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.2),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.secondaryMain),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppGradients.whitePill,
          borderRadius: BorderRadius.circular(AppBorderRadius.full),
          boxShadow: AppShadows.md,
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation(AppColors.secondaryMain),
                  ),
                )
              : Text(
                  'Start',
                  style: AppTextStyles.button.copyWith(fontSize: 18),
                ),
        ),
      ),
    );
  }

  Widget _buildTermsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
          child: Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _agreedToTerms ? AppColors.textPrimary : Colors.transparent,
              border: Border.all(
                color: AppColors.textPrimary.withValues(alpha: 0.95),
              ),
            ),
            child: _agreedToTerms
                ? const Icon(
                    Icons.check_rounded,
                    size: 15,
                    color: Colors.white,
                  )
                : null,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Wrap(
            children: [
              _legalText('By tapping Start, you agree to our '),
              _legalLink(
                'Terms',
                onTap: () => Get.toNamed(
                  AppRoutes.agreement,
                  arguments: {
                    'title': 'Terms of Service',
                    'url': AppEnv().h5User,
                  },
                ),
              ),
              _legalText(' and '),
              _legalLink(
                'Privacy Policy',
                onTap: () => Get.toNamed(
                  AppRoutes.agreement,
                  arguments: {
                    'title': 'Privacy Policy',
                    'url': AppEnv().h5Privacy,
                  },
                ),
              ),
              _legalText('.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legalText(String text) {
    return Text(
      text,
      style: AppTextStyles.caption.copyWith(
        color: AppColors.textPrimary.withValues(alpha: 0.9),
      ),
    );
  }

  Widget _legalLink(String text, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.textPrimary.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}
