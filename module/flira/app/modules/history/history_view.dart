import 'dart:io';

import 'package:flira/flira/app/modules/history/history_logic.dart';
import 'package:flira/flira/app/modules/nav/flira_state.dart';
import 'package:flira/flira/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HistoryPage extends StatelessWidget {
  HistoryPage({super.key});

  final HistoryLogic logic = Get.put(HistoryLogic());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final List<DiaryEntry> entries = logic.entries;

        return Scaffold(
          backgroundColor: const Color(0xFFFFF6F9),
          body: SafeArea(
            child: Column(
              children: <Widget>[
                _TopBar(onBack: Get.back),
                Expanded(
                  child: entries.isEmpty
                      ? const _EmptyTimeline()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
                          itemCount: entries.length,
                          itemBuilder: (_, int index) {
                            final DiaryEntry entry = entries[index];
                            final bool isFirst = index == 0;
                            final bool isLast = index == entries.length - 1;
                            return _TimelineItemCard(
                              entry: entry,
                              isFirst: isFirst,
                              isLast: isLast,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
      child: Row(
        children: <Widget>[
          _RoundBackButton(onTap: onBack),
          const Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(right: 44),
                child: Text(
                  'My Timeline',
                  style: TextStyle(
                    fontSize: 32 / 1.4,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF272737),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundBackButton extends StatelessWidget {
  const _RoundBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF303244)),
        ),
      ),
    );
  }
}

class _EmptyTimeline extends StatelessWidget {
  const _EmptyTimeline();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF7DEE7)),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.auto_stories_rounded, size: 62, color: Color(0xFFF3A2B9)),
              SizedBox(height: 14),
              Text(
                'No moments yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3D3440),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Start chatting with Flira and your memories\nwill appear here as a beautiful timeline.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF8D7781),
                  fontSize: 14,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineItemCard extends StatelessWidget {
  const _TimelineItemCard({
    required this.entry,
    required this.isFirst,
    required this.isLast,
  });

  final DiaryEntry entry;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.detail, arguments: entry.id),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 28,
              child: Column(
                children: <Widget>[
                  Container(
                    width: 2,
                    height: isFirst ? 8 : 18,
                    color: isFirst ? Colors.transparent : const Color(0xFFF4C8D6),
                  ),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF38FAE),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: isLast ? 8 : 120,
                    color: isLast ? Colors.transparent : const Color(0xFFF4C8D6),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF7DEE7)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: entry.photoUrl.startsWith('http')
                          ? Image.network(
                              entry.photoUrl,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(entry.photoUrl),
                              fit: BoxFit.cover,
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEEF4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  entry.mood,
                                  style: const TextStyle(
                                    color: Color(0xFFDF6F93),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _formatDate(entry.date),
                                style: const TextStyle(
                                  color: Color(0xFF9A8390),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            entry.userInput,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF352D37),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            entry.aiDiary,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF776673),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    const List<String> monthLabels = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${monthLabels[date.month - 1]} ${date.day}, ${date.year}';
  }
}
