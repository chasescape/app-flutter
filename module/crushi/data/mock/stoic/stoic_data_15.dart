import '../../../../gen_a/A.dart';
import '../../models/stoic_card.dart';

final stoic_data_15 = StoicCard(
  assetImg: A.assets_crushi_15,
  sceneCard: const SceneCard(
    setting: TaggedField(value: 'Home', confidence: 1.0,
      detail: 'domestic interior with wooden floors, house plants, and soft furnishings',
    ),
    timeOfDay: TaggedField(value: 'Morning', confidence: 0.9,
      detail: 'soft, diffused golden light streaming through sheer curtains',
    ),
    visualMood: TaggedField(value: 'Serene', confidence: 1.0,
      detail: 'person sitting in a calm, balanced posture within a quiet, organized space',
    ),
    stoicVirtue: TaggedField(value: 'Temperance', confidence: 0.9,
      detail: 'the practice of intentional stillness and moderation in a simple, orderly environment reflects self-restraint and inner balance',
    ),
    humanPresence: TaggedField(value: 'Alone', confidence: 1.0,
      detail: 'one individual in a personal, private space',
    ),
    natureRatio: TaggedField(value: 'Balanced', confidence: 0.8,
      detail: 'integration of indoor plants with the domestic setting',
    ),
    keyObjects: ["yoga mat", "lit candle", "house plants", "wooden floor"],
    dominantColors: ["warm beige", "earthy green", "muted brown"],
    lightQuality: 'soft diffused morning light',
  ),
  oneLineCapture: 'In the quiet of the morning, one cultivates the only garden that truly matters—the interior landscape of the soul.',
  tags: const ["Stillness", "Morning", "Temperance", "Home", "Balance", "Focus"],
  safety: const SafetyInfo(hasSensitiveContent: false
  ),
);
