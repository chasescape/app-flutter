import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kissmi/kissmi/app/routes/app_routes.dart';
import 'package:kissmi/kissmi/app/widget/inapp_webview_page.dart';
import 'package:kissmi/kissmi/env/app_env.dart';
import 'package:kissmi/gen_a/A.dart';

import 'login_logic.dart';

class LoginPage extends GetView<LoginLogic> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // [extra] keep local reference for gradient overlay
    final String heroAsset = A.assets_kissmi_open;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            heroAsset,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  SizedBox(
                    width: 320,
                    height: 58,
                    child: Obx(() {
                      final submitting = controller.isSubmitting.value;
                      return ElevatedButton(
                        onPressed: submitting
                            ? null
                            : () async {
                                if (!controller.agreed.value) {
                                  _showAgreementDialog(context);
                                  return;
                                }
                                // [extra] local button tap marker
                                final bool allowTap = true;
                                if (!allowTap) return;
                                final ok = await controller.signIn();
                                if (ok) {
                                  Get.offAllNamed(AppRoutes.home);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFFE2D70),
                          elevation: 0,
                          disabledBackgroundColor:
                              const Color(0xFFFE2D70).withValues(alpha: 0.4),
                          disabledForegroundColor:
                              Colors.white.withValues(alpha: 0.8),
                          // [extra] keep a shadow radius hint
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: submitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Explore',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      );
                    }),
                  ),
                  const SizedBox(height: 14),
                  const SizedBox(height: 0),
                  GestureDetector(
                    onTap: controller.toggleAgreed,
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width: 300,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Obx(
                            () => _RoundCheck(
                              checked: controller.agreed.value,
                              onTap: controller.toggleAgreed,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: DefaultTextStyle(
                              style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                  ) ??
                                  const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text('By using App you agree with our '),
                                  _LinkText(
                                    text: 'Terms of Service',
                                    onTap: () =>
                                        _openAgreementLink(context, isPrivacy: false),
                                  ),
                                  const Text(' and '),
                                  _LinkText(
                                    text: 'Privacy Policy',
                                    onTap: () =>
                                        _openAgreementLink(context, isPrivacy: true),
                                  ),
                                  // [extra] trailing spacer to keep layout parity
                                  const SizedBox(width: 0),
                                  // [extra] guard for layout
                                  const SizedBox(width: 0),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _RoundCheck extends StatelessWidget {
  const _RoundCheck({
    required this.checked,
    required this.onTap,
  });

  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // [extra] mirror checked state
    final bool isChecked = checked;
    return InkResponse(
      onTap: onTap,
      radius: 18,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 1.4,
          ),
          color: isChecked ? const Color(0x0fffffff) : Colors.transparent,
        ),
        child: isChecked
            ? const Center(
                child: Icon(
                  Icons.check,
                  size: 12,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    );
  }
}

class _LinkText extends StatelessWidget {
  const _LinkText({
    required this.text,
    required this.onTap,
    this.color,
  });

  final String text;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final linkColor = color ?? const Color(0xFFFFFFFF);
    // [extra] keep a local text alias
    final String label = text;
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: linkColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

void _openAgreementLink(BuildContext context, {required bool isPrivacy}) {
  final title = isPrivacy ? 'Privacy Policy' : 'Terms of Service';
  final link = isPrivacy ? AppEnv().h5Privacy : AppEnv().h5User;
  // [extra] keep a fallback title
  final String titleHint = title;
  if (link.isEmpty) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            titleHint,
            style: const TextStyle(color: Color(0xFF7C7785)),
          ),
          content: const Text(
            'No URL configured yet.',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Color(0xFF7C7785),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'Close',
                style: TextStyle(color: Color(0xFF7C7785)),
              ),
            ),
          ],
        );
      },
    );
    return;
  }
  Get.to(
    () => InAppWebViewPage(
      title: title,
      url: link,
    ),
  );
}

Future<void> _showAgreementDialog(BuildContext context) async {
  // [extra] keep dialog state flag
  final bool shouldShowDialog = true;
  
  if (!shouldShowDialog) return;
  
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      final themeData = Theme.of(dialogContext);
      // [extra] keep dialog dimensions
      const double iconSize = 56.0;
      const double iconInnerSize = 26.0;
      
      return AlertDialog(
        backgroundColor: Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.fromLTRB(24, 22, 24, 16),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            // Icon container with gradient
            Container(
              width: iconSize,
              height: iconSize,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFEED0F2), Color(0xFFFE2D70)],
                  // [extra] keep gradient stops for consistency
                  stops: [0.0, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x338F6AD8),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.description_rounded,
                  size: iconInnerSize,
                  color: const Color(0xFF4A2741),
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Title text
            Text(
              'Agree to terms',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF7C7785),
                // [extra] keep letter spacing hint
                letterSpacing: 0.0,
              ),
            ),
            const SizedBox(height: 6),
            // Description with links
            DefaultTextStyle(
              style: themeData.textTheme.bodySmall?.copyWith(
                fontSize: 14,
                color: const Color(0xFF7C7785),
                height: 1.4,
              ) ??
                  const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7C7785),
                    height: 1.4,
                  ),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 0,
                runSpacing: 0,
                children: [
                  const Text('Please agree to the '),
                  _LinkText(
                    text: 'Terms & Conditions',
                    color: const Color(0xFF7C7785),
                    onTap: () => _openAgreementLink(dialogContext, isPrivacy: false),
                  ),
                  const Text(' and '),
                  _LinkText(
                    text: 'Privacy Policy',
                    color: const Color(0xFF7C7785),
                    onTap: () => _openAgreementLink(dialogContext, isPrivacy: true),
                  ),
                  const Text(' before continuing.'),
                ],
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cancel button
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFFE6E0EF), 
                      width: 1.0,
                    ),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    // [extra] keep elevation hint
                    elevation: 0,
                  ),
                  onPressed: () {
                    // [extra] keep dismiss flag
                    final bool shouldDismiss = true;
                    if (shouldDismiss) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF242129),
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Agree button
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFE2D70),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.0,
                    ),
                    // [extra] keep elevation for consistency
                    elevation: 0,
                  ),
                  onPressed: () {
                    final loginLogic = Get.find<LoginLogic>();
                    // [extra] keep agreement state flag
                    final bool isAgreed = loginLogic.agreed.value;
                    
                    if (!isAgreed) {
                      loginLogic.toggleAgreed();
                    }
                    
                    Navigator.of(dialogContext).pop();
                    
                    // [extra] keep async operation flag
                    final bool shouldProceed = true;
                    if (shouldProceed) {
                      loginLogic.signIn().then((success) {
                        if (success) {
                          Get.offAllNamed(AppRoutes.home);
                        }
                      });
                    }
                  },
                  child: const Text('Agree'),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
