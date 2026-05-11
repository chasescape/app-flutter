import 'package:bilra/bilra/controllers/user_controller.dart';
import 'package:bilra/bilra/env/app_env.dart';
import 'package:bilra/bilra/routes/app_router.dart';
import 'package:bilra/bilra/services/coins_manager.dart';
import 'package:bilra/gen_a/A.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final UserController _userController;
  final CoinsManager _coinsManager = CoinsManager();
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;
  bool _isLoading = false;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _userController = Get.isRegistered<UserController>()
        ? Get.find<UserController>()
        : Get.put(UserController());
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => _showAgreementPage('terms');
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => _showAgreementPage('privacy');
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  Future<void> _handleStart() async {
    if (!_agreedToTerms) {
      final agreed = await _showAgreementPrompt();
      if (!agreed) return;
      setState(() {
        _agreedToTerms = true;
      });
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 900));
    await _userController
        .setAuthToken('mock_token_${DateTime.now().millisecondsSinceEpoch}');
    await _userController
        .setUserId('user_${DateTime.now().millisecondsSinceEpoch}');
    await _coinsManager.initialize();
    if (_coinsManager.currentCoins == 0) {
      await _coinsManager.setCoins(100);
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
    context.go(AppRoutes.home);
  }

  Future<bool> _showAgreementPrompt() async {
    return (await showDialog<bool>(
          context: context,
          barrierColor: const Color.fromRGBO(28, 13, 24, 0.26),
          builder: (context) => Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 34),
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFFEFF),
                    Color(0xFFFFF8FC),
                  ],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(86, 33, 66, 0.18),
                    blurRadius: 40,
                    offset: Offset(0, 18),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFFF8D6E7),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFF8BC6),
                            Color(0xFFF43F97),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'One quick step',
                    style: TextStyle(
                      color: Color(0xFF2E2230),
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please agree to the Terms of Service and Privacy Policy to continue exploring Bilra.',
                    style: TextStyle(
                      color: Color(0xFF6D5A68),
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF342539),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xFFF851AE),
                                Color(0xFFF5378A),
                              ],
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(244, 63, 151, 0.28),
                                blurRadius: 18,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: FilledButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Text(
                              'Agree',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )) ??
        false;
  }

  void _showAgreementPage(String type) {
    final url = type == 'terms' ? AppEnv().h5User : AppEnv().h5Privacy;
    AppRoutes.toAgreement(
      context,
      type == 'terms' ? 'Terms of Service' : 'Privacy Policy',
      url,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const agreementTextStyle = TextStyle(
      color: Color(0xFF4A3B45),
      fontSize: 15,
      height: 1.35,
      fontWeight: FontWeight.w500,
      shadows: [
        Shadow(
          color: Color.fromRGBO(255, 255, 255, 0.38),
          blurRadius: 12,
        ),
      ],
    );
    const agreementLinkStyle = TextStyle(
      color: Color(0xFF3B2E35),
      fontSize: 15,
      height: 1.35,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
    );

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              A.assets_bilra_BilraOpen,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x40F93B9C),
                            blurRadius: 24,
                            offset: Offset(0, 12),
                          ),
                        ],
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFFF73CA8),
                            Color(0xFFF93286),
                          ],
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleStart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          disabledBackgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Start',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() {
                            _agreedToTerms = !_agreedToTerms;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _agreedToTerms
                                  ? const Color(0xFFF73CA8)
                                  : Colors.white.withValues(alpha: 0.78),
                              border: Border.all(
                                color: _agreedToTerms
                                    ? const Color(0xFFF73CA8)
                                    : const Color(0xFFF073AA),
                                width: 1.5,
                              ),
                            ),
                            child: _agreedToTerms
                                ? const Icon(
                                    Icons.check,
                                    size: 13,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: agreementTextStyle,
                            children: [
                              const TextSpan(
                                text:
                                    'By tapping Sign in and using Bilra, you agree to our ',
                              ),
                              TextSpan(
                                text: 'Terms',
                                style: agreementLinkStyle,
                                recognizer: _termsRecognizer,
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy.',
                                style: agreementLinkStyle,
                                recognizer: _privacyRecognizer,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: bottomPadding > 12 ? 12 : 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
