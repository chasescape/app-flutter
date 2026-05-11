import '../../../../gen_a/A.dart';
import '../../models/stoic_card.dart';

final stoic_data_9 = StoicCard(
  assetImg: A.assets_crushi_9,
  sceneCard: const SceneCard(
    setting: TaggedField(value: 'Street', confidence: 1.0,
      detail: 'urban buildings, wet asphalt, street signs and storefronts',
    ),
    timeOfDay: TaggedField(value: 'Evening', confidence: 0.9,
      detail: 'glowing neon signs, deep shadows, dark sky',
    ),
    visualMood: TaggedField(value: 'Contemplative', confidence: 0.8,
      detail: 'solitary figure walking under an umbrella in the rain',
    ),
    stoicVirtue: TaggedField(value: 'Wisdom', confidence: 0.8,
      detail: 'navigating the chaotic, rain-slicked city with composure and singular focus reflects clarity of mind.',
    ),
    humanPresence: TaggedField(value: 'Alone', confidence: 1.0,
      detail: 'a single silhouette walking away from the camera',
    ),
    natureRatio: TaggedField(value: 'Minimal', confidence: 0.9,
      detail: 'rain is the only natural element in a concrete environment',
    ),
    keyObjects: ["umbrella", "wet pavement", "neon signs", "silhouette"],
    dominantColors: ["deep blue", "vibrant orange", "black"],
    lightQuality: 'dramatic high-contrast neon reflections on wet surfaces',
  ),
  oneLineCapture: 'The city roars with light and rain, yet the solitary walker remains untouched by the external storm.',
  tags: const ["solitude", "urban", "focus", "composure", "reflection", "evening"],
  safety: const SafetyInfo(hasSensitiveContent: false
  ),
);
