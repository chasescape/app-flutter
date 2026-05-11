import '../../../../gen_a/A.dart';
import '../../models/stoic_card.dart';

final stoic_data_14 = StoicCard(
  assetImg: A.assets_crushi_14,
  sceneCard: const SceneCard(
    setting: TaggedField(value: 'Library', confidence: 0.95,
      detail: 'stacks of antique books surrounding an open volume',
    ),
    timeOfDay: TaggedField(value: 'Late Night', confidence: 0.8,
      detail: 'warm, concentrated light source typical of a desk lamp in a dark room',
    ),
    visualMood: TaggedField(value: 'Contemplative', confidence: 0.9,
      detail: 'the quiet focus of an open book amidst surrounding stacks',
    ),
    stoicVirtue: TaggedField(value: 'Wisdom', confidence: 0.95,
      detail: 'the pursuit of knowledge and the discipline of reading are foundational to cultivating a rational mind',
    ),
    humanPresence: TaggedField(value: 'No People', confidence: 0.98,
      detail: 'only books and furniture are visible',
    ),
    natureRatio: TaggedField(value: 'None', confidence: 1.0,
      detail: 'entirely indoor, artificial environment',
    ),
    keyObjects: ["Open book", "Stacked antique books", "Wooden surface"],
    dominantColors: ["Brown", "Cream", "Sepia"],
    lightQuality: 'warm, focused illumination from above',
  ),
  oneLineCapture: 'In the silence of the stacks, the mind finds its true conversation with the past.',
  tags: const ["Study", "Knowledge", "Quiet", "Philosophy", "Focus", "Reflection"],
  safety: const SafetyInfo(hasSensitiveContent: false
  ),
);
