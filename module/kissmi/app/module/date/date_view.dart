import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/mood_store.dart';

import '../../widget/kissmi_background.dart';
import 'date_logic.dart';

class DatePage extends StatefulWidget {
  DatePage({Key? key}) : super(key: key);

  final DateLogic logic = Get.put(DateLogic());

  @override
  State<DatePage> createState() => _DatePageState();
}

class _DatePageState extends State<DatePage> {
  static const int _initialPage = 1200;
  late final PageController _pageController;
  int _currentPage = _initialPage;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _monthForPage(int page) {
    final DateTime now = DateTime.now();
    final int delta = page - _initialPage;
    return DateTime(now.year, now.month + delta, 1);
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String dailyTip = _dailySuggestion(now);
    final DateLogic logic = widget.logic;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: KissmiBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Cycle Calendar',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Track your cycle, spot patterns, and plan self‑care with your daily calendar.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 12),
                GetBuilder<DateLogic>(
                  builder: (logic) => _DailyTipCard(
                    tip: logic.tipForDate(now) ?? dailyTip,
                  ),
                ),
                const SizedBox(height: 10),
                _MonthHeader(
                  date: _monthForPage(_currentPage),
                  onPrev: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                  ),
                  onNext: () => _pageController.nextPage(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                  ),
                ),
                const SizedBox(height: 8),
                _WeekdayRow(),
                const SizedBox(height: 6),
                GetBuilder<DateLogic>(
                  builder: (_) => Column(
                    children: <Widget>[
                      SizedBox(
                        height: 300,
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) =>
                              setState(() => _currentPage = index),
                          itemBuilder: (context, pageIndex) {
                            final DateTime month = _monthForPage(pageIndex);
                            return _MonthGrid(
                              month: month,
                              today: now,
                              moodForDate: logic.moodForDate,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 4),
                      const _LegendRow(),
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
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.date,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime date;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final String monthLabel = '${date.year}.${date.month.toString().padLeft(2, '0')}';
    return Row(
      children: <Widget>[
        Text(
          monthLabel,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: onPrev,
          icon: Icon(Icons.chevron_left, color: Colors.white.withValues(alpha: 0.6)),
        ),
        const SizedBox(width: 6),
        IconButton(
          onPressed: onNext,
          icon: Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.6)),
        ),
      ],
    );
  }
}

class _WeekdayRow extends StatelessWidget {
  final List<String> labels = const <String>['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: labels
          .map(
            (label) => Expanded(
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isToday,
    required this.background,
    required this.emoji,
  });

  final int day;
  final bool isToday;
  final Color background;
  final String? emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: background.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isToday ? Colors.white : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '$day',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (emoji != null) ...<Widget>[
            const SizedBox(height: 4),
            Text(emoji!, style: const TextStyle(fontSize: 12)),
          ],
        ],
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.today,
    required this.moodForDate,
  });

  final DateTime month;
  final DateTime today;
  final String? Function(DateTime) moodForDate;

  @override
  Widget build(BuildContext context) {
    final DateTime monthStart = DateTime(month.year, month.month, 1);
    final DateTime monthEnd = DateTime(month.year, month.month + 1, 0);
    final int daysInMonth = monthEnd.day;
    final int startWeekday = monthStart.weekday % 7; // Sunday = 0

    // Simple prediction model (placeholder): 28‑day cycle, 5‑day period.
    final int cycleLength = 28;
    final int periodLength = 5;
    final DateTime lastPeriodStart = today.subtract(const Duration(days: 12));
    final DateTime nextPeriodStart = lastPeriodStart.add(Duration(days: cycleLength));
    final DateTime nextPeriodEnd = nextPeriodStart.add(Duration(days: periodLength - 1));
    final DateTime fertileStart = lastPeriodStart.add(const Duration(days: 12));
    final DateTime fertileEnd = lastPeriodStart.add(const Duration(days: 16));

    return GridView.builder(
      itemCount: startWeekday + daysInMonth,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        if (index < startWeekday) {
          return const SizedBox.shrink();
        }
        final int day = index - startWeekday + 1;
        final DateTime date = DateTime(month.year, month.month, day);
        final bool isToday = _isSameDay(date, today);
        final bool isPeriod = date.isAfter(nextPeriodStart.subtract(const Duration(days: 1))) &&
            date.isBefore(nextPeriodEnd.add(const Duration(days: 1)));
        final bool isFertile = date.isAfter(fertileStart.subtract(const Duration(days: 1))) &&
            date.isBefore(fertileEnd.add(const Duration(days: 1)));
        final String? moodEmoji = moodForDate(date);

        Color bg = const Color(0xFF1B203B);
        if (isPeriod) {
          bg = const Color(0xFFEC4899);
        } else if (isFertile) {
          bg = const Color(0xFF7C3AED);
        }

        return _DayCell(
          day: day,
          isToday: isToday,
          background: bg,
          emoji: moodEmoji,
        );
      },
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: const <Widget>[
        _LegendDot(color: Color(0xFFEC4899), label: 'Predicted period'),
        _LegendDot(color: Color(0xFF7C3AED), label: 'Fertile window'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
        ),
      ],
    );
  }
}

