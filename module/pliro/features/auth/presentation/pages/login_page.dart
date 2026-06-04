import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pliro/gen_a/A.dart';
import 'package:pliro/pliro/core/routes/app_routes.dart';
import 'package:pliro/pliro/core/theme/app_colors.dart';
import 'package:pliro/pliro/core/theme/app_text_styles.dart';
import 'package:pliro/pliro/core/theme/app_theme.dart';
import 'package:pliro/pliro/env/app_env.dart';
import 'package:pliro/pliro/interface.dart';
import 'package:pliro/pliro/shared/widgets/common_card.dart';

/// Login page with a soft first-screen treatment.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _agreedToTerms = false;

  Future<void> _handleLogin() async {
    if (_agreedToTerms) {
      await _signInAndEnterHome();
      return;
    }

    final agreed = await _showAgreementDialog();
    if (agreed != true) return;

    setState(() {
      _agreedToTerms = true;
    });
    await _signInAndEnterHome();
  }

  Future<void> _signInAndEnterHome() async {
    await Interface().doSignInAction();

    if (mounted) {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  Future<bool?> _showAgreementDialog() {
    return Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingLG,
          vertical: AppTheme.spacingXL,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingXL),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.96),
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(
                color: AppColors.rose.withOpacity(0.28),
              ),
              boxShadow: AppTheme.dialogShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Agree to Continue',
                  style: AppTextStyles.h3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingMD),
                Text(
                  'Please read and agree to the Terms of Service and Privacy Policy before entering.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingMD),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        AppRoutes.toAgreement(
                          'Terms of Service',
                          AppEnv().h5User,
                        );
                      },
                      child: Text(
                        'Terms of Service',
                        style: AppTextStyles.captionMedium.copyWith(
                          color: AppColors.roseDeep,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Text(' and ', style: AppTextStyles.caption),
                    GestureDetector(
                      onTap: () {
                        AppRoutes.toAgreement(
                          'Privacy Policy',
                          AppEnv().h5Privacy,
                        );
                      },
                      child: Text(
                        'Privacy Policy',
                        style: AppTextStyles.captionMedium.copyWith(
                          color: AppColors.roseDeep,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingXL),
                Row(
                  children: [
                    Expanded(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 48),
                        child: OutlinedButton(
                          onPressed: () => Get.back(result: false),
                          child: const Text(
                            'Disagree',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMD),
                    Expanded(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 48),
                        child: ElevatedButton(
                          onPressed: () => Get.back(result: true),
                          child: const Text(
                            'Agree',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
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
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(A.assets_pliro_open),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXL),
            child: Column(
              children: [
                const Spacer(flex: 3),
                _buildLoginButton(),
                const SizedBox(height: AppTheme.spacingLG),
                _buildAgreementRow(),
                const SizedBox(height: AppTheme.spacingXL),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: InkWell(
        onTap: _handleLogin,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF5A0F18),
                Color(0xFFB9253A),
                Color(0xFFD86A74),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(
              color: Colors.white.withOpacity(0.20),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB9253A).withOpacity(0.34),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Let us go',
              style: AppTextStyles.button.copyWith(
                color: Colors.white,
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
        SizedBox(
          width: 28,
          height: 28,
          child: Checkbox(
            value: _agreedToTerms,
            onChanged: (value) {
              setState(() {
                _agreedToTerms = value ?? false;
              });
            },
            fillColor: MaterialStateProperty.resolveWith(
              (states) => _agreedToTerms
                  ? AppColors.roseDeep
                  : AppColors.surface.withOpacity(0.80),
            ),
            checkColor: Colors.white,
            side: BorderSide(
              color: _agreedToTerms
                  ? AppColors.roseDeep
                  : AppColors.textDisabled.withOpacity(0.55),
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingSM),
        Expanded(
          child: Wrap(
            children: [
              Text('I agree to the ', style: AppTextStyles.caption),
              GestureDetector(
                onTap: () {
                  AppRoutes.toAgreement(
                    'Terms of Service',
                    AppEnv().h5User,
                  );
                },
                child: Text(
                  'Terms of Service',
                  style: AppTextStyles.captionMedium.copyWith(
                    color: AppColors.roseDeep,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Text(' and ', style: AppTextStyles.caption),
              GestureDetector(
                onTap: () {
                  AppRoutes.toAgreement(
                    'Privacy Policy',
                    AppEnv().h5Privacy,
                  );
                },
                child: Text(
                  'Privacy Policy',
                  style: AppTextStyles.captionMedium.copyWith(
                    color: AppColors.roseDeep,
                    decoration: TextDecoration.underline,
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
