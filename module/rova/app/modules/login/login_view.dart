import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:rova/gen_a/A.dart';

import '../../routes/app_routes.dart';
import 'login_logic.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginLogic logic = Get.find<LoginLogic>();

  bool _agreed = false;

  Future<void> _goHome() async {
    Get.offAllNamed(AppRoutes.nav);
  }

  Future<void> _onStartPressed() async {
    if (_agreed) {
      await _goHome();
      return;
    }

    final bool? agreedInDialog = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        const Color pink = Color(0xFFE84B7B);
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
              ),
          contentTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
              ),
          title: const Text('Please accept the terms'),
          content: const Text(
            'You need to agree to the Terms of Service and Privacy Policy before continuing.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(foregroundColor: pink),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: pink,
                foregroundColor: Colors.white,
              ),
              child: const Text('Agree & Continue'),
            ),
          ],
        );
      },
    );

    if (agreedInDialog == true) {
      setState(() => _agreed = true);
      await _goHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            A.assets_rova_open,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFE84B7B),
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      onPressed: _onStartPressed,
                      child: const Text(
                        'Start',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => setState(() => _agreed = !_agreed),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            _agreed
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            size: 18,
                            color: _agreed
                                ? Colors.black87
                                : Colors.black.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black.withValues(alpha: 0.75),
                            ),
                            children: [
                              const TextSpan(
                                text: 'By continuing, you agree to our ',
                              ),
                              TextSpan(
                                text: 'Terms',
                                style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Get.toNamed(AppRoutes.termsOfService);
                                  },
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Get.toNamed(AppRoutes.privacyPolicy);
                                  },
                              ),
                              const TextSpan(text: '.'),
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
        ],
      ),
    );
  }
}
