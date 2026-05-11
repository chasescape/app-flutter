import 'dart:io';

import 'package:flira/flira/app/modules/detail/detail_logic.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailPage extends StatelessWidget {
  DetailPage({Key? key}) : super(key: key);

  final DetailLogic logic = Get.put(DetailLogic());

  @override
  Widget build(BuildContext context) {
    final entry = logic.entry;
    if (entry == null) {
      return const Scaffold(
        body: Center(child: Text('Entry not found')),
      );
    }

    final DateTime date = entry.date;
    final String memoryDate = '${_monthLabel(date.month)} ${date.day}';
    final String fullDate = '${_weekdayLabel(date.weekday)}, ${_monthLabelFull(date.month)} ${date.day}, ${date.year}';

    return Scaffold(
      backgroundColor: const Color(0xFFF6EAF0),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _TopBar(onBack: Get.back),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                child: Column(
                  children: <Widget>[
                    _PhotoHeroCard(
                      photoUrl: entry.photoUrl,
                      memoryDate: memoryDate,
                    ),
                    const SizedBox(height: 14),
                    _QuoteCard(text: entry.userInput),
                    const SizedBox(height: 14),
                    _DateCard(fullDate: fullDate),
                    const SizedBox(height: 16),
                    const _SectionTitle(icon: '✧', text: 'AI Memory Story'),
                    const SizedBox(height: 8),
                    _StoryCard(text: entry.aiDiary),
                    const SizedBox(height: 14),
                    _TagsCard(mood: entry.mood),
                    const SizedBox(height: 14),
                    const _ThanksCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  static String _monthLabelFull(int month) {
    const List<String> labels = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return labels[month - 1];
  }

  static String _weekdayLabel(int weekday) {
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

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      color: const Color(0xFFEDE5EB),
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
      child: Row(
        children: <Widget>[
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onBack,
              borderRadius: BorderRadius.circular(22),
              child: Ink(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F0F3),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE7E2E7)),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 15,
                  color: Color(0xFF7A7680),
                ),
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(right: 36),
                child: Text(
                  'Memory',
                  style: TextStyle(
                    color: Color(0xFF2D2B37),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
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

class _PhotoHeroCard extends StatelessWidget {
  const _PhotoHeroCard({required this.photoUrl, required this.memoryDate});

  final String photoUrl;
  final String memoryDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: <Widget>[
            photoUrl.startsWith('http')
                ? Image.network(photoUrl, width: double.infinity, height: 480, fit: BoxFit.cover)
                : Image.file(File(photoUrl), width: double.infinity, height: 480, fit: BoxFit.cover),
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Memory of',
                    style: TextStyle(color: Colors.white, fontSize: 17 / 1.2),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    memoryDate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 50 / 1.7,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFF7E9EE),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 8,
            right: 4,
            child: Text(
              '❞',
              style: TextStyle(
                fontSize: 64,
                color: const Color(0xFFF3D6DE).withOpacity(0.55),
                height: 1,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Row(
                children: <Widget>[
                  Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Color(0xFFF08AA6)),
                  SizedBox(width: 8),
                  Text(
                    'Your Words',
                    style: TextStyle(
                      color: Color(0xFFF08AA6),
                      fontSize: 17 / 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                '"$text"',
                style: const TextStyle(
                  color: Color(0xFF4A5568),
                  fontSize: 35 / 2,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateCard extends StatelessWidget {
  const _DateCard({required this.fullDate});

  final String fullDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFF4F2F3),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF0AFC1),
            ),
            child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Recorded on',
                  style: TextStyle(color: Color(0xFF95A1B4), fontSize: 14),
                ),
                const SizedBox(height: 3),
                Text(
                  fullDate,
                  style: const TextStyle(color: Color(0xFF323E52), fontSize: 18 / 1.1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.text});

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(icon, style: const TextStyle(color: Color(0xFFF08AA6), fontSize: 20 / 1.2)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF2A3445),
            fontSize: 34 / 2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0xFFF4F2F3),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF334155),
          fontSize: 19 / 1.05,
          height: 1.6,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _TagsCard extends StatelessWidget {
  const _TagsCard({required this.mood});

  final String mood;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0xFFF4F2F3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Moments & Feelings',
            style: TextStyle(color: Color(0xFF98A2B3), fontSize: 15),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              _chip('☁️ $mood', const Color(0xFFF0A2B6), Colors.white),
              _chip('🗂 Life', const Color(0xFFF1CED8), const Color(0xFF705E67)),
              _chip('📸 Memory', const Color(0xFFB8D6D0), const Color(0xFF48605C)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontSize: 16 / 1.15),
      ),
    );
  }
}

class _ThanksCard extends StatelessWidget {
  const _ThanksCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFF4E6EC), Color(0xFFF0ECEF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF097AE),
            ),
            child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 16),
          const Text(
            'Every moment is precious',
            style: TextStyle(
              color: Color(0xFF38455C),
              fontSize: 36 / 2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Thank you for sharing this beautiful memory with Flira',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF9AA5B7),
              fontSize: 30 / 2,
            ),
          ),
        ],
      ),
    );
  }
}
