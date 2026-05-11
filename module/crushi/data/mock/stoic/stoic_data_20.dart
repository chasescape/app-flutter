import '../../../../gen_a/A.dart';
import '../../models/stoic_card.dart';

final stoic_data_20 = StoicCard(
  assetImg: A.assets_crushi_20,
  sceneCard: const SceneCard(
    setting: TaggedField(value: 'Home', confidence: 0.95,
      detail: 'a personal desk space with a steaming cup and open notebook',
    ),
    timeOfDay: TaggedField(value: 'Morning', confidence: 0.9,
      detail: 'soft, low-angle light casting long shadows through blinds',
    ),
    visualMood: TaggedField(value: 'Contemplative', confidence: 0.85,
      detail: 'the quiet arrangement of a book, pen, and steam rising from coffee',
    ),
    stoicVirtue: TaggedField(value: 'Temperance', confidence: 0.9,
      detail: 'the deliberate, orderly arrangement of tools for work and reflection suggests self-regulation',
    ),
    humanPresence: TaggedField(value: 'Alone', confidence: 0.95,
      detail: 'a solitary workspace setup without other people present',
    ),
    natureRatio: TaggedField(value: 'Minimal', confidence: 0.9,
      detail: 'a single small potted plant on the desk',
    ),
    keyObjects: ["steaming coffee cup", "open notebook", "pen", "desk lamp", "potted plant"],
    dominantColors: ["warm brown", "cream", "charcoal", "soft green"],
    lightQuality: 'soft, diffused morning light filtered through blinds',
  ),
  oneLineCapture: 'In the quiet stillness of the morning, the tools of one\'s purpose await the hand of the disciplined mind.',
  tags: const ["Focus", "Morning", "Order", "Intentionality", "Study", "Solitude"],
  safety: const SafetyInfo(hasSensitiveContent: false
  ),
);
