import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pliro/pliro/core/managers/coins_manager.dart';
import 'package:pliro/pliro/core/storage/storage_service.dart';
import 'package:pliro/pliro/interface.dart';

/// Profile controller
class ProfileController extends GetxController {
  final StorageService _storage = StorageService.instance;
  final CoinsManager _coinsManager = CoinsManager.instance;

  String username = 'Bead Artist';
  int coinBalance = 0;
  int totalRecords = 0;
  int badgeCount = 0;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load coins from CoinsManager
    coinBalance = _coinsManager.currentCoins;

    final records = await _storage.getRecords();
    totalRecords = records.length;
    badgeCount = 3; // Mock value
    update();
  }

  Future<void> onSignOut() async {
    // Confirmation dialog and loading are handled in Interface().signOut()
    await Interface().signOut();
  }

  Future<void> onDeleteAccount() async {
    // Confirmation dialogs and loading are handled in Interface().clearAllUserData()
    await Interface().clearAllUserData();
  }
}
