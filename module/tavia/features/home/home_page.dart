import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/state/state_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/tavia_ui.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/models/content_model.dart';

/// Image-first discovery home.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _loadContent();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 260 &&
        !_isLoading) {
      _loadMoreContent();
    }
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
      _page = 0;
    });

    await Future.delayed(const Duration(milliseconds: 420));

    if (!mounted) {
      return;
    }

    StateProvider.of(context).setHomeFeed(ContentModel.getMockList());
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadMoreContent() async {
    setState(() {
      _isLoading = true;
      _page += 1;
    });

    await Future.delayed(const Duration(milliseconds: 360));

    if (!mounted) {
      return;
    }

    final state = StateProvider.of(context);
    final current = state.homeFeed;
    final next = List.generate(
      5,
      (index) => ContentModel.mockByIndex(index + (_page * 3)),
    );
    state.setHomeFeed([...current, ...next]);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TaviaBackground(
        child: SafeArea(
          bottom: false,
          child: StreamHomeFeedWidget(
            loadingWidget: const LoadingIndicator(),
            builder: (context, feed) {
              if (feed.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.photo_library_outlined,
                  title: 'No visuals yet',
                  subtitle:
                      'Fresh image cards will show up here as soon as they load.',
                );
              }

              final heroItem = feed.length > 4 ? feed[4] : feed.first;
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.spacingLg,
                  AppConstants.spacingMd,
                  AppConstants.spacingLg,
                  AppConstants.spacingXxl,
                ),
                itemCount: 1 + feed.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppConstants.spacingLg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: AppConstants.spacingLg),
                          _buildHeroCard(heroItem),
                          const SizedBox(height: AppConstants.spacingLg),
                          Text(
                            'Fresh picks',
                            style: AppTextStyles.h2.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingXs),
                          Text(
                            'Large imagery first, with the copy intentionally dialed down.',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.white.withValues(alpha: 0.78),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final feedIndex = index - 1;
                  if (feedIndex >= feed.length) {
                    return const Padding(
                      padding: EdgeInsets.only(top: AppConstants.spacingXl),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final content = feed[feedIndex];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppConstants.spacingLg),
                    child: _FeedCard(
                      content: content,
                      tall: feedIndex.isEven,
                      onTap: () => _navigateToDetail(content.id),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
        child: TaviaCreateFab(
          onTap: () => context.push(AppRoutes.create),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const SizedBox(width: AppConstants.spacingMd),
        const Expanded(
          child: TaviaSectionTitle(
            title: 'Tavia Gallery',
            subtitle:
                'Soft-focus visuals curated around your latest mood board.',
          ),
        ),
        const SizedBox(width: AppConstants.spacingSm),
        TaviaIconButton(
          icon: Icons.person_outline,
          onTap: () => context.push(AppRoutes.profile),
        ),
      ],
    );
  }

  Widget _buildHeroCard(ContentModel content) {
    return GestureDetector(
      onTap: () => _navigateToDetail(content.id),
      child: TaviaPanel(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        borderRadius: BorderRadius.circular(34),
        color: AppColors.white.withValues(alpha: 0.18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TaviaMedia(
              source: content.imageUrl,
              height: 320,
              width: double.infinity,
              borderRadius: BorderRadius.circular(26),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content.title,
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(
                        content.description ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.white.withValues(alpha: 0.76),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppConstants.spacingMd),
                TaviaPrimaryButton(
                  label: 'Create',
                  onPressed: () => context.push(AppRoutes.create),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(String contentId) {
    context.push('${AppRoutes.detail}?${AppRoutes.paramId}=$contentId');
  }
}

class _FeedCard extends StatelessWidget {
  final ContentModel content;
  final bool tall;
  final VoidCallback onTap;

  const _FeedCard({
    required this.content,
    required this.tall,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TaviaPanel(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TaviaMedia(
              source: content.imageUrl,
              height: tall ? 330 : 258,
              width: double.infinity,
              borderRadius: BorderRadius.circular(24),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    content.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h3,
                  ),
                ),
              ],
            ),
            if ((content.description?.trim().isNotEmpty ?? false)) ...[
              const SizedBox(height: AppConstants.spacingXs),
              Text(
                content.description!.trim(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
