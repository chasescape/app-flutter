import '../../../../gen_a/A.dart';
import '../../models/stoic_card.dart';

final stoic_data_1 = StoicCard(
  assetImg: A.assets_crushi_1,
  sceneCard: const SceneCard(
    setting: TaggedField(value: 'Nature', confidence: 0.9,
      detail: 'Ancient stone ruins situated in an open, outdoor landscape.',
    ),
    timeOfDay: TaggedField(value: 'Golden Hour', confidence: 0.95,
      detail: 'Warm, low-angle sunlight casting long shadows and highlighting the stone texture.',
    ),
    visualMood: TaggedField(value: 'Contemplative', confidence: 0.85,
      detail: 'The quiet grandeur of ancient columns evokes reflection on the passage of time.',
    ),
    stoicVirtue: TaggedField(value: 'Wisdom', confidence: 0.9,
      detail: 'The ruins represent the endurance of truth and reason amidst the inevitable decay of human structures.',
    ),
    humanPresence: TaggedField(value: 'No People', confidence: 1.0,
      detail: 'The frame contains only architectural elements and landscape.',
    ),
    natureRatio: TaggedField(value: 'Balanced', confidence: 0.8,
      detail: 'A harmony between the crafted stone columns and the open, natural sky.',
    ),
    keyObjects: ["Doric columns", "Stone entablature", "Rocky ground"],
    dominantColors: ["Golden yellow", "Sky blue", "Warm grey"],
    lightQuality: 'Warm, directional golden hour sunlight',
  ),
  oneLineCapture: 'What remains of these stones is not ruin, but a testament to the endurance of the principles they once housed.',
  tags: const ["Ancient", "Ruins", "Endurance", "History", "GoldenHour", "Stones"],
  safety: const SafetyInfo(hasSensitiveContent: false
  ),
);
