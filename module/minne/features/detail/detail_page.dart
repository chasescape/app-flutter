import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/utils/app_overlay.dart';
import '../../data/models/cherish_card.dart';

/// Detail Page - Content Detail View (Yapo Detail Layout)
/// Shows full post with hero image, info sections, and actions
class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  static const Color _berryPrimary = Color(0xFF8F355B);
  static const Color _berrySecondary = Color(0xFFB06A84);
  static const Color _pageTop = Color(0xFFFFEAF4);
  static const Color _pageMid = Color(0xFFFFD7E7);
  static const Color _pageBottom = Color(0xFFFFF5DF);
  static const Color _cardBg = Color(0xFFFFFCFE);
  static const Color _softPink = Color(0xFFFFF1F6);
  CherishCard? _card;
  String? _heroImageRef;

  @override
  void initState() {
    super.initState();
    _loadCard();
  }

  @override
  Widget build(BuildContext context) {
    if (_card == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Content
          CustomScrollView(
            slivers: [
              // Hero image header
              SliverAppBar(
                expandedHeight: 350,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Image
                      _buildHeroImage(_heroImageRef ?? _card!.assetImg),

                      // Gradient overlay with text
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.42),
                            ],
                          ),
                        ),
                      ),

                      // Overlay text
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Text(
                          _card!.meta.oneLineMoment,
                          style: AppTextStyles.h2Style.copyWith(
                            color: AppColors.textInverse,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: _berryPrimary.withValues(alpha: 0.45),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Info sheet
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: _pageTop,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  padding: AppSpacing.paddingLG,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Scene info cards
                      _buildSceneInfoCard(),

                      AppSpacing.gapLG,

                      // Visual Poetry Section
                      _buildVisualPoetrySection(),

                      AppSpacing.gapXL,

                      // Tags
                      if (_card!.visualPoetry.cherishTags.isNotEmpty) ...[
                        Text(
                          'Tags',
                          style: AppTextStyles.h3Style.copyWith(
                            color: _berryPrimary,
                          ),
                        ),
                        AppSpacing.gapSM,
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: _card!.visualPoetry.cherishTags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.78),
                                borderRadius: AppBorderRadius.borderRadiusMD,
                                border: Border.all(
                                  color: const Color(0xFFFFD6E0),
                                ),
                              ),
                              child: Text(
                                tag,
                                style: AppTextStyles.captionStyle.copyWith(
                                  color: _berryPrimary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        AppSpacing.gapLG,
                      ],

                      // Daily Affirmation
                      _buildAffirmationCard(),

                      AppSpacing.gapXL,
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating action buttons
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.textInverse.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.shadowMD,
                  ),
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                ),

                // Share button
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.textInverse.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.shadowMD,
                  ),
                  child: IconButton(
                    onPressed: _shareCard,
                    icon: const Icon(Icons.share),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(String assetImgOrPath) {
    final value = assetImgOrPath.trim();

    // Built-in assets are stored as an actual asset path (preferred),
    // or a legacy string like "A.assets_minne_1".
    final assetMatch = RegExp(r'^A\.assets_minne_(\d+)$').firstMatch(value);
    if (value.startsWith('assets/') || assetMatch != null) {
      final assetPath = value.startsWith('assets/')
          ? value
          : 'assets/minne/${assetMatch!.group(1)}.jpg';
      return Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildHeroFallback(),
      );
    }

    // New flow stores the picked image path as "assetImg".
    final filePath = value.startsWith('file://') ? Uri.parse(value).toFilePath() : value;
    return Image.file(
      File(filePath),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildHeroFallback(),
    );
  }

  Widget _buildHeroFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_pageTop, _pageMid, _pageBottom],
        ),
      ),
    );
  }

  /// Build scene information card
  Widget _buildSceneInfoCard() {
    final scene = _card!.sceneCard;
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            _softPink,
          ],
        ),
        borderRadius: AppBorderRadius.borderRadiusMD,
        border: Border.all(
          color: const Color(0xFFFFCAD7),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFC2D6).withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.palette, color: Color(0xFFFF5B75), size: 20),
              AppSpacing.gapSM,
              Text(
                'Scene',
                style: AppTextStyles.h3Style.copyWith(
                  color: const Color(0xFFFF5B75),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppSpacing.gapSM,
          _buildSceneItem('Time', scene.timeAtmosphere.value),
          _buildSceneItem('Place', scene.sceneType.value),
          _buildSceneItem('Focus', scene.primarySubject.value),
          _buildSceneItem('Mood', scene.moodTone.value),
        ],
      ),
    );
  }

  /// Build visual poetry section
  Widget _buildVisualPoetrySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_stories, color: Color(0xFFFF5B75), size: 20),
            AppSpacing.gapSM,
            Text(
              'Healing Words',
              style: AppTextStyles.h3Style.copyWith(
                color: const Color(0xFFFF5B75),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        AppSpacing.gapMD,
        Container(
          padding: AppSpacing.paddingMD,
          decoration: BoxDecoration(
            color: _cardBg.withValues(alpha: 0.84),
            borderRadius: AppBorderRadius.borderRadiusMD,
            border: Border.all(
              color: const Color(0xFFFFE3B1),
            ),
          ),
          child: Text(
            _card!.visualPoetry.shortHealingText,
            style: AppTextStyles.bodyStyle.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.6,
              color: _berryPrimary,
            ),
          ),
        ),
      ],
    );
  }

  /// Build affirmation card
  Widget _buildAffirmationCard() {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFB6CF), Color(0xFFFFDC88)],
        ),
        borderRadius: AppBorderRadius.borderRadiusMD,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFC19D).withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.format_quote, color: _berryPrimary, size: 24),
          AppSpacing.gapMD,
          Expanded(
            child: Text(
              _card!.visualPoetry.dailyAffirmation,
              style: AppTextStyles.bodyMediumStyle.copyWith(
                color: _berryPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build scene item row
  Widget _buildSceneItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              label,
              style: AppTextStyles.captionStyle.copyWith(
                color: _berrySecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '·',
            style: AppTextStyles.captionStyle.copyWith(
              color: _berrySecondary,
            ),
          ),
          AppSpacing.gapSM,
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMediumStyle.copyWith(
                color: _berryPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loadCard() {
    final args = Get.arguments;
    if (args is CherishCard) {
      _card = args;
      _heroImageRef = args.assetImg;
      return;
    }
    if (args is Map) {
      final card = args['card'];
      if (card is CherishCard) {
        _card = card;
        final imagePath = args['imagePath'];
        if (imagePath is String && imagePath.trim().isNotEmpty) {
          _heroImageRef = imagePath.trim();
        } else {
          _heroImageRef = card.assetImg;
        }
      }
    }
  }

  void _shareCard() {
    _shareCardNative();
  }

  Future<void> _shareCardNative() async {
    final card = _card;
    if (card == null) return;

    final text = card.meta.oneLineMoment.trim();
    final imageRef = (_heroImageRef ?? card.assetImg).trim();

    try {
      if (imageRef.startsWith('assets/')) {
        final bytes = await rootBundle.load(imageRef);
        final ext = imageRef.toLowerCase().endsWith('.png') ? 'png' : 'jpg';
        final tempPath = '${Directory.systemTemp.path}/minne_share_${card.id}.$ext';
        final file = File(tempPath);
        await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
        await Share.shareXFiles(
          [XFile(file.path)],
          text: text.isEmpty ? null : text,
        );
        return;
      }

      final filePath = imageRef.startsWith('file://')
          ? Uri.parse(imageRef).toFilePath()
          : imageRef;
      final imageFile = File(filePath);
      if (await imageFile.exists()) {
        await Share.shareXFiles(
          [XFile(imageFile.path)],
          text: text.isEmpty ? null : text,
        );
        return;
      }

      await Share.share(text.isEmpty ? 'Minne' : text);
    } catch (e) {
      if (!mounted) return;
      AppOverlay.showToast(
        context,
        message: 'Share failed, please try again',
        type: ToastType.error,
      );
    }
  }
}
