import 'package:velise/gen_a/a.dart';
import '../models/thingtale_item.dart';

final thingtale_data_5 = ThingTaleItem(
  assetImg: A.assets_velise_5,
  sceneCard: SceneCard(
    location: "other",
    timeContext: "daily_use",
    mood: "cozy",
    lighting: "natural_bright",
  ),
  primaryItem: PrimaryItem(
    category: "book",
    nameHint: "Vintage open book with tortoiseshell glasses",
    quantity: 1,
    colors: ['yellow', 'brown', 'orange'],
    materials: ['paper', 'plastic', 'wood'],
    style: "vintage",
    condition: "vintage",
    craftsmanshipNotes: """The book features beautifully aged, deckle-edge yellowed pages and the glasses have a classic polished tortoiseshell finish.""",
  ),
  description: Description(
    appearance: """An open vintage book with deeply yellowed, textured pages sits on a weathered wooden side table. A pair of tortoiseshell reading glasses is perched on top, accompanied by a small ceramic owl figurine in the background.""",
    character: """The scene exudes a quiet, intellectual charm, suggesting a well-loved corner dedicated to slow living and stories.""",
    storyFeeling: """It represents the simple joy of a peaceful afternoon lost in the pages of a classic tale.""",
  ),
  tags: ['vintage', 'cozy', 'reading', 'nostalgic', 'hygge'],
  memoryReflection: MemoryReflection(
    opening: "every_time_i_see_this",
    reflection: """Every time I see this, I feel the warmth of a quiet afternoon where time seems to stand still between the lines of a favorite story.""",
  ),
  discovery: Discovery(
    specialDetails: ['deckle-edge paper texture', 'tortoiseshell frame pattern', 'hand-painted ceramic owl details'],
    possibleOrigin: "vintage store",
    companionItems: ['chunky knit blanket', 'cup of herbal tea', 'soft armchair'],
  ),
);