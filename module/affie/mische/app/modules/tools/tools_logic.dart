import 'package:get/get.dart';

class ToolsLogic extends GetxController {
  final activeTool = RxnString();
  final breathCount = 0.obs;
  final isBreathing = false.obs;
  final meditationTime = 0.obs;
  final isMeditating = false.obs;

  void startBreathing() {
    if (isBreathing.value) return;
    isBreathing.value = true;
    breathCount.value = 0;

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 4));
      if (!isBreathing.value) return false;
      breathCount.value += 1;
      if (breathCount.value >= 10) {
        isBreathing.value = false;
        return false;
      }
      return true;
    });
  }

  void startMeditation(int minutes) {
    if (isMeditating.value) return;
    isMeditating.value = true;
    meditationTime.value = minutes * 60;

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!isMeditating.value) return false;
      meditationTime.value -= 1;
      if (meditationTime.value <= 0) {
        isMeditating.value = false;
        meditationTime.value = 0;
        return false;
      }
      return true;
    });
  }

  String formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }
}
