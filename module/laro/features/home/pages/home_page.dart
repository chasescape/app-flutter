import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_routes.dart';
import '../../../core/app_theme.dart';
import '../../../core/pink_ui.dart';
import '../../../services/coins_manager.dart';
import '../models/lash_history_item.dart';
import '../providers/lash_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.heroGradient,
          shape: BoxShape.circle,
          boxShadow: [
            AppTheme.shadow(AppTheme.primaryMain, 0.22),
          ],
        ),
        child: const FloatingActionButton(
          onPressed: AppRoutes.toCreatePreview,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(Icons.add_rounded, size: 30),
        ),
      ),
      body: PinkDecorBackground(
        child: SafeArea(
          child: Consumer<LashProvider>(
            builder: (context, lashProvider, child) {
              final history = lashProvider.history;
              final recentItems = history.skip(1).take(4).toList();

              return Column(
                children: [
                  _buildTopBar(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppTheme.spacingMd,
                        0,
                        AppTheme.spacingMd,
                        AppTheme.spacingLg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBalanceCard(context, lashProvider),
                          const SizedBox(height: AppTheme.spacingLg),
                          if (history.isEmpty)
                            _buildExplainerCard(context)
                          else ...[
                            _buildSimpleSectionHeader(
                              context,
                              title: 'Your Latest Preview',
                              actionLabel: 'History',
                              onActionTap: AppRoutes.toHistory,
                            ),
                            const SizedBox(height: AppTheme.spacingMd),
                            _GeneratedHeroCard(
                              item: history.first,
                              onTap: () =>
                                  AppRoutes.toResultWithItem(history.first),
                            ),
                            if (recentItems.isNotEmpty) ...[
                              const SizedBox(height: AppTheme.spacingLg),
                              _buildSimpleSectionHeader(
                                context,
                                title: 'Recent Results',
                              ),
                              const SizedBox(height: AppTheme.spacingMd),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: recentItems.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: AppTheme.spacingMd,
                                  mainAxisSpacing: AppTheme.spacingMd,
                                  childAspectRatio: 0.72,
                                ),
                                itemBuilder: (context, index) {
                                  final item = recentItems[index];
                                  return _GeneratedPreviewCard(
                                    item: item,
                                    onTap: () =>
                                        AppRoutes.toResultWithItem(item),
                                  );
                                },
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingMd,
        AppTheme.spacingSm,
        AppTheme.spacingMd,
        AppTheme.spacingMd,
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Laro',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
          const Row(
            children: [
              Spacer(),
              _ActionBubble(
                icon: Icons.history_rounded,
                onTap: AppRoutes.toHistory,
              ),
              SizedBox(width: AppTheme.spacingSm),
              _ActionBubble(
                icon: Icons.shopping_bag_outlined,
                onTap: AppRoutes.toCoinStore,
              ),
              SizedBox(width: AppTheme.spacingSm),
              _ActionBubble(
                icon: Icons.person_outline_rounded,
                onTap: AppRoutes.toProfile,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, LashProvider lashProvider) {
    return PinkGlassCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppTheme.heroGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.monetization_on_rounded,
              color: AppTheme.textInverse,
              size: 28,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: CoinsManager().coinsNotifier,
              builder: (context, coins, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$coins coins',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    Text(
                      lashProvider.freeCount > 0
                          ? '${lashProvider.freeCount} free attempts left'
                          : 'Coin mode enabled',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                );
              },
            ),
          ),
          const PinkPill(
            text: 'AI Preview',
            backgroundColor: AppTheme.secondaryLight,
          ),
        ],
      ),
    );
  }

  Widget _buildExplainerCard(BuildContext context) {
    return PinkGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0x33FFFFFF),
                  Color(0x22FFB7D8),
                ],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(
                color: AppTheme.surfaceColor.withValues(alpha: 0.7),
              ),
            ),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 1.18,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFFFDDEB),
                          Color(0xFFFFC1DD),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 18,
                          right: 18,
                          child: Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor.withValues(
                                alpha: 0.24,
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 20,
                          bottom: 24,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor.withValues(
                                alpha: 0.18,
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 74,
                                height: 74,
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceColor.withValues(
                                    alpha: 0.22,
                                  ),
                                  borderRadius: BorderRadius.circular(26),
                                  border: Border.all(
                                    color: AppTheme.surfaceColor.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.auto_awesome_rounded,
                                  color: AppTheme.textInverse,
                                  size: 34,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacingMd),
                              const Text(
                                'Your first preview',
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacingXs),
                              Text(
                                'Generate once to replace this card.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppTheme.textPrimary
                                          .withValues(alpha: 0.72),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Text(
            'How it works',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          _buildExplainerStep(
            context,
            icon: Icons.upload_rounded,
            title: 'Upload photo',
          ),
          const SizedBox(height: AppTheme.spacingSm),
          _buildExplainerStep(
            context,
            icon: Icons.visibility_rounded,
            title: 'Choose style',
          ),
          const SizedBox(height: AppTheme.spacingSm),
          _buildExplainerStep(
            context,
            icon: Icons.auto_awesome_rounded,
            title: 'Generate preview',
          ),
          const SizedBox(height: AppTheme.spacingLg),
          const PinkPrimaryButton(
            label: 'Create Your First Preview',
            onPressed: AppRoutes.toCreatePreview,
            leading: Icon(Icons.add_rounded, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildExplainerStep(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.textPrimary.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: AppTheme.heroGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: AppTheme.textInverse,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: SizedBox(
              height: 42,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleSectionHeader(
    BuildContext context, {
    required String title,
    String? actionLabel,
    VoidCallback? onActionTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ),
        if (actionLabel != null && onActionTap != null)
          TextButton(
            onPressed: onActionTap,
            child: Text(actionLabel),
          ),
      ],
    );
  }
}

class _GeneratedHeroCard extends StatelessWidget {
  final LashHistoryItem item;
  final VoidCallback onTap;

  const _GeneratedHeroCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
            boxShadow: [
              AppTheme.shadow(AppTheme.primaryMain, 0.12),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
            child: AspectRatio(
              aspectRatio: 1.02,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _HistoryImage(
                      path: item.previewImageUrl, fallbackLabel: 'Preview'),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTheme.textPrimary.withValues(alpha: 0.62),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: AppTheme.spacingLg,
                    right: AppTheme.spacingLg,
                    bottom: AppTheme.spacingLg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PinkPill(
                          text: item.styleName,
                          backgroundColor:
                              AppTheme.surfaceColor.withValues(alpha: 0.9),
                        ),
                        const SizedBox(height: AppTheme.spacingSm),
                        Text(
                          item.title ?? 'Generated lash preview',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.textInverse,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        if ((item.subtitle ?? '').trim().isNotEmpty) ...[
                          const SizedBox(height: AppTheme.spacingXs),
                          Text(
                            item.subtitle!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.textInverse,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GeneratedPreviewCard extends StatelessWidget {
  final LashHistoryItem item;
  final VoidCallback onTap;

  const _GeneratedPreviewCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: AppTheme.textPrimary.withValues(alpha: 0.08),
            ),
            boxShadow: [
              AppTheme.shadow(AppTheme.textPrimary, 0.05),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusMedium),
                  ),
                  child: _HistoryImage(
                    path: item.previewImageUrl,
                    fallbackLabel: 'Preview',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title ?? item.styleName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    Text(
                      item.subtitle ?? 'Tap to view your generated result.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryImage extends StatelessWidget {
  final String path;
  final String fallbackLabel;

  const _HistoryImage({
    required this.path,
    required this.fallbackLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (path.trim().isEmpty) {
      return PinkImageFallback(label: fallbackLabel);
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return PinkImageFallback(label: fallbackLabel);
        },
      );
    }

    if (path.startsWith('/')) {
      return Image.file(
        File(path),
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return PinkImageFallback(label: fallbackLabel);
        },
      );
    }

    return Image.asset(
      path,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return PinkImageFallback(label: fallbackLabel);
      },
    );
  }
}

class _ActionBubble extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionBubble({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor.withValues(alpha: 0.76),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            AppTheme.shadow(AppTheme.primaryMain, 0.1),
          ],
        ),
        child: Icon(icon, color: AppTheme.textPrimary, size: 20),
      ),
    );
  }
}
