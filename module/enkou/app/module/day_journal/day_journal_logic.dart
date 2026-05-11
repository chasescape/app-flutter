import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:enkou/enkou/app/data/journal_store.dart';
import 'package:enkou/enkou/app/module/nav/nav_logic.dart';
import 'package:enkou/enkou/app/routes/app_routes.dart';

class DayJournalLogic extends GetxController {
  late final DateTime date;
  late final String locationTag;
  late final JournalStore journalStore;
  final RxnString entryId = RxnString();

  final textCtrl = TextEditingController();
  final RxList<JournalMediaItem> medias = <JournalMediaItem>[].obs;
  final RxList<String> tags = <String>[].obs;
  final ImagePicker _picker = ImagePicker();
  Timer? _textDebounce;
  bool _exiting = false;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final DateTime? argDate = args['date'] as DateTime?;
    date = argDate ?? DateTime.now();
    locationTag = args['locationTag'] as String? ?? '';
    final String? argEntryId = args['entryId'] as String?;
    final bool createNew = args['createNew'] as bool? ?? false;

    journalStore = Get.isRegistered<JournalStore>()
        ? Get.find<JournalStore>()
        : Get.put(JournalStore(), permanent: true);

    if (argEntryId != null) {
      final existed = journalStore.entryById(argEntryId);
      if (existed != null) {
        entryId.value = existed.id;
        textCtrl.text = existed.text;
        medias.assignAll(existed.medias);
        tags.assignAll(existed.tags);
      }
      return;
    }

    if (!createNew) {
      final existed = journalStore.entryForDate(date);
      if (existed != null) {
        entryId.value = existed.id;
        textCtrl.text = existed.text;
        medias.assignAll(existed.medias);
        tags.assignAll(existed.tags);
      }
    }

    textCtrl.addListener(() {
      _textDebounce?.cancel();
      _textDebounce = Timer(const Duration(milliseconds: 600), _persistEntry);
    });
  }

  @override
  void onClose() {
    _textDebounce?.cancel();
    textCtrl.dispose();
    super.onClose();
  }

  bool _hasMeaningfulContent() {
    return textCtrl.text.trim().isNotEmpty ||
        medias.isNotEmpty ||
        tags.isNotEmpty;
  }

  void _persistEntry() {
    // 避免自动保存生成“空记录”
    if (!_hasMeaningfulContent()) return;

    entryId.value ??=
        'journal_${journalStore.normalize(date).millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}';

    journalStore.upsertEntry(
      entryId: entryId.value,
      date: date,
      text: textCtrl.text.trim(),
      medias: medias.toList(),
      tags: tags.toList(),
      locationTag: locationTag,
    );
  }

  void startNewRecord() {
    entryId.value = null;
    textCtrl.clear();
    medias.clear();
    tags.clear();
  }

  void switchToRecord(String id) {
    final e = journalStore.entryById(id);
    if (e == null) return;
    entryId.value = e.id;
    textCtrl.text = e.text;
    medias.assignAll(e.medias);
    tags.assignAll(e.tags);
  }

  Future<void> addImageFromGallery() async {
    if (!await _ensurePhotoPermission()) return;
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      imageQuality: 90,
    );
    if (file == null) return;

    medias.add(
      JournalMediaItem(
        id: 'img_${DateTime.now().microsecondsSinceEpoch}',
        type: 'image',
        source: file.path,
        label: 'Photo',
      ),
    );
    _persistEntry();
  }

  Future<bool> _ensurePhotoPermission() async {
    final PermissionStatus status = await Permission.photos.status;
    if (status.isGranted || status.isLimited) return true;

    final PermissionStatus requested = await Permission.photos.request();
    if (requested.isGranted || requested.isLimited) return true;

    Get.snackbar(
      'Photos permission',
      'Please allow photo access in Settings to select images.',
      snackPosition: SnackPosition.BOTTOM,
    );
    return false;
  }

  Future<void> addVideoByInput() async {
    final ctrl = TextEditingController();
    final result = await Get.dialog<String>(
      AlertDialog(
        title: const Text('Add video'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            hintText: 'Paste video URL or name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Get.back(result: ctrl.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (result == null || result.isEmpty) return;

    medias.add(
      JournalMediaItem(
        id: 'vid_${DateTime.now().microsecondsSinceEpoch}',
        type: 'video',
        source: result,
        label: 'Video upload',
      ),
    );
    _persistEntry();
  }

  void removeMedia(String id) {
    medias.removeWhere((m) => m.id == id);
    _persistEntry();
  }

  void toggleTag(String tag) {
    if (tags.contains(tag)) {
      tags.remove(tag);
    } else {
      tags.add(tag);
    }
    _persistEntry();
  }

  void saveJournal() {
    exitToHome();
  }

  void exitToHome() {
    if (_exiting) return;
    _exiting = true;
    _persistEntry();

    if (Get.isRegistered<NavLogic>()) {
      Get.find<NavLogic>().changeTab(0);
    }
    Get.offAllNamed(AppRoutes.nav);
  }
}
