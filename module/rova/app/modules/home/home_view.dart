import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/rova_background.dart';
import '../nav/nav_logic.dart';
import 'home_logic.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: false,
      body: RovaBackground(
        blurSigma: 4,
        overlayColor: Color(0x33FFFFFF),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x33FFE7EF),
            Color(0x22FFFFFF),
          ],
        ),
        child: _HomeBody(),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  Widget build(BuildContext context) {
    final HomeLogic logic = Get.find<HomeLogic>();
    const Color pink = Color(0xFFE84B7B);
    const Color cardPink = Color(0xFFFFF6F9);

    return SafeArea(
      top: false,
      child: Obx(() {
        final images = logic.generatedImages;
        if (images.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 66, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _HomeHeader(),
                const SizedBox(height: 14),
                _BigCard(
                  title: 'Your latest designs',
                  subtitle:
                      'Generated nail ideas will show up here. Tap a card to preview or share later.',
                  color: cardPink,
                  leading: const Icon(Icons.auto_awesome, color: pink),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pink,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    onPressed: () {
                      final navLogic = Get.find<NavLogic>();
                      navLogic.setTab(1);
                    },
                    child: const Text('Create'),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Recent',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const spacing = 12.0;
                      final itemWidth =
                          (constraints.maxWidth - spacing) / 2.0;
                      return SingleChildScrollView(
                        child: Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: [
                            for (final item in images)
                              SizedBox(
                                width: itemWidth,
                                child: _ImageCard(
                                  label: _formatDate(item.createdAt),
                                  aiCopy: item.aiCopy,
                                  pathOrUrl: item.pathOrUrl,
                                  color: cardPink,
                                  onTap: () {
                                    Get.toNamed(
                                      AppRoutes.details,
                                      arguments: {
                                        'generatedImagePath': item.pathOrUrl,
                                        'outfitImagePath': null,
                                        'aiCopy': item.aiCopy,
                                        'outfitNotes': '',
                                        'preferredColors': '',
                                        'preferredStyle': '',
                                        'preferredElements': '',
                                        'customPrompt': '',
                                      },
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 84, 16, 16),
          children: [
            const _HomeHeader(),
            const SizedBox(height: 14),
            _HeroCard(
              title: 'Upload a selfie, get AI nail ideas',
              subtitle:
                  'Upload your selfie or a photo that shows your style. AI image-to-image will recommend nail designs that fit you. Each generation costs 100 coins.',
              buttonText: 'Generate',
              onPressed: () {
                final navLogic = Get.find<NavLogic>();
                navLogic.setTab(1);
              },
            ),
            const SizedBox(height: 14),
            const Text(
              'How it works',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            const _SmallCard(
              icon: Icons.face_retouching_natural_outlined,
              title: 'Upload a selfie or style photo',
              body:
                  'Use a clear selfie, outfit photo, or any image that best expresses your vibe.',
            ),
            const SizedBox(height: 10),
            const _SmallCard(
              icon: Icons.style_outlined,
              title: 'Upload your reference photo',
              body:
                  'Upload a selfie or style photo, then let AI analyze the visual vibe directly.',
            ),
            const SizedBox(height: 10),
            const _SmallCard(
              icon: Icons.auto_awesome_outlined,
              title: 'AI image-to-image recommendation',
              body:
                  'The model analyzes your photo style and generates nail designs that suit you.',
            ),
            const SizedBox(height: 120),
          ],
        );
      }),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to Rova',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Colors.black.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Start Your Design',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _BigCard extends StatelessWidget {
  const _BigCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.leading,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final Color color;
  final Widget leading;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      backgroundColor: const Color(0x88FFFFFF),
      borderColor: const Color(0x55FFFFFF),
      shadowColor: Colors.black.withValues(alpha: 0.10),
      highlight: false,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
            ),
            child: Center(child: leading),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    height: 1.25,
                    fontSize: 12.5,
                    color: Colors.black.withValues(alpha: 0.70),
                  ),
                ),
                const SizedBox(height: 12),
                Align(alignment: Alignment.centerLeft, child: trailing),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const Color pink = Color(0xFFE84B7B);
    return GlassCard(
      borderRadius: 26,
      blurSigma: 18,
      backgroundColor: const Color(0xD9FFE7EF),
      borderColor: const Color(0x66FFFFFF),
      shadowColor: Colors.black.withValues(alpha: 0.14),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      highlight: false,
      child: SizedBox(
        height: 330,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 2),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 20,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.file_upload_outlined,
                  color: pink,
                  size: 30,
                ),
              ),
            ),
            Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    height: 1.25,
                    fontSize: 12.5,
                    color: Colors.black.withValues(alpha: 0.62),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC93C).withValues(alpha: 0.95),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Each generation costs 100 coins',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.black.withValues(alpha: 0.62),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFFFF4FA1),
                      Color(0xFFE84B7B),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: pink.withValues(alpha: 0.28),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  onPressed: onPressed,
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallCard extends StatelessWidget {
  const _SmallCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    const Color pink = Color(0xFFE84B7B);
    return GlassCard(
      borderRadius: 16,
      blurSigma: 12,
      backgroundColor: const Color(0x80FFFFFF),
      borderColor: const Color(0x55FFFFFF),
      shadowColor: Colors.black.withValues(alpha: 0.08),
      padding: const EdgeInsets.all(14),
      highlight: false,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE7EF).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Icon(icon, size: 18, color: pink)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: TextStyle(
                    height: 1.25,
                    fontSize: 12,
                    color: Colors.black.withValues(alpha: 0.68),
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

class _ImageCard extends StatelessWidget {
  const _ImageCard({
    required this.label,
    required this.pathOrUrl,
    required this.aiCopy,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String pathOrUrl;
  final String aiCopy;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: GlassCard(
          borderRadius: 18,
          blurSigma: 14,
          backgroundColor: const Color(0x88FFFFFF),
          borderColor: const Color(0x55FFFFFF),
          shadowColor: Colors.black.withValues(alpha: 0.10),
          padding: const EdgeInsets.all(14),
          highlight: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  height: 118,
                  width: double.infinity,
                  child: _thumb(pathOrUrl),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                aiCopy.trim().isEmpty ? 'No description yet.' : aiCopy.trim(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.25,
                  color: Colors.black.withValues(alpha: 0.64),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _thumb(String value) {
    final v = value.trim();
    if (v.isEmpty) return _thumbPlaceholder();

    if (v.startsWith('http://') || v.startsWith('https://')) {
      return Image.network(
        v,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _thumbPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.white.withValues(alpha: 0.35),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: const Color(0xFFE84B7B).withValues(alpha: 0.7),
                ),
              ),
            ),
          );
        },
      );
    }

    return Image.file(
      File(v),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _thumbPlaceholder(),
    );
  }

  Widget _thumbPlaceholder() {
    const Color pink = Color(0xFFE84B7B);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            pink.withValues(alpha: 0.24),
            const Color(0xFFFFC3D6).withValues(alpha: 0.35),
            Colors.white.withValues(alpha: 0.3),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: pink.withValues(alpha: 0.75),
          size: 28,
        ),
      ),
    );
  }
}
