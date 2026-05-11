import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:minne/gen_a/A.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/app_overlay.dart';
import '../../interface.dart';
import '../../env/app_env.dart';
import '../../data/datasources/local_storage.dart';
import '../../routes/app_pages.dart';

/// Login Page - Fixed Pattern (CLAUDE.md requirement)
/// - Full screen background image (no Logo, title, subtitle)
/// - Single button with "Let us go" or "Explore" text
/// - Click button -> loading -> set authToken -> navigate to home
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  bool _agreedToTerms = false;
  late final TapGestureRecognizer _termsTap;
  late final TapGestureRecognizer _privacyTap;

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()
      ..onTap = () {
        final appEnv = AppEnv();
        AppRoutes.toAgreement(
          'Terms of Service',
          appEnv.h5User,
        );
      };
    _privacyTap = TapGestureRecognizer()
      ..onTap = () {
        final appEnv = AppEnv();
        AppRoutes.toAgreement(
          'Privacy Policy',
          appEnv.h5Privacy,
        );
      };
  }

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  Future<bool> _showAgreementDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFFF7FD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                'Agreement Required',
                style: AppTextStyles.h3Style.copyWith(
                  color: const Color(0xFF8E375B),
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: Text(
                'Please agree to the Terms of Service and Privacy Policy before continuing.',
                style: AppTextStyles.bodyStyle.copyWith(
                  color: const Color(0xFF8E375B),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.bodyStyle.copyWith(
                      color: const Color(0xFFA45A78),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8A9FF),
                    foregroundColor: const Color(0xFF4B145F),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    'Agree',
                    style: AppTextStyles.bodyStyle.copyWith(
                      color: const Color(0xFF4B145F),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _handleLogin() async {
    if (!_agreedToTerms) {
      final agreed = await _showAgreementDialog();
      if (!agreed || !mounted) return;
      setState(() => _agreedToTerms = true);
    }

    setState(() => _isLoading = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Set auth token
      Interface().authToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      await LocalStorage.setToken(Interface().authToken!);

      if (!mounted) return;

      // Navigate to home
      AppRoutes.toHome();
    } catch (e) {
      AppOverlay.showToast(
        context,
        message: 'Login failed, please try again',
        type: ToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              A.assets_minne_open6,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, bottomInset > 0 ? 20 : 28),
              child: Column(
                children: [
                  const Spacer(flex: 4),
                  SizedBox(
                    width: 310,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8A9FF),
                        disabledBackgroundColor: const Color(0xFFE8A9FF).withValues(alpha: 0.8),
                        foregroundColor: const Color(0xFF4B145F),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Color(0xFF4B145F)),
                              ),
                            )
                          : Text(
                              "Let's go",
                              style: AppTextStyles.buttonStyle.copyWith(
                                color: const Color(0xFF4B145F),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() => _agreedToTerms = !_agreedToTerms);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(top: 2),
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: _agreedToTerms
                                  ? const Color(0xFFE8A9FF)
                                  : Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(
                                color: _agreedToTerms
                                    ? const Color(0xFFE8A9FF)
                                    : Colors.white.withValues(alpha: 0.65),
                                width: 1.2,
                              ),
                              boxShadow: _agreedToTerms
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFFE8A9FF).withValues(alpha: 0.35),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: _agreedToTerms
                                ? const Icon(
                                    Icons.check,
                                    size: 12,
                                    color: Color(0xFF4B145F),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: AppTextStyles.smallStyle.copyWith(
                                color: const Color(0xE6FFFFFF),
                                fontSize: 10.5,
                                height: 1.45,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'By continuing with Minne, you agree to our ',
                                ),
                                TextSpan(
                                  text: 'Terms',
                                  recognizer: _termsTap,
                                  style: AppTextStyles.smallStyle.copyWith(
                                    color: const Color(0xFFF5C1FF),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                    decorationColor: const Color(0xFFF5C1FF),
                                  ),
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  recognizer: _privacyTap,
                                  style: AppTextStyles.smallStyle.copyWith(
                                    color: const Color(0xFFF5C1FF),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                    decorationColor: const Color(0xFFF5C1FF),
                                  ),
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ),
                            softWrap: true,
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
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
}
