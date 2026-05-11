import '../../../../gen_a/A.dart';
import '../../models/stoic_card.dart';

final stoic_data_6 = StoicCard(
  assetImg: A.assets_crushi_6,
  sceneCard: const SceneCard(
    setting: TaggedField(value: 'Restaurant', confidence: 0.95,
      detail: 'individual at a table with plated food and wine glasses in a dining environment',
    ),
    timeOfDay: TaggedField(value: 'Evening', confidence: 0.85,
      detail: 'dim interior lighting contrasting with the dark, wet street outside',
    ),
    visualMood: TaggedField(value: 'Contemplative', confidence: 0.9,
      detail: 'subject\'s gaze directed outward away from the meal and surrounding crowd',
    ),
    stoicVirtue: TaggedField(value: 'Temperance', confidence: 0.8,
      detail: 'the balanced plate and measured posture amidst a bustling, crowded environment suggest self-regulation and focus',
    ),
    humanPresence: TaggedField(value: 'Crowd', confidence: 0.9,
      detail: 'blurred figures and tables visible in the background of the dining room',
    ),
    natureRatio: TaggedField(value: 'None', confidence: 0.95,
      detail: 'entirely indoor urban setting with no visible natural elements',
    ),
    keyObjects: ["wine glass", "plate of food", "wristwatch", "window pane"],
    dominantColors: ["olive green", "warm amber", "muted gray"],
    lightQuality: 'warm indoor ambient light contrasting with cool, rainy daylight through the glass',
  ),
  oneLineCapture: 'Amidst the noise of the many, the soul remains a quiet observer of its own surroundings.',
  tags: const ["solitude", "reflection", "urban", "presence", "balance"],
  safety: const SafetyInfo(hasSensitiveContent: false
  ),
);
