import 'dart:async';
import 'dart:math' as math;

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:enkou/enkou/app/core/apple_maps_search_service.dart';
import 'package:enkou/enkou/app/widget/app_toast.dart';
import 'package:enkou/enkou/app/data/guides_store.dart';
import 'package:enkou/enkou/app/data/travel_plan_store.dart';
import 'package:enkou/enkou/app/data/travel_mock_data.dart';
import 'package:enkou/enkou/app/module/nav/nav_logic.dart';
import 'package:enkou/enkou/app/routes/app_routes.dart';

class GuidePlace {
  GuidePlace({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.position,
  });

  final String id;
  final String name;
  final String subtitle;
  final LatLng position;
}

class GuideCollection {
  GuideCollection({
    required this.id,
    required this.title,
    required this.color,
    required this.places,
  });

  final String id;
  final String title;
  final Color color;
  final RxList<GuidePlace> places;
}

class SearchPlaceCandidate {
  SearchPlaceCandidate({
    required this.name,
    required this.subtitle,
    required this.position,
  });

  final String name;
  final String subtitle;
  final LatLng position;
}

class GuidesLogic extends GetxController {
  late final TravelPlanStore planStore;
  late final GuidesStore guidesStore;
  Worker? _planWorker;
  Worker? _storeReadyWorker;
  Worker? _guidesReadyWorker;
  final RxInt scheduleVersion = 0.obs;
  final RxList<GuideCollection> guides = <GuideCollection>[].obs;
  final RxnString expandedGuideId = RxnString();
  final RxnString activeGuideId = RxnString();

  final Rxn<AppleMapController> mapController = Rxn<AppleMapController>();
  final Rx<LatLng> mapCenter = const LatLng(35.681236, 139.767125).obs; // Tokyo

  final RxString searchQuery = ''.obs;
  final RxList<SearchPlaceCandidate> searchResults =
      <SearchPlaceCandidate>[].obs;

  final RxBool isSearchOpen = false.obs;
  Timer? _searchDebounce;
  int _searchRequestId = 0;

  final List<Color> guideColors = const [
    Color(0xFF8E44FF),
    Color(0xFF3B82F6),
    Color(0xFFEC4899),
    Color(0xFFF97316),
    Color(0xFF10B981),
  ];

  @override
  void onInit() {
    super.onInit();
    planStore = Get.isRegistered<TravelPlanStore>()
        ? Get.find<TravelPlanStore>()
        : Get.put(TravelPlanStore(), permanent: true);
    guidesStore = Get.isRegistered<GuidesStore>()
        ? Get.find<GuidesStore>()
        : Get.put(GuidesStore(), permanent: true);
    _initGuidesFromStore();
    if (planStore.plansReady.value) {
      _seedMockSchedules();
    } else {
      _storeReadyWorker = ever<bool>(planStore.plansReady, (ready) {
        if (!ready) return;
        _seedMockSchedules();
        _storeReadyWorker?.dispose();
        _storeReadyWorker = null;
      });
    }
    _planWorker = ever<List<TravelPlanItem>>(planStore.plans, (_) {
      scheduleVersion.value++;
    });
    _runSearch('');
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    _planWorker?.dispose();
    _storeReadyWorker?.dispose();
    _guidesReadyWorker?.dispose();
    super.onClose();
  }

  void onMapCreated(AppleMapController controller) {
    mapController.value = controller;
  }

  void onCameraMove(CameraPosition position) {
    mapCenter.value = position.target;
  }

  void onMapLongPress(LatLng position) {
    mapCenter.value = position;
    _openAddCustomPlace(position);
  }

  Set<Annotation> get annotations {
    final guide = _activeGuideOrNull();
    if (guide == null) return <Annotation>{};

    return guide.places.map((p) {
      return Annotation(
        annotationId: AnnotationId(p.id),
        position: p.position,
        infoWindow: InfoWindow(title: p.name, snippet: p.subtitle),
        onTap: () {},
      );
    }).toSet();
  }

