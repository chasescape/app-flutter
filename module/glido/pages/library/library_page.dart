import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/tone_record.dart';
import '../../providers/app_state.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glido_ui.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  String _selectedScene = 'All';
  String _selectedMood = 'All';
  String _selectedTool = 'All';

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final allRecords = List<ToneRecord>.from(appState.records)
          ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));

        final sceneOptions = _buildFilterOptions(
          allRecords,
          (record) => record.sceneTag,
        );
        final moodOptions = _buildFilterOptions(
          allRecords,
          (record) => record.mainMood,
        );
        final toolOptions = _buildFilterOptions(
          allRecords,
          (record) => record.toolUsed,
        );

        var records = allRecords;

        if (_selectedScene != 'All') {
          records = records.where((r) => r.sceneTag == _selectedScene).toList();
        }
        if (_selectedMood != 'All') {
          records = records.where((r) => r.mainMood == _selectedMood).toList();
        }
        if (_selectedTool != 'All') {
          records = records.where((r) => r.toolUsed == _selectedTool).toList();
        }

        records = List<ToneRecord>.from(records)
          ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));

        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text('Library'),
          ),
          body: GlidoPageBackground(
            topSafeArea: true,
            padding: const EdgeInsets.only(top: kToolbarHeight),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.spacingMd,
                      AppTheme.spacingSm,
                      AppTheme.spacingMd,
                      0,
                    ),
                    child: GlidoSurface(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const GlidoSectionHeader(
                            title: 'Filter the archive',
                            subtitle:
                                'Keep the interface light while narrowing by scene, mood, or tool.',
                          ),
                          const SizedBox(height: AppTheme.spacingMd),
                          _FilterWrap(
                            label: 'Scene',
                            value: _selectedScene,
                            options: sceneOptions,
                            onSelected: (value) =>
                                setState(() => _selectedScene = value),
                          ),
                          const SizedBox(height: AppTheme.spacingMd),
                          _FilterWrap(
                            label: 'Mood',
                            value: _selectedMood,
                            options: moodOptions,
                            onSelected: (value) =>
                                setState(() => _selectedMood = value),
                          ),
                          const SizedBox(height: AppTheme.spacingMd),
                          _FilterWrap(
                            label: 'Tool',
                            value: _selectedTool,
                            options: toolOptions,
                            onSelected: (value) =>
                                setState(() => _selectedTool = value),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (records.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppTheme.spacingMd,
                        AppTheme.spacingLg,
                        AppTheme.spacingMd,
                        120,
                      ),
                      child: _LibraryEmptyState(),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.spacingMd,
                      AppTheme.spacingLg,
                      AppTheme.spacingMd,
                      120,
                    ),
                    sliver: SliverList.separated(
                      itemBuilder: (context, index) {
                        final record = records[index];
                        return Dismissible(
                          key: ValueKey(record.id),
                          direction: DismissDirection.endToStart,
                          background: const SizedBox.shrink(),
                          secondaryBackground: const _DeleteSwipeBackground(),
                          confirmDismiss: (_) =>
                              _confirmDeleteRecord(context, record),
                          onDismissed: (_) =>
                              _deleteRecord(context, appState, record),
                          child: _LibraryCard(record: record),
                        );
                      },
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppTheme.spacingMd),
                      itemCount: records.length,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _confirmDeleteRecord(
    BuildContext context,
    ToneRecord record,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete card?'),
        content: Text('Remove "${record.presetName}" from your library?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _deleteRecord(
    BuildContext context,
    AppState appState,
    ToneRecord record,
  ) {
    final previousRecords = List<ToneRecord>.from(appState.records);
    appState.deleteRecord(record.id);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('"${record.presetName}" deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => appState.setRecords(previousRecords),
          ),
        ),
      );
  }
}

class _FilterWrap extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onSelected;

  const _FilterWrap({
    required this.label,
    required this.value,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Wrap(
          spacing: AppTheme.spacingSm,
          runSpacing: AppTheme.spacingSm,
          children: options
              .map(
                (option) => ChoiceChip(
                  label: Text(option),
                  selected: value == option,
                  onSelected: (_) => onSelected(option),
                  backgroundColor: Colors.white.withValues(alpha: 0.76),
                  selectedColor: AppTheme.primaryMain,
                  side: BorderSide(
                    color: AppTheme.ink.withValues(alpha: 0.08),
                  ),
                  labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _LibraryCard extends StatelessWidget {
  final ToneRecord record;

  const _LibraryCard({
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppRoutes.toDetail(context, record.id),
      child: GlidoSurface(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlidoRecordImage(
              imagePath: record.afterImagePath,
              heroTag: glidoRecordHeroTag(record.id),
              height: 260,
              placeholderLabel: 'After image spotlight',
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.presetName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
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
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Text(
                  _formatLibraryDate(record.lastUpdated),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryEmptyState extends StatelessWidget {
  const _LibraryEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlidoSurface(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.filter_alt_off_rounded,
              size: 48,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              'No cards match these filters',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Try loosening the scene, mood, or tool selections to bring the image feed back.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteSwipeBackground extends StatelessWidget {
  const _DeleteSwipeBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.error,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.delete_forever_rounded,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            'Delete',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

String _formatLibraryDate(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inDays <= 0) {
    return 'Today';
  }
  if (diff.inDays == 1) {
    return 'Yesterday';
  }
  if (diff.inDays < 7) {
    return '${diff.inDays}d ago';
  }
  return '${date.month}/${date.day}/${date.year}';
}

List<String> _buildFilterOptions(
  List<ToneRecord> records,
  String Function(ToneRecord) selector,
) {
  final values = <String>{};
  for (final record in records) {
    final value = selector(record).trim();
    if (value.isNotEmpty) {
      values.add(value);
    }
  }
  return ['All', ...values];
}
