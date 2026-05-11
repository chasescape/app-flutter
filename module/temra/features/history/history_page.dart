import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/nail_models.dart';
import '../../routes/app_routes.dart';
import '../../services/ai_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<RecommendationResult> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    AppRoutes.router.routeInformationProvider.addListener(_handleRouteChange);
    _loadHistory();
  }

  @override
  void dispose() {
    AppRoutes.router.routeInformationProvider.removeListener(_handleRouteChange);
    super.dispose();
  }

  void _handleRouteChange() {
    final location = AppRoutes.router.routeInformationProvider.value.uri.path;
    if (location == AppRoutes.history) {
      _loadHistory();
    }
  }

  Future<void> _loadHistory() async {
    final results = await AIService().getHistory();
    if (mounted) {
      setState(() {
        _history = results;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteItem(String id) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Record',
      content: 'Are you sure you want to delete this recommendation?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
    );
    if (confirmed) {
      await AIService().deleteResult(id);
      _loadHistory();
    }
  }

  Future<void> _clearAll() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Clear All History',
      content: 'This will delete all your recommendation records. This action cannot be undone.',
      confirmText: 'Clear All',
      cancelText: 'Cancel',
    );
    if (confirmed) {
      await AIService().clearHistory();
      _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: PulseLoading(message: 'Loading your moodboards...'));
    }

    if (_history.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      color: AppColors.secondary,
      onRefresh: _loadHistory,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
        children: [
          Row(
            children: [
              const Expanded(
                child: SectionTitle(
                  eyebrow: 'History',
                  title: 'Your saved nail boards',
                  subtitle: 'Large previews first, details second.',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.error),
                onPressed: _clearAll,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._history.map((item) => _HistoryCard(item: item, onDelete: () => _deleteItem(item.id))),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: AppCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.collections_outlined, size: 52, color: AppColors.secondary),
              const SizedBox(height: 18),
              const Text(
                'No moodboards yet',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'When you generate looks, they will appear here as visual cards.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: 180,
                  child: AppButton(
                    text: 'Create',
                    onPressed: () => context.go(AppRoutes.create),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final RecommendationResult item;
  final VoidCallback onDelete;

  const _HistoryCard({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Stack(
        children: [
          AppImageStage(
            imagePath: item.imagePath,
            height: 320,
            onTap: () => context.push(
              AppRoutes.result,
              extra: {
                'imagePath': item.imagePath,
                'styles': item.styles,
                'sceneTag': item.sceneTag,
              },
            ),
            overlay: Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: AppColors.textOnDark),
                ),
              ),
            ),
            footer: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.styles.isNotEmpty ? item.styles.first.styleName : 'Dream look',
                  style: const TextStyle(
                    color: AppColors.textOnDark,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.sceneTag ?? '${item.styles.length} style directions',
                  style: const TextStyle(
                    color: Color(0xE6FFFFFF),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
