import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:mimiu/mimiu/app/modules/nav/nav_logic.dart';
import 'package:mimiu/mimiu/app/services/photo_scene_analysis_service.dart';
import 'package:mimiu/mimiu/app/widgets/page_header.dart';
import 'package:permission_handler/permission_handler.dart';

/// UI-only Upload page.
class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selected = const [];
  bool _uploading = false;

  Future<bool> _ensurePhotoPermission() async {
    final status = await Permission.photos.request();
    if (status.isGranted || status.isLimited) return true;
    final addOnly = await Permission.photosAddOnly.request();
    return addOnly.isGranted;
  }

  Future<void> _pickImages() async {
    if (_uploading) return;

    final allowed = await _ensurePhotoPermission();
    if (!allowed) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please allow photo access to continue.')),
      );
      return;
    }

    final files = await _picker.pickMultiImage(imageQuality: 92);
    if (!mounted) return;
    if (files.isEmpty) return;

    setState(() {
      _selected = files;
      _uploading = true;
    });

    // Simulate upload.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _uploading = false);
  }

  Future<void> _generate() async {
    if (_uploading) return;
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select photos first.')),
      );
      return;
    }

    final service = Get.isRegistered<PhotoSceneAnalysisService>()
        ? Get.find<PhotoSceneAnalysisService>()
        : Get.put(PhotoSceneAnalysisService(), permanent: true);

    // Fire-and-forget so user can navigate freely.
    unawaited(service.start(_selected));

    if (Get.isRegistered<NavLogic>()) {
      Get.find<NavLogic>().setView(NavViewType.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            const _Header(),
            Expanded(
              child: _Body(
                onPickImages: _pickImages,
                onGenerate: _generate,
                selected: _selected,
              ),
            ),
          ],
        ),
        if (_uploading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.55),
              child: const Center(
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        PageHeader(
          title: 'Upload Photos',
          titleSize: 30,
          subtitle: 'Select photos to organize',
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, 6),
          child: _QuotaBar(
            value: 0.72,
            gradient: LinearGradient(
              colors: [
                Color(0xFFFBBF24),
                Color(0xFFF59E0B),
                Color(0xFFF97316),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.onPickImages,
    required this.onGenerate,
    required this.selected,
  });

  final VoidCallback onPickImages;
  final VoidCallback onGenerate;
  final List<XFile> selected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 26),
      children: [
        const SizedBox(height: 18),
        // Height requested: 480
        SizedBox(
          height: 480,
          child: _UploadDropCard(
            onTap: onPickImages,
            selected: selected,
          ),
        ),
        if (selected.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black.withValues(alpha: 0.38),
              border: Border.all(
                color: const Color(0xFF92400E).withValues(alpha: 0.25),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 16,
                  color: Color(0xFFFBBF24),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'AI categorization costs 1 coin per photo.',
                    style: TextStyle(
                      color: Color(0xFFFDE68A),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 54,
            width: double.infinity,
            child: FilledButton(
              onPressed: onGenerate,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFBBF24).withValues(alpha: 0.95),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                  side: BorderSide(
                    color: const Color(0xFFFDE68A).withValues(alpha: 0.35),
                  ),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Analyze & Categorize',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
        ] else ...[
          const SizedBox(height: 18),
        ],
        const _QuickSortInfo(),
        const SizedBox(height: 22),
        const _InfoCard(
          icon: Icons.image_outlined,
          title: 'Batch Upload',
          subtitle: 'Upload multiple photos at once',
          accent: Color(0xFFFBBF24),
          strong: true,
        ),
        const SizedBox(height: 12),
        const _InfoCard(
          icon: Icons.flash_on_rounded,
          title: 'Gesture Control',
          subtitle: 'Swipe left-up to delete, right-down to keep',
          accent: Color(0xFFF59E0B),
        ),
      ],
    );
  }
}

class _UploadDropCard extends StatelessWidget {
  const _UploadDropCard({
    required this.onTap,
    required this.selected,
  });

  final VoidCallback onTap;
  final List<XFile> selected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 34, sigmaY: 34),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(42),
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.05,
                    colors: [
                      const Color(0xFFFBBF24).withValues(alpha: 0.28),
                      const Color(0xFFF59E0B).withValues(alpha: 0.16),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            border: Border.all(
              color: const Color(0xFF92400E).withValues(alpha: 0.45),
              width: 2,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade900.withValues(alpha: 0.86),
                Colors.black.withValues(alpha: 0.94),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF78350F).withValues(alpha: 0.55),
                blurRadius: 70,
                spreadRadius: 10,
                offset: const Offset(0, 26),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                if (selected.isNotEmpty)
                  Positioned.fill(
                    child: Image.file(
                      File(selected.first.path),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.18),
                          Colors.black.withValues(alpha: 0.78),
                        ],
                      ),
                    ),
                  ),
                ),
                if (selected.length > 1)
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: const Color(0xFFFBBF24).withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        '+${selected.length - 1}',
                        style: const TextStyle(
                          color: Color(0xFFFBBF24),
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                if (selected.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      children: [
                        const SizedBox(height: 28),
                        Container(
                          width: 124,
                          height: 124,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF92400E)
                                  .withValues(alpha: 0.35),
                              width: 2,
                            ),
                            color: Colors.black.withValues(alpha: 0.18),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.cloud_upload_rounded,
                              size: 56,
                              color: Color(0xFFFBBF24),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'Upload Photos',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFDE68A),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Tap to select photos',
                          style: TextStyle(
                            color: Color(0xFFE5E7EB),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_box_outlined,
                              size: 16,
                              color: Color(0xFFFBBF24),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Batch upload supported',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFBBF24),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 26),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
      ),
    );
  }
}

class _QuickSortInfo extends StatelessWidget {
  const _QuickSortInfo();

  @override
  Widget build(BuildContext context) {
    return const _BrightCard(
      radius: 30,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.bolt_rounded, color: Color(0xFFFBBF24), size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Sort Mode',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Swipe to organize quickly',
                    style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    this.strong = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return _BrightCard(
      radius: 30,
      accent: accent,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFF422006).withValues(alpha: 0.50),
              border: Border.all(
                color: const Color(0xFFFBBF24).withValues(alpha: 0.22),
              ),
            ),
            child: Icon(icon, color: accent, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _QuotaBar extends StatelessWidget {
  const _QuotaBar({required this.value, required this.gradient});

  final double value;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    final pct = value.clamp(0.0, 1.0);
    return Container(
      height: 10,
      decoration: BoxDecoration(
        color: Colors.grey.shade800.withValues(alpha: 0.50),
        borderRadius: BorderRadius.circular(999),
      ),
      clipBehavior: Clip.antiAlias,
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: pct,
          child: DecoratedBox(decoration: BoxDecoration(gradient: gradient)),
        ),
      ),
    );
  }
}

class _BrightCard extends StatelessWidget {
  const _BrightCard({
    required this.child,
    required this.radius,
    this.accent = const Color(0xFFFBBF24),
  });

  final Widget child;
  final double radius;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 34, sigmaY: 34),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius + 10),
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.05,
                    colors: [
                      accent.withValues(alpha: 0.28),
                      const Color(0xFFF59E0B).withValues(alpha: 0.16),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: const Color(0xFFFBBF24).withValues(alpha: 0.34),
              width: 2,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade900.withValues(alpha: 0.82),
                Colors.black.withValues(alpha: 0.94),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF78350F).withValues(alpha: 0.55),
                blurRadius: 70,
                spreadRadius: 10,
                offset: const Offset(0, 26),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }
}
