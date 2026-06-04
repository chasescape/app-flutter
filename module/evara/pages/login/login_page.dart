import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/evara_scaffold.dart';
import '../../env/app_env.dart';
import '../../interface.dart';
import '../../../gen_a/A.dart';

/// Login page aligned with the splash visual direction.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _agreedToTerms = false;

  Future<void> _handleLogin() async {
    if (!_agreedToTerms) {
      Get.dialog(
        AlertDialog(
          backgroundColor: AppTheme.bgSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          title: const Text('Agree to Continue'),
          content: const Text(
            'Please review and agree to the Terms of Service and Privacy Policy before entering Evara.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  _agreedToTerms = true;
                });
                Get.back();
                await Interface().doSignInAction();
              },
              child: const Text('Agree'),
            ),
          ],
        ),
      );
      return;
    }

    await Interface().doSignInAction();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            A.assets_evara_open,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingLg,
                AppTheme.spacingLg,
                AppTheme.spacingLg,
                AppTheme.spacingLg,
              ),
              child: Column(
                children: [
                  const Spacer(flex: 5),
                  EvaraGlassCard(
                    blur: 24,
                    color: Colors.black.withValues(alpha: 0.24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _agreedToTerms,
                              onChanged: (value) {
                                setState(() {
                                  _agreedToTerms = value ?? false;
                                });
                              },
                              activeColor: AppTheme.primaryMain,
                              checkColor: AppTheme.textInverse,
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 14),
                                child: Wrap(
                                  children: [
                                    const Text(
                                      'I agree to the ',
                                      style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: AppTheme.caption,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => AppRoutes.toAgreement(
                                        'Terms of Service',
                                        AppEnv().h5User,
                                      ),
                                      child: const Text(
                                        'Terms of Service',
                                        style: TextStyle(
                                          color: AppTheme.accentMain,
                                          fontSize: AppTheme.caption,
                                          decoration:
                                              TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                    const Text(
                                      ' & ',
                                      style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: AppTheme.caption,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => AppRoutes.toAgreement(
                                        'Privacy Policy',
                                        AppEnv().h5Privacy,
                                      ),
                                      child: const Text(
                                        'Privacy Policy',
                                        style: TextStyle(
                                          color: AppTheme.accentMain,
                                          fontSize: AppTheme.caption,
                                          decoration:
                                              TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingSm),
                        AppWidgets.gradientButton(
                          text: 'Enter Evara',
                          onPressed: _handleLogin,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
