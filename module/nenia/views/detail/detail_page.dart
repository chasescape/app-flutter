import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/style_analysis.dart';
import '../../widgets/common/soft_ui.dart';

class DetailController extends GetxController {
  late StyleAnalysis analysis;

  @override
  void onInit() {
    super.onInit();
    analysis = Get.arguments as StyleAnalysis? ??
        StyleAnalysis(
          styleVibe: StyleVibe(value: '', confidence: 0, evidence: ''),
          hairstyleCategory:
              HairstyleCategory(value: '', confidence: 0, evidence: ''),
          makeupIntensity:
              MakeupIntensity(value: '', confidence: 0, evidence: ''),
          outfitStyle: OutfitStyle(value: '', confidence: 0, evidence: ''),
          photoMood: PhotoMood(value: '', confidence: 0, evidence: ''),
          styleTags: [],
          creatorTypesToFollow: [],
          searchKeywords: SearchKeywords(
            youtubeSearch: '',
            instagramSearch: '',
          ),
          styleDescription: StyleDescription(
            whyThisFits: '',
            keyTakeaways: [],
          ),
          quickActionPlan: QuickActionPlan(
            startWith: '',
            copyThisSearchPhrase: '',
          ),
          visualNotes: VisualNotes(
            dominantColors: [],
            notableAccessories: [],
            photoStrengths: [],
            easyImprovements: [],
          ),
          safetyCheck: SafetyCheck(
            hasQualityIssues: false,
            qualityNotes: '',
            shouldReshoot: false,
          ),
          assetImg: '',
        );
  }

  Future<void> share(BuildContext context) async {
    final title =
        analysis.styleVibe.value.isEmpty ? 'Style detail' : analysis.styleVibe.value;
    final summary = analysis.styleDescription.whyThisFits.isEmpty
        ? analysis.outfitStyle.value
        : analysis.styleDescription.whyThisFits;
    final tags = analysis.styleTags.take(3).map((tag) => '#$tag').join(' ');
    final textBuffer = StringBuffer(title);
    if (summary.isNotEmpty) {
      textBuffer.write('\n$summary');
    }
    if (tags.isNotEmpty) {
      textBuffer.write('\n$tags');
    }

    final box = context.findRenderObject() as RenderBox?;
    final shareOrigin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;

    try {
      final imagePath = analysis.assetImg;
      if (imagePath.isNotEmpty && await File(imagePath).exists()) {
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: textBuffer.toString(),
          subject: title,
          sharePositionOrigin: shareOrigin,
        );
      } else {
        await Share.share(
          textBuffer.toString(),
          subject: title,
          sharePositionOrigin: shareOrigin,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Share failed',
        'Unable to open the share sheet right now.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primaryMain.withValues(alpha: 0.92),
        colorText: AppColors.textInverse,
      );
    }
  }

  Future<void> copySearchPhrase() async {
    await Clipboard.setData(
      ClipboardData(text: analysis.quickActionPlan.copyThisSearchPhrase),
    );
    Get.snackbar(
      'Copied',
      'Search phrase copied to clipboard.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryMain.withValues(alpha: 0.92),
      colorText: AppColors.textInverse,
    );
  }
}

class DetailPage extends GetView<DetailController> {
  DetailPage({super.key}) {
    Get.put(DetailController());
  }