  GuideCollection? _activeGuideOrNull() {
    final id = activeGuideId.value;
    if (id == null) return null;
    try {
      return guides.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  void createGuide(String title) {
    final id = 'guide_${DateTime.now().millisecondsSinceEpoch}';
    final color = guideColors[guides.length % guideColors.length];
    final guide = GuideCollection(
      id: id,
      title: title.trim().isEmpty ? 'New Guide' : title.trim(),
      color: color,
      places: <GuidePlace>[].obs,
    );

    guides.insert(0, guide);
    expandedGuideId.value = id;
    activeGuideId.value = id;
    _persistGuides();
  }

  void toggleGuideFolder(String guideId) {
    if (expandedGuideId.value == guideId) {
      expandedGuideId.value = null;
      return;
    }
    expandedGuideId.value = guideId;
    activeGuideId.value = guideId;
  }

  void setActiveGuide(String guideId) {
    activeGuideId.value = guideId;
  }

  void updateSearchQuery(String value) {
    searchQuery.value = value;
    _searchDebounce?.cancel();
    if (value.trim().isEmpty) {
      _runSearch(value);
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 260), () {
      _runSearch(value);
    });
  }

  void openSearch() {
    isSearchOpen.value = true;
  }

  void closeSearch() {
    isSearchOpen.value = false;
    _searchDebounce?.cancel();
    updateSearchQuery('');
  }

  void _runSearch(String query) {
    final requestId = ++_searchRequestId;
    _updateSearchResults(query, requestId);
  }

  void addCandidateToActiveGuide(SearchPlaceCandidate c) {
    final guide = _activeGuideOrNull();
    if (guide == null) return;

    final placeId =
        'place_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(9999)}';
    guide.places.add(
      GuidePlace(
        id: placeId,
        name: c.name,
        subtitle: c.subtitle,
        position: c.position,
      ),
    );

    moveTo(c.position, zoom: 14.5);
    _persistGuides();
  }

  void removePlace(String placeId) {
    final guide = _activeGuideOrNull();
    if (guide == null) return;
    guide.places.removeWhere((p) => p.id == placeId);
    planStore.removePlan(guide.id, placeId);
    _persistGuides();
  }

  DateTime? placeSchedule(String guideId, String placeId) {
    final plan = planStore.getPlan(guideId, placeId);
    if (plan == null) return null;
    return plan.scheduledAt;
  }

  void setPlaceSchedule({
    required GuideCollection guide,
    required GuidePlace place,
    required DateTime scheduledAt,
  }) {
    planStore.upsertPlan(
      guideId: guide.id,
      guideTitle: guide.title,
      placeId: place.id,
      placeName: place.name,
      scheduledAt: scheduledAt,
    );
  }

  void clearPlaceSchedule({
    required GuideCollection guide,
    required GuidePlace place,
  }) {
    planStore.removePlan(guide.id, place.id);
  }

  String placeScheduleLabel(String guideId, String placeId) {
    final plan = planStore.getPlan(guideId, placeId);
    if (plan == null) return 'Set time';
    return _formatDateTime(plan.scheduledAt);
  }

  String _formatDateTime(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$mm/$dd $hh:$min';
  }

  Future<void> moveTo(LatLng target, {double zoom = 13.0}) async {
    final controller = mapController.value;
    if (controller == null) return;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom),
      ),
    );
  }

  void _openAddCustomPlace(LatLng position) {
    final guide = _activeGuideOrNull();
    if (guide == null) {
      AppToast.show('Hint', 'Create or select a guide first.');
      return;
    }

    final titleCtrl = TextEditingController();
    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add place',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F1F33),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  hintText: 'Enter a place name (you can edit it later).',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: guide.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    final name = titleCtrl.text.trim().isEmpty
                        ? 'Pinned place'
                        : titleCtrl.text.trim();
                    final placeId =
                        'place_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(9999)}';
                    guide.places.add(
                      GuidePlace(
                        id: placeId,
                        name: name,
                        subtitle: 'Pinned from map',
                        position: position,
                      ),
                    );
                    Get.back();
                    _persistGuides();
                  },
                  child: const Text(
                    'Add to current guide',
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
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _updateSearchResults(String q, int requestId) async {
    final query = q.trim();

    // 空搜索：展示部分本地示例数据
    if (query.isEmpty) {
      final all = kMockTravelPlaces
          .map(
            (p) => SearchPlaceCandidate(
              name: p.name,
              subtitle: p.subtitle,
              position: LatLng(p.latitude, p.longitude),
            ),
          )
          .toList();
      if (requestId != _searchRequestId) return;
      // Only keep a small set of demo results
      searchResults.assignAll(all.take(6));
      return;
    }

    final List<SearchPlaceCandidate> combined = [];
    final lower = query.toLowerCase();

    // 1. Apple Maps 实时搜索（本身就支持模糊匹配）
    try {
      final remote = await AppleMapsSearchService.searchPlaces(query);
      combined.addAll(
        remote.map(
          (r) => SearchPlaceCandidate(
            name: r.name,
            subtitle: r.subtitle,
            position: r.position,
          ),
        ),
      );
    } catch (e, s) {
      // 如果原生有问题，先打个 log，方便你在 Xcode / 控制台看原因
      // ignore: avoid_print
      print('AppleMaps search error: $e\n$s');
    }

    // 2. 本地 mock 也加入候选，用来补充 / fallback
    combined.addAll(
      kMockTravelPlaces
          .where(
            (p) =>
                p.name.toLowerCase().contains(lower) ||
                p.subtitle.toLowerCase().contains(lower),
          )
          .map(
            (p) => SearchPlaceCandidate(
              name: p.name,
              subtitle: p.subtitle,
              position: LatLng(p.latitude, p.longitude),
            ),
          ),
    );

    // 去重：同名同坐标视为一个结果
    final seen = <String>{};
    final unique = <SearchPlaceCandidate>[];
    for (final c in combined) {
      final key =
          '${c.name}-${c.subtitle}-${c.position.latitude}-${c.position.longitude}';
      if (seen.add(key)) {
        unique.add(c);
      }
    }

    if (requestId != _searchRequestId) return;
    searchResults.assignAll(unique);
  }

  void _initGuidesFromStore() {
    if (guidesStore.guidesReady.value) {
      _loadGuidesFromStore();
      return;
    }
    _guidesReadyWorker = ever<bool>(guidesStore.guidesReady, (ready) {
      if (!ready) return;
      _loadGuidesFromStore();
      _guidesReadyWorker?.dispose();
      _guidesReadyWorker = null;
    });
  }

  void _loadGuidesFromStore() {
    if (guidesStore.guides.isNotEmpty) {
      final restored = guidesStore.guides.map((g) {
        return GuideCollection(
          id: g.id,
          title: g.title,
          color: Color(g.colorValue),
          places: g.places
              .map(
                (p) => GuidePlace(
                  id: p.id,
                  name: p.name,
                  subtitle: p.subtitle,
                  position: LatLng(p.latitude, p.longitude),
                ),
              )
              .toList()
              .obs,
        );
      }).toList();
      guides.assignAll(restored);
      if (restored.isNotEmpty) {
        expandedGuideId.value ??= restored.first.id;
        activeGuideId.value ??= restored.first.id;
      }
      return;
    }
    _seedMockGuides();
  }

  void _persistGuides() {
    final data = guides
        .map(
          (g) => GuideData(
            id: g.id,
            title: g.title,
            colorValue: g.color.value,
            places: g.places
                .map(
                  (p) => GuidePlaceData(
                    id: p.id,
                    name: p.name,
                    subtitle: p.subtitle,
                    latitude: p.position.latitude,
                    longitude: p.position.longitude,
                  ),
                )
                .toList(),
          ),
        )
        .toList();
    guidesStore.setGuides(data);
  }

  void _seedMockGuides() {
    // No initial guides - user starts with empty state
  }

  void _seedMockSchedules() {
    // No initial schedules - user starts with empty state
  }
}
