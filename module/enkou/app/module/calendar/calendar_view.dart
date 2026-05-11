import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:enkou/enkou/app/data/journal_store.dart';
import 'package:enkou/enkou/app/data/travel_plan_store.dart';
import 'package:enkou/enkou/app/widget/app_toast.dart';
import 'package:enkou/enkou/app/module/guides/guides_logic.dart';
import 'package:enkou/enkou/app/module/guides/guides_view.dart';
import 'package:enkou/enkou/app/module/coins/coins_logic.dart';
import 'package:intl/intl.dart';

import 'calendar_logic.dart';

// Lunar Whisper（雾感渐变）统一配色
const Color _lunarPink = Color(0xB3EED0F2);
const Color _lunarLavender = Color(0xB39EBAEB);
// 轻雾蓝，避免过重但仍保留渐变感
const Color _lunarSky = Color(0x5596DFF5);
const LinearGradient _pageBgGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  // 底部不再用纯白，而是回到接近白的 _bg，让整屏都保持轻微雾感
  stops: [0.0, 0.22, 0.5, 1.0],
  colors: [_lunarPink, _lunarLavender, _lunarSky, _bg],
);

const Color _bg = Color(0xFFF6F4FB);
const Color _surface = Color(0xFFFDFBFF);
const Color _titleColor = Color(0xFF242129);
const Color _mutedColor = Color(0xFF7C7785);
const Color _tertiaryMuted = Color(0xB37C7785);
const Color _separator = Color(0xFFE6E0EF);
const Color _controlBg = Color(0xFFEDE7F6);
const Color _iconCircleBg = Color(0xFFF2EEF8);
const Color _accent = Color(0xFF9864FF);
const Color _accentDeep = Color(0xFF6F4AD0);
const Color _rangeFill = Color(0x5CAA82FA);
const Color _planPillBg = Color(0xFFF1ECFA);

class CalendarPage extends StatelessWidget {
  CalendarPage({super.key});

