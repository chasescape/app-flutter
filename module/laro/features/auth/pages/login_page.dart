import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../gen_a/A.dart';
import '../../../core/app_routes.dart';
import '../../../core/app_theme.dart';
import '../../../env/app_env.dart';
import '../../../interface.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  bool _agreedToTerms = false;

  Future<void> _handleStart() async {
    if (!_agreedToTerms) {
      final agreed = await _showAgreementDialog();
      if (!agreed) {
        return;
      }
      setState(() {
        _agreedToTerms = true;
      });
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 900));
    await Interface().doSignInAction();

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });
    AppRoutes.toHome();
  }

  Future<bool> _showAgreementDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Agreement Required'),
              content: const Text(
                'Please agree to our Terms & Conditions and Privacy Policy to continue.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Agree'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Widget _buildAgreementText() {
    return RichText(
      textAlign: TextAlign.left,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 11,
          color: AppTheme.textPrimary,
          height: 1.35,
          fontWeight: FontWeight.w500,
        ),
        children: [
          const TextSpan(text: 'By using App you agree with our '),
          TextSpan(
            text: 'Terms & Conditions',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w700,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                AppRoutes.toAgreement('Terms of Service', AppEnv().h5User);
              },
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w700,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                AppRoutes.toAgreement('Privacy Policy', AppEnv().h5Privacy);
              },
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              A.assets_laro_lash_preview_open,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
              child: Column(
                children: [
                  const Spacer(flex: 7),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleStart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF12040A),
                        foregroundColor: AppTheme.textInverse,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.textInverse,
                                ),
                              ),
                            )
                          : const Text(
                              'Explore now',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: Checkbox(
                          value: _agreedToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreedToTerms = value ?? false;
                            });
                          },
                          shape: const CircleBorder(),
                          side: const BorderSide(
                            color: AppTheme.textPrimary,
                            width: 1,
                          ),
                          activeColor: AppTheme.textPrimary,
                          checkColor: AppTheme.textInverse,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: _buildAgreementText()),
                    ],
                  ),
                  const SizedBox(height: 26),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
