import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pliro/pliro/core/routes/app_routes.dart';
import 'package:pliro/pliro/core/theme/app_colors.dart';
import 'package:pliro/pliro/core/theme/app_text_styles.dart';
import 'package:pliro/pliro/core/theme/app_theme.dart';
import 'package:pliro/pliro/features/library/presentation/controllers/library_controller.dart';
import 'package:pliro/pliro/features/records/domain/models/bead_record.dart';
import 'package:pliro/pliro/shared/widgets/common_card.dart';
import 'package:pliro/pliro/shared/widgets/loading_state.dart';

/// Library page - shows all records with filters.
class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LibraryController());

    return DreamScaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          IconButton(
            onPressed: controller.toggleFilter,
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openRecordEditor(controller),
        child: const Icon(Icons.add),
      ),
      body: GetBuilder<LibraryController>(
        builder: (ctrl) {
          if (ctrl.isLoading) {
            return const LoadingIndicator(message: 'Arranging your works...');
          }

          return Column(
            children: [
              if (ctrl.showFilters) _buildFilterPanel(ctrl),
              Expanded(
                child: ctrl.filteredRecords.isEmpty
                    ? EmptyState(
                        icon: Icons.photo_library_outlined,
                        title: 'No records found',
                        subtitle: ctrl.hasFilters
                            ? 'Try a softer filter.'
                            : 'Add your first image-led record.',
                        action: ctrl.hasFilters
                            ? TextButton(
                                onPressed: ctrl.clearFilters,
                                child: const Text('Clear Filters'),
                              )
                            : ElevatedButton(
                                onPressed: () => _openRecordEditor(ctrl),
                                child: const Text('Create Record'),
                              ),
                      )
                    : RefreshIndicator(
                        onRefresh: ctrl.loadData,
                        color: AppColors.roseDeep,
                        child: GridView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            AppTheme.spacingMD,
                            AppTheme.spacingMD,
                            AppTheme.spacingMD,
                            AppTheme.spacingXXL,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: AppTheme.spacingMD,
                            mainAxisSpacing: AppTheme.spacingMD,
                            childAspectRatio: 0.68,
                          ),
                          itemCount: ctrl.filteredRecords.length,
                          itemBuilder: (context, index) {
                            final record = ctrl.filteredRecords[index];
                            return _buildRecordCard(record);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openRecordEditor(LibraryController controller) async {
    final saved = await Get.toNamed(AppRoutes.recordEditor);
    if (saved == true) {
      await controller.loadData();
    }
  }

  Widget _buildFilterPanel(LibraryController ctrl) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingMD,
        AppTheme.spacingSM,
        AppTheme.spacingMD,
        0,
      ),
      child: NeonCard(
        padding: const EdgeInsets.all(AppTheme.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Theme', style: AppTextStyles.bodySemiBold),
            const SizedBox(height: AppTheme.spacingSM),
            Wrap(
              spacing: AppTheme.spacingSM,
              runSpacing: AppTheme.spacingSM,
              children: [
                DreamChip(
                  label: 'All',
                  selected: ctrl.filterTheme == null,
                  onTap: () => ctrl.setFilterTheme(null),
                ),
                ...BeadTheme.values.map((theme) {
                  return DreamChip(
                    label: _themeLabel(theme),
                    selected: ctrl.filterTheme == theme,
                    onTap: () => ctrl.setFilterTheme(theme),
                  );
                }),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMD),
            Text('Status', style: AppTextStyles.bodySemiBold),
            const SizedBox(height: AppTheme.spacingSM),
            Wrap(
              spacing: AppTheme.spacingSM,
              runSpacing: AppTheme.spacingSM,
              children: [
                DreamChip(
                  label: 'All',
                  selected: ctrl.filterStatus == null,
                  color: AppColors.mint,
                  onTap: () => ctrl.setFilterStatus(null),
                ),
                ...BeadStatus.values.map((status) {
                  return DreamChip(
                    label: _statusLabel(status),
                    selected: ctrl.filterStatus == status,
                    color: AppColors.getStatusColor(status.name),
                    onTap: () => ctrl.setFilterStatus(status),
                  );
                }),
              ],
            ),
            if (ctrl.hasFilters) ...[
              const SizedBox(height: AppTheme.spacingSM),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: ctrl.clearFilters,
                  child: const Text('Clear all'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard(BeadRecord record) {
    return NeonCard(
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
              child: DreamImage(
                  path: record.finishedImagePath ?? record.patternImagePath),
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
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: AppColors.getStatusColor(record.status.name),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _themeLabel(BeadTheme theme) {
    switch (theme) {
      case BeadTheme.character:
        return 'Character';
      case BeadTheme.animal:
        return 'Animal';
      case BeadTheme.food:
        return 'Food';
      case BeadTheme.holiday:
        return 'Holiday';
      case BeadTheme.gameIcon:
        return 'Game';
      case BeadTheme.pixelStyle:
        return 'Pixel';
      case BeadTheme.custom:
        return 'Custom';
    }
  }

  String _statusLabel(BeadStatus status) {
    switch (status) {
      case BeadStatus.planned:
        return 'Planned';
      case BeadStatus.inProgress:
        return 'In Progress';
      case BeadStatus.finished:
        return 'Finished';
    }
  }
}
