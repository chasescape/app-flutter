import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:enkou/enkou/app/data/journal_store.dart';
import 'package:enkou/enkou/app/routes/app_routes.dart';
import 'package:enkou/gen_a/A.dart';

import 'home_logic.dart';

// Lunar Whisper（雾感渐变）配色：用于首页背景氛围
const Color _lunarPink = Color(0xB3EED0F2);
const Color _lunarLavender = Color(0xB39EBAEB);
const Color _lunarSky = Color(0x9F96DFF5);
const LinearGradient _lunarGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [_lunarPink, _lunarLavender, _lunarSky],
);

const Color _bgWhite = Color(0xFFF6F4FB); // lavender fog background
const Color _surface = Color(0xFFFDFBFF); // soft lavender-tinted surface
const Color _accent = Color(0xFF8F6AD8); // soft violet accent
const Color _accentDeep = Color(0xFF6F4AD0); // deeper violet
const Color _headerTitleColor = Color(0xFF2B2340); // dark violet for readability
const Color _headerSubTitleColor = Color(0xB32B2340); // same hue, softer alpha
const Color _chip = Color(0xF2FFFFFF); // high-opacity white for readable chips
const Color _cardShadow = Color(0x246F4AD0);
const Color _muted = Color(0xFF7C7785);
const Color _dividerSoft = Color(0x3DE6E0EF);

