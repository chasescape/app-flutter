import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../interface.dart';
import '../../routes/app_routes.dart';
import 'package:betwe/gen_a/A.dart';
import '../../widgets/app_colors.dart';
import 'login_logic.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final LoginLogic logic = Get.put(LoginLogic());
  final RxBool _agreedToTerms = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            A.assets_betwe_bg,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset(
                              A.assets_betwe_logo,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Betwe',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF171717),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: logic.isLoading.value
                                ? null
                                : () async {
                                    if (!_agreedToTerms.value) {
                                      final agreed = await Get.dialog<bool>(
                                        AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          backgroundColor: const Color(0xFF0B0B0B),
                                          title: const Text(
                                            'Agree to continue',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          content: const Text(
                                            'Please agree to the Terms & Conditions and Privacy Policy before continuing.',
                                            style: TextStyle(
                                              color: Color(0xFFE5E5E5),
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Get.back(result: false),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.white70,
                                              ),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () => Get.back(result: true),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                backgroundColor: const Color(0xFFFF6B9D),
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 8,
                                                ),
                                              ),
                                              child: const Text('Agree'),
                                            ),
                                          ],
                                        ),
                                        barrierDismissible: false,
                                      );
                                      if (agreed == true) {
                                        _agreedToTerms.value = true;
                                      } else {
                                        return;
                                      }
                                    }
                                    await logic.signIn();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: const StadiumBorder(),
                              elevation: 0,
                            ),
                            child: logic.isLoading.value
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Explore now',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            Obx(
                              () => GestureDetector(
                                onTap: () => _agreedToTerms.value = !_agreedToTerms.value,
                                child: Icon(
                                  _agreedToTerms.value
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  size: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const Text(
                              'By using App you agree with our',
                              style: TextStyle(fontSize: 12, color: Colors.black87),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(
                                  AppRoutes.webview,
                                  arguments: {
                                    'title': 'Terms & Conditions',
                                    'url': Interface().h5User ?? '',
                                  },
                                );
                              },
                              child: const Text(
                                'Terms & Conditions',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Text(
                              'and',
                              style: TextStyle(fontSize: 12, color: Colors.black87),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(
                                  AppRoutes.webview,
                                  arguments: {
                                    'title': 'Privacy Policy',
                                    'url': Interface().h5Privacy ?? '',
                                  },
                                );
                              },
                              child: const Text(
                                'Privacy Policy',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