  final CalendarLogic logic = Get.put(CalendarLogic());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(gradient: _pageBgGradient),
      child: SafeArea(
        bottom: true,
        child: Obx(() {
          final currentMonth = logic.currentMonth.value;
          final days = _buildMonthDays(currentMonth);
          final today = logic.normalizeDate(DateTime.now());

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPageHeader(theme),
                    if (logic.hasPendingScheduleTarget) ...[
                      const SizedBox(height: 8),
                      _buildPendingScheduleHint(),
                    ],
                  const SizedBox(height: 12),
                  _buildUsageTips(),
                  const SizedBox(height: 16),
                  _buildCalendarCard(theme, currentMonth, days, today),
                  const SizedBox(height: 20),
                  _buildTripsSection(theme),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPageHeader(ThemeData theme) {
    final mode = logic.filterMode.value;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calendar',
              style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: _titleColor,
                  ) ??
                  const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _titleColor,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Track your travel days',
              style: theme.textTheme.bodySmall?.copyWith(
                    color: _mutedColor,
                  ) ??
                  const TextStyle(
                    fontSize: 12,
                    color: _mutedColor,
                  ),
            ),
          ],
        ),
        CupertinoSlidingSegmentedControl<CalendarFilterMode>(
          groupValue: mode,
          backgroundColor: _controlBg,
          thumbColor: _surface,
          padding: const EdgeInsets.all(3),
          children: const {
            CalendarFilterMode.time: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Text(
                'Time',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            CalendarFilterMode.journal: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Text(
                'Journal',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          },
          onValueChanged: (value) {
            if (value == null) return;
            logic.setFilterMode(value);
          },
        ),
      ],
    );
  }

  Widget _buildCalendarCard(
    ThemeData theme,
    DateTime month,
    List<DateTime?> days,
    DateTime today,
  ) {
    final title = DateFormat('MMMM yyyy').format(month);

    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: _separator,
                width: 0.6,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: _titleColor,
                              ) ??
                              const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: _titleColor,
                              ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _IconCircleButton(
                          icon: Icons.chevron_left_rounded,
                          onTap: logic.goToPreviousMonth,
                        ),
                        const SizedBox(width: 8),
                        _IconCircleButton(
                          icon: Icons.chevron_right_rounded,
                          onTap: logic.goToNextMonth,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildWeekdayRow(theme),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.8, // 稍微加高每个日期格子
                  ),
                  itemCount: days.length,
                  itemBuilder: (context, index) {
                    final date = days[index];
                    if (date == null) {
                      return const SizedBox.shrink();
                    }

                    final normalized = logic.normalizeDate(date);
                    final isToday = normalized == today;
                    final planCount = logic.getPlanCount(normalized);

                    DateTime? rangeStart = logic.rangeStart.value != null
                        ? logic.normalizeDate(logic.rangeStart.value!)
                        : null;
                    DateTime? rangeEnd = logic.rangeEnd.value != null
                        ? logic.normalizeDate(logic.rangeEnd.value!)
                        : null;
                    if (rangeStart != null &&
                        rangeEnd != null &&
                        rangeEnd.isBefore(rangeStart)) {
                      final tmp = rangeStart;
                      rangeStart = rangeEnd;
                      rangeEnd = tmp;
                    }

                    bool isRangeStart = false;
                    bool isRangeEnd = false;
                    bool isInRange = false;
                    if (rangeStart != null) {
                      if (normalized.isAtSameMomentAs(rangeStart)) {
                        isRangeStart = true;
                      }
                      if (rangeEnd != null &&
                          normalized.isAtSameMomentAs(rangeEnd)) {
                        isRangeEnd = true;
                      }
                      if (rangeEnd != null &&
                          normalized.isAfter(rangeStart) &&
                          normalized.isBefore(rangeEnd)) {
                        isInRange = true;
                      }
                    }

                    final mode = logic.filterMode.value;
                    return _CalendarDayCell(
                      date: normalized,
                      isToday: isToday,
                      planCount: planCount,
                      // Journal 模式下不显示“单日选中态”，只展示区间样式
                      isSelected: mode == CalendarFilterMode.journal
                          ? false
                          : logic.selectedDate.value == normalized,
                      isRangeStart: isRangeStart,
                      isRangeEnd: isRangeEnd,
                      isInRange: isInRange,
                      highlightToday:
                          logic.rangeStart.value == null &&
                          logic.rangeEnd.value == null,
                      onTap: () => _onCalendarDayTap(context, normalized),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingScheduleHint() {
    final target = logic.pendingScheduleTarget!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _planPillBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _separator, width: 1),
      ),
      child: Text(
        'Set time for ${target.guideTitle} · ${target.placeName}',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: _accentDeep,
        ),
      ),
    );
  }

  Widget _buildUsageTips() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _accent.withValues(alpha: 0.08),
            _accent.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _accent.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              size: 18,
              color: _accent,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Tips',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _titleColor,
                    decoration: TextDecoration.none,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tap any date to write a journal. Switch to Time mode and select a date range to view your scheduled guides.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: _mutedColor,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onCalendarDayTap(BuildContext context, DateTime day) async {
    if (!logic.hasPendingScheduleTarget ||
        logic.filterMode.value != CalendarFilterMode.time) {
      logic.onDayTapped(day);
      return;
    }

    logic.selectedDate.value = day;
    final picked = await _showWheelTimePicker(context);
    if (picked == null) return;

    final scheduledAt = DateTime(
      day.year,
      day.month,
      day.day,
      picked.hour,
      picked.minute,
    );
    logic.bindPendingSchedule(scheduledAt);
    AppToast.show(
      'Time set',
      '${day.month}/${day.day} ${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
    );
  }

  Future<TimeOfDay?> _showWheelTimePicker(BuildContext context) async {
    var selected = DateTime.now();
    return showModalBottomSheet<TimeOfDay>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            height: 320,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: const Text('Cancel'),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () => Navigator.of(sheetContext).pop(
                          TimeOfDay(
                            hour: selected.hour,
                            minute: selected.minute,
                          ),
                        ),
                        child: const Text('Confirm'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: true,
                    minuteInterval: 1,
                    initialDateTime: selected,
                    onDateTimeChanged: (value) {
                      selected = value;
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

  (DateTime, DateTime) _selectedSpan() {
    final selected =
        logic.selectedDate.value ?? logic.normalizeDate(DateTime.now());
    final start = logic.rangeStart.value;
    final end = logic.rangeEnd.value;
    if (start == null) {
      return (selected, selected);
    }

    final normalizedStart = logic.normalizeDate(start);
    final normalizedEnd = end != null
        ? logic.normalizeDate(end)
        : normalizedStart;
    if (normalizedEnd.isBefore(normalizedStart)) {
      return (normalizedEnd, normalizedStart);
    }
    return (normalizedStart, normalizedEnd);
  }

  Widget _buildTripsSection(ThemeData theme) {
    final mode = logic.filterMode.value;
    if (mode == CalendarFilterMode.journal) {
      return _buildJournalSection(theme);
    }
    return _buildGuidesHubSection(theme);
  }

  Widget _buildGuidesHubSection(ThemeData theme) {
    final GuidesLogic guidesLogic = Get.isRegistered<GuidesLogic>()
        ? Get.find<GuidesLogic>()
        : Get.put(GuidesLogic());

    Future<void> openEditor({String? guideId}) async {
      if (guideId != null) {
        guidesLogic.setActiveGuide(guideId);
      }
      await Get.to(() => GuidesPage());
    }

    Future<void> openCreateGuideSheet() async {
      final ctrl = TextEditingController();
      await showModalBottomSheet<void>(
        context: Get.context!,
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
                      'New Guide',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _titleColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: ctrl,
                      autofocus: true,
                      decoration: const InputDecoration(
                        // hintText: 'e.g. Tokyo Spots',
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
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final existingCount = guidesLogic.guides.length;
                              
                              // First guide is free, subsequent guides cost 100 coins
                              if (existingCount >= 1) {
                                final coinsLogic = Get.isRegistered<CoinsLogic>()
                                    ? Get.find<CoinsLogic>()
                                    : Get.put(CoinsLogic(), permanent: true);
                                
                                const cost = 100;
                                final success = await coinsLogic.spendCoins(cost);
                                if (!success) {
                                  AppToast.short(
                                    'Not enough coins (need $cost).',
                                  );
                                  return;
                                }
                              }
                              
                              guidesLogic.createGuide(ctrl.text);
                              Navigator.of(ctx).pop();
                              
                              if (existingCount == 0) {
                                AppToast.show('Created', 'First guide is free!');
                              } else {
                                AppToast.show(
                                  'Created',
                                  'Guide added. 100 coins deducted.',
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Create'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    final span = _selectedSpan();
    final selectedStart = span.$1;
    final selectedEnd = span.$2;

    return Obx(() {
      final guides = guidesLogic.guides;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Guides',
                style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _titleColor,
                    ) ??
                    const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _titleColor,
                    ),
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: openCreateGuideSheet,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('New'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _accent,
                      backgroundColor: _surface,
                      side: const BorderSide(color: _separator),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () => openEditor(),
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('Edit'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (guides.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _accent.withValues(alpha: 0.08),
                    _accent.withValues(alpha: 0.04),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _accent.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.folder_rounded,
                      size: 18,
                      color: _accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Guide folders & coins',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _titleColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Your first guide folder is free. Each additional folder costs 100 coins.',
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                            color: _mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: openCreateGuideSheet,
                    child: const Text('Create'),
                  ),
                ],
              ),
            )
          else
            ...guides.map((g) {
              // 所有地点（含已排期和未排期）
              final allPlacesWithPlan = g.places
                  .map((p) => MapEntry<GuidePlace, TravelPlanItem?>(
                        p,
                        logic.planStore.getPlan(g.id, p.id),
                      ))
                  .toList();

              // 已排期且在选中区间内的
              final scheduled = allPlacesWithPlan
                  .where((e) =>
                      e.value?.scheduledAt != null &&
                      !logic
                          .normalizeDate(e.value!.scheduledAt)
                          .isBefore(selectedStart) &&
                      !logic
                          .normalizeDate(e.value!.scheduledAt)
                          .isAfter(selectedEnd))
                  .toList()
                ..sort((a, b) =>
                    a.value!.scheduledAt.compareTo(b.value!.scheduledAt));

              // 未排期地点（没选时间）默认也显示
              final unscheduled = allPlacesWithPlan
                  .where((e) => e.value?.scheduledAt == null)
                  .toList();

              String subtitle;
              if (scheduled.isEmpty) {
                subtitle = unscheduled.isEmpty
                    ? '0 planned'
                    : '${unscheduled.length} places · Not scheduled';
              } else {
                final first = scheduled.first.value!.scheduledAt;
                final last = scheduled.last.value!.scheduledAt;
                String fmt(DateTime d) =>
                    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                subtitle =
                    '${scheduled.length} planned · ${fmt(first)} → ${fmt(last)}';
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: g.color.withValues(alpha: 0.30),
                      width: 1.2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x11000000),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: g.color.withValues(alpha: 0.12),
                              ),
                              child: Icon(
                                Icons.folder_rounded,
                                color: g.color,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    g.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: _titleColor,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    subtitle,
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
                            IconButton(
                              onPressed: () => openEditor(guideId: g.id),
                              icon: const Icon(Icons.edit_rounded),
                              color: _accent,
                            ),
                          ],
                        ),
                        if (scheduled.isNotEmpty || unscheduled.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          const Divider(height: 1, color: _separator),
                          const SizedBox(height: 10),
                          ...(() {
                            final shownScheduled = scheduled.take(4).toList();
                            final shownUnscheduled = scheduled.length < 4
                                ? unscheduled
                                    .take(4 - shownScheduled.length)
                                    .toList()
                                : <MapEntry<GuidePlace, TravelPlanItem?>>[];

                            final rows = <Widget>[];
                            final total =
                                shownScheduled.length + shownUnscheduled.length;
                            var idx = 0;
                            for (final e in shownScheduled) {
                              final place = e.key;
                              final plan = e.value!;
                              rows.add(
                                _PlanTimelineRow(
                                  isFirst: idx == 0,
                                  isLast: idx == total - 1,
                                  color: g.color,
                                  scheduledAt: plan.scheduledAt,
                                  title: place.name,
                                  onTap: () {
                                    logic.openDayJournal(
                                      logic.normalizeDate(plan.scheduledAt),
                                    );
                                  },
                                ),
                              );
                              idx++;
                            }
                            for (final e in shownUnscheduled) {
                              final place = e.key;
                              rows.add(
                                _PlanTimelineRow(
                                  isFirst: idx == 0,
                                  isLast: idx == total - 1,
                                  color: g.color,
                                  scheduledAt: null,
                                  title: place.name,
                                  onTap: () => openEditor(guideId: g.id),
                                ),
                              );
                              idx++;
                            }
                            return rows;
                          })(),
                          if (scheduled.length + unscheduled.length > 4)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: () => openEditor(guideId: g.id),
                                child: const Text('View all'),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      );
    });
  }

  Widget _buildJournalSection(ThemeData theme) {
    logic.journalVersion.value;
    final span = _selectedSpan();
    final journals = logic.journalsInRange(span.$1, span.$2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Journals',
          style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: _titleColor,
              ) ??
              const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _titleColor,
              ),
        ),
        const SizedBox(height: 8),
        if (journals.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _accent.withValues(alpha: 0.08),
                  _accent.withValues(alpha: 0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _accent.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 18,
                    color: _accent,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Tips',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _titleColor,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'No journals in selected date(s). Tap a day above to write a journal entry for that date.',
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                          color: _mutedColor,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ...journals.map(
          (j) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _JournalCard(
              entry: j,
              onTap: () => logic.openJournalDetail(j),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayRow(ThemeData theme) {
    const labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels
          .map(
            (text) => Expanded(
              child: Center(
                child: Text(
                  text,
                  style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _mutedColor,
                      ) ??
                      const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _mutedColor,
                      ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  /// 生成当前月份的日期网格，前后补 null 用于占位
  List<DateTime?> _buildMonthDays(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    final firstWeekday = firstDay.weekday % 7; // 周日=0 ... 周六=6
    final List<DateTime?> days = [];

    for (int i = 0; i < firstWeekday; i++) {
      days.add(null);
    }

    for (int d = 1; d <= daysInMonth; d++) {
      days.add(DateTime(month.year, month.month, d));
    }

    return days;
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.date,
    required this.isToday,
    required this.planCount,
    required this.isSelected,
    required this.isRangeStart,
    required this.isRangeEnd,
    required this.isInRange,
    required this.highlightToday,
    required this.onTap,
  });

  final DateTime date;
  final bool isToday;
  final int planCount;
  final bool isSelected;
  final bool isRangeStart;
  final bool isRangeEnd;
  final bool isInRange;
   final bool highlightToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasPlan = planCount > 0;

    final bool highlightAsSelected = isSelected || isRangeStart || isRangeEnd;

    final Color selectedColor = _accent;
    final Color rangeFill = _rangeFill;
    Color backgroundColor = _surface;
    Color borderColor = Colors.transparent;
    if (highlightAsSelected) {
      backgroundColor = selectedColor;
    } else if (isInRange) {
      backgroundColor = rangeFill;
    } else {
      backgroundColor = _surface;
      // 只有在未选择自定义区间时，才额外高亮“今天”的边框
      borderColor = isToday && highlightToday ? _accent : Colors.transparent;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
        child: Column(
          mainAxisAlignment: hasPlan
              ? MainAxisAlignment.start
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildDayLabel(highlightAsSelected),
            if (hasPlan) ...[
              const SizedBox(height: 4),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: highlightAsSelected ? Colors.white : _accentDeep,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDayLabel(bool isSelected) {
    final dayText = date.day.toString();

    return Text(
      dayText,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isSelected ? Colors.white : _titleColor,
      ),
    );
  }
}

class _IconCircleButton extends StatelessWidget {
  const _IconCircleButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: _iconCircleBg,
          shape: BoxShape.circle,
          border: Border.all(
            color: _separator,
            width: 0.6,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: _titleColor,
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({
    required this.trip,
    required this.isExpanded,
    required this.color,
    required this.onTap,
    required this.openEditorForDay,
    required this.visibleStart,
    required this.visibleEnd,
    required this.dayPlansForTripDate,
  });

  final CalendarTrip trip;
  final bool isExpanded;
  final Color color;
  final VoidCallback onTap;
  final void Function(DateTime) openEditorForDay;
  final DateTime visibleStart;
  final DateTime visibleEnd;
  final List<TravelPlanItem> Function(DateTime) dayPlansForTripDate;

  @override
  Widget build(BuildContext context) {
    final rows = <_TripDayPlanRowData>[];
    var day = trip.startDate;
    while (!day.isAfter(trip.endDate)) {
      final normalized = DateTime(day.year, day.month, day.day);
      if (!normalized.isBefore(visibleStart) && !normalized.isAfter(visibleEnd)) {
        final plans = dayPlansForTripDate(normalized);
        for (final plan in plans) {
          rows.add(
            _TripDayPlanRowData(
              date: normalized,
              plan: plan,
            ),
          );
        }
      }
      day = day.add(const Duration(days: 1));
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isExpanded
                ? color.withValues(alpha: 0.30)
                : _separator,
            width: 1.2,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            Row(
              children: [
                _TripFolderIcon(color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.title,
                        style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                    color: _titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trip.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                    color: _mutedColor,
                      ),
                    ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.location_pin,
                  size: 18,
              color: _tertiaryMuted,
                ),
                const SizedBox(width: 4),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
              color: _mutedColor,
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 12, left: 4, right: 4, bottom: 4),
                child: Column(
                  children: [
                    for (int i = 0; i < rows.length; i++)
                      _TripTimelineRow(
                        date: rows[i].date,
                        color: color,
                        isFirst: i == 0,
                        isLast: i == rows.length - 1,
                        plan: rows[i].plan,
                        onTap: () => openEditorForDay(rows[i].date),
                      ),
                  ],
                ),
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }

}

class _TripFolderIcon extends StatelessWidget {
  const _TripFolderIcon({required this.color});

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

class _TripTimelineRow extends StatelessWidget {
  const _TripTimelineRow({
    required this.date,
    required this.color,
    required this.isFirst,
    required this.isLast,
    required this.plan,
    required this.onTap,
  });

  final DateTime date;
  final Color color;
  final bool isFirst;
  final bool isLast;
  final TravelPlanItem plan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayLabel = date.day.toString().padLeft(2, '0');
    final monthLabel = _monthShort(date.month);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 54,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dayLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _titleColor,
                        ) ??
                        const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _titleColor,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    monthLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: _mutedColor,
                        ) ??
                        const TextStyle(
                          fontSize: 10,
                          color: _mutedColor,
                        ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 2,
                  height: isLast ? 0 : 36,
                  color: _separator,
                ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.placeName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _titleColor,
                        ) ??
                        const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _titleColor,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Time: ${_formatTime(plan.scheduledAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: _mutedColor,
                        ) ??
                        const TextStyle(
                          fontSize: 11,
                          color: _mutedColor,
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

  String _monthShort(int month) {
    const labels = [
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
    return labels[(month - 1).clamp(0, 11)];
  }

  String _formatTime(DateTime d) {
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}

class _PlanTimelineRow extends StatelessWidget {
  const _PlanTimelineRow({
    required this.isFirst,
    required this.isLast,
    required this.color,
    required this.scheduledAt,
    required this.title,
    required this.onTap,
  });

  final bool isFirst;
  final bool isLast;
  final Color color;
  final DateTime? scheduledAt;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    String mm(int v) => v.toString().padLeft(2, '0');
    final dateLabel = scheduledAt != null
        ? '${mm(scheduledAt!.month)}/${mm(scheduledAt!.day)}'
        : '—';
    final timeLabel = scheduledAt != null
        ? '${mm(scheduledAt!.hour)}:${mm(scheduledAt!.minute)}'
        : '—';

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 56,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _mutedColor,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 2,
                  height: isLast ? 0 : 34,
                  color: _separator,
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _planPillBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _separator, width: 1),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _titleColor,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: _mutedColor,
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
}

class _TripDayPlanRowData {
  const _TripDayPlanRowData({
    required this.date,
    required this.plan,
  });

  final DateTime date;
  final TravelPlanItem plan;
}

class _JournalCard extends StatelessWidget {
  const _JournalCard({
    required this.entry,
    required this.onTap,
  });

  final JournalEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date =
        '${entry.date.month.toString().padLeft(2, '0')}/${entry.date.day.toString().padLeft(2, '0')}';
    final preview = entry.text.isEmpty ? 'No text' : entry.text;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: const Color(0xFFF1EEFF),
              ),
              child: Column(
                children: [
                  Text(
                    entry.date.day.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF5E36DE),
                    ),
                  ),
                  Text(
                    _monthShort(entry.date.month),
                    style: const TextStyle(fontSize: 10, color: Color(0xFF7E76A3)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$date Journal',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F1F33),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7F86A5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${entry.medias.length} media',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8E44FF),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFADB2CB),
            ),
          ],
        ),
      ),
    );
  }

  String _monthShort(int month) {
    const labels = [
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
    return labels[(month - 1).clamp(0, 11)];
  }
}
