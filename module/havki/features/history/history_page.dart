import 'package:flutter/material.dart';
import 'package:havki/havki/app/routes/app_routes.dart';
import 'package:havki/havki/app/theme/app_theme.dart';
import 'package:havki/havki/data/models/quote/quote_vibe_analysis_data.dart';
import 'package:havki/havki/services/quote_vibe_storage_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final QuoteVibeStorageService _storageService = QuoteVibeStorageService.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      await _storageService.initialize();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppCircleIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: AppSpacing.md),
                const Expanded(
                  child: AppSectionTitle(
                    eyebrow: 'Saved',
                    title: 'History',
                  ),
                ),
                if (_storageService.isNotEmpty)
                  AppCircleIconButton(
                    icon: Icons.delete_outline_rounded,
                    onPressed: _showClearConfirmDialog,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _storageService.isEmpty
                      ? Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 320),
                            child: AppGlassCard(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.photo_library_outlined,
                                      size: 30,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  const Text(
                                    'No saved cards yet',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: AppFontSizes.h3,
                                      fontWeight: AppFontWeights.bold,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  const Text(
                                    'Create your first photo reading and it will show up here as a visual card.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: AppFontSizes.caption,
                                      height: AppLineHeights.normal,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: AppNavigator.I.toCreate,
                                      child: const Text('Create now'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
                          itemCount: _storageService.history.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) => _HistoryCard(item: _storageService.history[index]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearConfirmDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear history'),
        content: const Text('Remove all saved analyses from this device?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await _storageService.clearHistory();
              if (!context.mounted) return;
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final QuoteVibeAnalysisData item;

  const _HistoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppNavigator.I.toDetail(item),
      child: AppGlassCard(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              child: AspectRatio(
                aspectRatio: 1.25,
                child: Image.asset(
                  item.assetImg,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _tag(item.sceneAnalysis.primaryMood),
                _tag(item.styleSignature),
                _tag(_formatDate(item.createdAt)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              item.firstCard.quote,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: AppFontSizes.caption,
                color: AppColors.textPrimary,
                fontWeight: AppFontWeights.semibold,
                height: AppLineHeights.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppBorderRadius.full),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: AppFontSizes.small,
          color: AppColors.textSecondary,
          fontWeight: AppFontWeights.semibold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
