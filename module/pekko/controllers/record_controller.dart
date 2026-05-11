import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/perfume_record.dart';
import '../data/models/perfume.dart';
import '../data/services/storage_service.dart';
import '../core/theme/app_colors.dart';
import 'main_controller.dart';

/// Record controller for adding/editing perfume records
class RecordController extends GetxController {
  final StorageService _storage = StorageService.to;
  final MainController _mainController = Get.find<MainController>();

  // Form observables
  final RxList<Perfume> availablePerfumes = <Perfume>[].obs;
  final Rxn<Perfume> selectedPerfume = Rxn<Perfume>();
  final Rxn<PerfumeNote> selectedNote = Rxn<PerfumeNote>();
  final Rxn<UsageScene> selectedScene = Rxn<UsageScene>();
  final Rxn<TimeOfDayType> selectedTime = Rxn<TimeOfDayType>();
  final Rxn<Season> selectedSeason = Rxn<Season>();

  final RxInt longevity = 6.obs;
  final RxInt moodRating = 3.obs;
  final RxString notes = ''.obs;
  final RxString outfit = ''.obs;
  final RxString weather = ''.obs;
  final RxInt compliments = 0.obs;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  final TextEditingController perfumeNameController = TextEditingController();
  final TextEditingController brandController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _initializeDefaults();
    loadAvailablePerfumes();
    _applyRouteArguments();
  }

  Future<void> loadAvailablePerfumes() async {
    availablePerfumes.value = await _storage.getPerfumes();
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
    selectedNote.value = PerfumeNote.floral;
  }

  void selectPerfume(Perfume perfume) {
    selectedPerfume.value = perfume;
    selectedNote.value = perfume.primaryNote;
    perfumeNameController.text = perfume.name;
    brandController.text = perfume.brand;
  }

  void selectNote(PerfumeNote note) {
    selectedNote.value = note;
    final current = selectedPerfume.value;
    if (current != null) {
      selectedPerfume.value = Perfume(
        id: current.id,
        name: current.name,
        brand: current.brand,
        imageUrl: current.imageUrl,
        primaryNote: note,
        notes: [note],
        description: current.description,
        createdAt: current.createdAt,
      );
    }
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

  void updateLongevity(int hours) {
    longevity.value = hours.clamp(1, 24);
  }

  void updateMoodRating(int rating) {
    moodRating.value = rating.clamp(1, 5);
  }

  void updateNotes(String value) {
    notes.value = value;
  }

  void updateOutfit(String value) {
    outfit.value = value;
  }

  void updateWeather(String value) {
    weather.value = value;
  }

  void updateCompliments(int count) {
    compliments.value = count.clamp(0, 100);
  }

  void updatePerfumeName(String value) {
    final current = selectedPerfume.value;
    selectedPerfume.value = Perfume(
      id: current?.id ?? 'draft-perfume',
      name: value.trim(),
      brand: current?.brand ?? brandController.text.trim(),
      imageUrl: current?.imageUrl,
      primaryNote: selectedNote.value ?? PerfumeNote.floral,
      notes: current?.notes ?? [selectedNote.value ?? PerfumeNote.floral],
      description: current?.description,
      createdAt: current?.createdAt ?? DateTime.now(),
    );
  }

  void updateBrand(String value) {
    final current = selectedPerfume.value;
    selectedPerfume.value = Perfume(
      id: current?.id ?? 'draft-perfume',
      name: current?.name ?? perfumeNameController.text.trim(),
      brand: value.trim(),
      imageUrl: current?.imageUrl,
      primaryNote: selectedNote.value ?? PerfumeNote.floral,
      notes: current?.notes ?? [selectedNote.value ?? PerfumeNote.floral],
      description: current?.description,
      createdAt: current?.createdAt ?? DateTime.now(),
    );
  }

  void _applyRouteArguments() {
    final args = Get.arguments;
    if (args is! Map) return;

    final perfumeName = args['perfumeName'] as String?;
    final brand = args['brand'] as String?;
    final imageUrl = args['imageUrl'] as String?;
    final note = args['note'] as PerfumeNote?;
    final scene = args['scene'] as UsageScene?;
    final timeOfDay = args['timeOfDay'] as TimeOfDayType?;
    final season = args['season'] as Season?;

    if (perfumeName != null && brand != null) {
      final perfume = Perfume(
        id: 'prefill-${DateTime.now().millisecondsSinceEpoch}',
        name: perfumeName,
        brand: brand,
        imageUrl: imageUrl,
        primaryNote: note ?? PerfumeNote.floral,
        notes: [note ?? PerfumeNote.floral],
        createdAt: DateTime.now(),
      );
      selectPerfume(perfume);
    }

    if (scene != null) selectedScene.value = scene;
    if (timeOfDay != null) selectedTime.value = timeOfDay;
    if (season != null) selectedSeason.value = season;
    if (note != null) selectedNote.value = note;
  }

  bool get isValidForm {
    return selectedPerfume.value != null &&
        (selectedPerfume.value!.name.trim().isNotEmpty) &&
        (selectedPerfume.value!.brand.trim().isNotEmpty) &&
        selectedTime.value != null;
  }

  int get cost => 0;

  Future<bool> canSaveRecord() async {
    return true;
  }

  Future<bool> saveRecord() async {
    if (!isValidForm) {
      Get.snackbar(
        'Error',
        'Please complete all required fields',
        backgroundColor: AppColors.error,
        colorText: AppColors.textInverse,
      );
      return false;
    }

    try {
      isSaving.value = true;

      // Create record
      final record = PerfumeRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        perfumeName: selectedPerfume.value!.name,
        brand: selectedPerfume.value!.brand,
        imageUrl: selectedPerfume.value!.imageUrl,
        noteType: selectedNote.value ?? PerfumeNote.floral,
        scene: selectedScene.value ?? UsageScene.casual,
        timeOfDay: selectedTime.value!,
        season: selectedSeason.value ?? Season.spring,
        longevity: 6,
        moodRating: moodRating.value,
        notes: notes.value.isEmpty ? null : notes.value,
        outfit: null,
        weather: null,
        createdAt: DateTime.now(),
        compliments: null,
      );

      await _storage.saveRecord(record);
      _mainController.notifyDataChanged();

      Get.back(result: true);
      Get.snackbar(
        'Success',
        'Entry saved to your diary.',
        backgroundColor: AppColors.success,
        colorText: AppColors.textInverse,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save record',
        backgroundColor: AppColors.error,
        colorText: AppColors.textInverse,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  void clearForm() {
    selectedPerfume.value = null;
    perfumeNameController.clear();
    brandController.clear();
    _initializeDefaults();
    longevity.value = 6;
    moodRating.value = 3;
    notes.value = '';
    outfit.value = '';
    weather.value = '';
    compliments.value = 0;
  }

  @override
  void onClose() {
    perfumeNameController.dispose();
    brandController.dispose();
    super.onClose();
  }
}
