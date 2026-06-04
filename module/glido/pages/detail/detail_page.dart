import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/tone_record.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glido_ui.dart';

class DetailPage extends StatelessWidget {
  final String recordId;

  const DetailPage({
    super.key,
    required this.recordId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final record = appState.records.firstWhere(
          (r) => r.id == recordId,
          orElse: () => throw Exception('Record not found'),
        );

        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(record.presetName),
            actions: [
              IconButton(
                icon: const Icon(Icons.copy_rounded),
                onPressed: () => _copyParameters(context, record),
                tooltip: 'Copy summary',
              ),
            ],
          ),
          body: GlidoPageBackground(
            topSafeArea: true,
            padding: const EdgeInsets.only(top: kToolbarHeight),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.spacingMd,
                    AppTheme.spacingSm,
                    AppTheme.spacingMd,
                    120,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        _DetailHero(record: record),
                        const SizedBox(height: AppTheme.spacingLg),
                        _ImageStorySection(record: record),
                        const SizedBox(height: AppTheme.spacingLg),
                        _ParametersSection(record: record),
                        if (record.detailNotes != null &&
                            record.detailNotes!.trim().isNotEmpty) ...[
                          const SizedBox(height: AppTheme.spacingLg),
                          _NotesSection(record: record),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _copyParameters(BuildContext context, ToneRecord record) {
    Clipboard.setData(ClipboardData(text: record.getParameterSummary()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Card summary copied'),
      ),
    );
  }
}

class _DetailHero extends StatelessWidget {
  final ToneRecord record;

  const _DetailHero({
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    return GlidoSurface(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlidoRecordImage(
            imagePath: record.afterImagePath ?? record.beforeImagePath,
            heroTag: glidoRecordHeroTag(record.id),
            height: 420,
            placeholderLabel: 'A featured image will live here',
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Wrap(
            spacing: AppTheme.spacingSm,
            runSpacing: AppTheme.spacingSm,
            children: [
              GlidoPill(
                label: record.sceneTag,
                gradient: AppTheme.highlightGradient,
              ),
              GlidoPill(
                label: record.mainMood,
                color: AppTheme.accentLight,
              ),
              GlidoPill(
                label: record.toolUsed,
                icon: Icons.tune_rounded,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            record.presetName,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'The image stays unobstructed. Supporting details live underneath in calm, separated panels.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _ImageStorySection extends StatelessWidget {
  final ToneRecord record;

  const _ImageStorySection({
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const GlidoSectionHeader(
          title: 'Before and after',
          subtitle:
              'Both frames stay fully visible, with all text outside the image area.',
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Row(
          children: [
            Expanded(
              child: _ImageCard(
                title: 'Before',
                imagePath: record.beforeImagePath,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: _ImageCard(
                title: 'After',
                imagePath: record.afterImagePath,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ImageCard extends StatelessWidget {
  final String title;
  final String? imagePath;

  const _ImageCard({
    required this.title,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return GlidoSurface(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlidoRecordImage(
            imagePath: imagePath,
            height: 240,
            placeholderLabel: '$title image',
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _ParametersSection extends StatelessWidget {
  final ToneRecord record;

  const _ParametersSection({
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlidoSectionHeader(
          title: 'Adjustments',
          subtitle: record.parameters.isEmpty
              ? 'No tuning values were saved for this card.'
              : 'Technical details stay separated from the hero image for cleaner focus.',
          trailing: TextButton.icon(
            onPressed: () => Clipboard.setData(
              ClipboardData(text: record.getParameterSummary()),
            ),
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copy'),
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        if (record.parameters.isEmpty)
          const GlidoSurface(
            child: _EmptyBlock(
              icon: Icons.tune_rounded,
              title: 'No parameters yet',
              subtitle:
                  'Save exposure, warmth, contrast, or grain when you want a more technical archive.',
            ),
          )
        else
          GlidoSurface(
            child: Column(
              children: record.parameters.entries
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingSm,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.key,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          GlidoPill(
                            label: entry.value.toString(),
                            color: AppTheme.bgSecondary,
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _NotesSection extends StatelessWidget {
  final ToneRecord record;

  const _NotesSection({
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const GlidoSectionHeader(
          title: 'Notes',
          subtitle:
              'Longer text stays in its own reading block, never over the photo.',
        ),
        const SizedBox(height: AppTheme.spacingMd),
        GlidoSurface(
          child: Text(
            record.detailNotes!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ),
      ],
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyBlock({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 40, color: AppTheme.textSecondary),
        const SizedBox(height: AppTheme.spacingMd),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }
}
