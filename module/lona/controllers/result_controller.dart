import 'package:get/get.dart';
import '../data/models/composition_result.dart';

class ResultController extends GetxController {
  late final CompositionResult result;
  final RxBool showGuide = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is CompositionResult) {
      result = Get.arguments as CompositionResult;
    } else {
      throw Exception('No result data passed');
    }
  }

  void toggleView() {
    showGuide.value = !showGuide.value;
  }

  void reanalyze() {
    Get.back();
  }
}
