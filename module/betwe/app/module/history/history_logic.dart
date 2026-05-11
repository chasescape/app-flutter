import 'package:get/get.dart';

import '../../service/ai_service.dart';
import '../../service/history_service.dart';

class HistoryRecord {
  const HistoryRecord({required this.result, required this.imagePath});

  final AiResult result;
  final String imagePath;
}

class HistoryLogic extends GetxController {
  final RxList<HistoryRecord> records = <HistoryRecord>[].obs;

  @override
  void onInit() {
    _load();
    super.onInit();
  }

  Future<void> _load() async {
    final list = await HistoryService.load();
    records.assignAll(list.map((e) => HistoryRecord(result: e.result, imagePath: e.imagePath)));
  }

  Future<void> addRecord(AiResult result, String imagePath) async {
    records.insert(0, HistoryRecord(result: result, imagePath: imagePath));
    final entries = records
        .map((r) => HistoryEntry(result: r.result, imagePath: r.imagePath))
        .toList();
    await HistoryService.save(entries);
  }
}
