import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vesper/vesper/app/routes/app_routes.dart';
import 'package:vesper/gen_a/A.dart';

import 'login_logic.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final LoginLogic logic = Get.put(LoginLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 主内容
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(A.assets_vesper_open1),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const Spacer(),
                  // Bottom Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                    child: Column(
                      children: [
                        // Let's go Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              logic.onLetGoPressed();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF5D2E46),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Let's go",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                    // Terms and Privacy
                    GestureDetector(
                      onTap: () => logic.toggleAgreement(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Obx(() => Icon(
                            logic.isAgreed.value 
                                ? Icons.check_circle 
                                : Icons.circle_outlined,
                            size: 20,
                            color: const Color(0xFF5D2E46),
                          )),
                          const SizedBox(width: 8),
                          Flexible(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF5D2E46),
                                ),
                                children: [
                                  const TextSpan(text: 'By using App you agree with our '),
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: () => Get.toNamed('${AppRoutes.privacyPolicy}/terms'),
                                      child: const Text(
                                        'Terms & Conditions',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF5D2E46),
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const TextSpan(text: ' and '),
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: () => Get.toNamed('${AppRoutes.privacyPolicy}/privacy'),
                                      child: const Text(
                                        'Privacy Policy',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF5D2E46),
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
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
          ),
          
          // Loading 遮罩层
          Obx(() {
            if (!logic.isLoading.value) return const SizedBox.shrink();
            
            return Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
