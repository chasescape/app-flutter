import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:crushi/crushi/core/theme/app_theme.dart';
import 'package:crushi/crushi/core/widgets/diffuse_background.dart';
import 'package:crushi/crushi/data/models/stoic_card.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class DetailPage extends StatelessWidget {
  final StoicCard card;

  const DetailPage({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final scene = card.sceneCard;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: DiffuseBackground(
              base: Color(0xFF070B16),
              bottom: Color(0xFF070B16),
            ),
          ),
          CustomScrollView(
            slivers: [
              // Hero image area
              SliverAppBar(
                expandedHeight: 520,
                pinned: true,
                backgroundColor: Colors.transparent,
                leading: Container(
                  margin: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primaryMain),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            actions: [
              Container(
                    margin: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                child: IconButton(
                  icon: const Icon(Icons.share_outlined, color: AppColors.primaryMain),
                  onPressed: () => _handleShare(context),
                ),
              ),
            ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                  // Actual image
                  _buildCardImage(card.assetImg),
                      // Gradient overlay + core text
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.12),
                              Colors.black.withOpacity(0.78),
                            ],
                            stops: const [0.25, 1.0],
                          ),
                        ),
                      ),
                      // Bottom overlay text
                      Positioned(
                        left: AppSpacing.lg,
                        right: AppSpacing.lg,
                        bottom: AppSpacing.md,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Virtue chip
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryMain.withOpacity(0.92),
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Text(
                                scene.stoicVirtue.value,
                                style: AppTypography.small.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            // One-line capture as main title
                            Text(
                              card.oneLineCapture,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textInverse,
                                height: 1.3,
                                fontFamily: AppTypography.fontFamily,
                                shadows: [
                                  Shadow(color: Colors.black54, blurRadius: 8),
                                ],
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content area
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // === Primary: Tags row ===
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: card.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryMain.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          tag,
                          style: AppTypography.small.copyWith(
                            color: AppColors.primaryMain,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // === Key attributes card (setting, mood, time) ===
                  _buildSectionCard(
                    children: [
                      _buildAttrRow(Icons.place_outlined, 'Setting', scene.setting.value,
                          scene.setting.detail),
                      _buildDivider(),
                      _buildAttrRow(Icons.wb_sunny_outlined, 'Time of Day', scene.timeOfDay.value,
                          scene.timeOfDay.detail),
                      _buildDivider(),
                      _buildAttrRow(Icons.mood_outlined, 'Visual Mood', scene.visualMood.value,
                          scene.visualMood.detail),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // === Scene details card (nature, presence, light) ===
                  _buildSectionCard(
                    children: [
                      _buildAttrRow(Icons.nature_outlined, 'Nature Ratio', scene.natureRatio.value,
                          scene.natureRatio.detail),
                      _buildDivider(),
                      _buildAttrRow(Icons.people_outline, 'Human Presence',
                          scene.humanPresence.value, scene.humanPresence.detail),
                      _buildDivider(),
                      _buildAttrRow(Icons.light_mode_outlined, 'Light Quality',
                          scene.lightQuality, null),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // === Key Objects (secondary info) ===
                  Text(
                    'Key Objects',
                    style: AppTypography.h3.copyWith(
                      color: AppColors.textInverse,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: scene.keyObjects.map((obj) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: Colors.black.withOpacity(0.06)),
                        ),
                        child: Text(
                          obj,
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // === Dominant Colors (secondary info) ===
                  Text(
                    'Dominant Colors',
                    style: AppTypography.h3.copyWith(
                      color: AppColors.textInverse,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: scene.dominantColors.map((color) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: Colors.black.withOpacity(0.06)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _parseColor(color),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              color,
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardImage(String path) {
    if (path.startsWith('/')) {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black12),
      );
    }
    return Image.asset(path, fit: BoxFit.cover);
  }

  Future<void> _handleShare(BuildContext context) async {
    final text = card.oneLineCapture;
    final box = context.findRenderObject() as RenderBox?;

    if (card.assetImg.startsWith('/')) {
      await Share.shareXFiles(
        [XFile(card.assetImg)],
        text: text,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
      return;
    }

    await Share.share(
      text,
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  Widget _buildSectionCard({required List<Widget> children}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.78),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
            boxShadow: AppShadows.sm,
          ),
          child: Column(children: children),
        ),
      ),
    );
  }

  Widget _buildAttrRow(IconData icon, String label, String value, String? detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primaryMain),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.small),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
                ),
                if (detail != null && detail.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: AppTypography.small.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Divider(height: 1),
    );
  }

  Color _parseColor(String colorName) {
    final lower = colorName.toLowerCase();
    if (lower.contains('blue')) return const Color(0xFF2196F3);
    if (lower.contains('green')) return const Color(0xFF4CAF50);
    if (lower.contains('red')) return const Color(0xFFF44336);
    if (lower.contains('yellow') || lower.contains('golden')) {
      return AppColors.primaryMain;
    }
    if (lower.contains('grey') || lower.contains('gray')) {
      return const Color(0xFF9E9E9E);
    }
    if (lower.contains('white')) return const Color(0xFFE0E0E0);
    if (lower.contains('brown')) return const Color(0xFF795548);
    if (lower.contains('purple')) return const Color(0xFF9C27B0);
    if (lower.contains('orange')) return const Color(0xFFFF9800);
    if (lower.contains('sky')) return const Color(0xFF87CEEB);
    if (lower.contains('warm')) return const Color(0xFFFFCCBC);
    if (lower.contains('dark')) return const Color(0xFF424242);
    return AppColors.primaryMain;
  }
}
