import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pliro/pliro/core/managers/coins_manager.dart';
import 'package:pliro/pliro/core/routes/app_routes.dart';
import 'package:pliro/pliro/core/theme/app_colors.dart';
import 'package:pliro/pliro/core/theme/app_text_styles.dart';
import 'package:pliro/pliro/core/theme/app_theme.dart';
import 'package:pliro/pliro/features/home/presentation/controllers/home_controller.dart';
import 'package:pliro/pliro/features/home/presentation/controllers/main_controller.dart';
import 'package:pliro/pliro/features/records/domain/models/bead_record.dart';
import 'package:pliro/pliro/shared/widgets/common_button.dart';
import 'package:pliro/pliro/shared/widgets/common_card.dart';
import 'package:pliro/pliro/shared/widgets/loading_state.dart';

/// Home page content (without bottom nav).
class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  final HomeController _controller = Get.put(HomeController());
  final CoinsManager _coinsManager = CoinsManager.instance;

  @override
  Widget build(BuildContext context) {
    return DreamBackground(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: GetBuilder<HomeController>(
              id: 'content',
              init: _controller,
              builder: (ctrl) {
                if (ctrl.isLoading) {
                  return const LoadingIndicator(
                      message: 'Opening your shelf...');
                }

                return RefreshIndicator(
                  onRefresh: ctrl.loadData,
                  color: AppColors.roseDeep,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.spacingMD,
                      AppTheme.spacingSM,
                      AppTheme.spacingMD,
                      AppTheme.spacingXL,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCreatePanel(ctrl),
                        const SizedBox(height: AppTheme.spacingLG),
                        _buildStatsStrip(ctrl),
                        const SizedBox(height: AppTheme.spacingXL),
                        _buildRecentWorks(ctrl),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingLG,
        AppTheme.spacingMD,
        AppTheme.spacingLG,
        AppTheme.spacingSM,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              boxShadow: AppTheme.glowShadow,
            ),
            child: const Icon(
              Icons.blur_on,
              color: AppColors.textInverse,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pliro',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Your bead works, softly kept',
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ValueListenableBuilder<int>(
            valueListenable: _coinsManager.coinsNotifier,
            builder: (context, coinBalance, child) {
              return _HeaderPill(
                icon: Icons.toll_outlined,
                label: '$coinBalance',
                onTap: () => Get.toNamed(AppRoutes.coinStore),
              );
            },
          ),
          const SizedBox(width: AppTheme.spacingSM),
          _HeaderPill(
            icon: Icons.person_outline,
            onTap: () {
              final mainController = Get.find<MainController>();
              mainController.changePage(3);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCreatePanel(HomeController controller) {
    return NeonCard(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            child: AspectRatio(
              aspectRatio: 1.78,
              child: CustomPaint(
                painter: _CreatePanelPainter(),
                child: const Center(
                  child: Icon(
                    Icons.add_photo_alternate_outlined,
                    color: AppColors.textInverse,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMD),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Capture a new work',
                  style: AppTextStyles.h3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMD),
              SizedBox(
                width: 132,
                child: NeonButton(
                  text: 'Create',
                  icon: Icons.add,
                  height: 48,
                  onPressed: controller.onCreateRecord,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsStrip(HomeController controller) {
    return Row(
      children: [
        Expanded(
          child: _StatCapsule(
            icon: Icons.check_circle_outline,
            value: '${controller.completedCount}',
            label: 'Finished',
            color: AppColors.mint,
          ),
        ),
        const SizedBox(width: AppTheme.spacingSM),
        Expanded(
          child: _StatCapsule(
            icon: Icons.collections_bookmark_outlined,
            value: '${controller.totalRecords}',
            label: 'Saved',
            color: AppColors.rose,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentWorks(HomeController controller) {
    final records = controller.recentRecords.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Recent works',
                style: AppTextStyles.h3,
              ),
            ),
            TextButton(
              onPressed: () {
                final mainController = Get.find<MainController>();
                mainController.changePage(1);
              },
              child: const Text('View all'),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingSM),
        if (records.isEmpty)
          EmptyState(
            icon: Icons.collections_bookmark_outlined,
            title: 'No records yet',
            subtitle: 'Start with one beautiful image.',
            width: double.infinity,
            margin: EdgeInsets.zero,
            action: SizedBox(
              width: 220,
              child: NeonButton(
                text: 'Create First Record',
                icon: Icons.add,
                onPressed: controller.onCreateRecord,
              ),
            ),
          )
        else
          SizedBox(
            height: 302,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: records.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: AppTheme.spacingMD),
              itemBuilder: (context, index) {
                return _RecentRecordCard(record: records[index]);
              },
            ),
          ),
      ],
    );
  }
}

class _HeaderPill extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback onTap;

  const _HeaderPill({
    required this.icon,
    this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        child: Container(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSM),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.66),
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            border: Border.all(color: Colors.white.withOpacity(0.72)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.roseDeep, size: 20),
              if (label != null) ...[
                const SizedBox(width: AppTheme.spacingXS),
                Text(
                  label!,
                  style: AppTextStyles.captionMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCapsule extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCapsule({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.24),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Icon(icon, color: AppColors.roseDeep, size: 22),
          ),
          const SizedBox(width: AppTheme.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: AppTextStyles.h3),
                Text(
                  label,
                  style: AppTextStyles.small,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentRecordCard extends StatelessWidget {
  final BeadRecord record;

  const _RecentRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 226,
      child: NeonCard(
        onTap: () => Get.toNamed(
          AppRoutes.recordDetail,
          arguments: {'recordId': record.id},
        ),
        padding: const EdgeInsets.all(AppTheme.spacingSM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                child: DreamImage(path: _primaryImagePath(record)),
              ),
            ),
            const SizedBox(height: AppTheme.spacingSM),
            Text(
              record.title,
              style: AppTextStyles.bodySemiBold,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppTheme.spacingXS),
            Row(
              children: [
                Expanded(
                  child: Text(
                    record.themeDisplayName,
                    style: AppTextStyles.small,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _StatusDot(status: record.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final BeadStatus status;

  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: AppColors.getStatusColor(status.name),
        shape: BoxShape.circle,
      ),
    );
  }
}

String? _primaryImagePath(BeadRecord record) {
  return record.finishedImagePath ?? record.patternImagePath;
}

class _CreatePanelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = AppColors.primaryGradient.createShader(rect);
    canvas.drawRect(rect, paint);

    final blushPaint = Paint()
      ..color = AppColors.blushMist.withOpacity(0.46)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.72)
      ..cubicTo(
        size.width * 0.24,
        size.height * 0.42,
        size.width * 0.66,
        size.height * 0.72,
        size.width,
        size.height * 0.48,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, blushPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
