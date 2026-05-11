import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/composition_result.dart';
import '../data/models/image_edit_result.dart';
import '../data/models/saved_result_item.dart';
import '../core/utils/app_constants.dart';

class StorageService extends GetxService {
  static StorageService get to => Get.find();
  static const int initialCoins = 100;

  SharedPreferences? _prefs;
  final ValueNotifier<int> _historyVersionNotifier = ValueNotifier(0);

  ValueNotifier<int> get historyVersionNotifier => _historyVersionNotifier;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _ensureSeedValues();
    await _migrateHistoryStorage();
    await _migrateImageEditHistoryStorage();
    return this;
  }

  int get freeCredits =>
      _prefs?.getInt('free_credits') ?? _generateRandomFreeCredits();

  Future<void> setFreeCredits(int value) async {
    await _prefs?.setInt('free_credits', value);
  }

  Future<void> decrementFreeCredits() async {
    final current = freeCredits;
    if (current > 0) {
      await setFreeCredits(current - 1);
    }
  }

  int get coins => _prefs?.getInt('coins') ?? 0;

  Future<void> setCoins(int value) async {
    await _prefs?.setInt('coins', value);
  }

  Future<void> addCoins(int amount) async {
    await setCoins(coins + amount);
  }

  Future<bool> spendCoins(int amount) async {
    final current = coins;
    if (current >= amount) {
      await setCoins(current - amount);
      return true;
    }
    return false;
  }

  List<CompositionResult> getHistory() {
    final historyJson = _prefs?.getStringList('history') ?? [];
    return historyJson
        .map(_parseHistoryItem)
        .whereType<CompositionResult>()
        .toList();
  }

  List<ImageEditResult> getImageEditHistory() {
    final historyJson = _prefs?.getStringList('image_edit_history') ?? [];
    return historyJson
        .map(_parseImageEditHistoryItem)
        .whereType<ImageEditResult>()
        .toList();
  }

  List<SavedResultItem> getSavedResults() {
    final compositionItems = getHistory().map(SavedResultItem.fromComposition);
    final imageEditItems =
        getImageEditHistory().map(SavedResultItem.fromImageEdit);

    final items = [...compositionItems, ...imageEditItems].toList()
      ..sort((left, right) => right.createdAt.compareTo(left.createdAt));

    return items;
  }

  Future<void> addHistory(CompositionResult result) async {
    final history = getHistory();
    final updatedHistory =
        [result, ...history].take(AppConstants.maxHistoryItems).toList();
    await _writeHistory(updatedHistory);
  }

  Future<void> deleteHistoryItem(String id) async {
    final history = getHistory();
    final updated = history.where((item) => item.id != id).toList();
    await _writeHistory(updated);
  }

  Future<void> clearHistory() async {
    await _prefs?.remove('history');
    _notifyHistoryChanged();
  }

  Future<void> addImageEditHistory(ImageEditResult result) async {
    final history = getImageEditHistory();
    final updatedHistory =
        [result, ...history].take(AppConstants.maxHistoryItems).toList();
    await _writeImageEditHistory(updatedHistory);
  }

  Future<void> deleteImageEditHistoryItem(String id) async {
    final history = getImageEditHistory();
    final updated = history.where((item) => item.id != id).toList();
    await _writeImageEditHistory(updated);
  }

  Future<void> clearImageEditHistory() async {
    await _prefs?.remove('image_edit_history');
    _notifyHistoryChanged();
  }

  Future<void> clearAllData() async {
    await _prefs?.clear();
  }

  int _generateRandomFreeCredits() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return AppConstants.minFreeCredits +
        (random %
            (AppConstants.maxFreeCredits - AppConstants.minFreeCredits + 1));
  }

  int getCostPerAnalysis() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return AppConstants.minCostPerAnalysis +
        (random %
            (AppConstants.maxCostPerAnalysis -
                AppConstants.minCostPerAnalysis +
                1));
  }

  Future<void> _writeHistory(List<CompositionResult> history) async {
    final historyJson =
        history.map((item) => jsonEncode(item.toJson())).toList();
    await _prefs?.setStringList('history', historyJson);
    _notifyHistoryChanged();
  }

  Future<void> _migrateHistoryStorage() async {
    final rawHistory = _prefs?.getStringList('history');
    if (rawHistory == null) {
      return;
    }

    final normalizedHistory = rawHistory
        .map(_parseHistoryItem)
        .whereType<CompositionResult>()
        .map((item) => jsonEncode(item.toJson()))
        .toList();

    final shouldRewrite = rawHistory.length != normalizedHistory.length ||
        !_listEquals(rawHistory, normalizedHistory);

    if (shouldRewrite) {
      await _prefs?.setStringList('history', normalizedHistory);
      _notifyHistoryChanged();
    }
  }

  Future<void> _writeImageEditHistory(List<ImageEditResult> history) async {
    final historyJson =
        history.map((item) => jsonEncode(item.toJson())).toList();
    await _prefs?.setStringList('image_edit_history', historyJson);
    _notifyHistoryChanged();
  }

  Future<void> _migrateImageEditHistoryStorage() async {
    final rawHistory = _prefs?.getStringList('image_edit_history');
    if (rawHistory == null) {
      return;
    }

    final normalizedHistory = rawHistory
        .map(_parseImageEditHistoryItem)
        .whereType<ImageEditResult>()
        .map((item) => jsonEncode(item.toJson()))
        .toList();

    final shouldRewrite = rawHistory.length != normalizedHistory.length ||
        !_listEquals(rawHistory, normalizedHistory);

    if (shouldRewrite) {
      await _prefs?.setStringList('image_edit_history', normalizedHistory);
      _notifyHistoryChanged();
    }
  }

  CompositionResult? _parseHistoryItem(String raw) {
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return _compositionResultFromMap(decoded);
      }
      if (decoded is Map) {
        return _compositionResultFromMap(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      // Fall back to legacy parsing below.
    }

    final legacyMap = _parseLegacyHistoryItem(raw);
    if (legacyMap == null) {
      return null;
    }

    try {
      return _compositionResultFromMap(legacyMap);
    } catch (_) {
      return null;
    }
  }

  CompositionResult _compositionResultFromMap(Map<String, dynamic> json) {
    final issues = _toStringList(json['issues']);
    final suggestions = _toStringList(json['suggestions']);
    final retakeSteps = _toStringList(json['retakeSteps']);

    return CompositionResult(
      id: (json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString())
          .toString(),
      originalImagePath: (json['originalImagePath'] ?? '').toString(),
      guideOverlayPath: json['guideOverlayPath']?.toString(),
      reframePreviewPath: json['reframePreviewPath']?.toString(),
      imageType: ImageType.values.firstWhere(
        (e) => e.name == json['imageType'],
        orElse: () => ImageType.object,
      ),
      goal: json['goal'] != null
          ? AnalysisGoal.values.firstWhere(
              (e) => e.name == json['goal'],
              orElse: () => AnalysisGoal.betterBalance,
            )
          : null,
      summary: (json['summary'] ?? '').toString(),
      issues: issues,
      suggestions: suggestions,
      retakeSteps: retakeSteps,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      coinsUsed: _toInt(json['coinsUsed']),
    );
  }

  ImageEditResult? _parseImageEditHistoryItem(String raw) {
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return _imageEditResultFromMap(decoded);
      }
      if (decoded is Map) {
        return _imageEditResultFromMap(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  ImageEditResult _imageEditResultFromMap(Map<String, dynamic> json) {
    return ImageEditResult(
      id: (json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString())
          .toString(),
      oldImagePaths: _toStringList(json['oldImagePaths']),
      resultImagePath: (json['resultImagePath'] ?? '').toString(),
      title: (json['title'] ?? 'AI result').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      whyBetter: (json['whyBetter'] ?? '').toString(),
      howItWorks: (json['howItWorks'] ?? '').toString(),
      editInstructionContext: (json['editInstructionContext'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      coinsUsed: _toInt(json['coinsUsed']),
    );
  }

  Map<String, dynamic>? _parseLegacyHistoryItem(String raw) {
    if (!raw.contains(':')) {
      return null;
    }

    final map = <String, dynamic>{};
    for (final pair in raw.split(',')) {
      final colonIndex = pair.indexOf(':');
      if (colonIndex <= 0 || colonIndex >= pair.length - 1) {
        continue;
      }
      final key = pair.substring(0, colonIndex).trim();
      final value = pair.substring(colonIndex + 1).trim();
      map[key] = value;
    }

    return map.isEmpty ? null : map;
  }

  List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    if (value is String && value.isNotEmpty) {
      return [value];
    }
    return <String>[];
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  bool _listEquals(List<String> left, List<String> right) {
    if (left.length != right.length) {
      return false;
    }

    for (var i = 0; i < left.length; i++) {
      if (left[i] != right[i]) {
        return false;
      }
    }

    return true;
  }

  void _notifyHistoryChanged() {
    _historyVersionNotifier.value++;
  }

  Future<void> _ensureSeedValues() async {
    if (!(_prefs?.containsKey('coins') ?? false)) {
      await _prefs?.setInt('coins', initialCoins);
    }
  }
}
