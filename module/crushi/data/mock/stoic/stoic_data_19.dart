import '../../../../gen_a/A.dart';
import '../../models/stoic_card.dart';

final stoic_data_19 = StoicCard(
  assetImg: A.assets_crushi_19,
  sceneCard: const SceneCard(
    setting: TaggedField(value: 'Nature', confidence: 1.0,
      detail: 'ocean shoreline at dusk',
    ),
    timeOfDay: TaggedField(value: 'Golden Hour', confidence: 0.95,
      detail: 'vibrant orange and purple sunset sky',
    ),
    visualMood: TaggedField(value: 'Contemplative', confidence: 0.9,
      detail: 'solitary figure standing still against a vast horizon',
    ),
    stoicVirtue: TaggedField(value: 'Wisdom', confidence: 0.85,
      detail: 'the stillness of the figure amidst the moving tides reflects an understanding of the nature of change.',
    ),
    humanPresence: TaggedField(value: 'Alone', confidence: 1.0,
      detail: 'single silhouette standing in the surf',
    ),
    natureRatio: TaggedField(value: 'Dominant', confidence: 0.95,
      detail: 'vast sky and ocean dwarfing the human figure',
    ),
    keyObjects: ["silhouette", "tide", "horizon"],
    dominantColors: ["orange", "purple", "deep blue"],
    lightQuality: 'warm, fading sunset glow',
  ),
  oneLineCapture: 'A single point of stillness witnessing the eternal, rhythmic pulse of the world.',
  tags: const ["solitude", "sunset", "reflection", "nature", "stillness"],
  safety: const SafetyInfo(hasSensitiveContent: false
  ),
);
