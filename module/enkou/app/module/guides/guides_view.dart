import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';

import 'guides_logic.dart';

const Color _lunarPink = Color(0xB3EED0F2);
const Color _lunarLavender = Color(0xB39EBAEB);
const Color _lunarSky = Color(0x9F96DFF5);
const LinearGradient _lunarGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [_lunarPink, _lunarLavender, _lunarSky],
);

const Color _bg = Color(0xFFF6F4FB);
const Color _surface = Color(0xFFFDFBFF);
const Color _titleColor = Color(0xFF242129);
const Color _mutedColor = Color(0xFF7C7785);
const Color _separator = Color(0xFFE6E0EF);
const Color _accent = Color(0xFF8F6AD8);
const Color _handle = Color(0xFFDCD6EA);

class GuidesPage extends StatelessWidget {
  GuidesPage({super.key});

  final GuidesLogic logic = Get.put(GuidesLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Obx(() {
        final isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

        return Stack(
          children: [
            Positioned.fill(
              child: isIOS
                  ? AppleMap(
                      initialCameraPosition: CameraPosition(
                        target: logic.mapCenter.value,
                        zoom: 12.5,
                      ),
                      myLocationEnabled: false,
                      compassEnabled: true,
                      mapType: MapType.standard,
                      annotations: logic.annotations,
                      onMapCreated: logic.onMapCreated,
                      onCameraMove: logic.onCameraMove,
                      onLongPress: logic.onMapLongPress,
                    )
                  : Container(
                      decoration: const BoxDecoration(gradient: _lunarGradient),
                      child: const Center(
                        child: Text(
                          'Apple Maps is only available on iOS devices or simulators.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: _mutedColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: _TopBar(
                  onNewGuide: () => _openCreateGuideSheet(context),
                  onSearch: () => logic.openSearch(),
                ),
              ),
            ),
            _GuidesBottomSheet(
              logic: logic,
            ),
            if (logic.isSearchOpen.value) _SearchOverlay(logic: logic),
          ],
        );
      }),
    );
  }

