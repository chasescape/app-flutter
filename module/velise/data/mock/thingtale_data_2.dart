import 'package:velise/gen_a/a.dart';
import '../models/thingtale_item.dart';

final thingtale_data_2 = ThingTaleItem(
  assetImg: A.assets_velise_2,
  sceneCard: SceneCard(
    location: "workspace",
    timeContext: "collection_display",
    mood: "nostalgic",
    lighting: "natural_bright",
  ),
  primaryItem: PrimaryItem(
    category: "memorabilia",
    nameHint: "Vintage suitcase of travel souvenirs",
    quantity: 1,
    colors: ['brown', 'tan', 'red'],
    materials: ['other', 'paper', 'fabric'],
    style: "vintage",
    condition: "vintage",
    craftsmanshipNotes: """A well-worn leather suitcase featuring brass hardware and authentic travel stickers from various global destinations.""",
  ),
  description: Description(
    appearance: """A classic brown leather suitcase is propped open, revealing an eclectic mix of postcards, figurines, and textiles. The collection is dense with texture and color, set against a backdrop of a world map and books.""",
    character: """The suitcase acts as a vessel for memories, carrying the weight and wonder of many different cultures in one place.""",
    storyFeeling: """It feels like a tangible map of a person's life experiences and the places that shaped them.""",
  ),
  tags: ['travel', 'souvenir', 'vintage', 'nostalgic', 'collection'],
  memoryReflection: MemoryReflection(
    opening: "this_reminds_me_of",
    reflection: """This reminds me of the thrill of packing for a new adventure and the quiet joy of rediscovering these treasures years later.""",
  ),
  discovery: Discovery(
    specialDetails: ['Hand-painted elephant figurine', 'Postcards with international stamps', 'Worn brass hardware on the suitcase'],
    possibleOrigin: "travel souvenir",
    companionItems: ['vintage film camera', 'world atlas', 'journal'],
  ),
);