import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bilra/bilra/controllers/history_controller.dart';
import 'package:bilra/bilra/data/mock/mock_data.dart';
import 'package:bilra/bilra/data/models/makeup_analysis.dart';
import 'package:bilra/bilra/routes/app_router.dart';
import 'package:bilra/bilra/theme/app_theme.dart';
import 'package:bilra/bilra/utils/app_assets.dart';
import 'package:bilra/bilra/widgets/bilra_ui.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, this.index});

  final String? index;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late MakeupAnalysis _data;
  bool _isLoading = true;
  late int _resolvedIndex;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _resolvedIndex =
        widget.index != null ? int.tryParse(widget.index!) ?? 0 : 0;
    try {
      final controller = Get.find<HistoryController>();
      final historyLength = controller.historyItems.length;
      if (controller.hasHistory && _resolvedIndex < historyLength) {
        _data = controller.historyItems[_resolvedIndex];
      } else {
        final mockIndex = _resolvedIndex - historyLength;
        if (mockIndex >= 0 && mockIndex < allMockMakeupAnalysis.length) {
          _data = allMockMakeupAnalysis[mockIndex];
        } else if (_resolvedIndex >= 0 &&
            _resolvedIndex < allMockMakeupAnalysis.length) {
          _data = allMockMakeupAnalysis[_resolvedIndex];
        } else {
          _data = _getDefaultData();
        }
      }
    } catch (_) {
      if (_resolvedIndex >= 0 &&
          _resolvedIndex < allMockMakeupAnalysis.length) {
        _data = allMockMakeupAnalysis[_resolvedIndex];
      } else {
        _data = _getDefaultData();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  MakeupAnalysis _getDefaultData() {
    return MakeupAnalysis(
      assetImg: AppAssets.galleryAt(_resolvedIndex),
      faceAnalysis: FaceAnalysis(
        eyePresence:
            EyePresence(value: 'natural', confidence: 0.82, evidence: ''),
        lipPresence:
            LipPresence(value: 'glossy', confidence: 0.84, evidence: ''),
        overallVibe:
            OverallVibe(value: 'soft_glam', confidence: 0.88, evidence: ''),
        skinUndertone:
            SkinUndertone(value: 'neutral', confidence: 0.78, evidence: ''),
        faceStructure:
            FaceStructure(value: 'balanced', confidence: 0.86, evidence: ''),
      ),
      makeupRecommendation: MakeupRecommendation(
        primaryStyle: 'soft_peach_glow',
        styleTagline: 'A clean, photo-ready finish with gentle warmth.',
        keywords: const [
          'dewy base',
          'peach blush',
          'soft shimmer',
        ],
        whyItWorks:
            'This direction keeps the complexion airy while softly lifting the eyes and lips for a polished studio finish.',
        startWithTip:
            'Start with a thin luminous base and keep the cheek color diffused instead of sharply sculpted.',
      ),
      searchGuidance: SearchGuidance(
        tutorialSearchTerms: const [
          'soft glam peach makeup',
          'dewy studio makeup tutorial',
        ],
        copyableSearchPhrase: 'soft peach glow makeup tutorial for beginners',
        recommendedPlatforms: const [
          'YouTube',
          'Instagram',
          'TikTok',
        ],
      ),
      occasionMatch: OccasionMatch(
        suitableOccasions: const [
          'content_shooting',
          'day_date',
          'weekend_brunch',
        ],
        occasionNotes:
            'Ideal for natural-light photos, brunch plans, and any day you want an elevated but not heavy finish.',
      ),
      qualityCheck: QualityCheck(
        isAnalyzable: true,
        retryReason: '',
        imageQualityNotes: 'Well-lit image with visible facial detail.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: BilraBackdrop(
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryMain),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BilraBackdrop(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            children: [
              BilraTopBar(
                title: 'Look detail',
                subtitle: 'Image-first recommendation',
                leading: BilraIconChipButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => AppRoutes.pop(context),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              BilraGlassCard(
                padding: const EdgeInsets.all(10),
                radius: 32,
                child: AspectRatio(
                  aspectRatio: 0.78,
                  child: BilraImageFrame(
                    imagePath: _data.assetImg,
                    fallbackIndex: _resolvedIndex,
                    preferIndexedGalleryForBundledAssets: true,
                    borderRadius: 26,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              BilraGlassCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                radius: 30,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _titleCase(_data.makeupRecommendation.primaryStyle),
                      style: AppTextStyles.h2,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _data.makeupRecommendation.styleTagline,
                      style: AppTextStyles.caption.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _data.makeupRecommendation.keywords
                          .take(6)
                          .map(
                            (keyword) => BilraPill(
                              label: keyword,
                              color: AppColors.surfaceSecondary,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _DetailInfoCard(
                        title: 'Why it works',
                        icon: Icons.auto_awesome_rounded,
                        content: _data.makeupRecommendation.whyItWorks,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _DetailInfoCard(
                        title: 'Start with',
                        icon: Icons.brush_outlined,
                        content: _data.makeupRecommendation.startWithTip,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _AnalysisCard(data: _data),
              const SizedBox(height: AppSpacing.md),
              _DetailInfoCard(
                title: 'Best for',
                icon: Icons.event_available_rounded,
                content: _data.occasionMatch.occasionNotes,
                tags: _data.occasionMatch.suitableOccasions,
              ),
              const SizedBox(height: AppSpacing.md),
              _SearchGuidanceCard(data: _data),
              const SizedBox(height: AppSpacing.md),
              _DetailInfoCard(
                title: 'Image quality',
                icon: Icons.verified_outlined,
                content: _data.qualityCheck.imageQualityNotes.isEmpty
                    ? 'This photo is ready for recommendation refinement.'
                    : _data.qualityCheck.imageQualityNotes,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _titleCase(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}

class _DetailInfoCard extends StatelessWidget {
  const _DetailInfoCard({
    required this.title,
    required this.icon,
    required this.content,
    this.tags,
  });

  final String title;
  final IconData icon;
  final String content;
  final List<String>? tags;

  @override
  Widget build(BuildContext context) {
    return BilraGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 18, color: AppColors.primaryMain),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(title,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(content, style: AppTextStyles.caption.copyWith(fontSize: 14)),
          if (tags != null && tags!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags!
                  .map(
                    (tag) => BilraPill(
                      label: tag.replaceAll('_', ' '),
                      color: AppColors.surfaceTertiary,
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  const _AnalysisCard({
    required this.data,
  });

  final MakeupAnalysis data;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'Eye presence',
        data.faceAnalysis.eyePresence.value,
        data.faceAnalysis.eyePresence.confidence
      ),
      (
        'Lip finish',
        data.faceAnalysis.lipPresence.value,
        data.faceAnalysis.lipPresence.confidence
      ),
      (
        'Overall vibe',
        data.faceAnalysis.overallVibe.value,
        data.faceAnalysis.overallVibe.confidence
      ),
      (
        'Undertone',
        data.faceAnalysis.skinUndertone.value,
        data.faceAnalysis.skinUndertone.confidence
      ),
      (
        'Face shape',
        data.faceAnalysis.faceStructure.value,
        data.faceAnalysis.faceStructure.confidence
      ),
    ];

    return BilraGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Facial read', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.md),
          for (final item in items) ...[
            _AnalysisRow(
              label: item.$1,
              value: item.$2,
              confidence: item.$3,
            ),
            if (item != items.last) const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _AnalysisRow extends StatelessWidget {
  const _AnalysisRow({
    required this.label,
    required this.value,
    required this.confidence,
  });

  final String label;
  final String value;
  final double confidence;

  @override
  Widget build(BuildContext context) {
    final percent = (confidence * 100).round();
    final chipColor = confidence >= 0.9
        ? AppColors.semanticSuccess
        : confidence >= 0.75
            ? AppColors.semanticWarning
            : AppColors.semanticInfo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: AppTextStyles.small)),
            BilraPill(
              label: '$percent%',
              color: chipColor,
              foregroundColor: AppColors.textInverse,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value.replaceAll('_', ' '),
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _SearchGuidanceCard extends StatelessWidget {
  const _SearchGuidanceCard({
    required this.data,
  });

  final MakeupAnalysis data;

  @override
  Widget build(BuildContext context) {
    return BilraGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Search guidance', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.md),
          Text(
            data.searchGuidance.copyableSearchPhrase,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          ...data.searchGuidance.tutorialSearchTerms.map(
            (term) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Icon(
                      Icons.circle,
                      size: 7,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(term, style: AppTextStyles.caption)),
                ],
              ),
            ),
          ),
          if (data.searchGuidance.recommendedPlatforms.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: data.searchGuidance.recommendedPlatforms
                  .map(
                    (platform) => BilraPill(
                      label: platform,
                      color: AppColors.surfaceSecondary,
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
