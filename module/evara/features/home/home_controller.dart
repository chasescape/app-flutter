import 'package:signals/signals_flutter.dart';
import 'package:get/get.dart';
import '../../core/singletons/user_service.dart';
import '../../core/singletons/storage_service.dart';
import 'dart:convert';

/// Home Page Controller - Signals State Management
class HomeController extends GetxController {
  final UserService _userService = UserService.instance;
  final StorageService _storage = StorageService.instance;

  // Signals
  final userCoins = signal<int>(0);
  final recentRecords = signal<List<Map<String, dynamic>>>([]);
  final isLoading = signal<bool>(false);
  final currentPage = signal<int>(0);

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;

    // Load coins
    final coins = await _userService.getCoins();
    userCoins.value = coins;

    // Load recent records (last 7 days)
    await _loadRecentRecords();

    isLoading.value = false;
  }

  Future<void> _loadRecentRecords() async {
    try {
      final recordsJson = await _storage.loadString(StorageKeys.makeupRecords);
      if (recordsJson != null) {
        final List<dynamic> decoded = jsonDecode(recordsJson);
        final allRecords = decoded.cast<Map<String, dynamic>>();

        // Filter last 7 days and take last 10
        final now = DateTime.now();
        final weekAgo = now.subtract(const Duration(days: 7));

        final recent = allRecords.where((record) {
          final createdAtStr = record['analysis']?['createdAt'] as String?;
          if (createdAtStr == null) return false;
          final createdAt = DateTime.parse(createdAtStr);
          return createdAt.isAfter(weekAgo);
        }).toList()
          ..sort((a, b) {
            final aTime = DateTime.parse(a['analysis']['createdAt']);
            final bTime = DateTime.parse(b['analysis']['createdAt']);
            return bTime.compareTo(aTime);
          });

        recentRecords.value = recent.take(10).toList();
      } else {
        recentRecords.value = [];
      }
    } catch (e) {
      recentRecords.value = [];
    }
  }

  @override
  Future<void> refresh() async {
    await _loadData();
  }

  Future<void> refreshRecords() async {
    await _loadRecentRecords();
  }

  void onPageChanged(int page) {
    currentPage.value = page;
  }
}
