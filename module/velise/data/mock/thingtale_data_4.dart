import 'package:velise/gen_a/a.dart';
import '../models/thingtale_item.dart';

final thingtale_data_4 = ThingTaleItem(
  assetImg: A.assets_velise_4,
  sceneCard: SceneCard(
    location: "other",
    timeContext: "daily_use",
    mood: "cozy",
    lighting: "natural_bright",
  ),
  primaryItem: PrimaryItem(
    category: "plant_pot",
    nameHint: "Succulent in a beige ceramic pot",
    quantity: 1,
    colors: ['green', 'beige', 'brown'],
    materials: ['ceramic', 'other'],
    style: "minimalist",
    condition: "excellent",
    craftsmanshipNotes: """The pot features a smooth, speckled glaze finish, while the succulent shows healthy, symmetrical leaf growth.""",
  ),
  description: Description(
    appearance: """A vibrant green succulent with thick, pointed leaves arranged in a tight rosette pattern. It is housed in a rounded, cream-colored ceramic pot with subtle dark speckles, sitting on a warm wooden surface.""",
    character: """The plant exudes a sense of quiet resilience and natural beauty, adding a living touch to the room's decor.""",
    storyFeeling: """This item represents the simple, grounding joy of tending to a living thing within one's personal sanctuary.""",
  ),
  tags: ['plant_pot', 'minimalist', 'home decor', 'cozy', 'nature'],
  memoryReflection: MemoryReflection(
    opening: "every_time_i_see_this",
    reflection: """Every time I see this little succulent, I am reminded of the quiet, sun-drenched mornings and the peaceful atmosphere of my favorite corner of the house.""",
  ),
  discovery: Discovery(
    specialDetails: ['Subtle speckled texture on the ceramic glaze', 'Perfectly symmetrical leaf arrangement', 'Soft natural light catching the edges of the leaves'],
    possibleOrigin: "home decor store",
    companionItems: ['framed photograph', 'vintage book', 'bedside lamp'],
  ),
);