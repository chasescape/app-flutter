import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zeria/gen_a/A.dart';
import 'package:zeria/zeria/interface.dart';
import 'package:zeria/zeria/constants/app_colors.dart';
import 'package:zeria/zeria/constants/app_routes.dart';
import 'package:zeria/zeria/constants/app_strings.dart';
import 'package:zeria/zeria/constants/app_text_styles.dart';
import 'package:zeria/zeria/env/app_env.dart';
import 'package:zeria/zeria/widgets/zeria_ui.dart';

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
      _showTermsDialog();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));
    Interface().authToken =
        'mock_token_${DateTime.now().millisecondsSinceEpoch}';

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
    context.go(AppRoutes.main);
  }

  void _showTermsDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms & Privacy'),
        content: const Text(
          'Please agree to the Terms of Service and Privacy Policy before entering Zeria.',
        ),
        actions: [
          ZeriaDialogActions(
            onCancel: () => Navigator.pop(context),
            onConfirm: () {
              setState(() {
                _agreedToTerms = true;
              });
              Navigator.pop(context);
              Future.microtask(_handleLogin);
            },
            confirmLabel: 'Agree',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            A.assets_zeria_open,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.brandBlush,
                alignment: Alignment.center,
                child: Text(
                  'open.png failed to load',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: AppColors.brandInk,
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 9),
                  ZeriaButton(
                    label: AppStrings.explore,
                    onPressed: _handleLogin,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 14),
                  _AgreementRow(
                    isChecked: _agreedToTerms,
                    onToggle: () {
                      setState(() {
                        _agreedToTerms = !_agreedToTerms;
                      });
                    },
                    onOpenTerms: () => context.push(
                      AppRoutes.buildAgreementUrl(
                        'Terms of Service',
                        AppEnv().h5User,
                      ),
                    ),
                    onOpenPrivacy: () => context.push(
                      AppRoutes.buildAgreementUrl(
                        'Privacy Policy',
                        AppEnv().h5Privacy,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgreementRow extends StatelessWidget {
  const _AgreementRow({
    required this.isChecked,
    required this.onToggle,
    required this.onOpenTerms,
    required this.onOpenPrivacy,
  });

  final bool isChecked;
  final VoidCallback onToggle;
  final VoidCallback onOpenTerms;
  final VoidCallback onOpenPrivacy;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isChecked ? Colors.white : Colors.transparent,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.9),
                width: 1.2,
              ),
            ),
            child: isChecked
                ? const Icon(
                    Icons.check_rounded,
                    size: 12,
                    color: AppColors.brandHotPink,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.small.copyWith(
                color: Colors.white.withValues(alpha: 0.88),
                height: 1.45,
              ),
              children: [
                const TextSpan(text: 'By tapping Start, you agree to our '),
                TextSpan(
                  text: 'Terms',
                  style: AppTextStyles.small.copyWith(
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = onOpenTerms,
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: AppTextStyles.small.copyWith(
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = onOpenPrivacy,
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
