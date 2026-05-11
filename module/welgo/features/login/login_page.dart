import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../../../gen_a/A.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../env/app_env.dart';
import '../../interface.dart';
import '../../light_handle.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  bool _agreedToTerms = false;
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkExistingLoginState();
  }

  Future<void> _checkExistingLoginState() async {
    final token = Interface().authToken;
    final isLoggedIn = token != null && token.isNotEmpty;

    if (isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        AppRoutes.toMain();
      });
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isCheckingAuth = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              A.assets_welgo_welgoopen,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.08),
                    Colors.white.withValues(alpha: 0.18),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: _isCheckingAuth
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(28, 18, 28, 20),
                    child: Column(
                      children: [
                        const Spacer(flex: 3),
                        _buildStartButton(),
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

  Widget _buildStartButton() {
    final isEnabled = !_isLoading;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: isEnabled ? 1 : 0.55,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? _handleStartTap : null,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFFF2D96),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF2D96).withValues(alpha: 0.34),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Center(
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                  : Text(
                      'Start',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleStartTap() async {
    if (_isLoading) {
      return;
    }

    if (_agreedToTerms) {
      await _handleLogin();
      return;
    }

    await _showAgreementDialog();
  }

  Widget _buildAgreementRow() {
    final secondaryText = AppTextStyles.small.copyWith(
      color: Colors.black.withValues(alpha: 0.78),
      fontSize: 12,
      height: 1.5,
      fontWeight: FontWeight.w600,
    );
    final linkText = secondaryText.copyWith(
      color: Colors.black,
      fontWeight: FontWeight.w800,
      decoration: TextDecoration.underline,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _agreedToTerms = !_agreedToTerms;
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              _agreedToTerms
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 18,
              color: Colors.black.withValues(alpha: 0.88),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: secondaryText,
              children: [
                const TextSpan(
                  text: 'By tapping Start and using Welgo, you agree to our ',
                ),
                TextSpan(
                  text: 'Terms',
                  style: linkText,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => AppRoutes.toAgreement(
                          'Terms of Service',
                          AppEnv().h5User,
                        ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: linkText,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => AppRoutes.toAgreement(
                          'Privacy Policy',
                          AppEnv().h5Privacy,
                        ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future<void>.delayed(const Duration(seconds: 1));
    await LightHandle.login();

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });
    AppRoutes.toMain();
  }

  Future<void> _showAgreementDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Agreement Required'),
          content: const Text(
            'Please agree to the Terms of Service and Privacy Policy before continuing.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                if (!mounted) {
                  return;
                }
                setState(() {
                  _agreedToTerms = true;
                });
                await _handleLogin();
              },
              child: const Text('Agree'),
            ),
          ],
        );
      },
    );
  }
}
