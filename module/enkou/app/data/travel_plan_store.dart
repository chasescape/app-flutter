import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PendingScheduleTarget {
  PendingScheduleTarget({
    required this.guideId,
    required this.guideTitle,
    required this.placeId,
    required this.placeName,
  });

  final String guideId;
  final String guideTitle;
  final String placeId;
  final String placeName;
}

class TravelPlanItem {
  TravelPlanItem({
    required this.id,
    required this.guideId,
    required this.guideTitle,
    required this.placeId,
    required this.placeName,
    required this.scheduledAt,
  });

  final String id;
  final String guideId;
  final String guideTitle;
  final String placeId;
  final String placeName;
  final DateTime scheduledAt;

  TravelPlanItem copyWith({
    String? guideTitle,
    String? placeName,
    DateTime? scheduledAt,
  }) {
    return TravelPlanItem(
      id: id,
      guideId: guideId,
      guideTitle: guideTitle ?? this.guideTitle,
      placeId: placeId,
      placeName: placeName ?? this.placeName,
      scheduledAt: scheduledAt ?? this.scheduledAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guideId': guideId,
      'guideTitle': guideTitle,
      'placeId': placeId,
      'placeName': placeName,
      'scheduledAt': scheduledAt.toIso8601String(),
    };
  }

  static TravelPlanItem? fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final guideId = json['guideId'] as String?;
    final guideTitle = json['guideTitle'] as String?;
    final placeId = json['placeId'] as String?;
    final placeName = json['placeName'] as String?;
    final scheduledAtRaw = json['scheduledAt'] as String?;
    final scheduledAt = scheduledAtRaw == null
        ? null
        : DateTime.tryParse(scheduledAtRaw);
    if (id == null ||
        guideId == null ||
        guideTitle == null ||
        placeId == null ||
        placeName == null ||
        scheduledAt == null) {
      return null;
    }

    return TravelPlanItem(
      id: id,
      guideId: guideId,
      guideTitle: guideTitle,
      placeId: placeId,
      placeName: placeName,
      scheduledAt: scheduledAt,
    );
  }
}

class TravelPlanStore extends GetxService {
  static const _plansKey = 'travel_plans_v1';

  final RxList<TravelPlanItem> plans = <TravelPlanItem>[].obs;
  final RxBool plansReady = false.obs;
  final Rxn<PendingScheduleTarget> pendingScheduleTarget =
      Rxn<PendingScheduleTarget>();
  Worker? _saveWorker;

  @override
  void onInit() {
    super.onInit();
    _initFromLocal();
  }

  @override
  void onClose() {
    _saveWorker?.dispose();
    super.onClose();
  }

  DateTime normalize(DateTime date) => DateTime(date.year, date.month, date.day);

  void upsertPlan({
    required String guideId,
    required String guideTitle,
    required String placeId,
    required String placeName,
    required DateTime scheduledAt,
  }) {
    final index = plans.indexWhere(
      (p) => p.guideId == guideId && p.placeId == placeId,
    );

    if (index >= 0) {
      plans[index] = plans[index].copyWith(
        guideTitle: guideTitle,
        placeName: placeName,
        scheduledAt: scheduledAt,
      );
      plans.refresh();
      _saveLocalPlans();
      return;
    }

    plans.insert(
      0,
      TravelPlanItem(
        id: 'plan_${DateTime.now().microsecondsSinceEpoch}',
        guideId: guideId,
        guideTitle: guideTitle,
        placeId: placeId,
        placeName: placeName,
        scheduledAt: scheduledAt,
      ),
    );
    _saveLocalPlans();
  }

  TravelPlanItem? getPlan(String guideId, String placeId) {
    return plans.firstWhereOrNull(
      (p) => p.guideId == guideId && p.placeId == placeId,
    );
  }

  List<TravelPlanItem> plansForDate(DateTime date) {
    final normalized = normalize(date);
    return plans
        .where((p) => normalize(p.scheduledAt).isAtSameMomentAs(normalized))
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  List<TravelPlanItem> plansForGuide(String guideId) {
    return plans.where((p) => p.guideId == guideId).toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  void removePlan(String guideId, String placeId) {
    plans.removeWhere((p) => p.guideId == guideId && p.placeId == placeId);
    _saveLocalPlans();
  }

  void removePlansByGuide(String guideId) {
    plans.removeWhere((p) => p.guideId == guideId);
    _saveLocalPlans();
  }

  void renameGuide(String guideId, String newTitle) {
    var changed = false;
    for (var i = 0; i < plans.length; i++) {
      final item = plans[i];
      if (item.guideId == guideId) {
        plans[i] = item.copyWith(guideTitle: newTitle);
        changed = true;
      }
    }
    if (changed) {
      plans.refresh();
      _saveLocalPlans();
    }
  }

  void setPendingScheduleTarget(PendingScheduleTarget target) {
    pendingScheduleTarget.value = target;
  }

  void clearPendingScheduleTarget() {
    pendingScheduleTarget.value = null;
  }

  Future<void> _initFromLocal() async {
    await _loadLocalPlans();
    plansReady.value = true;
    _saveWorker = ever<List<TravelPlanItem>>(plans, (_) {
      _saveLocalPlans();
    });
  }

  Future<void> _loadLocalPlans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_plansKey);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;

      final loaded = decoded
          .whereType<Map>()
          .map((e) => TravelPlanItem.fromJson(Map<String, dynamic>.from(e)))
          .whereType<TravelPlanItem>()
          .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      plans.assignAll(loaded);
    } catch (_) {
      // ignore parse/storage errors and keep in-memory fallback
    }
  }

  Future<void> _saveLocalPlans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(plans.map((e) => e.toJson()).toList());
      await prefs.setString(_plansKey, raw);
    } catch (_) {
      // ignore save errors
    }
  }

  /// 注销/删除账号时清空本地行程数据
  Future<void> clearUserData() async {
    plans.assignAll([]);
    await _saveLocalPlans();
  }
}
