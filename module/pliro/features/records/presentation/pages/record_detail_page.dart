import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pliro/pliro/core/theme/app_colors.dart';
import 'package:pliro/pliro/core/theme/app_text_styles.dart';
import 'package:pliro/pliro/core/theme/app_theme.dart';
import 'package:pliro/pliro/features/records/domain/models/bead_record.dart';
import 'package:pliro/pliro/features/records/presentation/controllers/record_detail_controller.dart';
import 'package:pliro/pliro/shared/widgets/common_card.dart';
import 'package:pliro/pliro/shared/widgets/loading_state.dart';

/// Record detail page.
class RecordDetailPage extends StatelessWidget {
  const RecordDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RecordDetailController());

    return DreamScaffold(
      appBar: AppBar(
        title: const Text('Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
        actions: [
          GetBuilder<RecordDetailController>(
            builder: (ctrl) {
              return IconButton(
                onPressed: ctrl.record == null ? null : ctrl.onDeleteRecord,
                icon: const Icon(Icons.delete_outline),
              );
            },
          ),
        ],
      ),
      body: GetBuilder<RecordDetailController>(
        builder: (ctrl) {
          if (ctrl.isLoading || ctrl.record == null) {
            return const LoadingIndicator(message: 'Opening record...');
          }

          final record = ctrl.record!;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingMD,
              AppTheme.spacingSM,
              AppTheme.spacingMD,
              AppTheme.spacingXXL,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroImage(record),
                const SizedBox(height: AppTheme.spacingLG),
                _buildTitleBlock(record),
                const SizedBox(height: AppTheme.spacingLG),
                _buildInfoGrid(record),
                if (record.mainColors.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.spacingLG),
                  _buildColorSection(record),
                ],
                if (record.notes != null && record.notes!.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.spacingLG),
                  _buildNotes(record),
                ],
                if (record.patternImagePath != null) ...[
                  const SizedBox(height: AppTheme.spacingLG),
                  _buildPatternImage(record),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroImage(BeadRecord record) {
    return NeonCard(
      padding: const EdgeInsets.all(AppTheme.spacingSM),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: AspectRatio(
          aspectRatio: 0.88,
          child: DreamImage(
            path: record.finishedImagePath ?? record.patternImagePath,
            placeholderIcon: Icons.image_not_supported_outlined,
            iconSize: 54,
          ),
        ),
      ),
    );
  }

  Widget _buildTitleBlock(BeadRecord record) {
    return NeonCard(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            record.title,
            style: AppTextStyles.h1.copyWith(fontSize: 28),
          ),
          const SizedBox(height: AppTheme.spacingMD),
          Wrap(
            spacing: AppTheme.spacingSM,
            runSpacing: AppTheme.spacingSM,
            children: [
              DreamChip(
                label: record.statusDisplayName,
                selected: true,
                color: _getStatusColor(record.status),
              ),
              DreamChip(
                label: record.themeDisplayName,
                color: AppColors.roseDeep,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(BeadRecord record) {
    final items = <Widget>[];
    if (record.finishedDate != null) {
      items.add(
        _InfoTile(
          icon: Icons.event_available_outlined,
          label: 'Finished',
          value: _formatDate(record.finishedDate!),
        ),
      );
    }
    if (record.beadCount > 0) {
      items.add(
        _InfoTile(
          icon: Icons.blur_on,
          label: 'Beads',
          value: '${record.beadCount}',
        ),
      );
    }
    items.add(
      _InfoTile(
        icon: Icons.category_outlined,
        label: 'Theme',
        value: record.themeDisplayName,
      ),
    );

    return Row(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          Expanded(child: items[index]),
          if (index != items.length - 1)
            const SizedBox(width: AppTheme.spacingSM),
        ],
      ],
    );
  }

  Widget _buildColorSection(BeadRecord record) {
    return NeonCard(
      padding: const EdgeInsets.all(AppTheme.spacingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Main colors', style: AppTextStyles.h3),
          const SizedBox(height: AppTheme.spacingMD),
          Wrap(
            spacing: AppTheme.spacingSM,
            runSpacing: AppTheme.spacingSM,
            children: record.mainColors.map((color) {
              return Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: AppTheme.cardShadow,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotes(BeadRecord record) {
    return NeonCard(
      padding: const EdgeInsets.all(AppTheme.spacingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notes', style: AppTextStyles.h3),
          const SizedBox(height: AppTheme.spacingSM),
          Text(
            record.notes!,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternImage(BeadRecord record) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppTheme.spacingXS),
          child: Text('Pattern sheet', style: AppTextStyles.h3),
        ),
        const SizedBox(height: AppTheme.spacingSM),
        NeonCard(
          padding: const EdgeInsets.all(AppTheme.spacingSM),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            child: AspectRatio(
              aspectRatio: 1,
              child: DreamImage(
                path: record.patternImagePath,
                placeholderIcon: Icons.grid_on,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(BeadStatus status) {
    switch (status) {
      case BeadStatus.planned:
        return AppColors.infoBlue;
      case BeadStatus.inProgress:
        return AppColors.warningOrange;
      case BeadStatus.finished:
        return AppColors.successGreen;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      child: Column(
        children: [
          Icon(icon, color: AppColors.roseDeep, size: 22),
          const SizedBox(height: AppTheme.spacingSM),
          Text(
            value,
            style: AppTextStyles.bodySemiBold,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: AppTextStyles.small,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
