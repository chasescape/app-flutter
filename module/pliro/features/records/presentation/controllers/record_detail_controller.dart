import 'package:get/get.dart';
import 'package:pliro/pliro/core/storage/storage_service.dart';
import 'package:pliro/pliro/features/records/domain/models/bead_record.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

/// Record detail controller
class RecordDetailController extends GetxController {
  final StorageService _storage = StorageService.instance;

  bool isLoading = true;
  BeadRecord? record;

  @override
  void onInit() {
    super.onInit();
    _loadRecord();
  }

  Future<void> _loadRecord() async {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final recordId = args['recordId'] as String? ?? '';

    if (recordId.isEmpty) {
      Get.back();
      return;
    }

    final records = await _storage.getRecords();
    record = records.firstWhereOrNull((r) => r.id == recordId);

    isLoading = false;
    update();
  }

  Future<void> onDeleteRecord() async {
    if (record == null) return;

    AwesomeDialog(
      context: Get.overlayContext!,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: 'Delete Record',
      desc: 'This action cannot be undone. Are you sure you want to delete this record?',
      btnCancelText: 'Cancel',
      btnOkText: 'Delete',
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        await _storage.deleteRecord(record!.id);
        Get.back();
      },
    ).show();
  }
}
