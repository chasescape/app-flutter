import 'dart:io';

import 'package:flutter/material.dart';
import 'package:havki/havki/app/theme/app_theme.dart';
import 'package:havki/havki/data/models/quote/quote_card_data.dart' hide SceneAnalysis;
import 'package:havki/havki/data/models/quote/quote_vibe_analysis_data.dart';

class DetailPage extends StatelessWidget {
  final dynamic quoteData;

  const DetailPage({
    super.key,
    required this.quoteData,
  });

  @override
  Widget build(BuildContext context) {
    if (quoteData is QuoteVibeAnalysisData) {
      return _buildQuoteVibeDetail(context, quoteData as QuoteVibeAnalysisData);
    }
    if (quoteData is QuoteCardData) {
      return _buildLegacyDetail(context, quoteData as QuoteCardData);
    }
    return const Scaffold(body: Center(child: Text('Invalid data type')));
  }

  Widget _buildLegacyDetail(BuildContext context, QuoteCardData data) {
    return _baseLayout(
      context,
      image: data.assetImg,
      body: [
        _quoteBlock(data.quote, data.author),
        const SizedBox(height: AppSpacing.md),
        const AppGlassCard(
          child: Text(
            'The image takes the lead here. Typography stays outside the frame so the scene keeps its breathing room.',
            style: TextStyle(
              fontSize: AppFontSizes.caption,
              color: AppColors.textSecondary,
              height: AppLineHeights.relaxed,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuoteVibeDetail(BuildContext context, QuoteVibeAnalysisData data) {
    return _baseLayout(
      context,
      image: data.assetImg,
      body: [
        _quoteBlock(data.firstCard.quote, data.firstCard.author),
        const SizedBox(height: AppSpacing.md),
        AppGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _tag(data.sceneAnalysis.primaryMood),
                  _tag(data.sceneAnalysis.timeOfDay),
                  _tag(data.styleSignature),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                data.sceneAnalysis.sceneDescription,
                style: const TextStyle(
                  fontSize: AppFontSizes.body,
                  color: AppColors.textPrimary,
                  height: AppLineHeights.normal,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Subjects: ${data.sceneAnalysis.visualElements.subjects.join(', ')}',
                style: const TextStyle(
                  fontSize: AppFontSizes.caption,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...data.quoteCards.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: SizedBox(
              width: double.infinity,
              child: AppGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.quote,
                      style: const TextStyle(
                        fontSize: AppFontSizes.body,
                        fontWeight: AppFontWeights.semibold,
                        color: AppColors.textPrimary,
                        height: AppLineHeights.normal,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      item.author,
                      style: const TextStyle(
                        fontSize: AppFontSizes.caption,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      item.interpretation,
                      style: const TextStyle(
                        fontSize: AppFontSizes.caption,
                        color: AppColors.textPrimary,
                        height: AppLineHeights.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _baseLayout(
    BuildContext context, {
    required String image,
    required List<Widget> body,
  }) {
    return Scaffold(
      body: AppBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              backgroundColor: Colors.transparent,
              pinned: true,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.xxxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: image,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                        child: AspectRatio(
                          aspectRatio: 0.82,
                          child: _buildImage(image),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ...body,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quoteBlock(String quote, String author) {
    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Featured line',
            style: TextStyle(
              fontSize: AppFontSizes.small,
              letterSpacing: 1.2,
              fontWeight: AppFontWeights.semibold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            quote,
            style: const TextStyle(
              fontSize: AppFontSizes.h3,
              fontWeight: AppFontWeights.bold,
              color: AppColors.textPrimary,
              height: AppLineHeights.normal,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            author,
            style: const TextStyle(
              fontSize: AppFontSizes.caption,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String image) {
    if (image.startsWith('assets/')) {
      return Image.asset(
        image,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return Image.file(
      File(image),
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Text(
            'Image unavailable',
            style: TextStyle(
              fontSize: AppFontSizes.caption,
              color: AppColors.textSecondary,
            ),
          ),
        );
      },
    );
  }

  Widget _tag(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppBorderRadius.full),
      ),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: AppFontSizes.small,
          fontWeight: AppFontWeights.semibold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
