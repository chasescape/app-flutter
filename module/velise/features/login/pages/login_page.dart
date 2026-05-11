import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../gen_a/A.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../env/app_env.dart';
import '../../../routes/app_pages.dart';
import '../controllers/login_controller.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8CADC),
              Color(0xFFF8F3EE),
              Color(0xFFE7CCFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 36, 28, 22),
            child: Column(
              children: [
                const Spacer(flex: 3),
                _buildBrandLockup(),
                const Spacer(flex: 4),
                _buildExploreButton(),
                const SizedBox(height: 16),
                _buildAgreementCopy(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandLockup() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.asset(
            A.assets_velise_velise,
            width: 78,
            height: 78,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Velise',
          style: AppTextStyles.h2Style.copyWith(
            color: Colors.black,
            fontWeight: AppTextStyles.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildExploreButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Obx(
        () => ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.onLoginTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.black87,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Explore now',
                  style: AppTextStyles.buttonStyle.copyWith(
                    color: Colors.white,
                    fontWeight: AppTextStyles.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildAgreementCopy() {
    final secondaryText = AppTextStyles.smallStyle.copyWith(
      color: Colors.black.withValues(alpha: 0.72),
      fontSize: 10.5,
      height: 1.45,
    );
    final linkText = secondaryText.copyWith(
      color: Colors.black,
      fontWeight: AppTextStyles.bold,
      decoration: TextDecoration.underline,
    );

    return Obx(
      () => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: controller.toggleAgreement,
            child: Container(
              width: 16,
              height: 16,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: controller.hasAgreedToTerms.value
                    ? Colors.black
                    : Colors.transparent,
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.82),
                  width: 1,
                ),
              ),
              child: controller.hasAgreedToTerms.value
                  ? const Icon(
                      Icons.check,
                      size: 11,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              children: [
                Text(
                  'By using App you agree with our ',
                  style: secondaryText,
                ),
                GestureDetector(
                  onTap: () => AppRoutes.toAgreement(
                    'Terms of Service',
                    AppEnv().h5User,
                  ),
                  child: Text(
                    'Terms & Conditions',
                    style: linkText,
                  ),
                ),
                Text(
                  ' and ',
                  style: secondaryText,
                ),
                GestureDetector(
                  onTap: () => AppRoutes.toAgreement(
                    'Privacy Policy',
                    AppEnv().h5Privacy,
                  ),
                  child: Text(
                    'Privacy Policy',
                    style: linkText,
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