const List<String> _homeTags = [
  'Today',
  'This Week',
  'Cities',
  'Mountains',
  'Coast',
  'Food',
];

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeLogic logic = Get.put(HomeLogic());
  late final PageController _pageController;
  late final JournalStore _journalStore;

  int _selectedTagIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.90);
    _journalStore = Get.isRegistered<JournalStore>()
        ? Get.find<JournalStore>()
        : Get.put(JournalStore(), permanent: true);
    _journalStore.seedMockIfEmpty();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return SafeArea(
      top: false,
      bottom: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final splitHeight = constraints.maxHeight * 0.38;
          final cardTop = (splitHeight - 30).clamp(150.0, 230.0).toDouble();
          return Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: _lunarGradient,
                  ),
                  child: Column(
                    children: [
                      // 顶部渐变氛围 + 底部雾白托底，避免内容落在“纯渐变”上显脏
                      const Expanded(child: SizedBox()),
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: _bgWhite,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 20,
                right: 20,
                child: Padding(
                  padding: EdgeInsets.only(top: topPadding + 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Soft Travel Log',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: _headerTitleColor,
                          letterSpacing: -0.5,
                          shadows: [
                            Shadow(
                              color: Color(0x33FFFFFF),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Capture dates, places, routes, moods, and stories.',
                        style: TextStyle(
                          fontSize: 13,
                          color: _headerSubTitleColor,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                              color: Color(0x22FFFFFF),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _chip,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: _accentDeep,
                                  size: 14,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  '2026 Journey',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _headerTitleColor,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _chip,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _accentDeep.withValues(alpha: 0.26),
                              ),
                            ),
                            child: Text(
                              _homeTags[_selectedTagIndex],
                              style: const TextStyle(
                                fontSize: 13,
                                color: _headerTitleColor,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: cardTop,
                left: 16,
                right: 10,
                bottom: 50,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SideTagList(
                      items: _homeTags,
                      activeIndex: _selectedTagIndex,
                      onTap: _onTagTapped,
                    ),
                    Expanded(
                      child: ClipRect(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Obx(() {
                            final cards = _buildCardsForTag();
                            if (cards.isEmpty) {
                              return _buildEmptyHintCard();
                            }

                            return PageView.builder(
                              controller: _pageController,
                              itemCount: cards.length,
                              itemBuilder: (context, index) {
                                final card = cards[index];
                                return GestureDetector(
                                  onTap: () => _openJournalDetail(card.entry),
                                  child: _TravelCard(
                                    data: card,
                                    pageOffset: _pageController,
                                    index: index,
                                  ),
                                );
                              },
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onTagTapped(int index) {
    if (_selectedTagIndex == index) return;
    setState(() {
      _selectedTagIndex = index;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  List<_TravelCardData> _buildCardsForTag() {
    final selectedTag = _homeTags[_selectedTagIndex].toLowerCase();

    List<JournalEntry> source;
    if (selectedTag == 'today') {
      // 展示“今天编辑过的所有日记”（不论日期是哪一天）
      source = _journalStore.editedOn(DateTime.now());
    } else {
      final entries = _journalStore.entries.toList();
      final today = _journalStore.normalize(DateTime.now());
      final weekStart = today.subtract(const Duration(days: 6));

      source = entries.where((e) {
        if (!_journalStore.hasImage(e)) return false;
        final day = _journalStore.normalize(e.date);

        if (selectedTag == 'this week') {
          return !day.isBefore(weekStart) && !day.isAfter(today);
        }

        return e.tags.any((t) => t.toLowerCase() == selectedTag);
      }).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    }

    return source
        .map(
          (e) => _TravelCardData(
            imageUrl: _journalStore.firstImage(e) ?? A.assets_enkou_03,
            title: e.locationTag.isEmpty ? 'Journal' : e.locationTag,
            subtitle: e.text.isEmpty ? 'Tap to read detail' : e.text,
            date: '${e.date.year}.${e.date.month.toString().padLeft(2, '0')}.${e.date.day.toString().padLeft(2, '0')}',
            entry: e,
          ),
        )
        .toList();
  }

  void _openJournalDetail(JournalEntry entry) {
    Get.toNamed(
      AppRoutes.detail,
      arguments: {
        'title':
            '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}-${entry.date.day.toString().padLeft(2, '0')}',
        'subtitle': entry.locationTag.isEmpty ? 'Journal' : entry.locationTag,
        'body': entry.text,
        'medias': entry.medias
            .map(
              (m) => {
                'type': m.type,
                'label': m.label,
                'source': m.source,
              },
            )
            .toList(),
        'entryId': entry.id,
        'date': entry.date,
        'locationTag': entry.locationTag,
      },
    );
  }

  Widget _buildEmptyHintCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: _navigateToTodayJournal,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFB8A4E8),
                Color(0xFF8F6AD8),
                Color(0xFF6F4AD0),
              ],
            ),
            boxShadow: const [
              BoxShadow(
                color: _cardShadow,
                blurRadius: 28,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background pattern
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: CustomPaint(
                      painter: _DotPatternPainter(),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit_note_rounded,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Start Your Journey',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Color(0x44000000),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Write your first journal entry to see it displayed here. Capture your memories, places, and moments.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Write Today\'s Journal',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _accentDeep,
                              ),
                            ),
                          ],
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
    );
  }

  void _navigateToTodayJournal() {
    final today = DateTime.now();
    Get.toNamed(
      AppRoutes.dayJournal,
      arguments: {'date': today},
    );
  }
}

class _SideTagList extends StatelessWidget {
  const _SideTagList({
    required this.items,
    required this.activeIndex,
    required this.onTap,
  });

  final List<String> items;
  final int activeIndex;
  final void Function(int index) onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (index) {
          final isActive = activeIndex == index;
          return GestureDetector(
            onTap: () => onTap(index),
            child: RotatedBox(
              quarterTurns: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? _accent : _surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    if (isActive)
                      const BoxShadow(
                        color: _cardShadow,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                  ],
                  border: isActive
                      ? null
                      : Border.all(color: _dividerSoft),
                ),
                child: Text(
                  items[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? Colors.white : _muted,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TravelCardData {
  const _TravelCardData({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.entry,
  });

  final String imageUrl;
  final String title;
  final String subtitle;
  final String date;
  final JournalEntry entry;
}

class _TravelCard extends StatelessWidget {
  const _TravelCard({
    required this.data,
    required this.pageOffset,
    required this.index,
  });

  final _TravelCardData data;
  final PageController pageOffset;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          color: Colors.black,
          boxShadow: const [
            BoxShadow(
              color: _cardShadow,
              blurRadius: 28,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_accentDeep, _accent],
                  ),
                ),
                child: _buildImage(),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Color(0x66000000),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xDFFFFFFF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final path = data.imageUrl;
    final isAsset = path.startsWith('assets/');
    final imageWidget = isAsset
        ? Image.asset(
            path,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(
                  Icons.landscape,
                  size: 80,
                  color: Colors.white30,
                ),
              );
            },
          )
        : Image.file(
            File(path),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(
                  Icons.landscape,
                  size: 80,
                  color: Colors.white30,
                ),
              );
            },
          );

    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        Colors.black.withValues(alpha: 0.25),
        BlendMode.darken,
      ),
      child: imageWidget,
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    const spacing = 20.0;
    const dotRadius = 2.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
