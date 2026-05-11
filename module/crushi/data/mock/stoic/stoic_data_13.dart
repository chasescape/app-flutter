import '../../../../gen_a/A.dart';
import '../../models/stoic_card.dart';

final stoic_data_13 = StoicCard(
  assetImg: A.assets_crushi_13,
  sceneCard: const SceneCard(
    setting: TaggedField(value: 'Office', confidence: 0.95,
      detail: 'desk, papers, keyboard, lamp, notebook',
    ),
    timeOfDay: TaggedField(value: 'Morning', confidence: 0.85,
      detail: 'soft, clear light consistent with early work hours',
    ),
    visualMood: TaggedField(value: 'Contemplative', confidence: 0.8,
      detail: 'contrast between chaotic paperwork and organized, clean space',
    ),
    stoicVirtue: TaggedField(value: 'Temperance', confidence: 0.9,
      detail: 'the juxtaposition of clutter and order highlights the need for moderation and focus',
    ),
    humanPresence: TaggedField(value: 'No People', confidence: 1.0,
      detail: 'no visible persons in the frame',
    ),
    natureRatio: TaggedField(value: 'Minimal', confidence: 0.9,
      detail: 'a single potted plant in the clean half of the frame',
    ),
    keyObjects: ["desk lamp", "potted plant", "notebook", "coffee cup", "stacked papers"],
    dominantColors: ["white", "black", "teal", "warm beige"],
    lightQuality: 'soft, natural daylight',
  ),
  oneLineCapture: 'Distinguish between the noise of your tasks and the clarity of your purpose.',
  tags: const ["focus", "order", "clarity", "work", "discipline"],
  safety: const SafetyInfo(hasSensitiveContent: false
  ),
);
