import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../models/nail_models.dart';
import '../../routes/app_routes.dart';
import '../../services/ai_service.dart';
import '../../services/coin_manager.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<RecommendationResult> _recent = [];

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    final history = await AIService().getHistory();
    if (mounted) {
      setState(() => _recent = history.take(3).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.secondary,
      onRefresh: _loadRecent,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: AppSpacing.lg),
            _buildHero(context),
            const SizedBox(height: AppSpacing.xl),
            SectionTitle(
              eyebrow: 'Moodboard',
              title: 'Recent dreamy looks',
              subtitle: 'Image-first cards that keep the vibe front and center.',
              trailing: TextButton(
                onPressed: () => context.go(AppRoutes.history),
                child: const Text('View all'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_recent.isEmpty) _buildEmptyState(context),
            ..._recent.map((item) => _RecentCard(item: item)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, lovely',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Find a manicure mood\nthat matches your hands.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Obx(() => CoinBadge(
                  coins: CoinManager.to.coins.value,
                  onTap: () => context.push(AppRoutes.coins),
                )),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => context.go(AppRoutes.settings),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.bgCardStrong,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderSoft),
                ),
                child: const Icon(Icons.tune_rounded, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHero(BuildContext context) {
    return AppImageStage(
      height: 430,
      emptyTitle: 'Start with one hand photo',
      emptySubtitle: 'We turn your snapshot into a polished style moodboard.',
      onTap: () => context.go(AppRoutes.create),
      overlay: Positioned(
        top: 18,
        left: 18,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: const Text(
            'AI Nail Match',
            style: TextStyle(
              color: AppColors.textOnDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Minimal copy, maximum visual impact.',
            style: TextStyle(
              color: AppColors.textOnDark,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload your hand and preview glossy, soft, or playful directions.',
            style: TextStyle(
              color: AppColors.textOnDark,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              _HeroMetric(label: '3 looks'),
              SizedBox(width: 10),
              _HeroMetric(label: 'Image-first'),
              SizedBox(width: 10),
              _HeroMetric(label: 'Fast'),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 180,
            child: AppButton(
              text: 'Create my board',
              icon: Icons.arrow_forward_rounded,
              onPressed: () => context.go(AppRoutes.create),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'No moodboards yet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your future recommendations will appear here as large visual cards.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 170,
            child: AppButton(
              text: 'Upload photo',
              icon: Icons.photo_camera_back_outlined,
              onPressed: () => context.go(AppRoutes.create),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentCard extends StatelessWidget {
  final RecommendationResult item;

  const _RecentCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: AppImageStage(
        imagePath: item.imagePath,
        height: 300,
        onTap: () => context.push(
          AppRoutes.result,
          extra: {
            'imagePath': item.imagePath,
            'styles': item.styles,
            'sceneTag': item.sceneTag,
          },
        ),
        overlay: Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              item.sceneTag ?? 'Mood match',
              style: const TextStyle(
                color: AppColors.textOnDark,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        footer: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.styles.isNotEmpty ? item.styles.first.styleName : 'Dream Look',
                    style: const TextStyle(
                      color: AppColors.textOnDark,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${item.styles.length} curated directions',
                    style: const TextStyle(
                      color: Color(0xE6FFFFFF),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.arrow_forward_rounded, color: AppColors.textOnDark),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String label;

  const _HeroMetric({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textOnDark,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
