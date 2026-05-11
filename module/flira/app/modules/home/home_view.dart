import 'dart:io';
import 'dart:ui';

import 'package:flira/flira/app/modules/home/home_logic.dart';
import 'package:flira/flira/app/modules/nav/flira_state.dart';
import 'package:flira/flira/app/modules/nav/nav_logic.dart';
import 'package:flira/flira/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final HomeLogic logic = Get.put(HomeLogic());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final DateTime now = DateTime.now();
      final String dateStr = '${_monthLabel(now.month)} ${now.day} · ${_weekdayLabel(now.weekday)}';
      final String greeting = _greeting(now.hour);
      final bool hasEntries = logic.entries.isNotEmpty;

      return Scaffold(
        backgroundColor: const Color(0xFFF6F4F5),
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: Container(
                  color: const Color(0xFFF7E9EF),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 130, 20, 20),
                    child: hasEntries ? _buildDataContent(context) : _buildEmptyContent(context),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: _Header(dateStr: dateStr, greeting: greeting),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDataContent(BuildContext context) {
    final DiaryEntry? todayEntry = logic.todayEntry;
    final List<DiaryEntry> timeline = logic.recentPhotos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (todayEntry != null)
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.detail, arguments: todayEntry.id),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4E8ED),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F7F8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: todayEntry.photoUrl.startsWith('http')
                          ? Image.network(
                              todayEntry.photoUrl,
                              width: double.infinity,
                              height: 360,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(todayEntry.photoUrl),
                              width: double.infinity,
                              height: 360,
                              fit: BoxFit.cover,
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '"${todayEntry.mood.toLowerCase()}"',
                            style: const TextStyle(
                              color: Color(0xFF4E5666),
                              fontSize: 32 / 2,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'AI Daily Diary:',
                            style: TextStyle(color: Color(0xFF9CA4B5), fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            todayEntry.aiDiary,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF3F495B),
                              fontSize: 33 / 2,
                              height: 1.55,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: <Widget>[
                              _Tag(text: todayEntry.mood, icon: '☁️'),
                              const SizedBox(width: 8),
                              const _Tag(text: 'Life', icon: '🏷️', pale: true),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${_monthLabel(todayEntry.date.month)} ${todayEntry.date.day}',
                            style: const TextStyle(color: Color(0xFF8E98AD), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF4E8ED),
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F4F7),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF39AB0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Flira AI',
                            style: TextStyle(
                              color: Color(0xFFF07E9B),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'How was your day today?',
                            style: TextStyle(color: Color(0xFF4A566B), fontSize: 32 / 2),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'I can help you organize today\'s life moments.',
                            style: TextStyle(color: Color(0xFF768195), fontSize: 31 / 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final NavLogic navLogic = Get.find<NavLogic>();
                      navLogic.changeTab(1);
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Record Today',
                      style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFFF08DA8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'My Timeline',
          style: TextStyle(
            color: Color(0xFF1E2A3E),
            fontSize: 38 / 1.4,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Your precious moments',
          style: TextStyle(color: Color(0xFF94A0B4), fontSize: 15),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: timeline.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, int i) {
              final DiaryEntry item = timeline[i];
              return GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.detail, arguments: item.id),
                child: Column(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: item.photoUrl.startsWith('http')
                          ? Image.network(item.photoUrl, width: 120, height: 150, fit: BoxFit.cover)
                          : Image.file(File(item.photoUrl), width: 120, height: 150, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_monthLabel(item.date.month)} ${item.date.day}',
                      style: const TextStyle(color: Color(0xFF7F8BA1), fontSize: 14),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3E4EA),
              borderRadius: BorderRadius.circular(28),
            ),
            padding: const EdgeInsets.all(14),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF6F3F5),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.fromLTRB(24, 36, 24, 30),
              child: Column(
                children: <Widget>[
                  const Icon(Icons.menu_book_rounded, size: 118, color: Color(0xFFF2A1B5)),
                  const SizedBox(height: 26),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7E6ED),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '✨ Welcome to Flira',
                      style: TextStyle(
                        color: Color(0xFFF08DA7),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your Journey Starts Here',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 40 / 1.4,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2738),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Share your precious moments with Flira\nAI. Every conversation becomes a\nbeautiful memory, every photo tells your\nstory.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF69778E), fontSize: 17 / 1.1, height: 1.8),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        final NavLogic navLogic = Get.find<NavLogic>();
                        navLogic.changeTab(1);
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFFF392AC),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                      child: const Text(
                        'Start My First Diary',
                        style: TextStyle(fontSize: 28 / 1.4, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Chat · Record · Remember',
                    style: TextStyle(color: Color(0xFF96A2B6), fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(
              3,
              (_) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5B8C8),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting(int hour) {
    if (hour < 12) return 'Good morning ☀️';
    if (hour < 17) return 'Good afternoon ☀️';
    return 'Good evening 🌙';
  }

  static String _monthLabel(int month) {
    const List<String> labels = <String>[
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
    return labels[month - 1];
  }

  String _weekdayLabel(int weekday) {
    const List<String> labels = <String>[
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return labels[weekday - 1];
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.dateStr, required this.greeting});

  final String dateStr;
  final String greeting;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
          decoration: BoxDecoration(
            color: const Color(0xFFEFE9EC).withOpacity(0.58),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.38),
                width: 1,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Flira',
                style: TextStyle(
                  color: Color(0xFFEF7F97),
                  fontSize: 44 / 1.4,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                dateStr,
                style: const TextStyle(
                  color: Color(0xFF92A0B5),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                greeting,
                style: const TextStyle(
                  color: Color(0xFF546176),
                  fontSize: 30 / 2,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.icon, this.pale = false});

  final String text;
  final String icon;
  final bool pale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: pale ? const Color(0xFFF4D8E1) : const Color(0xFFF39AB0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        '$icon $text',
        style: TextStyle(
          color: pale ? const Color(0xFF7C6A72) : Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }
}
