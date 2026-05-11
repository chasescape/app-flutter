import 'package:flira/flira/app/modules/nav/flira_state.dart';
import 'package:get/get.dart';

class DetailLogic extends GetxController {
  final String entryId = (Get.arguments ?? '').toString();

  DiaryEntry? get entry {
    for (final item in FliraState.entries) {
      if (item.id == entryId) return item;
    }
    return null;
  }
}
