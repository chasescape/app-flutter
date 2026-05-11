import '../../../../gen_a/A.dart';
import '../../models/stoic_card.dart';

final stoic_data_8 = StoicCard(
  assetImg: A.assets_crushi_8,
  sceneCard: const SceneCard(
    setting: TaggedField(value: 'Nature', confidence: 1.0,
      detail: 'High-altitude mountain peaks above a sea of clouds at sunrise.',
    ),
    timeOfDay: TaggedField(value: 'Golden Hour', confidence: 1.0,
      detail: 'The sun is low on the horizon, casting warm, golden light across the peaks.',
    ),
    visualMood: TaggedField(value: 'Serene', confidence: 0.9,
      detail: 'The vast, quiet expanse of the mountains and the stillness of the clouds evoke a sense of calm.',
    ),
    stoicVirtue: TaggedField(value: 'Temperance', confidence: 0.8,
      detail: 'The ascetic nature of climbing to such heights with only essential gear reflects the discipline of limiting desires.',
    ),
    humanPresence: TaggedField(value: 'Alone', confidence: 0.9,
      detail: 'A single person resting with their gear, no other people visible.',
    ),
    natureRatio: TaggedField(value: 'Dominant', confidence: 1.0,
      detail: 'The immense mountain range and cloud blanket dwarf the small amount of human equipment.',
    ),
    keyObjects: ["hiking backpack", "trekking poles", "hiking boots", "rocky terrain"],
    dominantColors: ["orange", "grey", "white", "gold"],
    lightQuality: 'warm, directional golden hour sunlight',
  ),
  oneLineCapture: 'Above the shifting clouds, the climber finds the stillness of the soul reflected in the permanence of the peaks.',
  tags: const ["mountain", "solitude", "summit", "sunrise", "ascent", "nature"],
  safety: const SafetyInfo(hasSensitiveContent: false
  ),
);
