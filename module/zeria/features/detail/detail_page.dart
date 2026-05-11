import 'package:flutter/material.dart';
import 'package:zeria/zeria/constants/app_colors.dart';
import 'package:zeria/zeria/constants/app_text_styles.dart';
import 'package:zeria/zeria/data/mock/spark_mock_data.dart';
import 'package:zeria/zeria/data/models/spark_result.dart';
import 'package:zeria/zeria/services/app_service.dart';
import 'package:zeria/zeria/widgets/zeria_ui.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({
    super.key,
    required this.id,
  });

  final String id;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late SparkResult _data;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    try {
      final sparkResult = AppService.to.getSparkResultById(widget.id);
      if (sparkResult != null) {
        _data = sparkResult;
      } else {
        final index = int.tryParse(widget.id) ?? 0;
        if (index >= 0 && index < allSparkMockData.length) {
          _data = allSparkMockData[index];
        } else {
          _data = getRandomSparkData();
        }
      }
    } catch (e) {
      _errorMessage = 'Unable to load this idea detail.';
      _data = getRandomSparkData();
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const ZeriaScreen(
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return ZeriaScreen(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: ZeriaHeader(
                title: 'Idea Detail',
                subtitle: '3 ACTIONABLE ROUTES',
                leading: ZeriaIconButton(
                  icon: Icons.arrow_back_rounded,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
                children: [
                  Hero(
                    tag: 'item_${widget.id}',
                    child: ZeriaSurfaceCard(
                      padding: EdgeInsets.zero,
                      radius: 34,
                      child: AspectRatio(
                        aspectRatio: 4 / 5,
                        child: ZeriaAdaptiveImage(
                          path: _data.imagePath,
                          assetPath: _data.assetImg,
                          borderRadius: BorderRadius.circular(33),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._data.tags.take(3).map(
                            (tag) => ZeriaPill(
                              label: tag,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.18),
                              foregroundColor: Colors.white,
                            ),
                          ),
                      ZeriaPill(
                        label: '${_data.ideas.length} action ideas',
                        backgroundColor: Colors.white.withValues(alpha: 0.18),
                        foregroundColor: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ZeriaSurfaceCard(
                    radius: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _data.oneLineSummary,
                          style: AppTextStyles.h2,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _data.sceneCard.visualSubject.evidence,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _errorMessage!,
                            style: AppTextStyles.small.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  ZeriaSurfaceCard(
                    radius: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Why this image unlocks ideas',
                          style: AppTextStyles.h3,
                        ),
                        const SizedBox(height: 14),
                        _buildInsightTile(
                          'What stands out',
                          _data.sceneCard.visualSubject.value,
                          _data.sceneCard.visualSubject.evidence,
                        ),
                        const SizedBox(height: 12),
                        _buildInsightTile(
                          'Emotional cue',
                          _data.sceneCard.atmosphere.value,
                          _data.sceneCard.atmosphere.evidence,
                        ),
                        const SizedBox(height: 12),
                        _buildInsightTile(
                          'Strongest opportunity',
                          _data.sceneCard.inspirationDimension.value,
                          _data.sceneCard.inspirationDimension.evidence,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  ZeriaSurfaceCard(
                    radius: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '3 actionable ideas',
                          style: AppTextStyles.h3,
                        ),
                        const SizedBox(height: 14),
                        ..._data.ideas.asMap().entries.map(
                              (entry) =>
                                  _buildIdeaCard(entry.key + 1, entry.value),
                            ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  ZeriaSurfaceCard(
                    radius: 30,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: _data.safety.hasSensitiveContent
                                ? const LinearGradient(
                                    colors: [
                                      AppColors.warning,
                                      AppColors.error
                                    ],
                                  )
                                : AppColors.accentGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            _data.safety.hasSensitiveContent
                                ? Icons.visibility_off_outlined
                                : Icons.verified_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _data.safety.hasSensitiveContent
                                    ? 'Use with care'
                                    : 'Ready to explore',
                                style: AppTextStyles.bodyBold,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _data.safety.notes,
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightTile(String label, String title, String body) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.small.copyWith(
              color: AppColors.brandHotPink,
            ),
          ),
          const SizedBox(height: 6),
          Text(title, style: AppTextStyles.bodyBold),
          const SizedBox(height: 6),
          Text(
            body,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdeaCard(int index, Idea idea) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: AppTextStyles.small.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  idea.title,
                  style: AppTextStyles.bodyBold,
                  softWrap: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            children: idea.executionDirection
                .asMap()
                .entries
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          margin: const EdgeInsets.only(top: 1),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: AppTextStyles.small.copyWith(
                                color: AppColors.brandHotPink,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          Text(
            idea.applicationScenario,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
