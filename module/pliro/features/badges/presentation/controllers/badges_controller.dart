import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pliro/pliro/core/storage/storage_service.dart';
import 'package:pliro/pliro/features/badges/presentation/pages/badges_page.dart';
import 'package:pliro/pliro/features/records/domain/models/bead_record.dart';

/// Badges controller
class BadgesController extends GetxController {
  final StorageService _storage = StorageService.instance;

  bool isLoading = true;
  int earnedBadgeCount = 0;
  int completedCount = 0;
  int savedRecordCount = 0;
  List<BadgeModel> allBadges = [];

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading = true;
    update();

    final records = await _storage.getRecords();

    // Calculate stats
    savedRecordCount = records.length;
    completedCount = records.where((r) => r.isFinished).length;

    // Generate badges
    allBadges = _generateBadges(records);
    earnedBadgeCount = allBadges.where((b) => b.isEarned).length;

    isLoading = false;
    update();
  }

  List<BadgeModel> _generateBadges(List<BeadRecord> records) {
    final badges = <BadgeModel>[];

    final savedCount = records.length;
    final finishedCount = records.where((r) => r.isFinished).length;
    final finishedImageCount =
        records.where((r) => _hasValue(r.finishedImagePath)).length;
    final patternImageCount =
        records.where((r) => _hasValue(r.patternImagePath)).length;
    final notedCount = records.where((r) => _hasValue(r.notes)).length;

    // First saved record badge
    badges.add(BadgeModel(
      id: 'first',
      name: 'First Capture',
      description: 'Save your first work record',
      icon: Icons.add_photo_alternate_outlined,
      isEarned: savedCount >= 1,
    ));

    // Finished works badge
    badges.add(BadgeModel(
      id: 'finished_lineup',
      name: 'Finished Lineup',
      description: 'Finish 5 works',
      icon: Icons.check_circle_outline,
      isEarned: finishedCount >= 5,
      progress: finishedCount,
      maxProgress: 5,
    ));

    // Saved records badge
    badges.add(BadgeModel(
      id: 'shelf_builder',
      name: 'Shelf Builder',
      description: 'Save 10 work records',
      icon: Icons.collections_bookmark_outlined,
      isEarned: savedCount >= 10,
      progress: savedCount,
      maxProgress: 10,
    ));

    // Finished images badge
    badges.add(BadgeModel(
      id: 'gallery_keeper',
      name: 'Gallery Keeper',
      description: 'Add finished photos to 5 records',
      icon: Icons.photo_library_outlined,
      isEarned: finishedImageCount >= 5,
      progress: finishedImageCount,
      maxProgress: 5,
    ));

    // Pattern images badge
    badges.add(BadgeModel(
      id: 'pattern_keeper',
      name: 'Pattern Keeper',
      description: 'Save 3 pattern sheets',
      icon: Icons.grid_on,
      isEarned: patternImageCount >= 3,
      progress: patternImageCount,
      maxProgress: 3,
    ));

    // Notes badge
    badges.add(BadgeModel(
      id: 'studio_notes',
      name: 'Studio Notes',
      description: 'Add notes to 3 records',
      icon: Icons.notes_outlined,
      isEarned: notedCount >= 3,
      progress: notedCount,
      maxProgress: 3,
    ));

    return badges;
  }

  bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;
}
