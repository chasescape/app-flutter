import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../env/app_env.dart';
import '../../interface.dart';
import '../../../gen_a/A.dart';
import '../../widgets/scent_loading_dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _agreed = false;

  Future<void> _onTapStart() async {
    if (!_agreed) {
      SmartDialog.show(
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: const Text(
            'Agreement Required',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            'Please agree to the Terms of Service and Privacy Policy first.',
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.9),
              height: 1.55,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => SmartDialog.dismiss(),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        SmartDialog.dismiss();
                        setState(() => _agreed = true);
                        _onTapStart();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Agree'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
      return;
    }

    ScentLoadingDialog.show(showMessage: false);
    await Interface().doSignInAction();
    ScentLoadingDialog.dismiss();

    if (mounted) {
      context.go(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(A.assets_glace_open),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.white.withValues(alpha: 0.10),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '9:41',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.94),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(flex: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _onTapStart,
                      child: const Text('Start'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Transform.scale(
                        scale: 0.94,
                        child: Checkbox(
                          value: _agreed,
                          onChanged: (v) =>
                              setState(() => _agreed = v ?? false),
                          fillColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return AppColors.textPrimary;
                            }
                            return Colors.white.withValues(alpha: 0.82);
                          }),
                          checkColor: Colors.white,
                          side: BorderSide(
                            color: AppColors.textPrimary.withValues(alpha: 0.6),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      Expanded(child: _buildAgreementText()),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: 132,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementText() {
    final baseStyle = TextStyle(
      fontSize: 12,
      color: AppColors.textPrimary.withValues(alpha: 0.88),
      height: 1.35,
    );

    const linkStyle = TextStyle(
      fontSize: 12,
      color: AppColors.primary,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
    );

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          const TextSpan(
            text: 'By tapping Start and using Glace, you agree to our ',
          ),
          TextSpan(
            text: 'Terms',
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () => context.toAgreement(
                    'Terms and Conditions',
                    AppEnv().h5User,
                  ),
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy.',
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () => context.toAgreement(
                    'Privacy Policy',
                    AppEnv().h5Privacy,
                  ),
          ),
        ],
      ),
    );
  }
}
