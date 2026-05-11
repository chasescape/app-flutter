import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../core/models/ingredient_analysis.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_routes.dart';
import '../../core/services/ai_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';

class ResultPage extends ConsumerStatefulWidget {
  const ResultPage({super.key});

  @override
  ConsumerState<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends ConsumerState<ResultPage> {
  bool _isLoading = true;
  IngredientAnalysis? _analysis;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _analyze();
      }
    });
  }

  Future<void> _analyze() async {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args == null) {
      setState(() {
        _error = 'Invalid arguments';
        _isLoading = false;
      });
      return;
    }

    final userData = ref.read(userDataProvider);
    final cost = ref.read(analysisCostProvider);

    if (userData.freeUses <= 0 && userData.coins < cost) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showInsufficientCoinsDialog(cost);
        }
      });
      return;
    }

    try {
      IngredientAnalysis result;

      if (args['imagePath'] != null) {
        result = await AiService.instance.analyzeImage(args['imagePath']);
      } else if (args['productName'] != null) {
        result = await AiService.instance.analyzeText(args['productName'], '');
      } else if (args['analysis'] != null) {
        result = args['analysis'] as IngredientAnalysis;
      } else {
        throw Exception('Invalid arguments');
      }

      if (args['analysis'] == null) {
        await ref.read(userDataProvider.notifier).consumeAnalysis(cost);
        await ref.read(analysisHistoryProvider.notifier).addAnalysis(result);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _analysis = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showInsufficientCoinsDialog(int cost) {
    Get.dialog(
      AlertDialog(
        title: const Text('Insufficient coins'),
        content: Text('You need $cost coins to analyze this item.'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              AppRoutes.back();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.offNamed(AppRoutes.coinStore);
            },
            child: const Text('Get coins'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: AppBackground(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: AppSpacing.lg),
                Text(
                  'Decoding ingredients...\nThis may take a moment.',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: AppBackground(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: AppCard(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      _error!,
                      style: AppTextStyles.body,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      text: 'Go back',
                      onPressed: Get.back,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_analysis == null) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: AppBackground(
          child: Center(child: Text('No data')),
        ),
      );
    }

    final analysis = _analysis!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      _ActionCircleButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: Get.back,
                      ),
                      const Spacer(),
                      const _ActionCircleButton(
                        icon: Icons.home_rounded,
                        onTap: AppRoutes.toMain,
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppBorderRadius.xlarge),
                    child: AspectRatio(
                      aspectRatio: 0.92,
                      child: AppRemoteImage(imageUrl: analysis.imageUrl),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOverviewCard(analysis),
                      const SizedBox(height: AppSpacing.lg),
                      _buildSummaryCard(analysis),
                      const SizedBox(height: AppSpacing.lg),
                      _buildIngredientsCard(analysis),
                      if (analysis.warnings.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.lg),
                        _buildWarningsCard(analysis),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      _buildCategoriesCard(analysis),
                      const SizedBox(height: AppSpacing.xl),
                      const Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              text: 'Scan another',
                              isOutlined: true,
                              onPressed: AppRoutes.toMain,
                            ),
                          ),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppButton(
                              text: 'Get coins',
                              onPressed: AppRoutes.toCoinStore,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildOverviewCard(IngredientAnalysis analysis) {
    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (analysis.categories.isNotEmpty)
                IngredientCategoryTag(
                  category: analysis.categories.first.split(' ').first,
                ),
              AppStatPill(
                icon: Icons.schedule_rounded,
                label: _formatDate(analysis.createdAt),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            analysis.productName,
            style: AppTextStyles.h2.copyWith(fontSize: 26),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: AppGradients.hero,
              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'AI-generated for reference. Verify with official product information.',
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.textPrimary,
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

  Widget _buildSummaryCard(IngredientAnalysis analysis) {
    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: 'Overview',
            subtitle: 'A short take before the detailed breakdown.',
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            analysis.summary,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsCard(IngredientAnalysis analysis) {
    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: 'Ingredient breakdown',
            subtitle: '${analysis.ingredients.length} items decoded',
          ),
          const SizedBox(height: AppSpacing.md),
          ...analysis.ingredients.map((ingredient) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ingredient.name,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (ingredient.commonName.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                ingredient.commonName,
                                style: AppTextStyles.small,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      SafetyRatingIndicator(rating: ingredient.safetyRating),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  IngredientCategoryTag(category: ingredient.category),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    ingredient.description,
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWarningsCard(IngredientAnalysis analysis) {
    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: 'Alerts',
            subtitle: 'Things worth double-checking before you buy.',
          ),
          const SizedBox(height: AppSpacing.md),
          ...analysis.warnings.map((warning) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 20,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          warning.type,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    warning.message,
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (warning.relatedIngredients.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: warning.relatedIngredients
                          .map(
                            (ingredient) => IngredientCategoryTag(
                              category: ingredient,
                              color: AppColors.error,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoriesCard(IngredientAnalysis analysis) {
    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: 'Category balance',
            subtitle: 'Relative distribution across the formula.',
          ),
          const SizedBox(height: AppSpacing.md),
          ...analysis.categories.map((category) {
            final parts = category.split(' ');
            final name = parts[0];
            final percentage = parts.length > 1 ? parts[1] : '';
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        percentage,
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppBorderRadius.full),
                    child: LinearProgressIndicator(
                      value: _parsePercentage(percentage),
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceVariant,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  double _parsePercentage(String percentage) {
    final clean = percentage.replaceAll('%', '');
    final value = double.tryParse(clean) ?? 0;
    return value / 100;
  }
}

class _ActionCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.82),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
