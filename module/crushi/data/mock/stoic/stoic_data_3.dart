import '../../../../gen_a/A.dart';
import '../../models/stoic_card.dart';

final stoic_data_3 = StoicCard(
  assetImg: A.assets_crushi_3,
  sceneCard: const SceneCard(
    setting: TaggedField(value: 'Library', confidence: 1.0,
      detail: 'rows of floor-to-ceiling wooden bookshelves filled with books',
    ),
    timeOfDay: TaggedField(value: 'Afternoon', confidence: 0.8,
      detail: 'golden light streaming through stained glass windows',
    ),
    visualMood: TaggedField(value: 'Contemplative', confidence: 0.9,
      detail: 'quiet, studious atmosphere with a solitary figure reading',
    ),
    stoicVirtue: TaggedField(value: 'Wisdom', confidence: 0.9,
      detail: 'the pursuit of knowledge and quiet reflection in a space dedicated to human thought represents the cultivation of Wisdom.',
    ),
    humanPresence: TaggedField(value: 'Alone', confidence: 1.0,
      detail: 'a single person standing between the shelves',
    ),
    natureRatio: TaggedField(value: 'None', confidence: 1.0,
      detail: 'an entirely indoor, architectural environment',
    ),
    keyObjects: ["bookshelves", "books", "stained glass window", "reading figure"],
    dominantColors: ["warm brown", "golden", "deep shadow"],
    lightQuality: 'soft, warm natural light filtering through high windows',
  ),
  oneLineCapture: 'In the silent company of the past, the mind finds the space to discern what is truly essential.',
  tags: const ["wisdom", "solitude", "contemplation", "study", "tranquility"],
  safety: const SafetyInfo(hasSensitiveContent: false
  ),
);
