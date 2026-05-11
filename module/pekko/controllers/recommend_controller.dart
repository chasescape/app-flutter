import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/perfume_record.dart';
import '../data/services/storage_service.dart';
import '../data/services/api_service.dart';
import '../core/theme/app_colors.dart';
import 'main_controller.dart';

/// Recommend controller for AI perfume recommendations
class RecommendController extends GetxController {
  final StorageService _storage = StorageService.to;
  final ApiService _api = ApiService.to;
  final MainController _mainController = Get.find<MainController>();

  // Input observables
  final Rxn<UsageScene> selectedScene = Rxn<UsageScene>();
  final Rxn<TimeOfDayType> selectedTime = Rxn<TimeOfDayType>();
  final Rxn<Season> selectedSeason = Rxn<Season>();

  // Results
  final RxList<Map<String, dynamic>> recommendations =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRecording = false.obs;
  final RxString loadingMessage = 'Preparing...'.obs;

  // Cancel token for AI requests
  bool _isCancelled = false;

  @override
  void onInit() {
    super.onInit();
    _initializeDefaults();
  }

  void _initializeDefaults() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      selectedTime.value = TimeOfDayType.morning;
    } else if (hour >= 12 && hour < 17) {
      selectedTime.value = TimeOfDayType.afternoon;
    } else if (hour >= 17 && hour < 21) {
      selectedTime.value = TimeOfDayType.evening;
    } else {
      selectedTime.value = TimeOfDayType.night;
    }

    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) {
      selectedSeason.value = Season.spring;
    } else if (month >= 6 && month <= 8) {
      selectedSeason.value = Season.summer;
    } else if (month >= 9 && month <= 11) {
      selectedSeason.value = Season.autumn;
    } else {
      selectedSeason.value = Season.winter;
    }

    selectedScene.value = UsageScene.casual;
  }

  void selectScene(UsageScene scene) {
    selectedScene.value = scene;
  }

  void selectTime(TimeOfDayType time) {
    selectedTime.value = time;
  }

  void selectSeason(Season season) {
    selectedSeason.value = season;
  }

  bool get isValidInput =>
      selectedScene.value != null &&
      selectedTime.value != null &&
      selectedSeason.value != null;

  int get cost => 30 + (DateTime.now().millisecond % 21);

  Future<bool> canGetRecommendation() async {
    final userData = await _storage.getUserData();
    return userData.hasFreeUses || userData.coins >= cost;
  }

  Future<void> getRecommendations() async {
    if (!isValidInput) {
      Get.snackbar(
        'Error',
        'Please select all options',
        backgroundColor: AppColors.error,
        colorText: AppColors.textInverse,
      );
      return;
    }

    final userData = await _storage.getUserData();

    if (!userData.hasFreeUses && userData.coins < cost) {
      Get.snackbar(
        'Insufficient Coins',
        'Need $cost coins for recommendations',
        backgroundColor: AppColors.warning,
        colorText: AppColors.textInverse,
      );
      return;
    }

    _isCancelled = false;
    try {
      isLoading.value = true;
      loadingMessage.value = 'Preparing...';

      // Deduct coins or use free use
      if (userData.hasFreeUses) {
        await _storage.useFreeUse();
      } else {
        await _storage.updateCoins(-cost);
      }

      await _mainController.refreshUserData();

      // Get history for better recommendations
      if (_isCancelled) return;
      loadingMessage.value = 'Analyzing your preferences...';
      final history = await _storage.getRecords();

      // Get recommendations from AI
      if (_isCancelled) return;
      loadingMessage.value = 'Finding perfect scents...';
      final results = await _api.getRecommendations(
        scene: selectedScene.value!,
        timeOfDay: selectedTime.value!,
        season: selectedSeason.value!,
        history: history,
      );

      if (_isCancelled) return;
      loadingMessage.value = 'Finalizing...';
      await Future.delayed(const Duration(milliseconds: 500));

      if (_isCancelled) return;
      recommendations.value = results;
    } catch (e) {
      if (!_isCancelled) {
        Get.snackbar(
          'Error',
          'Failed to get recommendations. Please try again.',
          backgroundColor: AppColors.error,
          colorText: AppColors.textInverse,
        );
      }
    } finally {
      if (!_isCancelled) {
        isLoading.value = false;
      }
      _isCancelled = false;
    }
  }

  /// Cancel the ongoing recommendation request
  void cancelRecommendation() {
    _isCancelled = true;
    isLoading.value = false;
  }

  Future<void> quickRecordWithRecommendation(Map<String, dynamic> rec) async {
    // Navigate to record page with pre-filled data
    Get.toNamed('/record', arguments: {
      'perfumeName': rec['name'] as String,
      'brand': rec['brand'] as String,
      'note': rec['note'] as PerfumeNote,
      'scene': selectedScene.value,
      'timeOfDay': selectedTime.value,
      'season': selectedSeason.value,
    });
  }

  void clearResults() {
    recommendations.clear();
  }
}
