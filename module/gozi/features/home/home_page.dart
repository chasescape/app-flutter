import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:achievenote/gozi/routes/global_router.dart';
import 'package:achievenote/gozi/services/coins_manager.dart';
import 'package:achievenote/gozi/services/achievement_storage_service.dart';
import 'package:achievenote/gozi/widgets/common/app_button.dart';
import 'package:achievenote/gozi/widgets/common/app_card.dart';
import 'package:achievenote/gozi/widgets/common/app_scaffold.dart';
import 'package:achievenote/gozi/theme/app_theme.dart';

/// Home Page - Main screen with upload entry and recent achievements
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Coins manager
  final CoinsManager _coinsManager = CoinsManager.instance;

  @override
  void initState() {
    super.initState();
    // Initialize CoinsManager
    _coinsManager.initialize();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image != null) {
      GlobalRouter.I.goToCreate(imagePath: image.path);
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (photo != null) {
      GlobalRouter.I.goToCreate(imagePath: photo.path);
    }
  }

  void _showImageSourceDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppTheme.lg),
        decoration: BoxDecoration(
          gradient: AppTheme.softSurfaceGradient,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusXl),
          ),
          border:
              Border.all(color: AppTheme.primaryWhite.withValues(alpha: 0.72)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Get.back();
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Get.back();
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('AchieveNote'),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 262),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppTheme.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.md),
                child: ValueListenableBuilder<int>(
                  valueListenable: _coinsManager.balanceNotifier,
                  builder: (context, balance, child) {
                    return ValueListenableBuilder<int>(
                      valueListenable: _coinsManager.freeUsesNotifier,
                      builder: (context, freeUses, child) {
                        final canCreate = _coinsManager.canCreateAchievement();
                        final cost = _coinsManager.getCreationCost();
                        final hasFreeUses = freeUses > 0;

                        return _UploadHeroCard(
                          canCreate: canCreate,
                          statusText: canCreate
                              ? (hasFreeUses
                                  ? '$freeUses free uses left'
                                  : '$cost coins per card')
                              : 'Need more coins',
                          onChoosePhoto:
                              canCreate ? _showImageSourceDialog : null,
                          onGetCoins: () => GlobalRouter.I.goToStore(),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: AppTheme.lg),
              GetX<AchievementStorageService>(
                builder: (service) {
                  final categories = service.getCategories();
                  if (categories.isEmpty) return const SizedBox.shrink();

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppTheme.md),
                    child: _HomeGoalFolders(
                      categories: categories.take(4).toList(),
                      countForCategory: service.getCategoryCount,
                      onTap: () => GlobalRouter.I.goToHistory(),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppTheme.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Recent Cards',
                        style: AppTheme.h3.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => GlobalRouter.I.goToHistory(),
                      child: const Text('See All'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.sm),
              GetX<AchievementStorageService>(
                builder: (service) {
                  final achievements = service.getRecentAchievements(count: 5);

                  if (achievements.isEmpty) {
                    return Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppTheme.md),
                      child: AppCard(
                        padding: const EdgeInsets.all(AppTheme.lg),
                        child: Row(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppTheme.primaryButtonGradient,
                              ),
                              child: const Icon(
                                Icons.edit_note_rounded,
                                color: AppTheme.primaryWhite,
                              ),
                            ),
                            const SizedBox(width: AppTheme.md),
                            Expanded(
                              child: Text(
                                'Your first image card is waiting.',
                                style: AppTheme.body.copyWith(
                                  color: AppTheme.textInverse,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 220,
                    child: ListView.separated(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppTheme.md),
                      scrollDirection: Axis.horizontal,
                      itemCount: achievements.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: AppTheme.md),
                      itemBuilder: (context, index) {
                        final achievement = achievements[index];
                        return SizedBox(
                          width: 168,
                          child: CompactAchievementCard(
                            title: achievement.title,
                            imagePath: achievement.imagePath,
                            category: achievement.category,
                            createdAt: achievement.createdAt,
                            onTap: () => GlobalRouter.I.goToResult(
                              imagePath: achievement.imagePath,
                              title: achievement.title,
                              description: achievement.description,
                              tags: achievement.tags,
                              category: achievement.category,
                              note: achievement.note,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeGoalFolders extends StatelessWidget {
  final List<String> categories;
  final int Function(String category) countForCategory;
  final VoidCallback onTap;

  const _HomeGoalFolders({
    required this.categories,
    required this.countForCategory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(AppTheme.md),
      borderRadius: AppTheme.radiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.folder_special_rounded,
                color: AppTheme.accentRed,
              ),
              const SizedBox(width: AppTheme.sm),
              Expanded(
                child: Text(
                  'Goal Folders',
                  style: AppTheme.body.copyWith(
                    color: AppTheme.textInverse,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppTheme.textSecondary,
                size: 14,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.md),
          Wrap(
            spacing: AppTheme.sm,
            runSpacing: AppTheme.sm,
            children: categories.map((category) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.md,
                  vertical: AppTheme.sm,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryWhite.withValues(alpha: 0.68),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  border: Border.all(
                    color: AppTheme.primaryWhite.withValues(alpha: 0.8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.folder_rounded,
                      color: AppTheme.accentLemon,
                      size: 16,
                    ),
                    const SizedBox(width: AppTheme.xs),
                    Text(
                      '$category ${countForCategory(category)}',
                      style: AppTheme.small.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _UploadHeroCard extends StatelessWidget {
  final bool canCreate;
  final String statusText;
  final VoidCallback? onChoosePhoto;
  final VoidCallback onGetCoins;

  const _UploadHeroCard({
    required this.canCreate,
    required this.statusText,
    required this.onChoosePhoto,
    required this.onGetCoins,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppTheme.sm),
      borderRadius: AppTheme.radiusXl,
      child: Column(
        children: [
          Container(
            height: 270,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              gradient: AppTheme.candyGradient,
              boxShadow: AppTheme.imageShadow,
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _UploadPreviewPainter(),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 58),
                    child: _AchievementFlowPreview(canCreate: canCreate),
                  ),
                ),
                Positioned(
                  left: AppTheme.md,
                  right: AppTheme.md,
                  bottom: AppTheme.md,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.md,
                            vertical: AppTheme.sm,
                          ),
                          decoration: BoxDecoration(
                            color:
                                AppTheme.primaryWhite.withValues(alpha: 0.82),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusFull),
                          ),
                          child: Text(
                            statusText,
                            style: AppTheme.small.copyWith(
                              color: canCreate
                                  ? AppTheme.textInverse
                                  : AppTheme.error,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.md),
          AppButton(
            text: 'Choose Photo',
            onPressed: onChoosePhoto,
            width: double.infinity,
          ),
          if (!canCreate) ...[
            const SizedBox(height: AppTheme.sm),
            AppSecondaryButton(
              text: 'Get Coins',
              onPressed: onGetCoins,
              width: double.infinity,
            ),
          ],
        ],
      ),
    );
  }
}

class _AchievementFlowPreview extends StatelessWidget {
  final bool canCreate;

  const _AchievementFlowPreview({
    required this.canCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: canCreate ? 1 : 0.58,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.md,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryWhite.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              border: Border.all(
                color: AppTheme.primaryWhite.withValues(alpha: 0.8),
              ),
            ),
            child: Text(
              'ACHIEVEMENT FLOW',
              style: AppTheme.small.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w900,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: AppTheme.md),
          const Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _FlowPhonePanel(),
                _FlowArrow(),
                _FlowProcessNode(),
                _FlowArrow(),
                _FlowCardStack(),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.xs),
          const Row(
            children: [
              Expanded(
                child: _FlowLabel(
                  title: 'CAPTURE',
                  subtitle: 'moments',
                ),
              ),
              Expanded(
                child: _FlowLabel(
                  title: 'NOTE',
                  subtitle: 'daily log',
                ),
              ),
              Expanded(
                child: _FlowLabel(
                  title: 'UNLOCK',
                  subtitle: 'cards',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FlowPhonePanel extends StatelessWidget {
  const _FlowPhonePanel();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 120,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.primaryWhite.withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: AppTheme.textPrimary.withValues(alpha: 0.78),
            width: 1.8,
          ),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Stack(
          children: [
            Positioned(
              top: 8,
              left: 22,
              right: 22,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textPrimary.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
              ),
            ),
            const Positioned(
              top: 28,
              left: 10,
              child: _FlowIconBubble(icon: Icons.menu_book_rounded),
            ),
            const Positioned(
              top: 28,
              right: 10,
              child: _FlowIconBubble(icon: Icons.fitness_center_rounded),
            ),
            const Positioned(
              bottom: 26,
              left: 10,
              child: _FlowIconBubble(icon: Icons.emoji_events_rounded),
            ),
            const Positioned(
              bottom: 26,
              right: 10,
              child: _FlowIconBubble(icon: Icons.flag_rounded),
            ),
            Positioned(
              bottom: 10,
              left: 22,
              right: 22,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textPrimary.withValues(alpha: 0.36),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlowIconBubble extends StatelessWidget {
  final IconData icon;

  const _FlowIconBubble({
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: AppTheme.primaryWhite.withValues(alpha: 0.72),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.textPrimary.withValues(alpha: 0.54),
          width: 1.2,
        ),
      ),
      child: Icon(
        icon,
        color: AppTheme.textPrimary,
        size: 14,
      ),
    );
  }
}

class _FlowArrow extends StatelessWidget {
  const _FlowArrow();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.arrow_forward_rounded,
      color: AppTheme.textPrimary.withValues(alpha: 0.78),
      size: 22,
    );
  }
}

class _FlowProcessNode extends StatelessWidget {
  const _FlowProcessNode();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 88,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppTheme.primaryWhite.withValues(alpha: 0.66),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.textPrimary.withValues(alpha: 0.72),
                width: 1.6,
              ),
              boxShadow: AppTheme.cardShadow,
            ),
            child: const Icon(
              Icons.edit_note_rounded,
              color: AppTheme.accentRed,
              size: 24,
            ),
          ),
          const Positioned(
            top: 3,
            right: 5,
            child: _SparkMark(size: 11),
          ),
          const Positioned(
            bottom: 8,
            left: 2,
            child: _SparkMark(size: 13),
          ),
        ],
      ),
    );
  }
}

class _SparkMark extends StatelessWidget {
  final double size;

  const _SparkMark({
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.close_rounded,
      color: AppTheme.textPrimary.withValues(alpha: 0.76),
      size: size,
    );
  }
}

class _FlowCardStack extends StatelessWidget {
  const _FlowCardStack();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 92,
      height: 126,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 8,
            child: _MiniAchievementCard(
              icon: Icons.school_rounded,
              title: 'STUDY',
              opacity: 0.7,
            ),
          ),
          Positioned(
            top: 14,
            left: 0,
            child: _MiniAchievementCard(
              icon: Icons.directions_run_rounded,
              title: 'FIT',
              opacity: 0.82,
            ),
          ),
          Positioned(
            top: 28,
            right: 0,
            child: _MiniAchievementCard(
              icon: Icons.verified_rounded,
              title: 'GOAL',
              opacity: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniAchievementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final double opacity;

  const _MiniAchievementCard({
    required this.icon,
    required this.title,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 58,
        height: 82,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppTheme.primaryWhite.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: AppTheme.textPrimary.withValues(alpha: 0.62),
            width: 1.4,
          ),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryButtonGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryWhite,
                size: 18,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              title,
              style: AppTheme.small.copyWith(
                color: AppTheme.textPrimary,
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 1),
            Text(
              'CARD',
              style: AppTheme.small.copyWith(
                color: AppTheme.textSecondary,
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlowLabel extends StatelessWidget {
  final String title;
  final String subtitle;

  const _FlowLabel({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: AppTheme.small.copyWith(
            color: AppTheme.textPrimary,
            fontSize: 9,
            fontWeight: FontWeight.w900,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          subtitle,
          style: AppTheme.small.copyWith(
            color: AppTheme.textSecondary,
            fontSize: 8,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _UploadPreviewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final whitePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(
      Offset(size.width * 0.14, size.height * 0.2),
      58,
      whitePaint,
    );

    final bubblePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.84),
          AppTheme.accentRed.withValues(alpha: 0.18),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.75, size.height * 0.27),
          radius: 42,
        ),
      );

    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.27),
      42,
      bubblePaint,
    );

    final path = Path()
      ..moveTo(size.width * 0.08, size.height * 0.78)
      ..cubicTo(
        size.width * 0.34,
        size.height * 0.62,
        size.width * 0.54,
        size.height * 0.9,
        size.width * 0.92,
        size.height * 0.72,
      );
    canvas.drawPath(
        path, whitePaint..color = Colors.white.withValues(alpha: 0.2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
