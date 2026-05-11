import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../cherish_ai/cherish_moment_storage.dart';
import '../../core/router/app_routes.dart';
import '../../core/state/app_state.dart';
import '../../core/state/state_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/tavia_ui.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/models/content_model.dart';

/// Visual history gallery.
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    _loadStoredHistory();
  }

  Future<void> _loadStoredHistory() async {
    final history = await CherishMomentStorage.getContentHistory();
    final visibleHistory = history.where(_hasAvailableImage).toList();

    if (visibleHistory.length != history.length) {
      for (final content in history) {
        if (!_hasAvailableImage(content)) {
          await CherishMomentStorage.remove(content.id);
        }
      }
    }

    AppState().setHistory(visibleHistory);
  }

  Future<void> _removeFromHistory(String contentId) async {
    await CherishMomentStorage.remove(contentId);
    AppState().removeFromHistory(contentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TaviaBackground(
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacingLg,
              AppConstants.spacingMd,
              AppConstants.spacingLg,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: AppConstants.spacingLg),
                Expanded(child: _buildHistoryList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        TaviaIconButton(
          icon: Icons.arrow_back_ios_new,
          onTap: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: AppConstants.spacingMd),
        const Expanded(
          child: TaviaSectionTitle(
            title: 'Saved Visuals',
            subtitle: 'A calm archive of image-led cards and past generations.',
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    return StreamHistoryWidget(
      builder: (context, history) {
        final visibleHistory = history.where(_hasAvailableImage).toList();

        if (visibleHistory.length != history.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              AppState().setHistory(visibleHistory);
            }
          });
        }

        if (visibleHistory.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.history,
            title: 'No saved visuals',
            subtitle: 'Generated cards will land here once you save them.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.only(bottom: AppConstants.spacingXxl),
          itemBuilder: (context, index) {
            final content = visibleHistory[index];
            return _HistoryCard(
              content: content,
              onRemove: () => _removeFromHistory(content.id),
            );
          },
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppConstants.spacingLg),
          itemCount: visibleHistory.length,
        );
      },
    );
  }

  bool _hasAvailableImage(ContentModel content) {
    final source = content.imageUrl?.trim() ?? '';
    if (source.isEmpty) {
      return false;
    }
    if (source.startsWith('http') || source.startsWith('assets/')) {
      return true;
    }
    return File(source).existsSync();
  }
}

class _HistoryCard extends StatelessWidget {
  final ContentModel content;
  final VoidCallback onRemove;

  const _HistoryCard({
    required this.content,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        '${AppRoutes.detail}?${AppRoutes.paramId}=${content.id}',
      ),
      child: TaviaPanel(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Row(
          children: [
            TaviaMedia(
              source: content.imageUrl,
              width: 108,
              height: 132,
              borderRadius: BorderRadius.circular(22),
            ),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  Text(
                    content.description ?? '',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingSm,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusFull),
                    ),
                    child: Text(
                      _formatDate(content.createdAt ?? DateTime.now()),
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.primaryMain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close),
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inHours < 24) {
      return '${difference.inHours.clamp(1, 23)}h ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }
    return '${date.month}/${date.day}/${date.year}';
  }
}
