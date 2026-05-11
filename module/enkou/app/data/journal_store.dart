import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:enkou/gen_a/A.dart';

class JournalMediaItem {
  JournalMediaItem({
    required this.id,
    required this.type,
    required this.source,
    required this.label,
  });

  final String id;
  final String type; // image | video
  final String source;
  final String label;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'source': source,
      'label': label,
    };
  }

  static JournalMediaItem? fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final type = json['type'] as String?;
    final source = json['source'] as String?;
    final label = json['label'] as String?;
    if (id == null || type == null || source == null || label == null) {
      return null;
    }
    return JournalMediaItem(
      id: id,
      type: type,
      source: source,
      label: label,
    );
  }
}

class JournalEntry {
  JournalEntry({
    required this.id,
    required this.date,
    required this.text,
    required this.medias,
    required this.tags,
    this.locationTag = '',
    DateTime? createdAt,
    this.lastEditedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final DateTime date;
  final String text;
  final List<JournalMediaItem> medias;
  final List<String> tags;
  final String locationTag;
  final DateTime createdAt;
  final DateTime? lastEditedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'text': text,
      'medias': medias.map((m) => m.toJson()).toList(),
      'tags': tags,
      'locationTag': locationTag,
      'createdAt': createdAt.toIso8601String(),
      'lastEditedAt': lastEditedAt?.toIso8601String(),
    };
  }

  static JournalEntry? fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final dateRaw = json['date'] as String?;
    final date = dateRaw == null ? null : DateTime.tryParse(dateRaw);
    final text = json['text'] as String?;
    final mediasRaw = json['medias'] as List<dynamic>?;
    final tagsRaw = json['tags'] as List<dynamic>? ?? [];
    final locationTag = json['locationTag'] as String? ?? '';
    final createdRaw = json['createdAt'] as String?;
    final createdAt = createdRaw == null ? null : DateTime.tryParse(createdRaw);
    final lastEditedRaw = json['lastEditedAt'] as String?;
    final lastEditedAt =
        lastEditedRaw == null ? null : DateTime.tryParse(lastEditedRaw);
    if (id == null || date == null || text == null || mediasRaw == null) {
      return null;
    }

    final medias = mediasRaw
        .whereType<Map>()
        .map((e) => JournalMediaItem.fromJson(Map<String, dynamic>.from(e)))
        .whereType<JournalMediaItem>()
        .toList();
    final tags = tagsRaw.whereType<String>().toList();

    return JournalEntry(
      id: id,
      date: date,
      text: text,
      medias: medias,
      tags: tags,
      locationTag: locationTag,
      createdAt: createdAt ?? date,
      lastEditedAt: lastEditedAt,
    );
  }
}

class JournalStore extends GetxService {
  static const _entriesKeyV2 = 'journal_entries_v2';
  static const _entriesKeyV1 = 'journal_entries_v1';

  static const List<String> topicTags = [
    'Cities',
    'Mountains',
    'Coast',
    'Food',
  ];

  final RxList<JournalEntry> entries = <JournalEntry>[].obs;
  final RxBool entriesReady = false.obs;
  Worker? _saveWorker;
  bool _seedScheduled = false;

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

  JournalEntry? entryForDate(DateTime date) {
    final day = normalize(date);
    final list = entries
        .where((e) => normalize(e.date) == day)
        .toList()
      ..sort((a, b) {
        final ae = a.lastEditedAt ?? a.createdAt;
        final be = b.lastEditedAt ?? b.createdAt;
        return be.compareTo(ae);
      });
    return list.isEmpty ? null : list.first;
  }

  List<JournalEntry> entriesForDate(DateTime date) {
    final day = normalize(date);
    final list = entries.where((e) => normalize(e.date) == day).toList()
      ..sort((a, b) {
        final ae = a.lastEditedAt ?? a.createdAt;
        final be = b.lastEditedAt ?? b.createdAt;
        return be.compareTo(ae);
      });
    return list;
  }

  JournalEntry? entryById(String id) {
    return entries.firstWhereOrNull((e) => e.id == id);
  }

  void upsertEntry({
    String? entryId,
    required DateTime date,
    required String text,
    required List<JournalMediaItem> medias,
    List<String> tags = const [],
    String locationTag = '',
  }) {
    final day = normalize(date);
    final now = DateTime.now();
    final id = entryId ?? 'journal_${day.millisecondsSinceEpoch}_${now.microsecondsSinceEpoch}';
    final index = entries.indexWhere((e) => e.id == id);
    final existingCreatedAt = index >= 0 ? entries[index].createdAt : now;
    final data = JournalEntry(
      id: id,
      date: day,
      text: text,
      medias: medias,
      tags: tags,
      locationTag: locationTag,
      createdAt: entryId == null ? now : existingCreatedAt,
      lastEditedAt: now,
    );

    if (index >= 0) {
      entries[index] = data;
      entries.refresh();
      _saveLocalEntries();
      return;
    }
    entries.insert(0, data);
    _saveLocalEntries();
  }

