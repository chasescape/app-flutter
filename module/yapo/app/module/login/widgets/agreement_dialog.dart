import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AgreementDialog extends StatefulWidget {
  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;

  const AgreementDialog({
    super.key,
    required this.onTermsTap,
    required this.onPrivacyTap,
  });

  @override
  State<AgreementDialog> createState() => _AgreementDialogState();

  static Future<bool?> show({
    required VoidCallback onTermsTap,
    required VoidCallback onPrivacyTap,
  }) {
    return Get.dialog<bool>(
      AgreementDialog(
        onTermsTap: onTermsTap,
        onPrivacyTap: onPrivacyTap,
      ),
      barrierDismissible: false,
    );
  }
}

class _AgreementDialogState extends State<AgreementDialog> {
  late final TapGestureRecognizer _dialogTermsRecognizer;
  late final TapGestureRecognizer _dialogPrivacyRecognizer;

  @override
  void initState() {
    super.initState();
    _dialogTermsRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Get.back();
        widget.onTermsTap();
      };

    _dialogPrivacyRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Get.back();
        widget.onPrivacyTap();
      };
  }

  @override
  void dispose() {
    _dialogTermsRecognizer.dispose();
    _dialogPrivacyRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1a0b2e),
                Color(0xFF2d1b4e),
              ],
            ),
            border: Border.all(
              color: const Color(0x4Dec4899),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x4Dec4899),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 图标
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFec4899), Color(0xFFa855f7)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x66ec4899),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),

              // 标题
              const Text(
                'Agreement Required',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFf9a8d4),
                ),
              ),
              const SizedBox(height: 12),

              // 内容
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xCCd8b4fe),
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(
                      text: 'To continue using Yapo, you need to agree to our ',
                    ),
                    TextSpan(
                      text: 'Terms of Service',
                      style: const TextStyle(
                        color: Color(0xFFf9a8d4),
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: _dialogTermsRecognizer,
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: const TextStyle(
                        color: Color(0xFFf9a8d4),
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: _dialogPrivacyRecognizer,
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // 按钮
              Row(
                children: [
                  // Decline 按钮
                  Expanded(
                    child: InkWell(
                      onTap: () => Get.back(result: false),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: const Color(0x26ec4899),
                          border: Border.all(
                            color: const Color(0x4Dec4899),
                            width: 1.5,
                          ),
                        ),
                        child: const Text(
                          'Decline',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xCCd8b4fe),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),

                  // Agree 按钮
                  Expanded(
                    child: InkWell(
                      onTap: () => Get.back(result: true),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFec4899), Color(0xFFa855f7)],
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x66ec4899),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Agree',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
    );
  }
}
