import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vesper/vesper/app/widgets/app_background.dart';

import 'details_logic.dart';
import 'dart:io';

import 'package:vesper/vesper/app/data/cheer_history_store.dart';

class DetailsPage extends StatelessWidget {
  DetailsPage({Key? key}) : super(key: key);

  final DetailsLogic logic = Get.put(DetailsLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        useImageBackground: true,
        safeArea: false,
        padding: EdgeInsets.zero,
        child: GetBuilder<DetailsLogic>(
          builder: (logic) {
            final CheerHistoryItem? item = logic.item;
            final result = item?.result;

            return Column(
              children: [
                Container(
                  height: 110,
                  padding: EdgeInsets.fromLTRB(
                    12,
                    MediaQuery.of(context).padding.top,
                    12,
                    8,
                  ),
                  child: const Row(
                    children: [
                      BackButton(color: Color(0xFF2B1A2B)),
                      SizedBox(width: 6),
                      Text(
                        'Move Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2B1A2B),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: SizedBox(
                            height: 520,
                            width: double.infinity,
                            child: item?.imagePath != null
                                ? Image.file(
                                    File(item!.imagePath),
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: Colors.black12,
                                    child: const Center(
                                      child: Icon(Icons.image, size: 48),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Toe Touch Jump',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2B1A2B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFC247),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'Intermediate',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Jump',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6E5B6F),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          result?.summary ??
                              'Master the classic toe touch with explosive power and perfect form.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6E5B6F),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _pinkSection(
                          title: 'Move Steps',
                          items: const [
                            'Bend knees and prepare to jump',
                            'Jump upward with explosive power',
                            'Extend legs horizontally while in air',
                            'Land softly with bent knees',
                          ],
                        ),
                        const SizedBox(height: 14),
                        _pinkSection(
                          title: 'Key Tips',
                          items: result?.tips ??
                              const [
                                'Keep your back straight',
                                'Point your toes',
                                'Use strong arm swing',
                                'Jump up, not forward',
                              ],
                        ),
                        const SizedBox(height: 14),
                        _pinkSection(
                          title: 'Strengths',
                          items: result?.strengths ?? const [],
                          emptyText: 'No strengths yet.',
                        ),
                        const SizedBox(height: 14),
                        _pinkSection(
                          title: 'Improvements',
                          items: result?.improvements ?? const [],
                          emptyText: 'No improvements yet.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _pinkSection({
    required String title,
    required List<String> items,
    String emptyText = 'No items yet.',
  }) {
    final List<String> list =
        items.isNotEmpty ? items : <String>[emptyText];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFF7FBF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...list.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '•',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      e,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
