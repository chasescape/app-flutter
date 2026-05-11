import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/nail_models.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class ResultPage extends StatelessWidget {
  final String imagePath;
  final List<NailStyleCard> styles;
  final String? sceneTag;

  const ResultPage({
    super.key,
    required this.imagePath,
    required this.styles,
    this.sceneTag,
  });

  @override
  Widget build(BuildContext context) {
    return DreamScaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        title: const Text('Your Moodboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 110, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppImageStage(
              imagePath: imagePath,
              height: 430,
              overlay: sceneTag != null
                  ? Positioned(
                      top: 18,
                      left: 18,
                      child: StyleTagChip(label: sceneTag!, isSelected: true),
                    )
                  : null,
              footer: const Text(
                'Your photo stays clear and unobstructed. Details live below.',
                style: TextStyle(
                  color: AppColors.textOnDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const SectionTitle(
              eyebrow: 'Details',
              title: 'Three polished directions',
              subtitle: 'Short, visual, and easy to show your nail artist.',
            ),
            const SizedBox(height: AppSpacing.md),
            ...styles.asMap().entries.map(
              (entry) => _StyleCard(index: entry.key + 1, card: entry.value),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'Try another photo',
                isOutlined: true,
                icon: Icons.refresh_rounded,
                onPressed: () => context.go(AppRoutes.create),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'Create another',
                icon: Icons.add_a_photo_rounded,
                onPressed: () => context.go(AppRoutes.create),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StyleCard extends StatelessWidget {
  final int index;
  final NailStyleCard card;

  const _StyleCard({required this.index, required this.card});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.heroGradient,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      color: AppColors.textOnDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  card.styleName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: card.styleTags.map((tag) => StyleTagChip(label: tag)).toList(),
          ),
          const SizedBox(height: 16),
          _InfoTile(title: 'Scene fit', content: card.sceneFit),
          const SizedBox(height: 10),
          _InfoTile(title: 'Why it works', content: card.whyItFits),
          const SizedBox(height: 14),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.draw_outlined, color: AppColors.secondary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    card.visualKeywords.join('  ·  '),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => copyToClipboard(context, card.visualKeywords.join(', ')),
                  child: const Icon(Icons.copy_rounded, color: AppColors.secondary, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String content;

  const _InfoTile({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.favorite_outline_rounded, color: AppColors.accent, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: content,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