  @override
  Widget build(BuildContext context) {
    final analysis = controller.analysis;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NeniaBackdrop(
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NeniaInlineHeader(
                        title: 'Style detail',
                        subtitle: 'Image-led breakdown and next steps.',
                        onBack: Get.back,
                        trailing: NeniaCircleButton(
                          icon: Icons.share_outlined,
                          onTap: () => controller.share(context),
                        ),
                      ),
                      const SizedBox(height: 18),
                      ClipRRect(
                        borderRadius: AppBorderRadius.allXl,
                        child: SizedBox(
                          height: Get.height * 0.5,
                          width: double.infinity,
                          child: NeniaAdaptiveImage(
                            path: analysis.assetImg,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      NeniaSurface(
                        radius: 30,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            NeniaPageHeader(
                              label: 'Detail',
                              title: analysis.styleVibe.value.isEmpty
                                  ? 'Untitled look'
                                  : analysis.styleVibe.value,
                              subtitle:
                                  analysis.styleDescription.whyThisFits.isEmpty
                                      ? analysis.outfitStyle.value
                                      : analysis.styleDescription.whyThisFits,
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (analysis.outfitStyle.value.isNotEmpty)
                                  NeniaTagChip(
                                      label: analysis.outfitStyle.value),
                                if (analysis.photoMood.value.isNotEmpty)
                                  NeniaTagChip(label: analysis.photoMood.value),
                                ...analysis.styleTags
                                    .take(3)
                                    .map((tag) => NeniaTagChip(label: '#$tag')),
                              ],
                            ),
                            if (analysis
                                .styleDescription.keyTakeaways.isNotEmpty) ...[
                              const SizedBox(height: 18),
                              Text('Key takeaways',
                                  style:
                                      AppTextStyles.h3.copyWith(fontSize: 17)),
                              const SizedBox(height: 10),
                              ...analysis.styleDescription.keyTakeaways
                                  .take(3)
                                  .map(
                                    (takeaway) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.only(top: 6),
                                            child: Icon(Icons.circle,
                                                size: 8,
                                                color: AppColors.secondaryMain),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              takeaway,
                                              style: AppTextStyles.body
                                                  .copyWith(
                                                      color: AppColors
                                                          .textSecondary),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildMetrics(analysis),
                      const SizedBox(height: 16),
                      _buildActionPlan(analysis),
                      const SizedBox(height: 16),
                      _buildVisualNotes(analysis),
                      const SizedBox(height: 16),
                      _buildSearchKeywords(analysis),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetrics(StyleAnalysis analysis) {
    final cards = [
      _MetricData(
        icon: Icons.checkroom_rounded,
        title: 'Outfit',
        value: analysis.outfitStyle.value,
        confidence: analysis.outfitStyle.confidence,
      ),
      _MetricData(
        icon: Icons.face_rounded,
        title: 'Hair',
        value: analysis.hairstyleCategory.value,
        confidence: analysis.hairstyleCategory.confidence,
      ),
      _MetricData(
        icon: Icons.brush_rounded,
        title: 'Makeup',
        value: analysis.makeupIntensity.value,
        confidence: analysis.makeupIntensity.confidence,
      ),
      _MetricData(
        icon: Icons.camera_alt_rounded,
        title: 'Mood',
        value: analysis.photoMood.value,
        confidence: analysis.photoMood.confidence,
      ),
    ];

    const spacing = 12.0;
    final rows = <List<_MetricData>>[];
    for (var index = 0; index < cards.length; index += 2) {
      rows.add(cards.skip(index).take(2).toList());
    }

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: EdgeInsets.only(bottom: row == rows.last ? 0 : spacing),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < row.length; i++) ...[
                  Expanded(child: _buildMetricCard(row[i])),
                  if (i != row.length - 1) const SizedBox(width: spacing),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetricCard(_MetricData card) {
    return NeniaSurface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              gradient: AppColors.spotlightGradient,
              borderRadius: AppBorderRadius.allMd,
            ),
            child: Icon(card.icon, color: AppColors.primaryMain),
          ),
          const SizedBox(height: 18),
          Text(card.title,
              style: AppTextStyles.small.copyWith(letterSpacing: 0.4)),
          const SizedBox(height: 4),
          Text(
            card.value.isEmpty ? 'TBD' : card.value,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          const SizedBox(height: 12),
          Text(
            '${(card.confidence * 100).toInt()}% confidence',
            style: AppTextStyles.small.copyWith(color: AppColors.secondaryDark),
          ),
        ],
      ),
    );
  }

  Widget _buildActionPlan(StyleAnalysis analysis) {
    return NeniaSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NeniaPageHeader(
            label: 'Plan',
            title: 'Quick next steps',
            subtitle:
                'Keep the instructions separate from the image so the photo stays unobstructed.',
          ),
          const SizedBox(height: 16),
          _buildActionTile(
            icon: Icons.play_arrow_rounded,
            title: 'Start with',
            value: analysis.quickActionPlan.startWith,
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            icon: Icons.search_rounded,
            title: 'Search phrase',
            value: analysis.quickActionPlan.copyThisSearchPhrase,
            trailing: NeniaSecondaryButton(
              label: 'Copy',
              icon: Icons.copy_rounded,
              onPressed: controller.copySearchPhrase,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String value,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: AppBorderRadius.allMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: AppBorderRadius.allMd,
            ),
            child: Icon(icon, color: AppColors.primaryMain, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.small),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'No guidance yet.' : value,
                  style:
                      AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing,
          ],
        ],
      ),
    );
  }

  Widget _buildVisualNotes(StyleAnalysis analysis) {
    final sections = <MapEntry<String, List<String>>>[
      MapEntry('Dominant colors', analysis.visualNotes.dominantColors),
      MapEntry('Accessories', analysis.visualNotes.notableAccessories),
      MapEntry('Photo strengths', analysis.visualNotes.photoStrengths),
      MapEntry('Easy improvements', analysis.visualNotes.easyImprovements),
    ].where((entry) => entry.value.isNotEmpty).toList();

    return NeniaSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NeniaPageHeader(
            label: 'Notes',
            title: 'Visual observations',
            subtitle: 'Grouped as light chips for faster scanning.',
          ),
          const SizedBox(height: 14),
          ...sections.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.key,
                      style: AppTextStyles.small.copyWith(letterSpacing: 0.4)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: entry.value
                        .map((item) => NeniaTagChip(label: item))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          if (analysis.safetyCheck.hasQualityIssues ||
              analysis.safetyCheck.qualityNotes.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.peach.withValues(alpha: 0.6),
                borderRadius: AppBorderRadius.allMd,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.warning),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      analysis.safetyCheck.qualityNotes.isEmpty
                          ? 'This image may benefit from a reshoot.'
                          : analysis.safetyCheck.qualityNotes,
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchKeywords(StyleAnalysis analysis) {
    final keywords = [
      (
        'Instagram',
        analysis.searchKeywords.instagramSearch,
        Icons.camera_alt_outlined
      ),
      (
        'YouTube',
        analysis.searchKeywords.youtubeSearch,
        Icons.play_circle_outline_rounded
      ),
      (
        'Alt search',
        analysis.searchKeywords.alternativeSearch1 ?? '',
        Icons.travel_explore_rounded
      ),
    ].where((item) => item.$2.isNotEmpty).toList();

    return NeniaSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NeniaPageHeader(
            label: 'Search',
            title: 'Reference searches',
            subtitle:
                'Useful phrases for finding matching inspiration across platforms.',
          ),
          const SizedBox(height: 16),
          ...keywords.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildActionTile(
                icon: item.$3,
                title: item.$1,
                value: item.$2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricData {
  final IconData icon;
  final String title;
  final String value;
  final double confidence;

  const _MetricData({
    required this.icon,
    required this.title,
    required this.value,
    required this.confidence,
  });
}
