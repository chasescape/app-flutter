import '../../../../gen_a/A.dart';
import '../../models/stoic_card.dart';

final stoic_data_7 = StoicCard(
  assetImg: A.assets_crushi_7,
  sceneCard: const SceneCard(
    setting: TaggedField(value: 'Commute', confidence: 0.9,
      detail: 'a train platform with benches and tracks stretching into the distance',
    ),
    timeOfDay: TaggedField(value: 'Golden Hour', confidence: 0.95,
      detail: 'warm, low-angled sunlight casting long shadows across the wooden platform',
    ),
    visualMood: TaggedField(value: 'Contemplative', confidence: 0.85,
      detail: 'a single suitcase left on a bench, implying departure or waiting in silence',
    ),
    stoicVirtue: TaggedField(value: 'Temperance', confidence: 0.8,
      detail: 'the solitary suitcase and empty platform reflect a life stripped of excess, focusing only on what is necessary for the path ahead',
    ),
    humanPresence: TaggedField(value: 'No People', confidence: 0.95,
      detail: 'the platform is entirely empty except for the lone object',
    ),
    natureRatio: TaggedField(value: 'Balanced', confidence: 0.7,
      detail: 'the industrial platform structure is softened by the natural light and weeds growing between the planks',
    ),
    keyObjects: ["vintage suitcase", "wooden bench", "railway tracks"],
    dominantColors: ["amber", "dark brown", "shadowy grey"],
    lightQuality: 'soft, warm, low-angled golden hour light',
  ),
  oneLineCapture: 'The traveler departs, leaving behind the weight of possessions to carry only the necessity of the mind.',
  tags: const ["departure", "solitude", "transition", "simplicity", "waiting"],
  safety: const SafetyInfo(hasSensitiveContent: false
  ),
);
