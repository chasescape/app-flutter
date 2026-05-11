import 'package:flutter/material.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/widgets/glass_card.dart';
import '../../app/widgets/bounce_in_animation.dart';
import '../../data/models/snap_analysis.dart';

class DetailPage extends StatelessWidget {
  final SnapAnalysis data;

  const DetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A0A2E), Color(0xFF120820)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // AppBar
                GlassAppBar(
                  title: 'Analysis',
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.share_outlined, size: 20),
                      onPressed: () {
                        final text = [
                          data.diagnosis.oneLineSummary,
                          '',
                          data.shareCaption,
                        ].where((e) => e.trim().isNotEmpty).join('\n');

                        Share.share(text, subject: 'Halee Analysis');
                      },
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero image with overlay text
                        BounceInAnimation(
                          delay: const Duration(milliseconds: 100),
                          child: _HeroImage(data: data),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Core conclusion - prominent
                        BounceInAnimation(
                          delay: const Duration(milliseconds: 200),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              gradient: AppColors.accentGradient.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusXl),
                              border: Border.all(color: AppColors.accentMain.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.auto_awesome, color: AppColors.accentMain, size: 18),
                                    SizedBox(width: 6),
                                    Text(
                                      'AI Summary',
                                      style: TextStyle(
                                        color: AppColors.accentMain,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  data.diagnosis.oneLineSummary,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        height: 1.5,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Scene attributes - chips
                        BounceInAnimation(
                          delay: const Duration(milliseconds: 250),
                          child: _SceneAttributesCard(sceneCard: data.sceneCard),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Strengths
                        BounceInAnimation(
                          delay: const Duration(milliseconds: 300),
                          child: _SectionCard(
                            title: 'Strengths',
                            icon: Icons.star_rounded,
                            child: Column(
                              children: data.diagnosis.strengths.map((s) => Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 6),
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: AppColors.success,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        s,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              height: 1.5,
                                              color: AppColors.textPrimary.withValues(alpha: 0.88),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              )).toList(),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Top improvement
                        BounceInAnimation(
                          delay: const Duration(milliseconds: 350),
                          child: _SectionCard(
                            title: 'Top Improvement',
                            icon: Icons.trending_up_rounded,
                            child: Text(
                              data.diagnosis.topImprovement,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    height: 1.5,
                                    color: AppColors.accentMain,
                                  ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Improvement tips
                        BounceInAnimation(
                          delay: const Duration(milliseconds: 400),
                          child: _SectionCard(
                            title: 'Improvement Tips',
                            icon: Icons.lightbulb_rounded,
                            child: Column(
                              children: data.improvementTips.map((tip) => Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                child: _TipCard(tip: tip),
                              )).toList(),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Creative variants
                        BounceInAnimation(
                          delay: const Duration(milliseconds: 450),
                          child: _SectionCard(
                            title: 'Creative Variants',
                            icon: Icons.palette_rounded,
                            child: Column(
                              children: data.creativeVariants.map((v) => Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                                child: _VariantCard(variant: v),
                              )).toList(),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Fun fact - collapsible style, lower contrast
                        BounceInAnimation(
                          delay: const Duration(milliseconds: 500),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.cardBg,
                              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusXl),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.info_outline_rounded, color: AppColors.textPrimary.withValues(alpha: 0.72), size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Did You Know?',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppColors.textPrimary.withValues(alpha: 0.86),
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  data.funFact,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.textPrimary.withValues(alpha: 0.78),
                                        height: 1.5,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Share caption
                        BounceInAnimation(
                          delay: const Duration(milliseconds: 550),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.cardBg,
                              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusXl),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Share Caption',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.textPrimary.withValues(alpha: 0.86),
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  data.shareCaption,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.textPrimary.withValues(alpha: 0.76),
                                        height: 1.5,
                                        fontStyle: FontStyle.italic,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Tags
                        const SizedBox(height: AppSpacing.md),
                        BounceInAnimation(
                          delay: const Duration(milliseconds: 600),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: data.tags.map((tag) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryMain.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: Text(
                                tag,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.accentMain,
                                    ),
                              ),
                            )).toList(),
                          ),
                        ),

                        const SizedBox(height: 120),
                      ],
                    ),
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

// --- Sub-widgets ---

class _HeroImage extends StatelessWidget {
  final SnapAnalysis data;
  const _HeroImage({required this.data});

  Widget _buildImage(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(path,
          width: double.infinity, height: 480, fit: BoxFit.cover);
    }
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(file,
          width: double.infinity, height: 480, fit: BoxFit.cover);
    }
    return Container(
      width: double.infinity,
      height: 480,
      color: AppColors.cardBg,
      child:
          const Icon(Icons.broken_image, size: 48, color: AppColors.textSecondary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusXl),
          child: _buildImage(data.assetImg),
        ),
        // Gradient overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusXl),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        // Overlay text
        Positioned(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: AppSpacing.md,
          child: Text(
            data.sceneCard.scene.value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
            ),
          ),
        ),
      ],
    );
  }
}

class _SceneAttributesCard extends StatelessWidget {
  final SceneCard sceneCard;
  const _SceneAttributesCard({required this.sceneCard});

  @override
  Widget build(BuildContext context) {
    final attrs = [
      ('Subject', sceneCard.subjectType.value, sceneCard.subjectType.confidence),
      ('Lighting', sceneCard.lighting.value, sceneCard.lighting.confidence),
      ('Composition', sceneCard.composition.value, sceneCard.composition.confidence),
      ('Color Tone', sceneCard.colorTone.value, sceneCard.colorTone.confidence),
      ('Atmosphere', sceneCard.atmosphere.value, sceneCard.atmosphere.confidence),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusXl),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.grid_view_rounded, color: AppColors.accentMain, size: 16),
              const SizedBox(width: 6),
              Text(
                'Scene Analysis',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: attrs.map((a) => _AttrChip(label: a.$1, value: a.$2, confidence: a.$3)).toList(),
          ),
        ],
      ),
    );
  }
}

class _AttrChip extends StatelessWidget {
  final String label;
  final String value;
  final double confidence;
  const _AttrChip({required this.label, required this.value, required this.confidence});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accentMain.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
        border: Border.all(color: AppColors.accentMain.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.accentMain,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '${(confidence * 100).toStringAsFixed(0)}%',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusXl),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.accentMain, size: 18),
              const SizedBox(width: 6),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final ImprovementTip tip;
  const _TipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.backgroundOverlay,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondaryMain.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tip.category,
                  style: const TextStyle(
                    color: AppColors.secondaryMain,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  tip.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary.withValues(alpha: 0.90),
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            tip.action,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  height: 1.4,
                  color: AppColors.textPrimary.withValues(alpha: 0.82),
                ),
          ),
          const SizedBox(height: 2),
          Text(
            'Expected: ${tip.expectedResult}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary.withValues(alpha: 0.62),
                  height: 1.4,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }
}

class _VariantCard extends StatelessWidget {
  final CreativeVariant variant;
  const _VariantCard({required this.variant});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.backgroundOverlay,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  variant.style,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            variant.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  height: 1.4,
                  color: AppColors.textPrimary.withValues(alpha: 0.82),
                ),
          ),
          const SizedBox(height: 2),
          Text(
            variant.executionTip,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary.withValues(alpha: 0.62),
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }
}
