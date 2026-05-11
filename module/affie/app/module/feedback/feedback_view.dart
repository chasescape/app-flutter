import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:affie/gen_a/A.dart';
import 'dart:ui';
import 'feedback_logic.dart';
import '../../theme/app_colors.dart';

class FeedbackPage extends StatelessWidget {
  FeedbackPage({super.key});

  final FeedbackLogic logic = Get.put(FeedbackLogic());

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Feedback',
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeSelection(),
            const SizedBox(height: 24),
            _buildInputSection(),
            const SizedBox(height: 30),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelection() {
    final isDark = Get.context != null && Theme.of(Get.context!).brightness == Brightness.dark;
    final types = [
      'Feature request',
      'Bug report',
      'UI improvement',
      'Other',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Feedback type',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: types.map((type) {
                final isSelected = logic.selectedType.value == type;
                return GestureDetector(
                  onTap: () => logic.selectType(type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: AppColors.gradientPink,
                            )
                          : null,
                      color: isSelected
                          ? null
                          : (isDark ? AppColors.darkCard : Colors.white)
                              .withOpacity(isDark ? 0.35 : 0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : AppColors.primary.withOpacity(0.22),
                      ),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.primaryDark),
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
      ],
    );
  }

  Widget _buildInputSection() {
    final isDark = Get.context != null && Theme.of(Get.context!).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkCard : Colors.white)
                    .withOpacity(isDark ? 0.55 : 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.15)),
              ),
              child: Stack(
                children: [
                  TextField(
                    controller: logic.contentController,
                    maxLines: 8,
                    decoration: InputDecoration(
                      hintText:
                          'Describe what happened and what you expected...',
                      hintStyle: TextStyle(
                        color: (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)
                            .withOpacity(0.8),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: TextStyle(
                      fontSize: 15,
                      color:
                          isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
                    ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Obx(
                      () => _VoiceButton(
                        isActive: logic.isListening.value,
                        onTap: () => logic.toggleVoiceInput(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageItem(String image) {
    final isDark = Get.context != null && Theme.of(Get.context!).brightness == Brightness.dark;

    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: (isDark ? AppColors.darkCard : Colors.white)
                .withOpacity(isDark ? 0.55 : 0.8),
            border: Border.all(color: AppColors.primary.withOpacity(0.12)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(A.assets_affie_logo, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: -5,
          right: -5,
          child: GestureDetector(
            onTap: () => logic.removeImage(image),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.95),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageButton() {
    final isDark = Get.context != null && Theme.of(Get.context!).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => logic.addImage(),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: (isDark ? AppColors.darkCard : Colors.white)
              .withOpacity(isDark ? 0.35 : 0.8),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.22),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate,
              color: AppColors.primary,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              'Add',
              style: TextStyle(
                fontSize: 12,
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    final isDark = Get.context != null && Theme.of(Get.context!).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact (optional)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkCard : Colors.white)
                    .withOpacity(isDark ? 0.55 : 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.15)),
              ),
              child: TextField(
                controller: logic.contactController,
                decoration: InputDecoration(
                  hintText: 'Email or phone number',
                  hintStyle: TextStyle(
                    color: (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)
                        .withOpacity(0.8),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  prefixIcon: const Icon(
                    Icons.contact_mail,
                    color: AppColors.primary,
                  ),
                ),
                style: TextStyle(
                  fontSize: 15,
                  color:
                      isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final isDark = Get.context != null && Theme.of(Get.context!).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => logic.submitFeedback(),
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.secondary,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(isDark ? 0.25 : 0.45),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Submit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _VoiceButton extends StatelessWidget {
  const _VoiceButton({
    required this.isActive,
    required this.onTap,
  });

  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isActive
                ? const LinearGradient(colors: AppColors.gradientSunset)
                : null,
            color: isActive
                ? null
                : (isDark ? AppColors.darkCard : Colors.white)
                    .withOpacity(isDark ? 0.35 : 0.7),
            border: Border.all(
              color: isActive
                  ? Colors.transparent
                  : AppColors.primary.withOpacity(0.18),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? Icons.mic_rounded : Icons.mic_none_rounded,
                size: 18,
                color: isActive
                    ? Colors.white
                    : (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.primaryDark),
              ),
              const SizedBox(width: 8),
              Text(
                isActive ? 'Listening' : 'Voice',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isActive
                      ? Colors.white
                      : (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.primaryDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
