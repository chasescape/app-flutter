import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../services/coins_manager.dart';
import '../../theme/app_border.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../ui/dreamy_ui.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final CoinsManager coinsManager = CoinsManager.to;

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            140,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Voreo',
                style: AppTypography.h1.copyWith(
                  color: AppColors.textDark,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Your hairstyle preview studio is ready.',
                style: AppTypography.body.copyWith(
                  color: AppColors.textGrey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ValueListenableBuilder<int>(
                valueListenable: coinsManager.coinBalanceNotifier,
                builder: (context, balance, child) {
                  return Container(
                    width: double.infinity,
                    padding: AppSpacing.allLG,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.82),
                      borderRadius:
                          BorderRadius.circular(AppBorder.radiusXLarge),
                      border: Border.all(color: AppColors.cardStroke),
                      boxShadow: AppShadows.shadowMD,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _HomeHeroText()),
                            SizedBox(width: AppSpacing.md),
                            _HeroBubbleCluster(),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Current balance: $balance coins',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Upload one selfie and generate a focused hairstyle suggestion with a cleaner, easier-to-use result flow.',
                          style: AppTypography.body.copyWith(
                            color: AppColors.textGrey,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: AppRoutes.toGenerate,
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: const Text('Create a new preview'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'How it works',
                style: AppTypography.h3.copyWith(color: AppColors.textDark),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'This is a simplified home page rebuild to make sure the main content always shows up first.',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textGrey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const _ExplainBubble(
                icon: Icons.photo_camera_back_rounded,
                title: '1. Upload one selfie',
                body: 'Start with one clear front-facing image.',
                tint: AppColors.softPink,
              ),
              const SizedBox(height: AppSpacing.md),
              const _ExplainBubble(
                icon: Icons.auto_awesome_rounded,
                title: '2. Generate one focused result',
                body:
                    'The app gives you one cleaner recommendation instead of a noisy grid.',
                tint: AppColors.softBlue,
              ),
              const SizedBox(height: AppSpacing.md),
              const _ExplainBubble(
                icon: Icons.content_cut_rounded,
                title: '3. Bring it to your barber',
                body:
                    'Use the preview and generated wording as your reference.',
                tint: AppColors.backgroundTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeroText extends StatelessWidget {
  const _HomeHeroText();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Visible home page',
          style: AppTypography.caption.copyWith(
            color: AppColors.textGrey,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Try a new hairstyle before you commit.',
          style: AppTypography.h2.copyWith(
            color: AppColors.textDark,
            height: 1.12,
          ),
        ),
      ],
    );
  }
}

class _HeroBubbleCluster extends StatelessWidget {
  const _HeroBubbleCluster();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      height: 74,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: 0,
            top: 2,
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.84),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cardStroke),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textDark,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'tool',
                      style: AppTypography.small.copyWith(
                        color: AppColors.textGrey,
                        fontSize: 10,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            left: 0,
            top: 0,
            child: _MiniToolTile(
              icon: Icons.face_retouching_natural_rounded,
              color: AppColors.softPink,
            ),
          ),
          const Positioned(
            left: 18,
            top: 18,
            child: _MiniToolTile(
              icon: Icons.content_cut_rounded,
              color: AppColors.softBlue,
            ),
          ),
          const Positioned(
            right: -2,
            bottom: 0,
            child: _MiniToolTile(
              icon: Icons.chat_bubble_outline_rounded,
              color: AppColors.backgroundTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniToolTile extends StatelessWidget {
  const _MiniToolTile({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(11),
        boxShadow: AppShadows.shadowSM,
      ),
      child: Icon(icon, size: 15, color: AppColors.textDark),
    );
  }
}

class _ExplainBubble extends StatelessWidget {
  const _ExplainBubble({
    required this.icon,
    required this.title,
    required this.body,
    required this.tint,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return DreamyGlassCard(
      radius: AppBorder.radiusXLarge,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.textDark),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textGrey,
                    height: 1.5,
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
