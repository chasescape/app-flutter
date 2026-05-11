import '../../../../gen_a/A.dart';
import '../../models/stoic_card.dart';

final stoic_data_12 = StoicCard(
  assetImg: A.assets_crushi_12,
  sceneCard: const SceneCard(
    setting: TaggedField(value: 'Rooftop', confidence: 1.0,
      detail: 'person standing on a high-rise ledge overlooking a city skyline at dusk',
    ),
    timeOfDay: TaggedField(value: 'Golden Hour', confidence: 0.9,
      detail: 'the vibrant orange and blue gradient of the sky behind the buildings',
    ),
    visualMood: TaggedField(value: 'Contemplative', confidence: 0.9,
      detail: 'a lone figure silhouetted against the vast, bustling urban expanse',
    ),
    stoicVirtue: TaggedField(value: 'Wisdom', confidence: 0.8,
      detail: 'observing the vastness of the city from a distance encourages a broader perspective on one\'s place in the world.',
    ),
    humanPresence: TaggedField(value: 'Alone', confidence: 1.0,
      detail: 'a single individual standing on the rooftop',
    ),
    natureRatio: TaggedField(value: 'Minimal', confidence: 0.9,
      detail: 'the scene is dominated by man-made architecture and urban lights',
    ),
    keyObjects: ["skyscrapers", "rooftop railing", "city lights", "horizon"],
    dominantColors: ["deep blue", "warm orange", "twilight grey"],
    lightQuality: 'fading natural light transitioning into artificial city glow',
  ),
  oneLineCapture: 'From this height, the noise of the world becomes a hum, and the individual concerns of the many fade into the order of the whole.',
  tags: const ["perspective", "solitude", "urban", "contemplation", "vastness"],
  safety: const SafetyInfo(hasSensitiveContent: false
  ),
);
