import 'package:flira/flira/app/modules/common/in_app_web_page.dart';
import 'package:flira/flira/app/routes/app_routes.dart';
import 'package:flira/flira/env/app_env.dart';
import 'package:flira/gen_a/A.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'login_logic.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginLogic logic = Get.put(LoginLogic());
  bool _agreed = true;
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = _openTerms;
    _privacyRecognizer = TapGestureRecognizer()..onTap = _openPrivacy;
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  String _composeH5Url({
    required String direct,
    required String fallbackPath,
  }) {
    if (direct.isNotEmpty) return direct;

    final hostH5 = AppEnv().hostH5;
    if (hostH5.isEmpty) return '';

    if (hostH5.endsWith('/')) {
      return '$hostH5${fallbackPath.replaceFirst('/', '')}';
    }
    return '$hostH5$fallbackPath';
  }

  void _openTerms() {
    final String url = _composeH5Url(
      direct: AppEnv().h5User,
      fallbackPath: '/terms-of-service',
    );
    if (url.isEmpty) {
      Get.snackbar(
        'Unavailable',
        'Terms link is not configured yet.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    Get.to(() => InAppWebPage(title: 'Terms & Conditions', url: url));
  }

  void _openPrivacy() {
    final String url = _composeH5Url(
      direct: AppEnv().h5Privacy,
      fallbackPath: '/privacy-policy',
    );
    if (url.isEmpty) {
      Get.snackbar(
        'Unavailable',
        'Privacy link is not configured yet.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    Get.to(() => InAppWebPage(title: 'Privacy Policy', url: url));
  }

  Future<bool> _showAgreementDialog() async {
    final bool? agree = await Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: Colors.white,
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x331E102A),
                blurRadius: 30,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: const Color(0xFFF3F3F3),
                ),
                child: const Icon(Icons.verified_user_outlined, color: Color(0xFF1E1E1E)),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please agree to continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F1F1F),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Before entering Flira, please read and agree to:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    onPressed: _openTerms,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1F1F1F),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: Size.zero,
                    ),
                    child: const Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      'and',
                      style: TextStyle(color: Color(0xFF666666), height: 1.2),
                    ),
                  ),
                  TextButton(
                    onPressed: _openPrivacy,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1F1F1F),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: Size.zero,
                    ),
                    child: const Text(
                      'Privacy Policy',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        side: const BorderSide(color: Color(0xFFE5E5E5)),
                        foregroundColor: const Color(0xFF4A4A4A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Get.back(result: true),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        backgroundColor: const Color(0xFF1F1F1F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                      ),
                      child: const Text('Agree', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );

    return agree == true;
  }

  Future<void> _handleLogin() async {
    if (logic.loading.value) return;

    if (!_agreed) {
      final bool agreedNow = await _showAgreementDialog();
      if (!agreedNow) return;
      if (!mounted) return;
      setState(() => _agreed = true);
    }

    try {
      await logic.signIn();
      if (!mounted) return;
      Get.offAllNamed(AppRoutes.nav);
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Login Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            A.assets_flira_open,
            fit: BoxFit.cover,
          ),
          Container(color: const Color(0x14FFFFFF)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 22),
              child: Column(
                children: <Widget>[
                  const Spacer(flex: 6),
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: !logic.loading.value ? _handleLogin : null,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFF220032),
                          disabledBackgroundColor: const Color(0xFF7B6A87),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: logic.loading.value
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Explore now',
                                style: TextStyle(
                                  fontSize: 35 / 1.4,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () => setState(() => _agreed = !_agreed),
                        child: Icon(
                          _agreed ? Icons.check_circle : Icons.circle_outlined,
                          size: 18,
                          color: const Color(0xFF2A1637),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: Color(0xFF35263F),
                              fontSize: 14,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                            ),
                            children: <InlineSpan>[
                              const TextSpan(text: 'By using App you agree with our\n'),
                              TextSpan(
                                text: 'Terms & Conditions',
                                style: const TextStyle(decoration: TextDecoration.underline),
                                recognizer: _termsRecognizer,
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: const TextStyle(decoration: TextDecoration.underline),
                                recognizer: _privacyRecognizer,
                              ),
                            ],
                          ),
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
