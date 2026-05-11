import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riko/riko/app/routes/app_routes.dart';
import 'package:riko/riko/light_handle.dart';
import 'package:riko/gen_a/A.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const String _agreementKey = 'user_agreement_accepted';
  bool _agreed = false;

  @override
  void initState() {
    super.initState();
    _loadAgreement();
  }

  Future<void> _loadAgreement() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _agreed = prefs.getBool(_agreementKey) ?? false;
    });
  }

  Future<void> _setAgreement(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_agreementKey, value);
    if (mounted) {
      setState(() => _agreed = value);
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            A.assets_riko_open,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () async {
                        if (!_agreed) {
                          _showAgreementDialog(
                            context,
                            onAgree: () async {
                              await _setAgreement(true);
                              await LightHandle.login();
                              Get.offAllNamed(AppRoutes.nav);
                            },
                          );
                          return;
                        }
                        _showLoading(context);
                        try {
                          await LightHandle.login();
                          Get.offAllNamed(AppRoutes.nav);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Login failed: $e')),
                          );
                          Get.offAllNamed(AppRoutes.nav);
                        } finally {
                          if (context.mounted) {
                            final nav =
                                Navigator.of(context, rootNavigator: true);
                            if (nav.canPop()) {
                              nav.pop();
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFEE7FA0),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Let's go",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _setAgreement(!_agreed),
                        behavior: HitTestBehavior.translucent,
                        child: Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(top: 0),
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.8),
                                width: 1.5,
                              ),
                              color: _agreed
                                  ? Colors.white.withOpacity(0.9)
                                  : Colors.transparent,
                            ),
                            child: _agreed
                                ? const Icon(Icons.check,
                                    size: 12, color: Color(0xFFEE7FA0))
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'By tapping Sign in and using Riko, you agree to our ',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 11,
                                height: 1.4,
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  Get.toNamed(AppRoutes.termsOfService),
                              child: const Text(
                                'Terms',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              ' and ',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 11,
                                height: 1.4,
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  Get.toNamed(AppRoutes.privacyPolicy),
                              child: const Text(
                                'Privacy Policy',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              '.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 11,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _showLoading(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    ),
  );
}

void _showAgreementDialog(
  BuildContext context, {
  required Future<void> Function() onAgree,
}) {
  showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Agreement Required'),
      content: Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('Please read and accept the '),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.termsOfService),
            child: const Text(
              'Terms',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const Text(' and '),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.privacyPolicy),
            child: const Text(
              'Privacy Policy',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const Text(' to continue.'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(dialogContext).pop();
            _showLoading(context);
            try {
              await onAgree();
            } finally {
              final nav = Navigator.of(context, rootNavigator: true);
              if (nav.canPop()) {
                nav.pop();
              }
            }
          },
          child: const Text('Agree'),
        ),
      ],
    ),
  );
}
