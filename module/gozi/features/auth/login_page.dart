import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:achievenote/gen_a/A.dart';
import 'package:achievenote/gozi/routes/global_router.dart';
import 'package:achievenote/gozi/widgets/common/app_button.dart';
import 'package:achievenote/gozi/widgets/common/loading_overlay.dart';
import 'package:achievenote/gozi/theme/app_theme.dart';
import 'package:achievenote/gozi/interface.dart';
import 'package:achievenote/gozi/env/app_env.dart';

/// Login Page - Simple login button with agreement confirmation
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _agreedToTerms = false;

  Future<void> _handleLogin() async {
    // Check if user agreed to terms
    if (!_agreedToTerms) {
      final agreed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Terms Agreement'),
          content: const Text(
            'To continue, please agree to our Terms of Service and Privacy Policy.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Agree & Continue'),
            ),
          ],
        ),
      );

      if (agreed != true) return;
    }

    // Show global loading
    if (mounted) {
      AppLoadingOverlay.show(context);
    }

    try {
      // Call Interface.doSignInAction
      await Interface().doSignInAction();

      // Simulate API delay (already included in doSignInAction via async)
      await Future.delayed(const Duration(seconds: 1));

      // Hide loading and navigate to home
      if (mounted) {
        AppLoadingOverlay.hide(context);
      }
      GlobalRouter.I.goToHome();
    } catch (e) {
      if (mounted) {
        AppLoadingOverlay.hide(context);
      }
      if (mounted) {
        Get.snackbar(
          'Error',
          'Login failed: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.error,
          colorText: AppTheme.primaryWhite,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              A.assets_gozi_open,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.lg),
              child: Column(
                children: [
                  const Spacer(),
                  AppButton(
                    text: "Let's go",
                    onPressed: _handleLogin,
                    width: double.infinity,
                  ),
                  const SizedBox(height: AppTheme.md),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _agreedToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreedToTerms = value ?? false;
                          });
                        },
                        fillColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return AppTheme.accentRed;
                          }
                          return AppTheme.primaryWhite.withValues(alpha: 0.82);
                        }),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _agreedToTerms = !_agreedToTerms;
                            });
                          },
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'I agree to ',
                                  style: AppTheme.small.copyWith(
                                    color: AppTheme.primaryWhite,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: AppTheme.small.copyWith(
                                    color: AppTheme.primaryWhite,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      GlobalRouter.I.goToAgreement(
                                        url: AppEnv().h5User,
                                        title: 'Terms of Service',
                                      );
                                    },
                                ),
                                TextSpan(
                                  text: ' & ',
                                  style: AppTheme.small.copyWith(
                                    color: AppTheme.primaryWhite,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: AppTheme.small.copyWith(
                                    color: AppTheme.primaryWhite,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      GlobalRouter.I.goToAgreement(
                                        url: AppEnv().h5Privacy,
                                        title: 'Privacy Policy',
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
