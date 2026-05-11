import '../../../../gen_a/A.dart';
import '../../models/stoic_card.dart';

final stoic_data_10 = StoicCard(
  assetImg: A.assets_crushi_10,
  sceneCard: const SceneCard(
    setting: TaggedField(value: 'Street', confidence: 1.0,
      detail: 'Cobblestone path between historic buildings with street lamps.',
    ),
    timeOfDay: TaggedField(value: 'Evening', confidence: 0.9,
      detail: 'Dim ambient light, glowing warm shop windows, and dusk-toned sky.',
    ),
    visualMood: TaggedField(value: 'Contemplative', confidence: 0.8,
      detail: 'Solitary figure in rain, quiet atmosphere, reflective surfaces.',
    ),
    stoicVirtue: TaggedField(value: 'Temperance', confidence: 0.7,
      detail: 'The figure moves steadily through the rain, undisturbed by the external discomfort—a display of moderation and self-control.',
    ),
    humanPresence: TaggedField(value: 'Alone', confidence: 0.9,
      detail: 'Single person walking with an umbrella as the primary subject.',
    ),
    natureRatio: TaggedField(value: 'Minimal', confidence: 0.9,
      detail: 'Rain is the only natural element; the rest is stone and architecture.',
    ),
    keyObjects: ["umbrella", "cobblestone path", "trench coat", "glowing windows"],
    dominantColors: ["slate blue", "charcoal", "warm amber"],
    lightQuality: 'diffused cool twilight with warm artificial accents',
  ),
  oneLineCapture: 'The rain falls as it must, and the traveler walks as he chooses, indifferent to the storm.',
  tags: const ["solitude", "rain", "stoic", "persistence", "urban", "nightfall"],
  safety: const SafetyInfo(hasSensitiveContent: false
  ),
);
