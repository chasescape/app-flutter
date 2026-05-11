import 'package:get/get.dart';
import '../models/result_card.dart';
import '../services/storage_service.dart';
import '../services/coins_manager.dart';
import '../services/encouragement_service.dart';
import '../services/tool_charge_service.dart';
import '../controllers/main_controller.dart';

class ResultController extends GetxController {
  final StorageService _storage = StorageService.to;
  final CoinsManager _coinsManager = CoinsManager.instance;
  final EncouragementService _aiService = EncouragementService.instance;
  final ToolChargeService _chargeService = ToolChargeService.instance;

  final RxList<ResultCard> resultCards = <ResultCard>[].obs;
  final RxBool isGenerating = false.obs;
  final RxString generatingStatus = ''.obs;
  final RxString selectedTemplate = 'simple'.obs;
  final Rx<ResultCard?> currentCard = Rx<ResultCard?>(null);

  final List<String> templates = ['simple', 'vibrant', 'warm'];

  @override
  void onInit() {
    super.onInit();
    _loadResultCards();
  }

  void _loadResultCards() {
    resultCards.value = _storage.getResultCards();
    if (resultCards.isNotEmpty) {
      currentCard.value = resultCards.first;
    }
  }

  Future<bool> generateResultCard() async {
    final mainController = Get.find<MainController>();

    final canUseFree = _coinsManager.freeResults > 0;
    final canUseCoins = _chargeService.hasEnoughCoins();

    if (!canUseFree && !canUseCoins) {
      _chargeService.showInsufficientCoinsDialog(
        customMessage: 'You need ${ToolChargeService.defaultToolCost} coins to generate an achievement card.',
      );
      return false;
    }

    isGenerating.value = true;
    generatingStatus.value = 'Preparing...';

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      generatingStatus.value = 'Generating encouragement...';

      final totalAmount = mainController.todayAmount.value;
      final dailyGoal = mainController.settings.value.dailyGoal;
      final progress = mainController.getProgress();
      final streak = mainController.getStreak();

      final encouragement = await _aiService.generateEncouragementWithRetry(
        totalAmount: totalAmount,
        dailyGoal: dailyGoal,
        progress: progress,
        streak: streak,
      );

      generatingStatus.value = 'Finalizing...';
      await Future.delayed(const Duration(milliseconds: 300));

      final card = ResultCard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        totalAmount: totalAmount,
        dailyGoal: dailyGoal,
        progress: progress,
        streak: streak,
        aiEncouragement: encouragement,
        template: selectedTemplate.value,
      );

      if (canUseFree) {
        final freeResultUsed = await _coinsManager.useFreeResult();
        if (!freeResultUsed) {
          throw Exception('Failed to use free result');
        }
      } else {
        final charged = await _chargeService.chargeForTool(
          onInsufficientCoins: () {
            _chargeService.showInsufficientCoinsDialog();
          },
        );
        if (!charged) {
          throw Exception('Failed to charge coins');
        }
      }

      await _storage.addResultCard(card);
      resultCards.insert(0, card);
      currentCard.value = card;

      isGenerating.value = false;
      generatingStatus.value = '';

      return true;
    } catch (e) {
      isGenerating.value = false;
      generatingStatus.value = '';

      Get.snackbar(
        'Generation Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.9),
        colorText: Get.theme.colorScheme.onError,
      );

      return false;
    }
  }

  void selectTemplate(String template) {
    selectedTemplate.value = template;
  }

  void cancelGeneration() {
    isGenerating.value = false;
    generatingStatus.value = '';
  }

  Future<void> deleteResultCard(String id) async {
    await _storage.deleteResultCard(id);
    resultCards.removeWhere((c) => c.id == id);
    if (currentCard.value?.id == id && resultCards.isNotEmpty) {
      currentCard.value = resultCards.first;
    }
  }
}
