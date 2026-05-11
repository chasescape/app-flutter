import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mische/mische/app/routes/app_routes.dart';

import '../../network/auth_gateway.dart';
import '../../../interface.dart';

class LoginLogic extends GetxController {
  final agreeToTerms = false.obs;
  final isLoading = false.obs;

  late final AuthGateway _authGateway;

  Duration _loadingDuration = const Duration(milliseconds: 3200);
  DateTime? _loadingStartedAt;

  @override
  void onInit() {
    super.onInit();
    _authGateway = AuthGateway.ins;
  }

  Future<void> handleStart(BuildContext context) async {
    if (!agreeToTerms.value) {
      _showTermsDialog(context);
      return;
    }

    final success = await _login();
    if (success && context.mounted) {
      Get.offAllNamed(AppRoutes.nav);
    }
  }

  Future<bool> _login() async {
    if (isLoading.value) {
      return false;
    }

    isLoading.value = true;
    _loadingStartedAt = DateTime.now();
    try {
      final response = await _authGateway.signInWithDevice();
      final code = response['code'];
      final success = response['success'];
      if (code is int && code != 0) {
        throw Exception(response['msg'] ?? response['key'] ?? 'Login failed');
      }
      if (success is bool && success == false) {
        throw Exception(response['msg'] ?? response['key'] ?? 'Login failed');
      }

      return true;
    } catch (e) {
      Get.snackbar('Login failed', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      await _ensureMinimumLoadingTime();
      isLoading.value = false;
    }
  }

  Future<void> _ensureMinimumLoadingTime() async {
    final startedAt = _loadingStartedAt;
    if (startedAt == null) {
      return;
    }

    final elapsed = DateTime.now().difference(startedAt);
    if (elapsed >= _loadingDuration) {
      return;
    }

    await Future.delayed(_loadingDuration - elapsed);
  }

  void _showTermsDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFF8FC),
          elevation: 10,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
          contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          actionsAlignment: MainAxisAlignment.center,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF7AB7), Color(0xFFE91E8C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33E91E8C),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.article_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Agree to terms',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF8B1A5C),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 4,
                children: [
                  const Text(
                    'Please agree to the',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF6B2A4D),
                      height: 1.4,
                      fontSize: 12,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed(
                      AppRoutes.webview,
                      arguments: {
                        'title': 'Terms of Service',
                        'url': Interface().h5UserUrl ?? '',
                      },
                    ),
                    child: const Text(
                      'Terms of Service',
                      style: TextStyle(
                        color: Color(0xFFE91E8C),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const Text(
                    'and',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF6B2A4D),
                      height: 1.4,
                      fontSize: 12,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed(
                      AppRoutes.webview,
                      arguments: {
                        'title': 'Privacy Policy',
                        'url': Interface().h5PrivacyUrl ?? '',
                      },
                    ),
                    child: const Text(
                      'Privacy Policy',
                      style: TextStyle(
                        color: Color(0xFFE91E8C),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const Text(
                    'before continuing.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF6B2A4D),
                      height: 1.4,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF8B1A5C),
                            side: const BorderSide(color: Color(0xFFE9D3DF)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: ElevatedButton(
                          onPressed: () async {
                            agreeToTerms.value = true;
                            Navigator.of(dialogContext).pop();
                            await handleStart(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE91E8C),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: const Text(
                            'Agree',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
