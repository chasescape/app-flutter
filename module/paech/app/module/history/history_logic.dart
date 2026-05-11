import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryEntry {
  const HistoryEntry({
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.imagePath,
    required this.tips,
    this.createdAt,
  });

  final String title;
  final String subtitle;
  final String timeLabel;
  final String? imagePath;
  final List<Map<String, String>> tips;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'timeLabel': timeLabel,
      'imagePath': imagePath,
      'tips': tips,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      timeLabel: json['timeLabel'] as String,
      imagePath: json['imagePath'] as String?,
      tips: (json['tips'] as List<dynamic>?)
              ?.map((e) => Map<String, String>.from(e as Map))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}

class HistoryLogic extends GetxController {
  final RxList<HistoryEntry> entries = <HistoryEntry>[].obs;
  
  SharedPreferences? _prefs;
  static const String _historyKey = 'generation_history';
  
  // 用于标记是否已完成初始化
  bool _isInitialized = false;
  final List<Future<void> Function()> _pendingOperations = [];

  @override
  void onInit() {
    super.onInit();
    _initializeAsync();
  }
  
  /// 异步初始化
  Future<void> _initializeAsync() async {
    await _loadHistory();
    _isInitialized = true;
    
    // 执行所有待处理的操作
    for (final operation in _pendingOperations) {
      await operation();
    }
    _pendingOperations.clear();
  }
  
  /// 确保已初始化
  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    
    // 等待初始化完成（最多等待3秒）
    var waitCount = 0;
    while (!_isInitialized && waitCount < 30) {
      await Future.delayed(const Duration(milliseconds: 100));
      waitCount++;
    }
    
    if (!_isInitialized) {
      debugPrint('Warning: HistoryLogic initialization timeout');
      // 强制初始化
      _prefs ??= await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }

  bool get isEmpty => entries.isEmpty;

  /// 从本地加载历史记录
  Future<void> _loadHistory() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final historyJson = _prefs?.getString(_historyKey);
      
      if (historyJson != null && historyJson.isNotEmpty) {
        final List<dynamic> historyList = jsonDecode(historyJson) as List<dynamic>;
        final loadedEntries = historyList
            .map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>))
            .toList();
        
        // 验证图片文件是否存在，过滤掉无效的记录
        final validEntries = <HistoryEntry>[];
        var removedCount = 0;
        
        for (final entry in loadedEntries) {
          if (entry.imagePath != null && entry.imagePath!.isNotEmpty) {
            final file = File(entry.imagePath!);
            if (await file.exists()) {
              validEntries.add(entry);
            } else {
              removedCount++;
              debugPrint('Removed invalid history entry (image not found): ${entry.title}');
            }
          } else {
            // 没有图片路径的记录也保留（如果有的话）
            validEntries.add(entry);
          }
        }
        
        entries.assignAll(validEntries);
        
        // 如果有记录被清理，保存更新后的历史
        if (removedCount > 0) {
          await _saveHistory();
          debugPrint('Cleaned up $removedCount invalid history entries');
        }
        
        debugPrint('Loaded ${entries.length} valid history entries from local storage');
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
    }
  }

  /// 保存历史记录到本地
  Future<void> _saveHistory() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final historyJson = jsonEncode(
        entries.map((e) => e.toJson()).toList(),
      );
      await _prefs?.setString(_historyKey, historyJson);
      debugPrint('Saved ${entries.length} history entries to local storage');
    } catch (e) {
      debugPrint('Error saving history: $e');
    }
  }

  /// 添加新的历史记录
  Future<void> addHistoryEntry({
    required String title,
    required String subtitle,
    required String? imagePath,
    required List<Map<String, String>> tips,
  }) async {
    // 确保已初始化
    await _ensureInitialized();
    
    final now = DateTime.now();
    final timeLabel = _formatTimeLabel(now);
    
    final entry = HistoryEntry(
      title: title,
      subtitle: subtitle,
      timeLabel: timeLabel,
      imagePath: imagePath,
      tips: tips,
      createdAt: now,
    );

    // 添加到列表开头（最新的在前面）
    entries.insert(0, entry);
    
    // 限制历史记录数量（最多保存50条）
    if (entries.length > 50) {
      entries.removeRange(50, entries.length);
    }
    
    await _saveHistory();
    debugPrint('Added history entry: $title, total entries: ${entries.length}');
  }

  /// 格式化时间标签
  String _formatTimeLabel(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    }
  }

  /// 清空历史记录
  Future<void> clearHistory() async {
    await _ensureInitialized();
    entries.clear();
    await _saveHistory();
    debugPrint('History cleared');
  }

  /// 删除指定的历史记录
  Future<void> removeHistoryEntry(int index) async {
    await _ensureInitialized();
    if (index >= 0 && index < entries.length) {
      entries.removeAt(index);
      await _saveHistory();
      debugPrint('Removed history entry at index $index');
    }
  }
  
  /// 验证并清理无效的历史记录（图片文件不存在的记录）
  Future<int> cleanupInvalidEntries() async {
    final validEntries = <HistoryEntry>[];
    var removedCount = 0;
    
    for (final entry in entries) {
      if (entry.imagePath != null && entry.imagePath!.isNotEmpty) {
        final file = File(entry.imagePath!);
        if (await file.exists()) {
          validEntries.add(entry);
        } else {
          removedCount++;
          debugPrint('Cleaned up invalid entry: ${entry.title}');
        }
      } else {
        validEntries.add(entry);
      }
    }
    
    if (removedCount > 0) {
      entries.assignAll(validEntries);
      await _saveHistory();
      debugPrint('Cleaned up $removedCount invalid history entries');
    }
    
    return removedCount;
  }
}
