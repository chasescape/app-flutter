import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../gen_a/A.dart';
import '../../env/app_env.dart';
import '../../interface.dart';
import '../../routes/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _agreed = false;
  bool _isLoading = false;

  Future<void> _onLogin() async {
    if (_isLoading) return;
    if (!_agreed) {
      _showAgreementDialog();
      return;
    }
    await _doLogin();
  }

  void _showAgreementDialog() {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Agreement Required'),
        content: const Text(
          'Please agree to the Terms & Conditions and Privacy Policy to continue.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _agreed = true);
              await _doLogin();
            },
            child: const Text('Agree'),
          ),
        ],
      ),
    );
  }

  Future<void> _doLogin() async {
    setState(() => _isLoading = true);
    await Interface().doSignInAction();
    if (!mounted) return;
    setState(() => _isLoading = false);
    AppRoutes.router.go(AppRoutes.create);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            A.assets_temra_open,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
              child: Column(
                children: [
                  const Spacer(flex: 6),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _onLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF18050F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
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
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _agreed = !_agreed),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            _agreed
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            size: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text(
                              'By using App you agree with our ',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                height: 1.35,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => AppRoutes.toAgreement(
                                'Terms of Service',
                                AppEnv().h5User,
                              ),
                              child: const Text(
                                'Terms & Conditions',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const Text(
                              ' and ',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                height: 1.35,
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
                                  color: Colors.black87,
                                  fontSize: 10,
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
