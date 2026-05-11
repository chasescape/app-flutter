import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/hairstyle_preview.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_border.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../ui/dreamy_ui.dart';

class HairstyleDetailPage extends StatelessWidget {
  const HairstyleDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final HairstylePreview? preview = Get.arguments as HairstylePreview?;

    if (preview == null) {
      return const Scaffold(
        body: DreamyEmptyState(
          title: 'Style not found',
          subtitle: 'We could not load this hairstyle preview.',
          icon: Icons.image_search_rounded,
        ),
      );
    }

    return DreamyPageScaffold(
      showFloor: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                120,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DreamyTopBar(
                    title: preview.title,
                    subtitle: preview.subtitle,
                    onBack: AppRoutes.goBack,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DreamyImageCard(
                    height: 420,
                    radius: AppBorder.radiusXLarge,
                    child: Image.asset(
                      preview.assetImg,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const DreamyImageFallback(label: 'Hero preview');
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      if ((preview.featureHighlight ?? '').isNotEmpty)
                        DreamyStatPill(label: preview.featureHighlight!),
                      if ((preview.maintenanceLevel ?? '').isNotEmpty)
                        DreamyStatPill(label: preview.maintenanceLevel!),
                      if ((preview.bestFor ?? '').isNotEmpty)
                        DreamyStatPill(label: preview.bestFor!),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  DreamyGlassCard(
                    radius: AppBorder.radiusXLarge,
                    padding: AppSpacing.allLG,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const DreamySectionLabel(
                          title: 'Why this look works',
                          subtitle:
                              'Placed below the image so the artwork stays clean.',
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          preview.whyBetter,
                          style: AppTypography.body.copyWith(
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          preview.howItWorks,
                          style: AppTypography.body.copyWith(
                            color: AppColors.textGrey,
                            height: 1.7,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (preview.oldAssetImgs.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    const DreamySectionLabel(
                      title: 'More angles',
                      subtitle:
                          'Supporting visuals stay secondary and never cover the hero.',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      height: 124,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: preview.oldAssetImgs.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: AppSpacing.md),
                        itemBuilder: (context, index) {
                          return SizedBox(
                            width: 96,
                            child: DreamyImageCard(
                              radius: AppBorder.radiusLarge,
                              child: Image.asset(
                                preview.oldAssetImgs[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const DreamyImageFallback(
                                    label: 'Alt view',
                                    icon: Icons.photo_library_outlined,
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  DreamyPrimaryButton(
                    label: 'Try this style',
                    onTap: AppRoutes.toGenerate,
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
