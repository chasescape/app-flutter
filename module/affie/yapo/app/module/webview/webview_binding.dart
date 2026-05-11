import 'package:get/get.dart';
import 'webview_logic.dart';

class WebViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WebViewLogic());
  }
}
