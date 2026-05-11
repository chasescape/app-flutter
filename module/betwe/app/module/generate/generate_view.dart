import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/app_background.dart';
import '../../widgets/app_colors.dart';
import 'generate_logic.dart';

class GeneratePage extends StatelessWidget {
  GeneratePage({super.key});

  final GenerateLogic logic = Get.put(GenerateLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        useImageBackground: true,
        safeArea: false,
        padding: EdgeInsets.zero,
        child: SafeArea(
          child: GetBuilder<GenerateLogic>(
            builder: (logic) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create Care Tip',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Upload a photo and write a short tip.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.35)),
                      ),
                      child: const Text(
                        'Each generation costs 100 coins',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Title',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'e.g. Perfect Sweater Care in 5 Steps',
                      hintStyle: const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.82),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _PhotoSection(
                    image: logic.selectedImage,
                    onTap: logic.uploadPhoto,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: logic.speechEnabled ? logic.toggleListening : null,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: logic.isListening
                                ? const Color(0xFFFF6B9D)
                                : Colors.white.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(10),
                            border: logic.isListening
                                ? null
                                : Border.all(color: Colors.black12),
                          ),
                          child: Icon(
                            logic.isListening ? Icons.mic : Icons.mic_none,
                            color: logic.isListening ? Colors.white : Colors.black54,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: logic.descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Share your steps and tips in a few sentences.',
                      hintStyle: const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.75),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF7BBF), Color(0xFFB67CFF)],
                        ),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: logic.publishPost,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.publish,color: Colors.white),
                        label: const Text(
                          'Publish',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoSection extends StatelessWidget {
  const _PhotoSection({
    required this.image,
    required this.onTap,
  });

  final File? image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 480,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFB67CFF).withOpacity(0.35)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB67CFF).withOpacity(0.18),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFFF7BBF), Color(0xFFB67CFF)],
                      ),
                    ),
                    child: const Icon(Icons.add_photo_alternate, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tap to upload photo',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'PNG or JPG up to 10MB',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.file(
                  image!,
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }
}
