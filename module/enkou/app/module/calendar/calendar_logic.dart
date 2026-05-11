import 'package:get/get.dart';
import 'package:enkou/enkou/app/data/journal_store.dart';
import 'package:enkou/enkou/app/data/travel_plan_store.dart';
import 'package:enkou/enkou/app/module/nav/nav_logic.dart';
import 'package:enkou/enkou/app/routes/app_routes.dart';

enum CalendarFilterMode {
  time,
  journal,
}

class CalendarTrip {
  CalendarTrip({
    required this.id,
    required this.guideId,
    required this.title,
    required this.subtitle,
    required this.startDate,
    required this.endDate,
  });

  final String id;
  final String guideId;
  final String title;
  final String subtitle;
  final DateTime startDate;
  final DateTime endDate;
}

class CalendarLogic extends GetxController {
  late final TravelPlanStore planStore;
  late final JournalStore journalStore;
  Worker? _planWorker;
  Worker? _journalWorker;
  final RxInt journalVersion = 0.obs;

  /// 当前展示的月份（只关心年月，日固定用 1）
  final Rx<DateTime> currentMonth = DateTime.now().obs;

  /// 当前选中的日期（用于高亮）
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();

  /// 当前选择的时间范围起止（time 模式下使用）
  final Rxn<DateTime> rangeStart = Rxn<DateTime>();
  final Rxn<DateTime> rangeEnd = Rxn<DateTime>();

  /// 已规划地点映射：日期 -> 地点摘要
  final RxMap<DateTime, String> plannedLocations = <DateTime, String>{}.obs;

  /// 每天对应的行程 id（用于定位行程卡片）
  final RxMap<DateTime, String> plannedTripIds = <DateTime, String>{}.obs;

  /// 每天对应的行程数量（显示出行 icon / badge）
  final RxMap<DateTime, int> dayPlanCounts = <DateTime, int>{}.obs;

  /// 本月行程单列表
  final RxList<CalendarTrip> trips = <CalendarTrip>[].obs;

  /// 当前展开的行程卡片 id（单选）
  final RxnString expandedTripId = RxnString();

  /// 顶部筛选模式：按时间范围 或 按地点
  final Rx<CalendarFilterMode> filterMode = CalendarFilterMode.time.obs;

  @override
  void onInit() {
    super.onInit();
    planStore = Get.isRegistered<TravelPlanStore>()
        ? Get.find<TravelPlanStore>()
        : Get.put(TravelPlanStore(), permanent: true);
    journalStore = Get.isRegistered<JournalStore>()
        ? Get.find<JournalStore>()
        : Get.put(JournalStore(), permanent: true);
    journalStore.seedMockIfEmpty();

    final now = DateTime.now();
    currentMonth.value = DateTime(now.year, now.month, 1);
    selectedDate.value = normalizeDate(now);
    if (hasPendingScheduleTarget) {
      filterMode.value = CalendarFilterMode.time;
    }

    _rebuildFromPlans();
    _planWorker = ever<List<TravelPlanItem>>(planStore.plans, (_) {
      _rebuildFromPlans();
    });
    _journalWorker = ever<List<JournalEntry>>(journalStore.entries, (_) {
      journalVersion.value++;
    });
  }

  @override
  void onClose() {
    _planWorker?.dispose();
    _journalWorker?.dispose();
    super.onClose();
  }

  void _rebuildFromPlans() {
    final byGuide = <String, List<TravelPlanItem>>{};
    final dayToNames = <DateTime, Set<String>>{};
    final dayToGuide = <DateTime, String>{};
    final dayToCount = <DateTime, int>{};

    for (final p in planStore.plans) {
      byGuide.putIfAbsent(p.guideId, () => []).add(p);
      final d = normalizeDate(p.scheduledAt);
      dayToNames.putIfAbsent(d, () => <String>{}).add(p.placeName);
      dayToGuide.putIfAbsent(d, () => p.guideId);
      dayToCount[d] = (dayToCount[d] ?? 0) + 1;
    }

    final nextTrips = <CalendarTrip>[];
    byGuide.forEach((guideId, items) {
      items.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      final first = items.first;
      DateTime start = normalizeDate(first.scheduledAt);
      DateTime end = normalizeDate(first.scheduledAt);
      for (final item in items) {
        final day = normalizeDate(item.scheduledAt);
        if (day.isBefore(start)) start = day;
        if (day.isAfter(end)) end = day;
      }

      nextTrips.add(
        CalendarTrip(
          id: 'trip_$guideId',
          guideId: guideId,
          title: first.guideTitle,
          subtitle: '${items.length} places planned',
          startDate: start,
          endDate: end,
        ),
      );
    });

    nextTrips.sort((a, b) => a.startDate.compareTo(b.startDate));
    trips.assignAll(nextTrips);

    plannedLocations.assignAll(
      dayToNames.map(
        (k, v) => MapEntry(
          k,
          v.take(2).join(' · '),
        ),
      ),
    );
    plannedTripIds.assignAll(
      dayToGuide.map((k, v) => MapEntry(k, 'trip_$v')),
    );
    dayPlanCounts.assignAll(dayToCount);
  }

