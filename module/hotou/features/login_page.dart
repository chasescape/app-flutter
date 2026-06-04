import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotou/gen_a/A.dart';
import 'package:hotou/hotou/features/game_home_page.dart';
import 'package:hotou/hotou/features/profile_detail_pages.dart';
import 'package:hotou/hotou/interface.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _agreedToTerms = false;
  bool _isLoading = false;

  Future<void> _handleStart() async {
    HapticFeedback.lightImpact();
    if (!_agreedToTerms) {
      final agreed = await _showAgreementDialog();
      if (!agreed) {
        return;
      }
      if (!mounted) {
        return;
      }
      setState(() => _agreedToTerms = true);
    }

    setState(() => _isLoading = true);
    await Interface().doSignInAction();
    Interface().authToken ??= 'hotou_guest_token';

    if (!mounted) {
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => const GameHomePage(),
      ),
    );
  }

  Future<bool> _showAgreementDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Agreement Required'),
              content: const Text(
                'Please agree to the User Agreement and Privacy Policy to continue.',
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

  void _openAgreement(AgreementType type) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => AgreementPage(type: type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: _LoginBackground()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
              child: Column(
                children: <Widget>[
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _handleStart,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF263D32),
                        disabledBackgroundColor:
                            const Color(0xFF263D32).withOpacity(0.58),
                        foregroundColor: const Color(0xFFFFF7DF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Color(0xFFFFF7DF),
                              ),
                            )
                          : const Text("Let's go"),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _AgreementRow(
                    agreedToTerms: _agreedToTerms,
                    onChanged: (value) {
                      setState(() => _agreedToTerms = value ?? false);
                    },
                    onOpenUserAgreement: () {
                      _openAgreement(AgreementType.userAgreement);
                    },
                    onOpenPrivacyPolicy: () {
                      _openAgreement(AgreementType.privacyPolicy);
                    },
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

class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      A.assets_hotou_open,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    );
  }
}

class _AgreementRow extends StatelessWidget {
  const _AgreementRow({
    required this.agreedToTerms,
    required this.onChanged,
    required this.onOpenUserAgreement,
    required this.onOpenPrivacyPolicy,
  });

  final bool agreedToTerms;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onOpenUserAgreement;
  final VoidCallback onOpenPrivacyPolicy;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Checkbox(
          value: agreedToTerms,
          onChanged: onChanged,
          activeColor: const Color(0xFF263D32),
          checkColor: const Color(0xFFFFF7DF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Wrap(
              spacing: 3,
              runSpacing: 3,
              children: <Widget>[
                const Text(
                  'I agree to the',
                  style: _AgreementTextStyles.body,
                ),
                _AgreementLink(
                  label: 'User Agreement',
                  onTap: onOpenUserAgreement,
                ),
                const Text(
                  'and',
                  style: _AgreementTextStyles.body,
                ),
                _AgreementLink(
                  label: 'Privacy Policy',
                  onTap: onOpenPrivacyPolicy,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AgreementLink extends StatelessWidget {
  const _AgreementLink({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: _AgreementTextStyles.link,
      ),
    );
  }
}

class _AgreementTextStyles {
  const _AgreementTextStyles._();

  static const TextStyle body = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle link = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.w900,
    decoration: TextDecoration.underline,
    decorationColor: Colors.white,
  );
}
