import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/app_background.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_colors.dart';
import '../details/details_view.dart';
import 'history_logic.dart';

class HistoryPage extends StatelessWidget {
  HistoryPage({super.key});

  final HistoryLogic logic = Get.put(HistoryLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        useImageBackground: true,
        safeArea: false,
        padding: EdgeInsets.zero,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'AI History',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Obx(() {
                  final records = logic.records;
                  if (records.isEmpty) {
                    return AppCard(
                      borderRadius: 24,
                      backgroundColor: Colors.white.withOpacity(0.95),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'No records yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'When you generate AI care tips, they will appear here.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: records
                        .map(
                          (record) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                final item = record.result;
                                Get.to(
                                  () => DetailsPage(
                                    title: item.title,
                                    subtitle: item.overview,
                                    progress: 1.0,
                                    image: record.imagePath,
                                    category: item.category,
                                    overview: item.overview,
                                    steps: item.steps,
                                    proTips: item.proTips,
                                  ),
                                );
                              },
                              child: AppCard(
                                borderRadius: 24,
                                backgroundColor: Colors.white.withOpacity(0.95),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.file(
                                        File(record.imagePath),
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            record.result.title,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            record.result.overview,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                }),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