  void goToPreviousMonth() {
    final month = currentMonth.value;
    final prev = DateTime(month.year, month.month - 1, 1);
    currentMonth.value = prev;
  }

  void goToNextMonth() {
    final month = currentMonth.value;
    final next = DateTime(month.year, month.month + 1, 1);
    currentMonth.value = next;
  }

  DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String? getPlannedLocation(DateTime date) {
    final normalized = normalizeDate(date);
    return plannedLocations[normalized];
  }

  int getPlanCount(DateTime date) {
    final normalized = normalizeDate(date);
    return dayPlanCounts[normalized] ?? 0;
  }

  CalendarTrip? getTripForDate(DateTime date) {
    final normalized = normalizeDate(date);
    final tripId = plannedTripIds[normalized];
    if (tripId == null) return null;

    try {
      return trips.firstWhere((t) => t.id == tripId);
    } catch (_) {
      return null;
    }
  }

  List<TravelPlanItem> getPlansForDate(DateTime date) {
    return planStore.plansForDate(normalizeDate(date));
  }

  List<TravelPlanItem> getTripPlansForDate(String tripId, DateTime date) {
    final trip = trips.firstWhereOrNull((t) => t.id == tripId);
    if (trip == null) return <TravelPlanItem>[];
    final dayPlans = getPlansForDate(date);
    return dayPlans.where((p) => p.guideId == trip.guideId).toList();
  }

  PendingScheduleTarget? get pendingScheduleTarget =>
      planStore.pendingScheduleTarget.value;
  bool get hasPendingScheduleTarget => pendingScheduleTarget != null;

  void clearPendingScheduleTarget() {
    planStore.clearPendingScheduleTarget();
  }

  void bindPendingSchedule(DateTime scheduledAt) {
    final target = pendingScheduleTarget;
    if (target == null) return;

    planStore.upsertPlan(
      guideId: target.guideId,
      guideTitle: target.guideTitle,
      placeId: target.placeId,
      placeName: target.placeName,
      scheduledAt: scheduledAt,
    );
    clearPendingScheduleTarget();

    if (Get.isRegistered<NavLogic>()) {
      Get.find<NavLogic>().changeTab(1);
    }
  }

  void setFilterMode(CalendarFilterMode mode) {
    if (filterMode.value == mode) return;
    filterMode.value = mode;
  }

  void onDayTapped(DateTime date) {
    final normalized = normalizeDate(date);
    if (filterMode.value == CalendarFilterMode.journal) {
      // Journal 模式下点击日期：直接进入编辑，不更新单日选中态
      // 避免切回 time 模式后出现“紫色单日选中背景”
      openDayJournal(normalized);
      return;
    }

    selectedDate.value = normalized;

    if (filterMode.value == CalendarFilterMode.time) {
      _updateRange(normalized);
    }

    final trip = getTripForDate(normalized);
    if (trip != null) {
      expandedTripId.value = trip.id;
    }
  }

  void _updateRange(DateTime tapped) {
    final start = rangeStart.value;
    final end = rangeEnd.value;

    if (start == null || end != null) {
      rangeStart.value = tapped;
      rangeEnd.value = null;
      return;
    }

    if (tapped.isBefore(start)) {
      rangeStart.value = tapped;
      rangeEnd.value = null;
    } else if (tapped.isAtSameMomentAs(start)) {
      rangeEnd.value = null;
    } else {
      rangeEnd.value = tapped;
    }
  }

  void openDayJournal(DateTime date) {
    final normalized = normalizeDate(date);
    final plans = getPlansForDate(normalized);
    final location = plans.isEmpty ? '' : plans.first.placeName;

    Get.toNamed(
      AppRoutes.dayJournal,
      arguments: {
        'date': normalized,
        'locationTag': location,
      },
    );
  }

  void toggleTrip(String id) {
    if (expandedTripId.value == id) {
      expandedTripId.value = null;
      if (filterMode.value == CalendarFilterMode.journal) {
        rangeStart.value = null;
        rangeEnd.value = null;
      }
      return;
    }

    expandedTripId.value = id;

    if (filterMode.value == CalendarFilterMode.journal) {
      final trip = trips.firstWhereOrNull((t) => t.id == id);
      if (trip != null) {
        rangeStart.value = normalizeDate(trip.startDate);
        rangeEnd.value = normalizeDate(trip.endDate);
        currentMonth.value = DateTime(
          trip.startDate.year,
          trip.startDate.month,
          1,
        );
      }
    }
  }

  List<JournalEntry> recentJournals({int days = 10}) {
    return journalStore.recentEntries(days: days);
  }

  List<JournalEntry> journalsInRange(DateTime start, DateTime end) {
    final s = normalizeDate(start);
    final e = normalizeDate(end);
    final min = e.isBefore(s) ? e : s;
    final max = e.isBefore(s) ? s : e;
    return journalStore.entries.where((j) {
      final d = normalizeDate(j.date);
      return !d.isBefore(min) && !d.isAfter(max);
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void openJournalDetail(JournalEntry entry) {
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
      },
    );
  }
}
