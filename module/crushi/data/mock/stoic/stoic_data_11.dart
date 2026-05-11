import '../../../../gen_a/A.dart';
import '../../models/stoic_card.dart';

final stoic_data_11 = StoicCard(
  assetImg: A.assets_crushi_11,
  sceneCard: const SceneCard(
    setting: TaggedField(value: 'Commute', confidence: 1.0,
      detail: 'Interior of a subway car with passengers and destination signage.',
    ),
    timeOfDay: TaggedField(value: 'Unknown', confidence: 0.8,
      detail: 'Artificial lighting inside a subway car obscures the time of day outside.',
    ),
    visualMood: TaggedField(value: 'Contemplative', confidence: 0.7,
      detail: 'Individuals focused on their devices, inward-looking expressions, quiet atmosphere.',
    ),
    stoicVirtue: TaggedField(value: 'Temperance', confidence: 0.7,
      detail: 'Amidst the crowd and digital distraction, maintaining one\'s own composure and focus requires self-restraint.',
    ),
    humanPresence: TaggedField(value: 'Crowd', confidence: 1.0,
      detail: 'Multiple passengers occupying the subway car.',
    ),
    natureRatio: TaggedField(value: 'None', confidence: 1.0,
      detail: 'Entirely enclosed, artificial urban environment.',
    ),
    keyObjects: ["Smartphone", "Backpack", "Subway pole", "Winter clothing"],
    dominantColors: ["Blue", "Grey", "Black"],
    lightQuality: 'Even, artificial fluorescent overhead lighting',
  ),
  oneLineCapture: 'Surrounded by many, yet each remains an island in their own mind.',
  tags: const ["commute", "urban", "solitude", "focus", "modernity"],
  safety: const SafetyInfo(hasSensitiveContent: false
  ),
);
