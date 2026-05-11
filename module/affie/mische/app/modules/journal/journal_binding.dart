import 'package:get/get.dart';

import '../../services/ai_client.dart';
import '../../services/ai_service.dart';
import '../emotion/emotion_logic.dart';
import 'journal_logic.dart';

class JournalBinding extends Bindings {
  @override
  void dependencies() {
    final emotionLogic = Get.find<EmotionLogic>();
    AiService? aiService;
    if (AiClient.hasApiKey()) {
      if (!Get.isRegistered<AiService>()) {
        Get.put(AiService(AiClient.create()), permanent: true);
      }
      aiService = Get.find<AiService>();
    }
    Get.lazyPut(() => JournalLogic(
          emotionLogic: emotionLogic,
          aiService: aiService,
        ));
  }
}
