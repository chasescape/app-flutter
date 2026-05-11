import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../theme/app_colors.dart';
import '../../routes/app_routes.dart';
import 'history_logic.dart';

class HistoryPage extends StatelessWidget {
  HistoryPage({super.key});

  final HistoryLogic logic = Get.put(HistoryLogic());

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor =
        isDark ? AppColors.darkTextPrimary : AppColors.primaryDark;

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'History',
          style: TextStyle(
            color: titleColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(Icons.delete_outline, color: titleColor),
              onPressed: logic.historyList.isEmpty
                  ? null
                  : () => _showClearAllDialog(context),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final visibleItems = logic.historyList.where(_canDisplayItem).toList();
        return visibleItems.isEmpty
            ? _buildEmptyState(context)
            : GridView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 3 / 4,
                ),
                itemCount: visibleItems.length,
                itemBuilder: (context, index) => _buildHistoryCard(
                  context,
                  visibleItems[index],
                  index,
                ),
              );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor =
        isDark ? AppColors.darkTextPrimary : AppColors.primaryDark;
    final subtitleColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFE8B4D9).withValues(alpha: 0.3),
                  const Color(0xFFF5E6F1).withValues(alpha: 0.3),
                ],
              ),
            ),
            child:
                const Icon(Icons.history, size: 60, color: Color(0xFFE8B4D9)),
          ),
          const SizedBox(height: 24),
          Text(
            'No history yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start exploring to build your adventure log.',
            style: TextStyle(
              fontSize: 14,
              color: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, HistoryItem item, int index) {
    final isAi = item.type == 'ai';

    final heroImage = isAi
        ? null
        : null; // 预留：后续如需继续支持内置 cave，可在这里补图

    final title = isAi ? (item.title ?? 'AI Gear Check') : 'Cave exploration';

    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(50 * (1 - value), 0),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Dismissible(
        key: ValueKey(
          'history_${item.createdAt?.millisecondsSinceEpoch ?? 0}_${item.imagePath ?? item.id ?? index}',
        ),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) => logic.removeHistoryItem(item),
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red.shade300,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          child: const Icon(Icons.delete, color: Colors.white, size: 28),
        ),
        child: GestureDetector(
          onTap: () {
            if (isAi && item.aiData != null) {
              Get.toNamed(AppRoutes.detail,
                arguments: {
                  'aiResult': item.aiData,
                },
              );
            } else if (!isAi && item.id != null) {
              Get.toNamed(AppRoutes.detail,
                arguments: {'id': item.id},
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE8B4D9).withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  if (heroImage != null)
                    Positioned.fill(
                      child: Image.asset(
                        heroImage,
                        fit: BoxFit.cover,
                      ),
                    )
                  else if (item.imagePath != null &&
                      item.imagePath!.isNotEmpty)
                    Positioned.fill(
                      child: Image.file(
                        File(item.imagePath!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.05),
                            Colors.black.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (item.createdAt ?? DateTime.now())
                              .toLocal()
                              .toString()
                              .substring(0, 16),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Completed',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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

  bool _canDisplayItem(HistoryItem item) {
    final path = item.imagePath;
    if (path == null || path.isEmpty) {
      return item.type != 'ai';
    }
    return File(path).existsSync();
  }

  Future<void> _showClearAllDialog(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor =
        isDark ? AppColors.darkTextPrimary : AppColors.primaryDark;
    final subtitleColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    await Get.dialog<void>(
      AlertDialog(
        backgroundColor: AppColors.getSurface(context),
        title: Text(
          'Clear history?',
          style: TextStyle(color: titleColor, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This will remove all history records.',
          style: TextStyle(color: subtitleColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: subtitleColor)),
          ),
          TextButton(
            onPressed: () async {
              await logic.clearAllHistory();
              Get.back();
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
