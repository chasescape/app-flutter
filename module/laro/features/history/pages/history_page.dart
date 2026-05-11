import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_routes.dart';
import '../../../core/app_theme.dart';
import '../../../core/pink_ui.dart';
import '../../home/providers/lash_provider.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return PinkPageScaffold(
      leading: const PinkBackButton(onTap: AppRoutes.back),
      title: 'History',
      centerTitle: true,
      child: Consumer<LashProvider>(
        builder: (context, lashProvider, child) {
          final hasPreviewHistory = lashProvider.history.isNotEmpty;

          if (!hasPreviewHistory) {
            return Center(
              child: PinkGlassCard(
                padding: const EdgeInsets.all(AppTheme.spacingXl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: AppTheme.heroGradient,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.photo_library_outlined,
                        color: AppTheme.textInverse,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    Text(
                      'No previews yet',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    Text(
                      'Create your first look and it will appear here with a larger visual card.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    const PinkPrimaryButton(
                      label: 'Create Preview',
                      onPressed: AppRoutes.toCreatePreview,
                      leading: Icon(Icons.auto_awesome_rounded, size: 18),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasPreviewHistory) ...[
                  const PinkSectionTitle(
                    title: 'Preview History',
                    subtitle: 'Generated lash results from the edit flow.',
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppTheme.spacingMd,
                      mainAxisSpacing: AppTheme.spacingMd,
                      childAspectRatio: 0.68,
                    ),
                    itemCount: lashProvider.history.length,
                    itemBuilder: (context, index) {
                      final item = lashProvider.history[index];
                      return GestureDetector(
                        onTap: () => AppRoutes.toResultWithItem(item),
                        child: PinkGlassCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                          top: Radius.circular(
                                            AppTheme.radiusLarge,
                                          ),
                                        ),
                                        child: item.previewImageUrl
                                                .startsWith('http')
                                            ? Image.network(
                                                item.previewImageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return const PinkImageFallback(
                                                    label: 'Preview',
                                                  );
                                                },
                                              )
                                            : Image.file(
                                                File(item.previewImageUrl),
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return const PinkImageFallback(
                                                    label: 'Preview',
                                                  );
                                                },
                                              ),
                                      ),
                                    ),
                                    Positioned(
                                      top: AppTheme.spacingSm,
                                      right: AppTheme.spacingSm,
                                      child: GestureDetector(
                                        onTap: () => _showDeleteDialog(
                                          context,
                                          item.id,
                                          lashProvider,
                                        ),
                                        child: Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            color: AppTheme.surfaceColor
                                                .withValues(alpha: 0.86),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.delete_outline_rounded,
                                            size: 18,
                                            color: AppTheme.error,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  AppTheme.spacingMd,
                                  AppTheme.spacingSm,
                                  AppTheme.spacingMd,
                                  AppTheme.spacingMd,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    PinkPill(
                                      text: item.styleName,
                                      backgroundColor: AppTheme.secondaryLight,
                                      foregroundColor: AppTheme.textPrimary,
                                    ),
                                    const SizedBox(height: AppTheme.spacingSm),
                                    Text(
                                      _formatDate(item.createdAt),
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: AppTheme.spacingLg),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    }
    if (difference.inDays == 1) {
      return 'Yesterday';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    }
    return '${date.month}/${date.day}/${date.year}';
  }

  void _showDeleteDialog(
      BuildContext context, String id, LashProvider lashProvider) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Preview'),
          content: const Text('Remove this saved preview from your history?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                lashProvider.deleteHistoryItem(id);
                Navigator.of(dialogContext).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
