import '../../../../gen_a/A.dart';
import '../../models/stoic_card.dart';

final stoic_data_2 = StoicCard(
  assetImg: A.assets_crushi_2,
  sceneCard: const SceneCard(
    setting: TaggedField(value: 'Nature', confidence: 1.0,
      detail: 'sandy beach shoreline at sunset',
    ),
    timeOfDay: TaggedField(value: 'Golden Hour', confidence: 1.0,
      detail: 'warm sunset hues reflecting on water and wet sand',
    ),
    visualMood: TaggedField(value: 'Serene', confidence: 0.9,
      detail: 'calm waves and vast horizon',
    ),
    stoicVirtue: TaggedField(value: 'Temperance', confidence: 0.8,
      detail: 'the quiet rhythm of the tides and the fading light represent nature\'s natural boundaries and cycles.',
    ),
    humanPresence: TaggedField(value: 'No People', confidence: 1.0,
      detail: 'empty beach with only footprints',
    ),
    natureRatio: TaggedField(value: 'Dominant', confidence: 1.0,
      detail: 'landscape is entirely organic elements',
    ),
    keyObjects: ["footprints", "tide", "horizon"],
    dominantColors: ["gold", "soft blue", "amber"],
    lightQuality: 'warm, diffused sunset glow',
  ),
  oneLineCapture: 'The tide erases the footprints, reminding us that even our most deliberate marks are but temporary guests of the shore.',
  tags: const ["nature", "solitude", "impermanence", "sunset", "reflection"],
  safety: const SafetyInfo(hasSensitiveContent: false
  ),
);
