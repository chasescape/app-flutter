import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../gen_a/A.dart';
import '../../../env/app_env.dart';
import '../../../interface.dart';
import '../../../routes/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _agreedToTerms = false;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    if (!_agreedToTerms) {
      Get.dialog<void>(
        AlertDialog(
          title: const Text('Agreement Required'),
          content: const Text(
            'Please agree to the Terms & Conditions and Privacy Policy to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back<void>(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _agreedToTerms = true;
                });
                Get.back<void>();
                _handleLogin();
              },
              child: const Text('Agree'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Interface().doSignInAction();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
    AppRoutes.toMain();
  }

  void _showAgreement(String title, String url) {
    AppRoutes.toAgreement(title, url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              A.assets_wekoo_open,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              child: Column(
                children: [
                  const Spacer(flex: 7),
                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5E9B).withValues(alpha: 0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                  ),
                  const Spacer(flex: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF160607),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Explore now'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Transform.translate(
                        offset: const Offset(-10, -10),
                        child: Checkbox(
                          value: _agreedToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreedToTerms = value ?? false;
                            });
                          },
                          side: const BorderSide(
                            color: Color(0xFF1B1012),
                            width: 1.2,
                          ),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          activeColor: const Color(0xFF1B1012),
                          checkColor: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text(
                                'By using App you agree with our ',
                                style: TextStyle(
                                  color: Color(0xFF1B1012),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  height: 1.35,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _showAgreement(
                                  'Terms & Conditions',
                                  AppEnv().h5User,
                                ),
                                child: const Text(
                                  'Terms & Conditions',
                                  style: TextStyle(
                                    color: Color(0xFF1B1012),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                              const Text(
                                ' and ',
                                style: TextStyle(
                                  color: Color(0xFF1B1012),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  height: 1.35,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _showAgreement(
                                  'Privacy Policy',
                                  AppEnv().h5Privacy,
                                ),
                                child: const Text(
                                  'Privacy Policy',
                                  style: TextStyle(
                                    color: Color(0xFF1B1012),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: AbsorbPointer(
                child: Container(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
