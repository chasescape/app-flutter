import 'package:get/get.dart';
import 'package:vesper/vesper/app/data/cheer_history_store.dart';

class DetailsLogic extends GetxController {
  CheerHistoryItem? item;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is CheerHistoryItem) {
      item = args;
    }
  }
}
