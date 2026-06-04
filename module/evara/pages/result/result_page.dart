import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../gen_a/A.dart';
import '../../core/singletons/ai_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/evara_scaffold.dart';

/// Result page with immersive hero image and text separated below it.
class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  dynamic _arguments;
  late MakeupAnalysisResult _result;

  @override
  void initState() {
    super.initState();
    _arguments = Get.arguments;

    if (_arguments is MakeupAnalysisResult) {
      _result = _arguments;
    } else if (_arguments is Map<String, dynamic>) {
      final recordData = _arguments['record'] as Map<String, dynamic>;
      _result = MakeupAnalysisResult.fromJson(
        recordData['analysis'] as Map<String, dynamic>,
      );
    } else {
      Get.back();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return EvaraScaffold(
      safeTop: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 460,
            backgroundColor: Colors.transparent,
            foregroundColor: AppTheme.textInverse,
            leading: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.24),
                foregroundColor: AppTheme.textInverse,
              ),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    File(_result.imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      A.assets_evara_open,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.05),
                          Colors.black.withValues(alpha: 0.12),
                          Colors.black.withValues(alpha: 0.85),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LOOK RECORD',
                          style: TextStyle(
                            color: AppTheme.textInverse.withValues(alpha: 0.88),
                            fontSize: AppTheme.small,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _result.styleTags.isNotEmpty
                              ? _result.styleTags.first
                              : 'Today\'s makeup',
                          style: const TextStyle(
                            color: AppTheme.textInverse,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _buildHeroLabels()
                              .take(2)
                              .map((tag) => _HeroChip(label: tag))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingLg,
              0,
              AppTheme.spacingLg,
              AppTheme.spacingXxl,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: EvaraGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My tags',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: AppTheme.caption,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _result.styleTags
                              .map((tag) => AppWidgets.tag(
                                    tag,
                                    color: AppTheme.primaryMain
                                        .withValues(alpha: 0.16),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const EvaraSectionTitle(
                  eyebrow: 'Record',
                  title: 'Today\'s makeup notes',
                  subtitle:
                      'Keep this entry focused on your own tags, photo notes, and how the look felt that day.',
                ),
                const SizedBox(height: AppTheme.spacingLg),
                _buildRecordSummary(),
                const SizedBox(height: AppTheme.spacingLg),
                _buildSceneSummary(),
                const SizedBox(height: AppTheme.spacingLg),
                _buildDisclaimer(),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSceneSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EvaraGlassCard(
          child: Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Photo angle',
                  value: _result.shotType,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: _MetricTile(
                  label: 'Light',
                  value: _result.lighting,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        EvaraGlassCard(
          child: Wrap(
            runSpacing: AppTheme.spacingMd,
            spacing: AppTheme.spacingMd,
            children: [
              _InfoPill(label: 'Focus note', value: _result.focusArea),
              _InfoPill(label: 'Look mood', value: _result.occasion),
              _InfoPill(label: 'Season', value: _result.season),
              _InfoPill(label: 'Time', value: _result.timeOfDay),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecordSummary() {
    return EvaraGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Recorded on',
                  value: _formatRecordedAt(_result.createdAt),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              const Expanded(
                child: _MetricTile(
                  label: 'Entry type',
                  value: 'Personal makeup diary',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Text(
            _buildRecordDescription(),
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: AppTheme.caption,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return EvaraGlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.info.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: AppTheme.info,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          const Expanded(
            child: Text(
              'This entry is saved as your own makeup record, so you can revisit the tags, photo details, and overall mood from that day.',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: AppTheme.caption,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRecordedAt(DateTime dateTime) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[dateTime.month - 1];
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$month $day, ${dateTime.year}  $hour:$minute';
  }

  String _buildRecordDescription() {
    if (_result.recordNote.trim().isNotEmpty) {
      return _result.recordNote.trim();
    }
    final firstTag =
        _result.styleTags.isNotEmpty ? _result.styleTags.first : 'today\'s look';
    return 'Saved this look as a personal record for $firstTag. Use it to remember the vibe, lighting, and details you liked most in this makeup moment.';
  }

  List<String> _buildHeroLabels() {
    final labels = <String>[];
    labels.addAll(_result.styleTags.take(2));
    if (labels.isEmpty) {
      labels.addAll(_result.occasionTags.take(2));
    }
    if (labels.isEmpty && _result.occasion.trim().isNotEmpty) {
      labels.add(_result.occasion.trim());
    }
    return labels;
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;

  const _MetricTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: AppTheme.small,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: AppTheme.body,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final String value;

  const _InfoPill({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 132),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: AppTheme.small,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: AppTheme.caption,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final String label;

  const _HeroChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.textInverse,
          fontSize: AppTheme.caption,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