class _DailyTipCard extends StatelessWidget {
  const _DailyTipCard({required this.tip});

  final String tip;

  @override
  Widget build(BuildContext context) {
    final _TipDigest digest = _TipDigest.fromText(tip);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF232B52),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.lightbulb_outline, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Today’s suggestion',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    if (digest.summary.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 6),
                      Text(
                        digest.summary,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (digest.keywords.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: digest.keywords
                  .map(
                    (k) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                      ),
                      child: Text(
                        k,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 12),
          _AdviceSection(
            title: 'Suitable today',
            accent: const Color(0xFF7C3AED),
            lines: digest.suitable,
          ),
          const SizedBox(height: 10),
          _AdviceSection(
            title: 'Better avoid',
            accent: const Color(0xFFEC4899),
            lines: digest.avoid,
          ),
          const SizedBox(height: 8),
          Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(top: 6),
              iconColor: Colors.white.withValues(alpha: 0.7),
              collapsedIconColor: Colors.white.withValues(alpha: 0.7),
              title: Text(
                'View full suggestion',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w600,
                ),
              ),
              children: <Widget>[
                Text(
                  tip,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipDigest {
  const _TipDigest({
    required this.summary,
    required this.keywords,
    required this.suitable,
    required this.avoid,
    required this.focus,
  });

  final String summary;
  final List<String> keywords;
  final List<String> suitable;
  final List<String> avoid;
  final List<String> focus;

  static _TipDigest fromText(String text) {
    final cleaned = text.trim();
    if (cleaned.isEmpty) {
      return const _TipDigest(
        summary: '',
        keywords: <String>[],
        suitable: <String>[],
        avoid: <String>[],
        focus: <String>[],
      );
    }

    final List<String> rawLines = cleaned
        .replaceAll('\r', '\n')
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final List<String> lines = rawLines
        .map((line) => line.replaceAll(RegExp(r'\*+'), '').trim())
        .where((line) => line.isNotEmpty)
        .toList();

    String summary = '';
    final List<String> suitable = <String>[];
    final List<String> avoid = <String>[];

    String? currentSection;
    for (final line in lines) {
      final lower = line.toLowerCase();
      if (lower.startsWith('suitable')) {
        currentSection = 'suitable';
        continue;
      }
      if (lower.startsWith('better avoid') || lower.startsWith('avoid')) {
        currentSection = 'avoid';
        continue;
      }

      final cleanedLine = line.replaceAll(RegExp(r'^[-•\s\d\.]+'), '').trim();
      if (cleanedLine.isEmpty) continue;
      if (cleanedLine.toLowerCase() == 'suitable today' ||
          cleanedLine.toLowerCase() == 'better avoid') {
        continue;
      }

      if (currentSection == 'suitable') {
        suitable.add(cleanedLine);
        continue;
      }
      if (currentSection == 'avoid') {
        avoid.add(cleanedLine);
        continue;
      }

      if (summary.isEmpty) {
        summary = cleanedLine;
      }
    }

    if (summary.isEmpty) {
      final fallback = lines
          .map((e) => e.replaceAll(RegExp(r'^[-•\s]+'), '').trim())
          .firstWhere(
            (e) => e.isNotEmpty && !e.toLowerCase().contains('suitable') && !e.toLowerCase().contains('avoid'),
            orElse: () => '',
          );
      summary = fallback;
    }

    if (suitable.isEmpty || avoid.isEmpty) {
      final List<String> sentences = cleaned
          .replaceAll('\r', '\n')
          .split(RegExp(r'[\n\.!\?]+'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (suitable.isEmpty) {
        suitable.addAll(
          sentences.where((s) => !s.toLowerCase().contains('avoid')).take(3),
        );
      }
      if (avoid.isEmpty) {
        avoid.addAll(
          sentences.where((s) => s.toLowerCase().contains('avoid')).take(3),
        );
        if (avoid.isEmpty && sentences.length > 3) {
          avoid.addAll(sentences.skip(3).take(2));
        }
      }
    }

    final List<String> suitableTop = suitable.take(3).toList();
    final List<String> avoidTop = avoid.take(3).toList();
    final List<String> focusTop = _extractFocusLines(lines).take(3).toList();

    final Set<String> stop = <String>{
      'the','a','an','and','or','to','of','in','on','for','with','your','you','today','keep','try',
      'avoid','add','take','aim','reduce','plan','only','tips','tip','lifestyle','reference','just',
      'are','is','be','as','at','it','this','that','from','by','into','after','before','more',
      'here','summary','quick','mood','state','fatigue','level','suitable','better','full',
    };
    final Map<String, int> freq = <String, int>{};
    final Iterable<String> words = cleaned
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s\-]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty && w.length >= 4 && !stop.contains(w));
    for (final w in words) {
      freq[w] = (freq[w] ?? 0) + 1;
    }

    final List<MapEntry<String, int>> keywordEntries = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final List<String> keywordTop = keywordEntries
        .take(4)
        .map((e) => _titleCase(e.key))
        .toList();

    return _TipDigest(
      summary: summary,
      keywords: keywordTop,
      suitable: suitableTop,
      avoid: avoidTop,
      focus: focusTop,
    );
  }

  static Iterable<String> _extractFocusLines(List<String> lines) {
    final List<String> focus = <String>[];
    final RegExp moodLine = RegExp(r'mood\s*:', caseSensitive: false);
    final RegExp stateLine = RegExp(r'(state|fatigue|energy|symptom)', caseSensitive: false);
    for (final line in lines) {
      if (moodLine.hasMatch(line) || stateLine.hasMatch(line)) {
        focus.add(line.replaceAll(RegExp(r'^[-•\s\d\.]+'), '').trim());
      }
    }
    return focus;
  }
}

class _AdviceSection extends StatelessWidget {
  const _AdviceSection({
    required this.title,
    required this.accent,
    required this.lines,
  });

  final String title;
  final Color accent;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 8),
          if (lines.isEmpty)
            Text(
              'No data yet.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            )
          else
            ...lines.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('• ', style: TextStyle(color: Colors.white.withValues(alpha: 0.75))),
                    Expanded(
                      child: Text(
                        line,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: Colors.white.withValues(alpha: 0.82),
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

String _titleCase(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

class _CoachCard extends StatelessWidget {
  const _CoachCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF232B52),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Mood & Cycle Coach',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chat-style check-ins + cycle prediction for lifestyle guidance only.',
            style: TextStyle(
              fontSize: 12,
              height: 1.35,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const <Widget>[
              _CoachTag(text: 'Track mood & energy'),
              _CoachTag(text: 'Log symptoms & fatigue'),
              _CoachTag(text: 'Today: do / avoid'),
              _CoachTag(text: 'Lifestyle-only tips'),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.chat_bubble_outline, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'AI offers reference tips only. No medical advice — just everyday lifestyle suggestions.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachTag extends StatelessWidget {
  const _CoachTag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED).withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: Colors.white.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _dailySuggestion(DateTime date) {
  const suggestions = <String>[
    'Hydrate well today and take a short walk to ease tension.',
    'Add a protein‑rich meal to keep your energy steady.',
    'Try a 5‑minute stretch for lower back and hips.',
    'Plan a calm evening and reduce caffeine after noon.',
    'Log your mood and note any triggers or wins.',
    'Prioritize sleep: aim for 7‑8 hours tonight.',
    'Take breaks from screens and rest your eyes.',
  ];
  final int index = date.day % suggestions.length;
  return suggestions[index];
}

String? _mockMoodForDay(int day) => null;
