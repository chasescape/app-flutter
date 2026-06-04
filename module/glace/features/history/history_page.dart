import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../models/perfume_record.dart';
import '../../services/record_service.dart';
import '../../widgets/glace_ui.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final RecordService _recordService = RecordService();
  List<PerfumeRecord> _filteredRecords = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    setState(() {
      _filteredRecords = _recordService.getAllRecords();
    });
  }

  void _deleteRecord(String id) {
    SmartDialog.show(
      builder: (_) => AlertDialog(
        title: const Text('Delete record'),
        content: const Text('Remove this card from your glow gallery?'),
        actions: [
          TextButton(
            onPressed: () => SmartDialog.dismiss(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _recordService.deleteRecord(id);
              SmartDialog.dismiss();
              _loadRecords();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _clearAllRecords() {
    if (_filteredRecords.isEmpty) {
      SmartDialog.showToast('Nothing to clear');
      return;
    }

    SmartDialog.show(
      builder: (_) => AlertDialog(
        title: const Text('Clear journal'),
        content: const Text(
          'Delete all saved entries? This action cannot be undone.',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => SmartDialog.dismiss(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _recordService.clearAllRecords();
                      SmartDialog.dismiss();
                      _loadRecords();
                      SmartDialog.showToast('Journal cleared');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Clear all'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openDetail(PerfumeRecord record) {
    context.push(
      Routes.recordDetail,
      extra: {
        'record': record,
        'heroTag': 'history-${record.id}',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlaceScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Journal',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        foregroundColor: AppColors.textPrimary,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _clearAllRecords,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.70),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
                child: const Icon(
                  Icons.delete_sweep_rounded,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      safeArea: false,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlaceSurfaceCard(
                    color: Colors.white.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(24),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.photo_library_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_filteredRecords.length} saved',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                'Tap a card to open',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
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
            Expanded(
              child: _filteredRecords.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.78,
                      ),
                      itemCount: _filteredRecords.length,
                      itemBuilder: (context, index) {
                        final record = _filteredRecords[index];
                        return Dismissible(
                          key: ValueKey(record.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (_) async {
                            _deleteRecord(record.id);
                            return false;
                          },
                          child: GlaceImageCard(
                            record: record,
                            heroTag: 'history-${record.id}',
                            onTap: () => _openDetail(record),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: GlaceSurfaceCard(
          color: Colors.white.withValues(alpha: 0.72),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GlaceLogoBadge(size: 64),
              SizedBox(height: 14),
              Text(
                'Nothing in the journal yet',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Create a first record to unlock your pastel image wall.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
