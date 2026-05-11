import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/glass_card.dart';
import '../../widgets/rova_background.dart';
import 'details_logic.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  void _showImagePreview(BuildContext context, String path) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.88),
      builder: (context) {
        return Dialog.fullscreen(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: Image.file(
                      File(path),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 18,
                right: 18,
                child: SafeArea(
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.14),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.of(context).pop(),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final DetailsLogic logic = Get.find<DetailsLogic>();

    final generatedPath = logic.generatedImagePath;
    final outfitPath = logic.outfitImagePath;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RovaBackground(
        blurSigma: 4,
        overlayColor: const Color(0x22FFFFFF),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x33FFE7EF),
            Color(0x22FFFFFF),
          ],
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
              const SizedBox(height: 12),
              GlassCard(
                borderRadius: 26,
                blurSigma: 20,
                backgroundColor: const Color(0x66FFFFFF),
                borderColor: const Color(0x66FFFFFF),
                shadowColor: const Color(0x12000000),
                highlight: false,
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nail Recommendation',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: generatedPath.isEmpty
                          ? Container(
                              height: 420,
                              color: Colors.white.withValues(alpha: 0.5),
                              child: Center(
                                child: Text(
                                  'No image',
                                  style: TextStyle(
                                    color: Colors.black.withValues(alpha: 0.55),
                                  ),
                                ),
                              ),
                            )
                          : InkWell(
                              onTap: () =>
                                  _showImagePreview(context, generatedPath),
                              child: Image.file(
                                File(generatedPath),
                                height: 280,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (outfitPath != null && outfitPath.isNotEmpty)
                GlassCard(
                  borderRadius: 22,
                  blurSigma: 18,
                  backgroundColor: const Color(0x66FFFFFF),
                  borderColor: const Color(0x66FFFFFF),
                  shadowColor: const Color(0x12000000),
                  highlight: false,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Outfit Photo',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          onTap: () => _showImagePreview(context, outfitPath),
                          child: Image.file(
                            File(outfitPath),
                            height: 380,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Obx(() {
                final desc = logic.description.value.trim();

                return GlassCard(
                  borderRadius: 22,
                  blurSigma: 18,
                  backgroundColor: const Color(0xBFFFFFFF),
                  borderColor: const Color(0x55FFFFFF),
                  shadowColor: const Color(0x14000000),
                  highlight: false,
                  padding: const EdgeInsets.all(14),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 3,
                              height: 16,
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFFFF4FA1).withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Effects Description',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Colors.black.withValues(alpha: 0.84),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          desc.isEmpty ? 'No description available.' : desc,
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.35,
                            color: Colors.black.withValues(alpha: 0.70),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
