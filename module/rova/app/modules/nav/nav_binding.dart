import 'package:get/get.dart';
import 'package:rova/rova/app/services/openai_image_service.dart';
import '../generate/generate_logic.dart';
import '../home/home_logic.dart';
import '../profile/profile_logic.dart';
import 'nav_logic.dart';

class NavBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NavLogic());
    Get.lazyPut(() => HomeLogic());
    Get.lazyPut(() => GenerateLogic());
    Get.lazyPut(() => ProfileLogic());
    Get.lazyPut(() => OpenAIImageService(), fenix: true);
  }
}
