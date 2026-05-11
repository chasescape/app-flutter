import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tanie/tanie/data/models/reflection_entry.dart';
import 'package:tanie/tanie/routes/app_routes.dart';
import 'package:tanie/tanie/services/reflection_storage_service.dart';
import 'package:tanie/tanie/theme/app_colors.dart';
import 'package:tanie/tanie/theme/app_shadows.dart';
import 'package:tanie/tanie/theme/app_text_styles.dart';
import 'package:tanie/tanie/widgets/app_loading.dart';
import 'package:tanie/tanie/widgets/app_ui.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<ReflectionEntry> _reflections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReflections();
  }

  Future<void> _loadReflections() async {
    setState(() => _isLoading = true);

    try {
      await reflectionStorageService.init();
      final reflections = reflectionStorageService.getAllEntries();
      if (!mounted) return;
      setState(() {
        _reflections = reflections;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load reflections: $e')),
      );
    }
  }

  Future<void> _deleteReflection(int index) async {
    await reflectionStorageService.deleteEntry(index);
    if (!mounted) return;
    setState(() {
      _reflections.removeAt(index);
    });
  }

  Future<void> _clearAllReflections() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Clear History', style: AppTextStyles.h3),
                const SizedBox(height: 10),
                const Text(
                  'This will remove all saved reflections from your gallery.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: const Text('Clear'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldClear != true) return;

    await reflectionStorageService.clearAll();
    if (!mounted) return;
    setState(() {
      _reflections = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackdrop(
        child: _isLoading
            ? const AppLoading(isFullScreen: false)
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_reflections.isEmpty) {
      return AppEmptyState(
        message:
            'Your gallery is still empty.\nCreate a reflection to start collecting moments.',
        icon: Icons.photo_library_outlined,
        actionLabel: 'Create One',
        onAction: () => context.go(AppRoutes.create),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReflections,
      color: AppColors.secondaryMain,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
              child: AppSectionTitle(
                title: 'My Gallery',
                trailing: AppIconCircle(
                  icon: Icons.delete_outline_rounded,
                  onTap: _clearAllReflections,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final reflection = _reflections[index];
                  return Dismissible(
                    key: ValueKey(
                      '${reflection.assetImg}-${reflection.reflection.observation}-$index',
                    ),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      margin: EdgeInsets.only(
                        bottom: index == _reflections.length - 1 ? 0 : 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.white,
                        size: 28,
                      ),
                    ),
                    onDismissed: (_) => _deleteReflection(index),
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: index == _reflections.length - 1 ? 0 : 16,
                      ),
                      child: _HistoryReflectionCard(
                        reflection: reflection,
                        onTap: () =>
                            context.push(AppRoutes.detail, extra: reflection),
                      ),
                    ),
                  );
                },
                childCount: _reflections.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryReflectionCard extends StatelessWidget {
  final ReflectionEntry reflection;
  final VoidCallback onTap;

  const _HistoryReflectionCard({
    required this.reflection,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = _formatTitle(reflection.sceneUnderstanding.mainSubject);

    return AppSectionCard(
      padding: const EdgeInsets.all(10),
      gradient: AppColors.softGradient,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppAdaptiveImage(
            imagePath: reflection.assetImg,
            width: 116,
            height: 138,
            borderRadius: BorderRadius.circular(22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: SizedBox(
              height: 138,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h3.copyWith(fontSize: 19),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    reflection.reflection.observation,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTitle(String value) {
    if (value.trim().isEmpty) {
      return 'Untitled Reflection';
    }

    return value
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
