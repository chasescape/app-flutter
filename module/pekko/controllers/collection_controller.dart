import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../data/models/perfume.dart';
import '../data/models/perfume_record.dart';
import '../data/services/storage_service.dart';
import '../core/theme/app_colors.dart';
import 'main_controller.dart';

/// Collection controller for managing the user's owned perfumes.
class CollectionController extends GetxController {
  final StorageService _storage = StorageService.to;
  final MainController _mainController = Get.find<MainController>();

  final RxList<Perfume> perfumes = <Perfume>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final Rx<PerfumeNote> selectedNote = PerfumeNote.floral.obs;
  final RxnString selectedImagePath = RxnString();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    loadPerfumes();
  }

  Future<void> loadPerfumes() async {
    try {
      isLoading.value = true;
      perfumes.value = await _storage.getPerfumes();
    } finally {
      isLoading.value = false;
    }
  }

  List<Perfume> get filteredPerfumes {
    if (searchQuery.value.trim().isEmpty) return perfumes;
    final query = searchQuery.value.toLowerCase();
    return perfumes.where((perfume) {
      return perfume.name.toLowerCase().contains(query) ||
          perfume.brand.toLowerCase().contains(query) ||
          (perfume.description?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
  }

  int get totalPerfumes => perfumes.length;

  int countByNote(PerfumeNote note) {
    return perfumes.where((perfume) => perfume.primaryNote == note).length;
  }

  Future<void> pickCollectionImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 88,
      );

      if (pickedFile == null) return;

      selectedImagePath.value = pickedFile.path;
    } catch (e) {
      Get.snackbar(
        'Unable to Pick Image',
        'Please try again and allow photo access if needed.',
        backgroundColor: AppColors.error,
        colorText: AppColors.textInverse,
      );
    }
  }

  Future<void> savePerfumeFromForm() async {
    final name = nameController.text.trim();
    final brand = brandController.text.trim();

    if (name.isEmpty || brand.isEmpty) {
      Get.snackbar(
        'Missing Details',
        'Please enter both a fragrance name and brand.',
        backgroundColor: AppColors.warning,
        colorText: AppColors.textInverse,
      );
      return;
    }

    final perfume = Perfume(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      brand: brand,
      imageUrl: await _persistSelectedImage(name, brand),
      primaryNote: selectedNote.value,
      notes: [selectedNote.value],
      description: descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
      createdAt: DateTime.now(),
    );

    await _storage.savePerfume(perfume);
    clearForm();
    await loadPerfumes();
    _mainController.notifyDataChanged();
    Get.back();
    Get.snackbar(
      'Saved',
      '$brand $name has been added to your collection.',
      backgroundColor: AppColors.success,
      colorText: AppColors.textInverse,
    );
  }

  Future<void> deletePerfume(String id) async {
    await _storage.deletePerfume(id);
    await loadPerfumes();
    _mainController.notifyDataChanged();
    Get.snackbar(
      'Removed',
      'The fragrance was removed from your collection.',
      backgroundColor: AppColors.textPrimary,
      colorText: AppColors.textInverse,
    );
  }

  void clearForm() {
    nameController.clear();
    brandController.clear();
    descriptionController.clear();
    selectedNote.value = PerfumeNote.floral;
    selectedImagePath.value = null;
  }

  Future<String?> _persistSelectedImage(String name, String brand) async {
    final sourcePath = selectedImagePath.value;
    if (sourcePath == null || sourcePath.isEmpty) return null;

    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) return null;

    final documentsDir = await getApplicationDocumentsDirectory();
    final perfumesDir = Directory('${documentsDir.path}/perfume_images');
    if (!await perfumesDir.exists()) {
      await perfumesDir.create(recursive: true);
    }

    final extension = sourceFile.path.split('.').last;
    final safeName = '${brand}_$name'
        .replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_')
        .toLowerCase();
    final fileName =
        '${safeName}_${DateTime.now().millisecondsSinceEpoch}.$extension';
    final savedFile = await sourceFile.copy('${perfumesDir.path}/$fileName');
    return savedFile.path;
  }

  @override
  void onClose() {
    nameController.dispose();
    brandController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
