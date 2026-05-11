import 'dart:convert';

import 'package:get/get.dart';

import '../../core/storage/local_storage.dart';
import '../../data/models/equipment/equipment_model.dart';

class HistoryLogic extends GetxController {
  // 使用响应式列表存储历史记录（不加载 MockData）
  final RxList<EquipmentModel> _historyItems = <EquipmentModel>[].obs;

  late LocalStorage _localStorage;

  @override
  void onInit() {
    super.onInit();
    _localStorage = Get.find<LocalStorage>();

    print('=== HistoryLogic onInit called ===');
    print('Instance hash: ${hashCode}');
    print(
        'Initial items count (before load from storage): ${_historyItems.length}');

    _loadFromStorage();
  }

  // 从持久化中加载历史记录
  void _loadFromStorage() {
    try {
      final List<String> storedList = _localStorage.getHistoryList();
      print(
          'HistoryLogic._loadFromStorage: loaded raw list length = ${storedList.length}');

      final List<EquipmentModel> items = [];
      for (final item in storedList) {
        try {
          final map = jsonDecode(item) as Map<String, dynamic>;
          items.add(EquipmentModel.fromMap(map));
        } catch (e) {
          print('HistoryLogic._loadFromStorage: skip invalid item: $e');
        }
      }

      _historyItems.assignAll(items);
      print(
          'HistoryLogic._loadFromStorage: assign items length = ${_historyItems.length}');
    } catch (e) {
      print('HistoryLogic._loadFromStorage: failed to load history: $e');
    }
  }

  // 持久化当前历史记录列表
  Future<void> _saveToStorage() async {
    try {
      final List<String> list =
          _historyItems.map((e) => jsonEncode(e.toMap())).toList();
      await _localStorage.saveHistoryList(list);
      print('HistoryLogic._saveToStorage: saved list length = ${list.length}');
    } catch (e) {
      print('HistoryLogic._saveToStorage: failed to save history: $e');
    }
  }

  // 获取历史记录列表 - 返回响应式列表本身
  RxList<EquipmentModel> get historyItems {
    print(
        'HistoryLogic.historyItems getter called, count: ${_historyItems.length}');
    return _historyItems;
  }

  /// 添加新的设备记录（插入到列表开头）
  Future<void> addEquipment(EquipmentModel equipment) async {
    print('=== HistoryLogic.addEquipment called ===');
    print('Instance hash: ${hashCode}');
    print('Equipment: ${equipment.equipmentName}');
    print('Before add - list length: ${_historyItems.length}');

    _historyItems.insert(0, equipment);

    await _saveToStorage();

    print('After add - list length: ${_historyItems.length}');
    print('Equipment details: ${equipment.equipmentName}, ${equipment.date}');
    print('=== End addEquipment ===');
  }

  /// 根据 ID 删除记录
  Future<void> removeEquipment(String id) async {
    _historyItems.removeWhere((item) => item.id == id);
    await _saveToStorage();
  }

  /// 清空所有记录
  Future<void> clearAll() async {
    _historyItems.clear();
    try {
      await _localStorage.removeHistoryList();
    } catch (e) {
      print(
          'HistoryLogic.clearAll: failed to remove history list from storage: $e');
    }
  }
}
