import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/global_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../routes/app_pages.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/post_card.dart';
import '../../widgets/common/soft_ui.dart';

class HistoryController extends GetxController {
  final GlobalController _globalController = GlobalController.to;
  final RxList<Post> myPosts = <Post>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMyPosts();
  }

  void loadMyPosts() {
    isLoading.value = true;
    myPosts.value = _globalController.myPosts;
    isLoading.value = false;
  }

  @override
  Future<void> refresh() async {
    loadMyPosts();
  }

  void goToDetail(Post post) {
    Get.bottomSheet(
      NeniaBackdrop(
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: NeniaSurface(
              radius: 30,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: AppBorderRadius.allLg,
                    child: SizedBox(
                      height: 220,
                      width: double.infinity,
                      child: NeniaAdaptiveImage(path: post.imageUrl),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(post.title, style: AppTextStyles.h3),
                  const SizedBox(height: 8),
                  Text(post.content, style: AppTextStyles.caption),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  void goToCreate() {
    Routes.toUpload();
  }
}

class HistoryPage extends GetView<HistoryController> {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HistoryController());
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NeniaBackdrop(
        child: SafeArea(
          bottom: false,
          child: Obx(() {
            if (controller.isLoading.value) {
              return const LoadingWidget(message: 'Loading posts');
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                  child: NeniaInlineHeader(
                    title: 'Your created moments',
                    subtitle:
                        'Reframed with larger image cards and lighter metadata.',
                    onBack: Get.back,
                  ),
                ),
                Expanded(
                  child: controller.myPosts.isEmpty
                      ? NeniaEmptyState(
                          icon: Icons.photo_library_outlined,
                          title: 'No posts yet',
                          message:
                              'Analyze a look or create a moment and it will show up here.',
                          actionLabel: 'Analyze style',
                          onAction: controller.goToCreate,
                        )
                      : RefreshIndicator(
                          onRefresh: controller.refresh,
                          child: GridView.builder(
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.72,
                            ),
                            itemCount: controller.myPosts.length,
                            itemBuilder: (context, index) {
                              final post = controller.myPosts[index];
                              return PostCard(
                                post: post,
                                height: 240,
                                onTap: () => controller.goToDetail(post),
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
