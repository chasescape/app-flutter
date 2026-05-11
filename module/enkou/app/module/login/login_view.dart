import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:enkou/enkou/app/routes/app_routes.dart';
import 'package:enkou/enkou/app/widget/inapp_webview_page.dart';
import 'package:enkou/enkou/env/app_env.dart';
import 'package:enkou/gen_a/A.dart';

import 'login_logic.dart';

class LoginPage extends GetView<LoginLogic> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            A.assets_enkou_open,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  SizedBox(
                    width: 300.w,
                    height: 52.h,
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
                                final ok = await controller.signIn();
                                if (ok) {
                                  Get.offAllNamed(AppRoutes.nav);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8E44FF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          disabledBackgroundColor:
                              const Color(0xFF8E44FF).withValues(alpha: 0.4),
                          disabledForegroundColor:
                              Colors.white.withValues(alpha: 0.8),
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
                                'Explore now',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      );
                    }),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: controller.toggleAgreed,
                    child: SizedBox(
                      width: 300.w,
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
                                    color: const Color(0xFF1E1E1E),
                                    fontWeight: FontWeight.w600,
                                  ) ??
                                  const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF1E1E1E),
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
    return InkResponse(
      onTap: onTap,
      radius: 18,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF1E1E1E),
            width: 1.4,
          ),
          color: checked ? const Color(0xFF1E1E1E) : Colors.transparent,
        ),
        child: checked
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
  });

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF1E1E1E),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

void _openAgreementLink(BuildContext context, {required bool isPrivacy}) {
  final title = isPrivacy ? 'Privacy Policy' : 'Terms of Service';
  final link = isPrivacy ? AppEnv().h5Privacy : AppEnv().h5User;
  if (link.isEmpty) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: const Text(
            'No URL configured yet.',
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
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
  final theme = Theme.of(context);

  await showDialog<void>(
    context: context,
    builder: (ctx) {
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
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFEED0F2), Color(0xFF9EBAEB)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x338F6AD8),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.description_rounded,
                  size: 26,
                  color: Color(0xFF4A2741),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Agree to terms',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF242129),
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 6),
            DefaultTextStyle(
              style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 14,
                    color: const Color(0xFF7C7785),
                    height: 1.4,
                    decoration: TextDecoration.none,
                  ) ??
                  const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7C7785),
                    height: 1.4,
                    decoration: TextDecoration.none,
                  ),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('Please agree to the '),
                  _LinkText(
                    text: 'Terms & Conditions',
                    onTap: () =>
                        _openAgreementLink(context, isPrivacy: false),
                  ),
                  const Text(' and '),
                  _LinkText(
                    text: 'Privacy Policy',
                    onTap: () =>
                        _openAgreementLink(context, isPrivacy: true),
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
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE6E0EF), width: 1),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF242129),
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF8E44FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  onPressed: () {
                    final logic = Get.find<LoginLogic>();
                    if (!logic.agreed.value) {
                      logic.toggleAgreed();
                    }
                    Navigator.of(ctx).pop();
                    logic.signIn().then((ok) {
                      if (ok) {
                        Get.offAllNamed(AppRoutes.nav);
                      }
                    });
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
