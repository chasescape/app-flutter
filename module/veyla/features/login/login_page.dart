import 'package:flutter/material.dart';

import '../../../gen_a/A.dart';
import '../../interface.dart';
import '../../routes/app_pages.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/confirm_dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isCheckingAuth = true;
  bool _isLoading = false;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _checkExistingLogin();
  }

  Future<void> _checkExistingLogin() async {
    final authToken = StorageService.instance.authToken;
    if (authToken != null && authToken.isNotEmpty) {
      Interface().authToken = authToken;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          AppRoutes.toHome();
        }
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _isCheckingAuth = false;
    });
  }

  Future<void> _handleLogin() async {
    if (!_agreedToTerms) {
      final agreed = await ConfirmDialog.show(
        context,
        title: 'Agreement Required',
        content: 'Please agree to the Terms & Conditions and Privacy Policy to continue.',
        confirmText: 'Agree',
        cancelText: 'Cancel',
      );

      if (agreed != true || !mounted) {
        return;
      }

      setState(() {
        _agreedToTerms = true;
      });
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    await StorageService.instance.setAuthToken('mock_token');
    Interface().authToken = 'mock_token';

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    AppRoutes.toHome();
  }

  void _openTerms() {
    AppRoutes.toAgreement('Terms & Conditions', Interface().h5User);
  }

  void _openPrivacy() {
    AppRoutes.toAgreement('Privacy Policy', Interface().h5Privacy);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            A.assets_veyla_open,
            fit: BoxFit.cover,
          ),
          if (_isCheckingAuth)
            const ColoredBox(
              color: Color(0x1AFFFFFF),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            )
          else
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 26,
                vertical: 24,
              ),
              child: Column(
                children: [
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D0912),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Explore now',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: Checkbox(
                            value: _agreedToTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreedToTerms = value ?? false;
                              });
                            },
                            side: const BorderSide(
                              color: Color(0xFF2A2D40),
                              width: 1.2,
                            ),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            shape: const CircleBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text(
                              'By using App you agree with our ',
                              style: AppTextStyles.small,
                            ),
                            GestureDetector(
                              onTap: _openTerms,
                              child: Text(
                                'Terms & Conditions',
                                style: AppTextStyles.small.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const Text(
                              ' and ',
                              style: AppTextStyles.small,
                            ),
                            GestureDetector(
                              onTap: _openPrivacy,
                              child: Text(
                                'Privacy Policy',
                                style: AppTextStyles.small.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
