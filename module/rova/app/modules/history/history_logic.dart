import 'dart:io';

import 'package:get/get.dart';
import 'package:rova/rova/app/modules/home/home_logic.dart';

class HistoryLogic extends GetxController {
  List<GeneratedDesignItem> get items => Get.find<HomeLogic>().generatedImages;

  bool isFilePath(String value) {
    final v = value.trim();
    if (v.isEmpty) return false;
    final file = File(v);
    return file.existsSync();
  }
}