  void _openCreateGuideSheet(BuildContext context) {
    final ctrl = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 520,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: _separator, width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 22,
                        offset: Offset(0, -6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'New guide',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _titleColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: ctrl,
                        autofocus: true,
                        decoration: const InputDecoration(
                          // hintText:
                          //     'For example: Tokyo highlights / Kyoto temples',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _accent,
                                side: const BorderSide(color: _separator),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                logic.createGuide(ctrl.text);
                                Navigator.of(ctx).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _accent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text(
                                'Create',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.onNewGuide,
    required this.onSearch,
  });

  final VoidCallback onNewGuide;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Row(
      children: [
        if (canPop) ...[
          GestureDetector(
            onTap: Get.back,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _separator, width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: _titleColor,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: GestureDetector(
            onTap: onSearch,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: const Row(
                children: [
                  Icon(Icons.search, color: _mutedColor),
                  SizedBox(width: 8),
                  Text(
                    'Search places',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _mutedColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onNewGuide,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _accent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x2A6F4AD0),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _GuidesBottomSheet extends StatelessWidget {
  const _GuidesBottomSheet({required this.logic});

  final GuidesLogic logic;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.32,
      maxChildSize: 0.87,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            // 不再绘制额外的“口袋”背景，只保留内部卡片
            color: Colors.transparent,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Obx(() {
              logic.scheduleVersion.value;
              final guides = logic.guides;
              if (guides.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFF8F5FF),
                            Color(0xFFF0EBFF),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _accent.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: _accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.map_outlined,
                              size: 32,
                              color: _accent,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Travel Guide Planner',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: _titleColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Create personalized travel itineraries with places, dates, and routes on the map.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                              color: _mutedColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _separator,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'FREE',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'First guide',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _titleColor,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Text(
                                  '•',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _separator,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Tap the + button above to create your first guide',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _mutedColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final activeId = logic.activeGuideId.value;
              final initialPage = activeId == null
                  ? 0
                  : guides
                      .indexWhere((g) => g.id == activeId)
                      .clamp(0, guides.length - 1);
            final controller = PageController(
              // 单张卡片独占一页，不再预留侧边
              viewportFraction: 1.0,
              initialPage: initialPage,
            );
            const double pageGap = 12;

              return PageView.builder(
                controller: controller,
                onPageChanged: (index) {
                  if (index >= 0 && index < guides.length) {
                    logic.setActiveGuide(guides[index].id);
                  }
                },
                itemCount: guides.length,
                itemBuilder: (context, index) {
                  final g = guides[index];
                  // 只在滑动过程中给左右留“缝隙”，停在页面中心时占满，不露白边
                  return AnimatedBuilder(
                    animation: controller,
                    builder: (context, child) {
                      double t = 0;
                      if (controller.hasClients) {
                        final page =
                            controller.page ?? controller.initialPage.toDouble();
                        t = (page - index).abs().clamp(0.0, 1.0);
                      }
                      final gap = pageGap * t;
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: gap),
                        child: child,
                      );
                    },
                    child: _GuideRouteCard(
                      logic: logic,
                      guide: g,
                    ),
                  );
                },
              );
            }),
          ),
        );
      },
    );
  }

}

class _GuideRouteCard extends StatelessWidget {
  const _GuideRouteCard({
    required this.logic,
    required this.guide,
  });

  final GuidesLogic logic;
  final GuideCollection guide;

  @override
  Widget build(BuildContext context) {
    final places = guide.places.toList();

    // 按日期排序：有时间的在前，按时间升序；无时间的在后
    final items = places.map((p) {
      final scheduled = logic.placeSchedule(guide.id, p.id);
      return (place: p, scheduled: scheduled);
    }).toList()
      ..sort((a, b) {
        final da = a.scheduled;
        final db = b.scheduled;
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return da.compareTo(db);
      });

    String? dateSpanLabel() {
      final dated = items.where((e) => e.scheduled != null).toList();
      if (dated.isEmpty) return null;
      final first = dated.first.scheduled!;
      final last = dated.last.scheduled!;
      if (first.year == last.year &&
          first.month == last.month &&
          first.day == last.day) {
        return '${first.year}-${first.month.toString().padLeft(2, '0')}-${first.day.toString().padLeft(2, '0')}';
      }
      String fmtDate(DateTime d) =>
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      return '${fmtDate(first)} · ${fmtDate(last)}';
    }

    final dateSpan = dateSpanLabel();

    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: guide.color.withValues(alpha: 0.30),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FolderIcon(color: guide.color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guide.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _titleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateSpan ?? '${places.length} places',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _mutedColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: _separator),
            const SizedBox(height: 8),
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Text(
                        'Tap on the map or search to add places',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _mutedColor,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 8),
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final p = items[index].place;
                        return _PlaceRow(
                          color: guide.color,
                          place: p,
                          onTap: () {
                            logic.setActiveGuide(guide.id);
                            logic.moveTo(p.position, zoom: 14.5);
                          },
                          dateLabel: logic.placeScheduleLabel(
                            guide.id,
                            p.id,
                          ),
                          onEditDate: () async {
                            logic.setActiveGuide(guide.id);
                            await _openPlaceScheduleSheet(
                              context,
                              logic: logic,
                              guide: guide,
                              place: p,
                            );
                          },
                          onClearDate: () {
                            logic.setActiveGuide(guide.id);
                            logic.clearPlaceSchedule(guide: guide, place: p);
                          },
                          onRemove: () {
                            logic.setActiveGuide(guide.id);
                            logic.removePlace(p.id);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FolderIcon extends StatelessWidget {
  const _FolderIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withValues(alpha: 0.12),
      ),
      child: Icon(
        Icons.folder_rounded,
        color: color,
        size: 24,
      ),
    );
  }
}

class _PlaceRow extends StatelessWidget {
  const _PlaceRow({
    required this.color,
    required this.place,
    required this.onTap,
    required this.dateLabel,
    required this.onEditDate,
    required this.onClearDate,
    required this.onRemove,
  });

  final Color color;
  final GuidePlace place;
  final VoidCallback onTap;
  final String dateLabel;
  final VoidCallback onEditDate;
  final VoidCallback onClearDate;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(Icons.location_pin, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    place.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _mutedColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onEditDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  dateLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onClearDate,
              child: const Icon(
                Icons.event_busy_rounded,
                size: 18,
                color: _mutedColor,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: _mutedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchOverlay extends StatelessWidget {
  const _SearchOverlay({required this.logic});

  final GuidesLogic logic;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: logic.closeSearch,
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      ),
                    ],
                    border: Border.all(color: _separator, width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search,
                        color: _mutedColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          autofocus: true,
                          onChanged: logic.updateSearchQuery,
                          decoration: const InputDecoration(
                            hintText: 'Search places (sample data)',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: logic.closeSearch,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 10,
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _accent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight:
                            MediaQuery.of(context).size.height * 0.3,
                      ),
                      child: Obx(() {
                        final results = logic.searchResults.take(5).toList();
                        if (results.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Container(
                          decoration: BoxDecoration(
                            color: _surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: _separator, width: 1),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                            itemCount: results.length,
                            separatorBuilder: (_, __) => const Divider(
                              height: 1,
                              color: _separator,
                            ),
                            itemBuilder: (context, index) {
                              final r = results[index];
                              return ListTile(
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                title: Text(
                                  r.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _titleColor,
                                  ),
                                ),
                                subtitle: Text(
                                  r.subtitle,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: _mutedColor,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.add_circle_outline_rounded,
                                  color: _accent,
                                ),
                                onTap: () {
                                  logic.addCandidateToActiveGuide(r);
                                  logic.closeSearch();
                                },
                              );
                            },
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x11000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: _separator, width: 1),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: const Text(
                        'Tip: Long-press on the map to drop a pin and add it to the current guide.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _mutedColor,
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
    );
  }
}

Future<void> _openPlaceScheduleSheet(
  BuildContext context, {
  required GuidesLogic logic,
  required GuideCollection guide,
  required GuidePlace place,
}) async {
  DateTime initial =
      logic.placeSchedule(guide.id, place.id) ?? DateTime.now();
  DateTime selected = initial;
  DateTime visibleMonth = DateTime(initial.year, initial.month, 1);
  bool pickingTime = false;

  DateTime normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  List<DateTime?> buildMonthDays(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekday = firstDay.weekday % 7; // Sun=0..Sat=6

    final List<DateTime?> days = [];
    for (int i = 0; i < firstWeekday; i++) {
      days.add(null);
    }
    for (int d = 1; d <= daysInMonth; d++) {
      days.add(DateTime(month.year, month.month, d));
    }
    return days;
  }

  String monthTitle(DateTime month) =>
      '${month.year}年 ${month.month}月';

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          final size = MediaQuery.of(ctx).size;
          return GestureDetector(
            onTap: () => Navigator.of(ctx).pop(),
            behavior: HitTestBehavior.opaque,
            child: SafeArea(
              top: false,
              bottom: false,
              child: GestureDetector(
                onTap: () {}, // 阻止点击事件冒泡
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: size.height * 0.55,
                    width: size.width,
                    decoration: const BoxDecoration(
                      color: _bg,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 12,
                      bottom: 16 +
                          MediaQuery.of(ctx).padding.bottom +
                          MediaQuery.of(ctx).viewInsets.bottom,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: _handle,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            child: pickingTime
                                ? SizedBox(
                                    key: const ValueKey('time'),
                                    child: CupertinoDatePicker(
                                      mode: CupertinoDatePickerMode.time,
                                      initialDateTime: selected,
                                      use24hFormat: true,
                                      onDateTimeChanged: (value) {
                                        setState(() {
                                          selected = DateTime(
                                            selected.year,
                                            selected.month,
                                            selected.day,
                                            value.hour,
                                            value.minute,
                                          );
                                        });
                                      },
                                    ),
                                  )
                                : SizedBox(
                                    key: const ValueKey('calendar'),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  visibleMonth = DateTime(
                                                    visibleMonth.year,
                                                    visibleMonth.month - 1,
                                                    1,
                                                  );
                                                });
                                              },
                                              child: Container(
                                                width: 38,
                                                height: 38,
                                                decoration: BoxDecoration(
                                                  color: _surface,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: _separator,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.chevron_left_rounded,
                                                  color: _titleColor,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  monthTitle(visibleMonth),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w800,
                                                    color: _titleColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  visibleMonth = DateTime(
                                                    visibleMonth.year,
                                                    visibleMonth.month + 1,
                                                    1,
                                                  );
                                                });
                                              },
                                              child: Container(
                                                width: 38,
                                                height: 38,
                                                decoration: BoxDecoration(
                                                  color: _surface,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: _separator,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.chevron_right_rounded,
                                                  color: _titleColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: _surface,
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              border: Border.all(
                                                color: _separator,
                                                width: 1,
                                              ),
                                            ),
                                            padding: const EdgeInsets.all(12),
                                            child: Column(
                                              children: [
                                                // 星期标题行
                                                Row(
                                                  children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                                                      .map((day) => Expanded(
                                                            child: Center(
                                                              child: Text(
                                                                day,
                                                                style: const TextStyle(
                                                                  fontSize: 11,
                                                                  fontWeight: FontWeight.w700,
                                                                  color: _mutedColor,
                                                                ),
                                                              ),
                                                            ),
                                                          ))
                                                      .toList(),
                                                ),
                                                const SizedBox(height: 8),
                                                Expanded(
                                                  child: LayoutBuilder(
                                                    builder: (context, constraints) {
                                                      final days =
                                                          buildMonthDays(visibleMonth);
                                                      // 计算需要的行数
                                                      return SingleChildScrollView(
                                                        child: GridView.builder(
                                                          shrinkWrap: true,
                                                          physics: const NeverScrollableScrollPhysics(),
                                                          gridDelegate:
                                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                            crossAxisCount: 7,
                                                            mainAxisSpacing: 6,
                                                            crossAxisSpacing: 6,
                                                            childAspectRatio: 1.0,
                                                          ),
                                                          itemCount: days.length,
                                                          itemBuilder: (context, index) {
                                                            final d = days[index];
                                                            if (d == null) {
                                                              return const SizedBox
                                                                  .shrink();
                                                            }
                                                            final isSelected =
                                                                normalize(selected) ==
                                                                    normalize(d);
                                                            return GestureDetector(
                                                              onTap: () {
                                                                setState(() {
                                                                  selected = DateTime(
                                                                    d.year,
                                                                    d.month,
                                                                    d.day,
                                                                    selected.hour,
                                                                    selected.minute,
                                                                  );
                                                                });
                                                              },
                                                              behavior:
                                                                  HitTestBehavior.opaque,
                                                              child: AnimatedContainer(
                                                                duration: const Duration(
                                                                  milliseconds: 160,
                                                                ),
                                                                curve: Curves.easeOut,
                                                                decoration: BoxDecoration(
                                                                  color: isSelected
                                                                      ? guide.color
                                                                      : _bg,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                    10,
                                                                  ),
                                                                ),
                                                                child: Center(
                                                                  child: Text(
                                                                    '${d.day}',
                                                                    style: TextStyle(
                                                                      fontSize: 13,
                                                                      fontWeight:
                                                                          FontWeight.w700,
                                                                      color: isSelected
                                                                          ? Colors.white
                                                                          : _titleColor,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: guide.color,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              if (!pickingTime) {
                                setState(() => pickingTime = true);
                                return;
                              }
                              logic.setPlaceSchedule(
                                guide: guide,
                                place: place,
                                scheduledAt: selected,
                              );
                              Navigator.of(ctx).pop();
                            },
                            child: Text(
                              pickingTime ? 'Save time' : 'Next',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
