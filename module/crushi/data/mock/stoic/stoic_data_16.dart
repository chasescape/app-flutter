import '../../../../gen_a/A.dart';
import '../../models/stoic_card.dart';

final stoic_data_16 = StoicCard(
  assetImg: A.assets_crushi_16,
  sceneCard: const SceneCard(
    setting: TaggedField(value: 'Nature', confidence: 1.0,
      detail: 'dense forest trail with ferns and tall pine trees',
    ),
    timeOfDay: TaggedField(value: 'Morning', confidence: 0.9,
      detail: 'soft, diffused light and mist clinging to the trees',
    ),
    visualMood: TaggedField(value: 'Contemplative', confidence: 0.8,
      detail: 'solitary runner moving through a quiet, misty environment',
    ),
    stoicVirtue: TaggedField(value: 'Temperance', confidence: 0.9,
      detail: 'the disciplined, rhythmic movement of the body amidst the stillness of nature reflects self-mastery.',
    ),
    humanPresence: TaggedField(value: 'Alone', confidence: 1.0,
      detail: 'a single person running on a path',
    ),
    natureRatio: TaggedField(value: 'Dominant', confidence: 1.0,
      detail: 'trees and greenery occupy nearly the entire frame',
    ),
    keyObjects: ["running gear", "trail path", "tall pines", "ferns"],
    dominantColors: ["green", "brown", "grey"],
    lightQuality: 'soft diffused morning light',
  ),
  oneLineCapture: 'In the rhythm of the stride, the mind finds its center amidst the quiet endurance of the woods.',
  tags: const ["solitude", "discipline", "endurance", "nature", "focus"],
  safety: const SafetyInfo(hasSensitiveContent: false
  ),
);
