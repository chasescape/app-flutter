import '../../../../gen_a/A.dart';
import '../../models/stoic_card.dart';

final stoic_data_18 = StoicCard(
  assetImg: A.assets_crushi_18,
  sceneCard: const SceneCard(
    setting: TaggedField(value: 'Library', confidence: 0.95,
      detail: 'extensive bookshelves filled with volumes in the background',
    ),
    timeOfDay: TaggedField(value: 'Night', confidence: 0.9,
      detail: 'dark window view with reflection and warm artificial lamp light',
    ),
    visualMood: TaggedField(value: 'Contemplative', confidence: 0.95,
      detail: 'open book, reading glasses, and quiet, isolated workspace',
    ),
    stoicVirtue: TaggedField(value: 'Wisdom', confidence: 0.9,
      detail: 'the act of reading and study in a quiet space exemplifies the pursuit of knowledge and reasoned thought',
    ),
    humanPresence: TaggedField(value: 'No People', confidence: 0.95,
      detail: 'empty chair and desk setup with no individuals present',
    ),
    natureRatio: TaggedField(value: 'None', confidence: 0.95,
      detail: 'indoor study environment with no plants or natural elements visible',
    ),
    keyObjects: ["open book", "reading glasses", "desk lamp", "coffee cup", "inkwell"],
    dominantColors: ["brown", "warm yellow", "black"],
    lightQuality: 'warm, focused lamp light against a dark, moody background',
  ),
  oneLineCapture: 'In the silence of the night, the mind finds its true work among the wisdom of the ages.',
  tags: const ["study", "silence", "books", "contemplation", "night", "focus"],
  safety: const SafetyInfo(hasSensitiveContent: false
  ),
);
