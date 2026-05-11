import 'package:get/get.dart';
import 'package:enkou/enkou/app/data/travel_plan_store.dart';

class HistoryGuide {
  HistoryGuide({
    required this.id,
    required this.title,
    required this.summary,
    required this.steps,
    required this.startDate,
    required this.endDate,
  });

  final String id;
  final String title;
  final String summary;
  final List<String> steps;
  final DateTime startDate;
  final DateTime endDate;
}

class HistoryLogic extends GetxController {
  late final TravelPlanStore planStore;
  final RxList<HistoryGuide> guides = <HistoryGuide>[].obs;
  Worker? _planWorker;

  @override
  void onInit() {
    super.onInit();
    planStore = Get.isRegistered<TravelPlanStore>()
        ? Get.find<TravelPlanStore>()
        : Get.put(TravelPlanStore(), permanent: true);
    _rebuildFromPlans();
    _planWorker = ever<List<TravelPlanItem>>(planStore.plans, (_) {
      _rebuildFromPlans();
    });
  }

  @override
  void onClose() {
    _planWorker?.dispose();
    super.onClose();
  }

  DateTime _normalize(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  void _rebuildFromPlans() {
    final byGuide = <String, List<TravelPlanItem>>{};

    for (final p in planStore.plans) {
      byGuide.putIfAbsent(p.guideId, () => <TravelPlanItem>[]).add(p);
    }

    final next = <HistoryGuide>[];

    byGuide.forEach((guideId, items) {
      if (items.isEmpty) return;
      items.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

      final first = items.first.scheduledAt;
      final last = items.last.scheduledAt;
      final start = _normalize(first);
      final end = _normalize(last);

      String fmtDate(DateTime d) =>
          '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
      String fmtTime(DateTime d) =>
          '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

      final steps = items
          .map(
            (p) =>
                '${fmtDate(p.scheduledAt)} · ${fmtTime(p.scheduledAt)} · ${p.placeName}',
          )
          .toList();

      final summary = items.length == 1
          ? '1 place · ${fmtDate(start)}'
          : '${items.length} places · ${fmtDate(start)} → ${fmtDate(end)}';

      next.add(
        HistoryGuide(
          id: guideId,
          title: items.first.guideTitle,
          summary: summary,
          steps: steps,
          startDate: start,
          endDate: end,
        ),
      );
    });

    next.sort((a, b) => a.startDate.compareTo(b.startDate));
    guides.assignAll(next);
  }
}
