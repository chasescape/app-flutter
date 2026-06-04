import 'dart:io';
import 'dart:convert';
import 'package:signals/signals_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/singletons/ai_service.dart';
import '../../core/singletons/coins_manager.dart';
import '../../core/singletons/storage_service.dart';

/// Create Page Controller - Signals State Management
class CreateController extends GetxController {
  final StorageService _storage = StorageService.instance;
  final CoinsManager _coinsManager = CoinsManager.instance;

  // Signals
  final selectedImage = signal<File?>(null);
  final isSaving = signal<bool>(false);
  final userCoins = signal<int>(0);
  final costPerRecord = signal<int>(12);

  @override
  void onInit() {
    super.onInit();
    _loadCoins();
    _coinsManager.coinsNotifier.addListener(_syncCoins);
  }

  @override
  void onClose() {
    _coinsManager.coinsNotifier.removeListener(_syncCoins);
    super.onClose();
  }

  void _syncCoins() {
    userCoins.value = _coinsManager.coinsNotifier.value;
  }

  Future<void> _loadCoins() async {
    userCoins.value = await _coinsManager.getCoins();
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      selectedImage.value = File(picked.path);
    }
  }

  Future<MakeupAnalysisResult?> analyzeMakeup({
    String? customTags,
    String? recordNote,
    String? photoAngle,
    String? lightingNote,
    String? focusNote,
    String? lookMood,
  }) async {
    final image = selectedImage.value;
    if (image == null) {
      return null;
    }

    final currentCoins = await _coinsManager.getCoins();
    if (currentCoins < costPerRecord.value) {
      Get.snackbar(
        'Insufficient Coins',
        'You need ${costPerRecord.value} coins to save a new record.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    isSaving.value = true;

    try {
      final finalResult = MakeupAnalysisResult(
        imagePath: image.path,
        styleTags: _buildStyleTags(customTags),
        occasionTags: _buildOccasionTags(
          customTags: customTags,
          lookMood: lookMood,
        ),
        recordNote: (recordNote ?? '').trim(),
        shotType: _fallbackValue(photoAngle, 'Personal photo'),
        focusArea: _fallbackValue(focusNote, 'Full look'),
        lighting: _fallbackValue(lightingNote, 'Not specified'),
        occasion: _fallbackValue(lookMood, 'Personal record'),
        season: _seasonLabel(DateTime.now()),
        timeOfDay: _timeOfDayLabel(DateTime.now()),
        createdAt: DateTime.now(),
      );

      final deducted = await _coinsManager.subCoins(costPerRecord.value);
      if (!deducted) {
        Get.snackbar(
          'Insufficient Coins',
          'You need ${costPerRecord.value} coins to save a new record.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      }

      await _saveRecord(finalResult);
      await _loadCoins();

      return finalResult;
    } catch (e) {
      await _coinsManager.addCoins(costPerRecord.value);
      await _loadCoins();
      Get.snackbar(
        'Error',
        'Failed to save this record: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> _saveRecord(MakeupAnalysisResult result) async {
    final recordsJson = await _storage.loadString(StorageKeys.makeupRecords);
    List<Map<String, dynamic>> records = [];

    if (recordsJson != null) {
      try {
        records = List<Map<String, dynamic>>.from(
          const JsonDecoder().convert(recordsJson) as List,
        );
      } catch (e) {
        records = [];
      }
    }

    if (records.length >= 200) {
      records.removeAt(0);
    }

    final record = MakeupRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: result.imagePath,
      analysis: result,
    );

    records.add(record.toJson());
    await _storage.saveString(StorageKeys.makeupRecords, const JsonEncoder().convert(records));
  }

  void clearImage() {
    selectedImage.value = null;
  }

  List<String> _buildStyleTags(String? customTags) {
    final parsed = _parseTags(customTags);
    return parsed.isNotEmpty ? parsed : const ['Today\'s look'];
  }

  List<String> _buildOccasionTags({
    String? customTags,
    String? lookMood,
  }) {
    final values = <String>[];
    values.addAll(_parseTags(customTags).take(2));
    final trimmedMood = (lookMood ?? '').trim();
    if (trimmedMood.isNotEmpty && !values.contains(trimmedMood)) {
      values.add(trimmedMood);
    }
    return values.isNotEmpty ? values.take(2).toList() : const ['My record'];
  }

  List<String> _parseTags(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return [];
    }
    return raw
        .split(RegExp(r'[,，/#\n]+'))
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();
  }

  String _fallbackValue(String? manual, String fallback) {
    final trimmed = (manual ?? '').trim();
    return trimmed.isNotEmpty ? trimmed : fallback;
  }

  String _seasonLabel(DateTime dateTime) {
    final month = dateTime.month;
    if (month >= 3 && month <= 5) {
      return 'Spring';
    }
    if (month >= 6 && month <= 8) {
      return 'Summer';
    }
    if (month >= 9 && month <= 11) {
      return 'Autumn';
    }
    return 'Winter';
  }

  String _timeOfDayLabel(DateTime dateTime) {
    final hour = dateTime.hour;
    if (hour < 12) {
      return 'Morning';
    }
    if (hour < 18) {
      return 'Afternoon';
    }
    return 'Evening';
  }
}
