import 'package:get/get.dart';
import '../data/models/compose_scene.dart';

class ComposeDetailController extends GetxController {
  late final ComposeScene scene;
  final RxInt selectedOldImageIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is ComposeScene) {
      scene = Get.arguments as ComposeScene;
    } else {
      throw Exception('No scene data passed');
    }
  }

  void selectOldImage(int index) {
    selectedOldImageIndex.value = index;
  }
}
