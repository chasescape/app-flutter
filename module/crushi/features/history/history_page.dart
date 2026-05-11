import 'package:flutter/material.dart';
import 'package:crushi/crushi/core/theme/app_theme.dart';
import 'package:crushi/crushi/core/router/global_router.dart';
import 'package:crushi/crushi/core/widgets/diffuse_background.dart';
import 'package:crushi/crushi/core/widgets/glass_card.dart';
import 'package:crushi/crushi/data/generated_history_store.dart';
import 'package:crushi/crushi/data/models/stoic_card.dart';
import 'dart:io';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Widget _glowGlass({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryMain.withOpacity(0.16),
            blurRadius: 26,
            spreadRadius: -6,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.06),
            blurRadius: 16,
            spreadRadius: -8,
          ),
        ],
      ),
      child: GlassCard(
        padding: padding,
        tintOpacity: 0.16,
        borderOpacity: 0.22,
        boxShadow: AppShadows.sm,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: DiffuseBackground(
              base: Color(0xFF070B16),
              bottom: Color(0xFF070B16),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    AppSpacing.xs,
                    AppSpacing.sm,
                    AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => GlobalRouter.I.goBack(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: AppColors.textInverse,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          'History',
                          style: AppTypography.h3.copyWith(
                            color: AppColors.textInverse,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      ValueListenableBuilder<List<StoicCard>>(
                        valueListenable: GeneratedHistoryStore.I.items,
                        builder: (context, items, _) {
                          if (items.isEmpty) return const SizedBox.shrink();
                          return TextButton(
                            onPressed: () => _showClearAllDialog(),
                            child: const Text(
                              'Clear',
                              style: TextStyle(
                                color: AppColors.textInverse,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ValueListenableBuilder<List<StoicCard>>(
                    valueListenable: GeneratedHistoryStore.I.items,
                    builder: (context, items, _) {
                      if (items.isEmpty) {
                        return _EmptyState(
                          onCreate: () => GlobalRouter.I.goToCreate(),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          AppSpacing.xl,
                        ),
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.md),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final card = items[index];
                          return _buildHistoryCard(
                            card,
                            onDelete: () => _showDeleteDialog(index),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    StoicCard card, {
    required VoidCallback onDelete,
  }) {
    return GestureDetector(
      onTap: () => GlobalRouter.I.goToDetail(card: card),
      child: _glowGlass(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: SizedBox(
                width: 76,
                height: 76,
                child: _buildCardImage(card.assetImg),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.oneLineCapture,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textInverse,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    card.sceneCard.stoicVirtue.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textInverse.withOpacity(0.72),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: onDelete,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: AppColors.textInverse.withOpacity(0.75),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardImage(String path) {
    if (path.startsWith('/')) {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const ColoredBox(color: AppColors.bgTertiary),
      );
    }
    return Image.asset(path, fit: BoxFit.cover);
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: const Text('Delete'),
        content: const Text('Remove this item from history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              GeneratedHistoryStore.I.removeAt(index);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: const Text('Clear All'),
        content: const Text('Remove all items from history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              GeneratedHistoryStore.I.clear();
              Navigator.pop(ctx);
            },
            child: const Text('Clear All', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.onCreate,
  });

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          tintOpacity: 0.18,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryMain.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: AppColors.primaryMain,
                  size: 26,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'No history yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textInverse,
                  fontFamily: AppTypography.fontFamily,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Your creations will appear here.\nCreate your first one to get started.',
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  color: AppColors.textInverse.withOpacity(0.75),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: onCreate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryMain,
                    foregroundColor: AppColors.textInverse,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                  child: const Text(
                    'Create Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textInverse,
                      fontFamily: AppTypography.fontFamily,
                    ),
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
