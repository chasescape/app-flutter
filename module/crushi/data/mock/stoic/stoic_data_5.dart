import '../../../../gen_a/A.dart';
import '../../models/stoic_card.dart';

final stoic_data_5 = StoicCard(
  assetImg: A.assets_crushi_5,
  sceneCard: const SceneCard(
    setting: TaggedField(value: 'Cafe', confidence: 1.0,
      detail: 'latte art in a ceramic mug on a wooden counter next to a window',
    ),
    timeOfDay: TaggedField(value: 'Afternoon', confidence: 0.8,
      detail: 'soft, diffused daylight typical of a rainy afternoon',
    ),
    visualMood: TaggedField(value: 'Contemplative', confidence: 0.9,
      detail: 'rain-streaked window separating the quiet interior from the busy street',
    ),
    stoicVirtue: TaggedField(value: 'Temperance', confidence: 0.8,
      detail: 'the deliberate choice to pause with a simple coffee amidst the external bustle demonstrates self-regulation',
    ),
    humanPresence: TaggedField(value: 'Alone', confidence: 0.9,
      detail: 'single mug and phone on the counter, focusing on the perspective of the individual',
    ),
    natureRatio: TaggedField(value: 'Minimal', confidence: 0.9,
      detail: 'rain is the only natural element in an urban setting',
    ),
    keyObjects: ["latte mug", "wooden counter", "smartphone", "rain-streaked window"],
    dominantColors: ["brown", "grey", "white"],
    lightQuality: 'soft, diffused, cool daylight',
  ),
  oneLineCapture: 'Observe the storm beyond the glass, yet remain undisturbed within the quiet sanctuary of the present moment.',
  tags: const ["solitude", "rainy-day", "urban", "stillness", "focus", "reflection"],
  safety: const SafetyInfo(hasSensitiveContent: false
  ),
);
