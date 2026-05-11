import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tanie/tanie/data/models/reflection_entry.dart';

/// Reflection Storage Service
/// Manages local persistence of reflection entries
class ReflectionStorageService {
  ReflectionStorageService._();
  static final ReflectionStorageService _instance = ReflectionStorageService._();
  factory ReflectionStorageService() => _instance;

  static const String _storageKey = 'reflection_entries';
  List<ReflectionEntry>? _cachedEntries;

  /// Initialize the service
  Future<void> init() async {
    await _loadEntries();
  }

  /// Get all reflection entries
  List<ReflectionEntry> getAllEntries() {
    return _cachedEntries ?? [];
  }

  /// Get entry by ID (using index)
  ReflectionEntry? getEntryAtIndex(int index) {
    if (_cachedEntries == null || index < 0 || index >= _cachedEntries!.length) {
      return null;
    }
    return _cachedEntries![index];
  }

  /// Save a new reflection entry
  Future<void> saveEntry(ReflectionEntry entry) async {
    final prefs = await SharedPreferences.getInstance();

    _cachedEntries ??= [];
    _cachedEntries!.insert(0, entry); // Add to beginning of list

    await _saveToPrefs(prefs);
  }

  /// Delete an entry by index
  Future<void> deleteEntry(int index) async {
    if (_cachedEntries == null || index < 0 || index >= _cachedEntries!.length) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    _cachedEntries!.removeAt(index);

    await _saveToPrefs(prefs);
  }

  /// Update an entry by index
  Future<void> updateEntry(int index, ReflectionEntry updatedEntry) async {
    if (_cachedEntries == null || index < 0 || index >= _cachedEntries!.length) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    _cachedEntries![index] = updatedEntry;

    await _saveToPrefs(prefs);
  }

  /// Clear all entries
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    _cachedEntries = [];
  }

  /// Get entry count
  int get entryCount => _cachedEntries?.length ?? 0;

  /// Load entries from persistent storage
  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null || jsonString.isEmpty) {
      _cachedEntries = [];
      return;
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _cachedEntries = jsonList
          .map((json) => ReflectionEntry.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If parsing fails, start with empty list
      _cachedEntries = [];
    }
  }

  /// Save entries to persistent storage
  Future<void> _saveToPrefs(SharedPreferences prefs) async {
    if (_cachedEntries == null) return;

    final jsonString = jsonEncode(
      _cachedEntries!.map((entry) => entry.toJson()).toList(),
    );

    await prefs.setString(_storageKey, jsonString);
  }
}

/// Global instance
final reflectionStorageService = ReflectionStorageService();
