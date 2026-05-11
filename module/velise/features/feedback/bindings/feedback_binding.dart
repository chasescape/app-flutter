import 'package:get/get.dart';
import '../controllers/feedback_controller.dart';

/// Feedback Binding
/// Dependency injection for feedback feature
class FeedbackBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FeedbackController>(() => FeedbackController());
  }
}
