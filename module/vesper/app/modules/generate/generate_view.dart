import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vesper/vesper/app/widgets/app_background.dart';

import 'generate_logic.dart';

class GeneratePage extends StatelessWidget {
  GeneratePage({super.key});

  final GenerateLogic logic = Get.put(GenerateLogic());

  static const Color ink = Color(0xFF2B1A2B);
  static const Color inkMuted = Color(0xFF6E5B6F);
  static const Color pinkA = Color(0xFFFF8AC4);
  static const Color pinkB = Color(0xFFFF6AB3);
  static const Color pinkC = Color(0xFFFF5BAA);
  static const Color gold = Color(0xFFFFC247);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        useImageBackground: true,
        safeArea: false,
        padding: EdgeInsets.zero,
        child: GetBuilder<GenerateLogic>(
          builder: (logic) {
            return Stack(
              children: [
                Positioned(
                  top: 140,
                  left: -40,
                  child: _blurBlob(color: pinkA.withOpacity(0.35), size: 180),
                ),
                Positioned(
                  bottom: 200,
                  right: -30,
                  child: _blurBlob(color: gold.withOpacity(0.25), size: 200),
                ),
                Positioned(
                  top: 360,
                  right: 30,
                  child: _blurBlob(
                    color: Colors.white.withOpacity(0.18),
                    size: 120,
                  ),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        const Text(
                          'Practice Mode',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: ink,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _sectionHeader(
                          title: 'Your Practice Photo',
                        ),
                        const SizedBox(height: 12),
                        _uploadCard(logic),
                        const SizedBox(height: 16),
                        _analyzeButton(logic),
                        const SizedBox(height: 16),
                        _tipsCard(),
                        if (logic.errorMessage != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            logic.errorMessage!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (logic.isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.12),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _uploadCard(GenerateLogic logic) {
    final image = logic.selectedImage;
    return Container(
      height: 480,
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8EE),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB60B63).withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: InkWell(
        onTap: logic.onPickPhoto,
        borderRadius: BorderRadius.circular(22),
        child: image == null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                    child: const Icon(
                      Icons.upload_rounded,
                      size: 34,
                      color: Color(0xFFFF2F8B),
                    ),
                    ),
                    const SizedBox(height: 12),
                  const Text(
                    'Upload your practice photo',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2B1A2B),
                    ),
                  ),
                    const SizedBox(height: 6),
                  Text(
                    'Take a clear photo matching the reference pose above',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6E5B6F),
                    ),
                  ),
                  ],
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.file(
                  image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
      ),
    );
  }

  Widget _tipsCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            pinkA.withOpacity(0.35),
            Color(0xFFFFB6D8).withOpacity(0.28),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.35),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 16,
                color: ink,
              ),
              SizedBox(width: 8),
              Text(
                'Photography Tips',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _tip('Clear lighting: Use natural or bright indoor light'),
          _tip('Full body: Ensure entire pose is visible in frame'),
          _tip('Match angle: Try to replicate the reference photo angle'),
          _tip('Plain background: Avoid busy or cluttered backgrounds'),
        ],
      ),
    );
  }

  Widget _analyzeButton(GenerateLogic logic) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF5AA9), Color(0xFFFF3A92)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF3A92).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: TextButton.icon(
          onPressed: logic.onAnalyze,
          icon: const Icon(Icons.upload_rounded, color: Colors.white),
          label: const Text(
            'Analyze Photo',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  // Details button removed: analysis now navigates immediately.

  Widget _sectionHeader({
    required String title,
    Widget? trailing,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ink,
              ),
            ),
          ],
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.35), width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
      ),
    );
  }

  Widget _tip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(color: ink, fontSize: 12),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: inkMuted,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blurBlob({required Color color, required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
