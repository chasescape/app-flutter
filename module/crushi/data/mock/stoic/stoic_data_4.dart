import '../../../../gen_a/A.dart';
import '../../models/stoic_card.dart';

final stoic_data_4 = StoicCard(
  assetImg: A.assets_crushi_4,
  sceneCard: const SceneCard(
    setting: TaggedField(value: 'Park', confidence: 0.95,
      detail: 'wooden bench surrounded by autumn trees and fallen leaves',
    ),
    timeOfDay: TaggedField(value: 'Autumn', confidence: 0.9,
      detail: 'golden-brown foliage and muted overcast light',
    ),
    visualMood: TaggedField(value: 'Contemplative', confidence: 0.9,
      detail: 'person sitting quietly with a book in a tranquil outdoor setting',
    ),
    stoicVirtue: TaggedField(value: 'Temperance', confidence: 0.85,
      detail: 'the simple act of sitting in stillness amidst the changing seasons reflects self-restraint and moderation',
    ),
    humanPresence: TaggedField(value: 'Alone', confidence: 0.95,
      detail: 'a single person on a bench',
    ),
    natureRatio: TaggedField(value: 'Balanced', confidence: 0.85,
      detail: 'urban architecture visible in the distance behind natural foliage',
    ),
    keyObjects: ["wooden bench", "book", "fallen leaves"],
    dominantColors: ["amber", "brown", "muted green", "gray"],
    lightQuality: 'soft, diffused daylight',
  ),
  oneLineCapture: 'The leaves fall as they must, and the mind finds its center in the quiet between the seasons.',
  tags: const ["autumn", "solitude", "stillness", "reflection", "nature"],
  safety: const SafetyInfo(hasSensitiveContent: false
  ),
);
