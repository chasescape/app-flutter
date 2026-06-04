import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pliro/pliro/core/storage/storage_service.dart';
import 'package:pliro/pliro/core/theme/app_theme.dart';
import 'package:pliro/pliro/features/badges/presentation/controllers/badges_controller.dart';
import 'package:pliro/pliro/features/home/presentation/controllers/home_controller.dart';
import 'package:pliro/pliro/features/library/presentation/controllers/library_controller.dart';
import 'package:pliro/pliro/features/records/domain/models/bead_record.dart';

/// Record editor controller
class RecordEditorController extends GetxController {
  final StorageService _storage = StorageService.instance;
  final ImagePicker _picker = ImagePicker();

  // Form data
  final titleController = TextEditingController();
  final notesController = TextEditingController();

  File? finishedImage;
  File? patternImage;

  // UI state
  bool isSaving = false;

  bool get canSave =>
      titleController.text.trim().isNotEmpty &&
      (finishedImage != null || patternImage != null);

  @override
  void onInit() {
    super.onInit();
    titleController.addListener(update);
  }

  @override
  void onClose() {
    titleController.dispose();
    notesController.dispose();
    super.onClose();
  }

  void onTitleChanged(String value) {
    update();
  }

  Future<void> pickImage(ImageType type) async {
    final source = await Get.dialog<ImageSource>(
      AlertDialog(
        title: const Text('Add Image'),
        content: const Text('Choose where to add your image from'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: ImageSource.camera),
            child: const Text('Camera'),
          ),
          TextButton(
            onPressed: () => Get.back(result: ImageSource.gallery),
            child: const Text('Photo Library'),
          ),
        ],
      ),
    );

    if (source == null) return;

    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      if (type == ImageType.finished) {
        finishedImage = File(image.path);
      } else {
        patternImage = File(image.path);
      }
      update();
    }
  }

  Future<void> onSave() async {
    if (!canSave || isSaving) return;

    FocusManager.instance.primaryFocus?.unfocus();

    isSaving = true;
    update();

    try {
      // Create record
      final record = BeadRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: titleController.text.trim(),
        theme: BeadTheme.custom,
        status: BeadStatus.finished,
        finishedImagePath: finishedImage?.path,
        patternImagePath: patternImage?.path,
        beadCount: 0,
        mainColors: const [],
        finishedDate: DateTime.now(),
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      );

      // Save to storage
      await _storage.addRecord(record);
      await _refreshRecordSurfaces();

      isSaving = false;
      update();

      // Navigate back before showing feedback so the pop is not consumed by
      // snackbar/overlay state.
      Get.back(result: true);

      Get.snackbar(
        'Record Saved',
        'Your bead work has been added to your archive',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.successGreen.withOpacity(0.9),
        colorText: Colors.white,
      );
    } catch (e) {
      isSaving = false;
      update();

      Get.snackbar(
        'Save Failed',
        'Unable to save your record. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorRed.withOpacity(0.9),
        colorText: Colors.white,
      );
    }
  }

  Future<void> _refreshRecordSurfaces() async {
    final refreshes = <Future<void>>[];

    void addRefresh(Future<void> Function() refresh) {
      refreshes.add(Future<void>.sync(refresh).catchError((_) {}));
    }

    if (Get.isRegistered<HomeController>()) {
      addRefresh(() => Get.find<HomeController>().loadData());
    }
    if (Get.isRegistered<LibraryController>()) {
      addRefresh(() => Get.find<LibraryController>().loadData());
    }
    if (Get.isRegistered<BadgesController>()) {
      addRefresh(() => Get.find<BadgesController>().loadData());
    }

    await Future.wait(refreshes);
  }
}