  List<JournalEntry> recentEntries({int days = 10}) {
    final now = normalize(DateTime.now());
    final start = now.subtract(Duration(days: days - 1));
    final list = entries
        .where((e) {
          final d = normalize(e.date);
          return !d.isBefore(start) && !d.isAfter(now);
        })
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  /// 返回“今天编辑过”的所有日记（按最近编辑时间倒序）
  List<JournalEntry> editedOn(DateTime day) {
    final target = normalize(day);
    final list = entries.where((e) {
      final edited = e.lastEditedAt ?? e.createdAt;
      return normalize(edited) == target;
    }).toList()
      ..sort((a, b) {
        final ae = a.lastEditedAt ?? a.createdAt;
        final be = b.lastEditedAt ?? b.createdAt;
        return be.compareTo(ae);
      });
    return list;
  }

  bool hasImage(JournalEntry entry) {
    return entry.medias.any((m) => m.type == 'image');
  }

  String? firstImage(JournalEntry entry) {
    // 返回该日记中最后一张图片（无论是 assets 还是本地 file 路径）
    final images =
        entry.medias.where((m) => m.type.toLowerCase() == 'image').toList();
    if (images.isEmpty) return null;
    return images.last.source;
  }

  static const _mockIdPrefix = 'mock_seed_';

  void seedMockIfEmpty() {
    // No mock data for app review - users start with empty state
  }

  Future<void> _initFromLocal() async {
    await _loadLocalEntries();
    entriesReady.value = true;
    _saveWorker = ever<List<JournalEntry>>(entries, (_) {
      _saveLocalEntries();
    });
  }

  Future<void> _loadLocalEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawV2 = prefs.getString(_entriesKeyV2);
      final rawV1 = prefs.getString(_entriesKeyV1);
      final raw = (rawV2 != null && rawV2.isNotEmpty)
          ? rawV2
          : (rawV1 ?? '');
      if (raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;

      final loaded = decoded
          .whereType<Map>()
          .map((e) => JournalEntry.fromJson(Map<String, dynamic>.from(e)))
          .whereType<JournalEntry>()
          .toList()
        ..sort((a, b) {
          final ae = a.lastEditedAt ?? a.createdAt;
          final be = b.lastEditedAt ?? b.createdAt;
          return be.compareTo(ae);
        });
      entries.assignAll(loaded);
      _migrateLegacyAssetSources();
    } catch (_) {
      // ignore parse/storage errors
    }
  }

  void _migrateLegacyAssetSources() {
    if (entries.isEmpty) return;

    final allowed = <String>[
      A.assets_enkou_01,
      A.assets_enkou_02,
      A.assets_enkou_03,
      A.assets_enkou_04,
      A.assets_enkou_05,
      A.assets_enkou_06,
      A.assets_enkou_07,
      A.assets_enkou_08,
      A.assets_enkou_09,
      A.assets_enkou_10,
      A.assets_enkou_11,
      A.assets_enkou_open,
      A.assets_enkou_logo,
    ];
    final allowedSet = allowed.toSet();
    final validAsset = RegExp(r'^assets/enkou/\d{2}\.jpg$');

    var changed = false;
    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      final nextMedias = <JournalMediaItem>[];
      var entryChanged = false;

      for (var j = 0; j < e.medias.length; j++) {
        final m = e.medias[j];
        if (m.type.toLowerCase() != 'image') {
          nextMedias.add(m);
          continue;
        }

        final src = m.source;
        final isLegacyImg = src.contains('IMG_') || src.contains('img_');
        final isAllowed = allowedSet.contains(src);
        final isValidAsset = validAsset.hasMatch(src);

        if (isLegacyImg || (!isAllowed && src.startsWith('assets/') && !isValidAsset)) {
          final replacement = allowed[(i + j) % allowed.length];
          nextMedias.add(
            JournalMediaItem(
              id: m.id,
              type: m.type,
              source: replacement,
              label: m.label,
            ),
          );
          entryChanged = true;
          continue;
        }

        nextMedias.add(m);
      }

      if (entryChanged) {
        entries[i] = JournalEntry(
          id: e.id,
          date: e.date,
          text: e.text,
          medias: nextMedias,
          tags: e.tags,
          locationTag: e.locationTag,
          createdAt: e.createdAt,
          lastEditedAt: e.lastEditedAt,
        );
        changed = true;
      }
    }

    if (changed) {
      entries.refresh();
      _saveLocalEntries();
    }
  }

  Future<void> _saveLocalEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(entries.map((e) => e.toJson()).toList());
      await prefs.setString(_entriesKeyV2, raw);
    } catch (_) {
      // ignore save errors
    }
  }

  /// 注销/删除账号时清空本地日记数据
  Future<void> clearUserData() async {
    entries.assignAll([]);
    await _saveLocalEntries();
  }
}
