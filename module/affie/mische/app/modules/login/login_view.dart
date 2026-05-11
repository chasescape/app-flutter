import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mische/gen_a/A.dart';
import 'package:mische/mische/app/routes/app_routes.dart';

import '../../../interface.dart';
import 'login_logic.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final LoginLogic logic = Get.put(LoginLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(A.assets_mische_open),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content overlay
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bottom section with button and terms
                const SizedBox.square(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Obx(
                          () => ElevatedButton(
                            onPressed: logic.isLoading.value ? null : () => logic.handleStart(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              disabledBackgroundColor: Colors.white.withValues(alpha: 0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: logic.isLoading.value
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      valueColor: AlwaysStoppedAnimation(Color(0xFFE91E8C)),
                                    ),
                                  )
                                : const Text(
                                    'Start',
                                    style: TextStyle(
                                      color: Color(0xFFE91E8C),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Terms checkbox
                      Obx(
                        () => Row(
                          children: [
                            Checkbox(
                              value: logic.agreeToTerms.value,
                              onChanged: (value) {
                                logic.agreeToTerms.value = value ?? false;
                              },
                              fillColor: WidgetStateProperty.all(Colors.white),
                              checkColor: const Color(0xFF8B1A5C),
                              side: const BorderSide(color: Colors.white, width: 2),
                            ),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                  children: [
                                    const TextSpan(text: 'By tapping Sign in and using Hook, you agree to our '),
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.baseline,
                                      baseline: TextBaseline.alphabetic,
                                      child: GestureDetector(
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
                                          ),
                                        ),
                                      ),
                                    ),
                                    const TextSpan(text: ' and '),
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.baseline,
                                      baseline: TextBaseline.alphabetic,
                                      child: GestureDetector(
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
                                          ),
                                        ),
                                      ),
                                    ),
                                    const TextSpan(text: '.'),
                                  ],
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
          Obx(
            () => logic.isLoading.value
                ? Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.45),
                      child: Center(
                        child: Lottie.asset(
                          A.assets_loading_Welcome,
                          width: 220,
                          height: 220,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
