import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/theme.dart';
import '../../app/state/app_state.dart';
import '../../app/state/app_state_provider.dart';
import '../../models/novel.dart';
import '../../router/app_router.dart';
import '../../widgets/animations/bounce_in_animation.dart';
import '../../widgets/visuals/sunny_visuals.dart';

/// Library Page
/// Displays all novels with search capabilities
class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  void _updateSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);

    List<Novel> filteredNovels = appState.novels;

    if (_searchQuery.isNotEmpty) {
      filteredNovels = appState.searchNovels(_searchQuery);
    }

    return Scaffold(
      body: SunnyPage(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Header
            const _LibraryHeader(),

            // Search Bar
            _buildSearchBar(),

            const SizedBox(height: AppSpacing.sm),

            // Novel List
            Expanded(
              child: filteredNovels.isEmpty
                  ? _EmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      itemCount: filteredNovels.length,
                      itemBuilder: (context, index) {
                        return _NovelListItem(
                          novel: filteredNovels[index],
                          index: index,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.editor),
        icon: const Icon(Icons.add),
        label: const Text('Add Novel'),
        backgroundColor: const Color(AppColors.buttonPrimary),
        foregroundColor: const Color(AppColors.textInverse),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: TextField(
        controller: _searchController,
        onChanged: _updateSearch,
        decoration: InputDecoration(
          hintText: 'Search stories, authors, characters...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
              : null,
        ),
      ),
    );
  }
}

class _LibraryHeader extends StatelessWidget {
  const _LibraryHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          const Icon(
            Icons.library_books,
            color: Color(AppColors.primaryMain),
            size: 24,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Novel Library',
            style: AppTypography.getH2TextStyle(
              const Color(AppColors.textPrimary),
            ),
          ),
          const Spacer(),
          // Sort Button
          IconButton(
            icon: const Icon(Icons.sort),
            color: const Color(AppColors.textSecondary),
            onPressed: () {
              // TODO: Show sort options
            },
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 64,
            color: Color(AppColors.primaryMain),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No records found',
            style: AppTypography.getH3TextStyle(
              const Color(AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Try adjusting filters or add a novel',
            style: AppTypography.getCaptionTextStyle(
              const Color(AppColors.textSecondary),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NovelListItem extends StatelessWidget {
  final Novel novel;
  final int index;

  const _NovelListItem({
    required this.novel,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return BounceInAnimation(
      delay: Duration(milliseconds: 50 * index),
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.editorDetail(novel.id)),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: const Color(AppColors.cardElevated),
            borderRadius: AppBorderRadius.allLG,
            border: Border.all(
              color: const Color(AppColors.cardElevated),
              width: 3,
            ),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              NovelCoverArt(
                novel: novel,
                width: 92,
                height: 120,
                compact: true,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      novel.title,
                      style: AppTypography.getH3TextStyle(
                        const Color(AppColors.textPrimary),
                      ).copyWith(fontWeight: AppTypography.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      novel.author,
                      style: AppTypography.getCaptionTextStyle(
                        const Color(AppColors.textSecondary),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        _StatusBadge(status: novel.status),
                        _GenreChip(genre: novel.genre),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        if (novel.characters.isNotEmpty) ...[
                          const Icon(
                            Icons.people,
                            size: 14,
                            color: Color(AppColors.textSecondary),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${novel.characters.length}',
                            style: AppTypography.getSmallTextStyle(
                              const Color(AppColors.textSecondary),
                            ),
                          ),
                        ],
                        const Spacer(),
                        if (novel.readingMinutes != null)
                          Text(
                            '${(novel.readingMinutes! / 60).toStringAsFixed(1)}h',
                            style: AppTypography.getSmallTextStyle(
                              const Color(AppColors.textSecondary),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(
                Icons.chevron_right,
                color: Color(AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final NovelStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.12),
        borderRadius: AppBorderRadius.allSM,
        border: Border.all(
          color: _getStatusColor(status).withOpacity(0.28),
          width: 1,
        ),
      ),
      child: Text(
        status.label,
        style: AppTypography.getSmallTextStyle(
          _getStatusColor(status),
        ).copyWith(
          fontWeight: AppTypography.medium,
        ),
      ),
    );
  }

  Color _getStatusColor(NovelStatus status) {
    switch (status) {
      case NovelStatus.toRead:
        return const Color(AppColors.statusToRead);
      case NovelStatus.reading:
        return const Color(AppColors.statusReading);
      case NovelStatus.finished:
        return const Color(AppColors.statusFinished);
      case NovelStatus.paused:
        return const Color(AppColors.statusPaused);
      case NovelStatus.dropped:
        return const Color(AppColors.statusDropped);
    }
  }
}

class _GenreChip extends StatelessWidget {
  final NovelGenre genre;

  const _GenreChip({required this.genre});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: const Color(AppColors.backgroundTertiary),
        borderRadius: AppBorderRadius.allSM,
        border: Border.all(
          color: const Color(AppColors.cardElevated),
          width: 1.5,
        ),
      ),
      child: Text(
        genre.label,
        style: AppTypography.getSmallTextStyle(
          const Color(AppColors.textSecondary),
        ),
      ),
    );
  }
}
