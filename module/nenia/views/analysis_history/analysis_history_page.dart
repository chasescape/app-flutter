import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/global_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/style_analysis.dart';
import '../../routes/app_pages.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/soft_ui.dart';

class AnalysisHistoryController extends GetxController {
  final GlobalController _globalController = GlobalController.to;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    isLoading.value = true;
    await _globalController.refreshStyleAnalysisHistory();
    isLoading.value = false;
  }

  Future<void> refreshHistory() async {
    await _loadHistory();
  }

  void goToDetail(StyleAnalysis analysis) {
    Routes.toDetail(analysis);
  }

  void goToUpload() {
    Routes.toUpload();
  }

  void clearAllHistory() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surfacePrimary,
        title: const Text('Clear history', style: AppTextStyles.h3),
        content: const Text('Remove all saved analyses from this device?',
            style: AppTextStyles.body),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Get.back();
              _globalController.clearStyleAnalysisHistory();
              Get.snackbar('Success', 'History cleared');
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class AnalysisHistoryPage extends GetView<AnalysisHistoryController> {
  const AnalysisHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AnalysisHistoryController());
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NeniaBackdrop(
        child: SafeArea(
          bottom: false,
          child: Obx(() {
            if (controller.isLoading.value) {
              return const LoadingWidget(message: 'Loading history');
            }

            final history = controller._globalController.styleAnalysisHistory;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                  child: NeniaInlineHeader(
                    title: 'Saved analyses',
                    subtitle:
                        'A cleaner picture-led grid for revisiting previous looks.',
                    onBack: Get.back,
                    trailing: history.isNotEmpty
                        ? NeniaCircleButton(
                            icon: Icons.delete_outline_rounded,
                            onTap: controller.clearAllHistory,
                          )
                        : null,
                  ),
                ),
                Expanded(
                  child: history.isEmpty
                      ? NeniaEmptyState(
                          icon: Icons.collections_bookmark_outlined,
                          title: 'No saved looks yet',
                          message:
                              'Analyze a photo and it will appear here as a full-bleed card.',
                          actionLabel: 'Start analysis',
                          onAction: controller.goToUpload,
                        )
                      : RefreshIndicator(
                          onRefresh: controller.refreshHistory,
                          child: GridView.builder(
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.68,
                            ),
                            itemCount: history.length,
                            itemBuilder: (context, index) {
                              final analysis = history[index];
                              return NeniaPhotoCard(
                                onTap: () => controller.goToDetail(analysis),
                                label: analysis.styleTags.isNotEmpty
                                    ? '#${analysis.styleTags.first}'
                                    : 'Saved',
                                title: analysis.styleVibe.value,
                                subtitle: analysis.outfitStyle.value,
                                image:
                                    NeniaAdaptiveImage(path: analysis.assetImg),
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
