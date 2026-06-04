import 'package:flutter/material.dart';

import '../../gen_a/A.dart';
import '../env/app_env.dart';
import '../interface.dart';
import 'agreement_page.dart';
import 'favio_palette.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  bool _agreedToTerms = false;

  Future<void> _handleStart() async {
    if (_isLoading) {
      return;
    }

    if (!_agreedToTerms) {
      final bool agreed = await _showAgreementDialog();
      if (!agreed || !mounted) {
        return;
      }
      setState(() {
        _agreedToTerms = true;
      });
    }

    setState(() {
      _isLoading = true;
    });

    await Interface().doSignInAction();

    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<bool> _showAgreementDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Agreement Required'),
              content: const Text(
                'Please agree to the Terms of Service and Privacy Policy before continuing.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Agree'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _openAgreement({
    required String title,
    required String url,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AgreementPage(
          title: title,
          url: url,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            A.assets_favio_open,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              child: Column(
                children: <Widget>[
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _handleStart,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF101217),
                        textStyle: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: FavioPalette.brandDark,
                              ),
                            )
                          : const Text("Let's go"),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _AgreementSection(
                    agreedToTerms: _agreedToTerms,
                    onAgreementChanged: (bool? value) {
                      setState(() {
                        _agreedToTerms = value ?? false;
                      });
                    },
                    onOpenTerms: () => _openAgreement(
                      title: 'Terms of Service',
                      url: AppEnv().h5User,
                    ),
                    onOpenPrivacy: () => _openAgreement(
                      title: 'Privacy Policy',
                      url: AppEnv().h5Privacy,
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

class _AgreementSection extends StatelessWidget {
  const _AgreementSection({
    required this.agreedToTerms,
    required this.onAgreementChanged,
    required this.onOpenTerms,
    required this.onOpenPrivacy,
  });

  final bool agreedToTerms;
  final ValueChanged<bool?> onAgreementChanged;
  final VoidCallback onOpenTerms;
  final VoidCallback onOpenPrivacy;

  @override
  Widget build(BuildContext context) {
    const TextStyle baseStyle = TextStyle(
      color: Colors.white,
      fontSize: 12,
      height: 1.5,
    );
    const TextStyle linkStyle = TextStyle(
      color: Colors.white,
      fontSize: 12,
      height: 1.5,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
      decorationColor: Colors.white,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Transform.translate(
          offset: const Offset(-4, -6),
          child: Checkbox(
            value: agreedToTerms,
            onChanged: onAgreementChanged,
            activeColor: Colors.white,
            checkColor: FavioPalette.brandDark,
            side: const BorderSide(color: Colors.white70),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Wrap(
              children: <Widget>[
                const Text('I agree to the ', style: baseStyle),
                GestureDetector(
                  onTap: onOpenTerms,
                  child: const Text('Terms of Service', style: linkStyle),
                ),
                const Text(' and ', style: baseStyle),
                GestureDetector(
                  onTap: onOpenPrivacy,
                  child: const Text('Privacy Policy', style: linkStyle),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
