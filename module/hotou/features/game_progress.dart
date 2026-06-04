import 'package:flutter/foundation.dart';

class GameProgress {
  GameProgress._();

  static final ValueNotifier<int> highestLevel = ValueNotifier<int>(1);

  static void syncLevel(int level) {
    if (level > highestLevel.value) {
      highestLevel.value = level;
    }
  }
}
