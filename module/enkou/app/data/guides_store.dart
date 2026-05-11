import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GuidePlaceData {
  const GuidePlaceData({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String name;
  final String subtitle;
  final double latitude;
  final double longitude;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subtitle': subtitle,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  static GuidePlaceData? fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final name = json['name'] as String?;
    final subtitle = json['subtitle'] as String?;
    final latitude = json['latitude'] as num?;
    final longitude = json['longitude'] as num?;
    if (id == null ||
        name == null ||
        subtitle == null ||
        latitude == null ||
        longitude == null) {
      return null;
    }
    return GuidePlaceData(
      id: id,
      name: name,
      subtitle: subtitle,
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
    );
  }
}

class GuideData {
  const GuideData({
    required this.id,
    required this.title,
    required this.colorValue,
    required this.places,
  });

  final String id;
  final String title;
  final int colorValue;
  final List<GuidePlaceData> places;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'colorValue': colorValue,
      'places': places.map((p) => p.toJson()).toList(),
    };
  }

  static GuideData? fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final title = json['title'] as String?;
    final colorValue = json['colorValue'] as num?;
    final placesRaw = json['places'] as List<dynamic>?;
    if (id == null || title == null || colorValue == null || placesRaw == null) {
      return null;
    }
    final places = placesRaw
        .whereType<Map>()
        .map((e) => GuidePlaceData.fromJson(Map<String, dynamic>.from(e)))
        .whereType<GuidePlaceData>()
        .toList();
    return GuideData(
      id: id,
      title: title,
      colorValue: colorValue.toInt(),
      places: places,
    );
  }
}

class GuidesStore extends GetxService {
  static const _guidesKey = 'travel_guides_v1';

  final RxList<GuideData> guides = <GuideData>[].obs;
  final RxBool guidesReady = false.obs;
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

  void setGuides(List<GuideData> next) {
    guides.assignAll(next);
    _saveLocalGuides();
  }

  Future<void> _initFromLocal() async {
    await _loadLocalGuides();
    guidesReady.value = true;
    _saveWorker = ever<List<GuideData>>(guides, (_) {
      _saveLocalGuides();
    });
  }

  Future<void> _loadLocalGuides() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_guidesKey);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      final loaded = decoded
          .whereType<Map>()
          .map((e) => GuideData.fromJson(Map<String, dynamic>.from(e)))
          .whereType<GuideData>()
          .toList();
      guides.assignAll(loaded);
    } catch (_) {
      // ignore parse/storage errors and keep in-memory fallback
    }
  }

  Future<void> _saveLocalGuides() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(guides.map((e) => e.toJson()).toList());
      await prefs.setString(_guidesKey, raw);
    } catch (_) {
      // ignore save errors
    }
  }

  /// 注销/删除账号时清空本地 guides 数据
  Future<void> clearUserData() async {
    guides.assignAll([]);
    await _saveLocalGuides();
  }
}
