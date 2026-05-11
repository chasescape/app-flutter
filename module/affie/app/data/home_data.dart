import 'package:affie/gen_a/A.dart';

class HomeData {
  static HomeCave featuredAdventure = HomeCave(
    id: 'stalactite_cave',
    title: 'Stalactite Cave',
    location: 'Kentucky, USA',
    image: A.assets_affie_01,
    rating: 4.8,
    explorersCount: 234,
    difficulty: 'Beginner',
    durationAndGroup: '1.5–2 hours, 8–15 people',
    description:
        'Step into a world of natural wonder, where thousands of stalactites and stalagmites have formed over millions of years. This accessible cave features calm underground pools and towering limestone formations, making it a perfect introduction to cave exploration.',
    experienceHighlights: const [
      'Towering stalactite and stalagmite formations',
      'Calm underground water pools',
      'Ancient limestone structures',
    ],
    requiredEquipment: const [
      'Comfortable walking shoes',
      'Light jacket',
      'Headlamp',
      'Water bottle',
    ],
  );

  static List<HomeCave> popularDestinations = [
    HomeCave(
      id: 'glow_cave',
      title: 'Glow Cave',
      location: 'Okinawa, Japan',
      image: A.assets_affie_02,
      rating: 4.9,
      explorersCount: 567,
      difficulty: 'Moderate',
      description:
          'Discover a magical underworld illuminated by bioluminescent features and crystal-clear underground rivers. Warm-toned rock formations and cool blue water create a surreal atmosphere along wooden walkways and staircases.',
      experienceHighlights: const [
        'Bioluminescent cave features',
        'Crystal-clear underground rivers',
        'Colorful mineral formations',
        'Wooden walkway exploration',
      ],
      requiredEquipment: const [
        'Non-slip waterproof shoes',
        'Headlamp with backup battery',
        'Light waterproof jacket',
        'Gloves',
        'Camera for photography',
      ],
    ),
    HomeCave(
      id: 'coastal_cave',
      title: 'Coastal Cave',
      location: 'Sardinia, Italy',
      image: A.assets_affie_06,
      rating: 4.7,
      explorersCount: 128,
      difficulty: 'Moderate',
      description:
          'Explore a stunning coastal cave where turquoise sea water meets white marble formations and a hidden sandy beach. Stalactites hang above as waves echo through the chamber.',
      experienceHighlights: const [
        'Turquoise sea access',
        'White marble cave walls',
        'Hidden sandy beach',
        'Stalactite formations',
      ],
      requiredEquipment: const [
        'Water shoes',
        'Waterproof jacket',
        'Headlamp',
        'Sunscreen',
        'Camera',
      ],
    ),
    HomeCave(
      id: 'sunlit_cave',
      title: 'Sunlit Cave',
      location: 'Oman',
      image: A.assets_affie_08,
      rating: 5.0,
      explorersCount: 98,
      difficulty: 'Beginner',
      description:
          'A sunlit canyon cave where golden beams illuminate smooth boulders and a glowing green pool at the base.',
      experienceHighlights: const [
        'Dramatic sunbeam lighting',
        'Glowing green pool',
        'Smooth boulder floor',
        'Canyon cave architecture',
      ],
      requiredEquipment: const [
        'Sturdy hiking boots',
        'Hat and sunglasses',
        'Water bottle',
        'Light jacket',
        'Camera',
      ],
    ),
    HomeCave(
      id: 'jungle_cave',
      title: 'Jungle Cave',
      location: 'Guangxi, China',
      image: A.assets_affie_10,
      rating: 5.0,
      explorersCount: 98,
      difficulty: 'Moderate',
      description:
          'A massive limestone cave hidden in subtropical forest, with a shallow stream and misty sunbeams over moss‑covered rocks.',
      experienceHighlights: const [
        'Lush jungle interior',
        'Winding cave stream',
        'Sunbeam filtering',
        'Moss-covered rock formations',
      ],
      requiredEquipment: const [
        'Sturdy waterproof boots',
        'Lightweight rain jacket',
        'Headlamp',
        'Insect repellent',
        'Water bottle',
      ],
    ),
  ];

  static HomeCave popularWide = HomeCave(
    id: 'sunlit_cave',
    title: 'Sunlit Cave',
    location: 'Oman',
    image: A.assets_affie_08,
    rating: 5.0,
    explorersCount: 98,
    difficulty: 'Beginner',
    description:
        'Step into a sunlit canyon cave where golden beams pierce the opening, illuminating smooth boulders and a glowing green pool. Natural light creates a dramatic, otherworldly scene.',
    experienceHighlights: const [
      'Dramatic sunbeam lighting',
      'Glowing green pool',
      'Smooth boulder floor',
      'Canyon cave architecture',
    ],
    requiredEquipment: const [
      'Sturdy hiking boots',
      'Hat and sunglasses',
      'Water bottle',
      'Light jacket',
      'Camera',
    ],
  );

  static List<HomeShare> communityShares = [
    HomeShare(
      id: 'camp_kitchen',
      title: 'Camp Kitchen Kit',
      author: 'Leo Martinez',
      location: 'Outdoor campsite',
      image: A.assets_affie_04,
      tag: 'Equipment',
      likes: 234,
      date: 'Feb 5, 2026',
      about:
          'My go-to camp kitchen setup for outdoor cooking. It’s compact, organized, and perfect for whipping up delicious meals in the wilderness—no fancy tools required, just good food and great company.',
      equipmentItems: const [
        'Stackable storage crates',
        'Portable coffee maker',
        'Foldable camping chair',
        'Insulated food containers',
        'Reusable tableware',
      ],
    ),
    HomeShare(
      id: 'rugged_audio',
      title: 'Rugged Audio Gear',
      author: 'Jordan Reed',
      location: 'Trail & camp',
      image: A.assets_affie_05,
      tag: 'Equipment',
      likes: 189,
      date: 'Feb 12, 2026',
      about:
          'These portable speakers are built for adventure. Waterproof, shockproof, and packed with powerful sound, they’re the perfect companion for hiking, camping, or any outdoor excursion where music is a must.',
      equipmentItems: const [
        'Rugged portable speaker (olive green)',
        'Rugged portable speaker (sand beige)',
        'Rugged portable speaker (matte black)',
        'Weather-resistant casing',
        'Multi-function control knobs',
      ],
    ),
    HomeShare(
      id: 'climbing_cave_kit',
      title: 'Climbing Cave Kit',
      author: 'Chloe Bennett',
      location: 'Cave exploration',
      image: A.assets_affie_09,
      tag: 'Equipment',
      likes: 156,
      date: 'Feb 22, 2026',
      about:
          'This professional climbing gear set is tested and approved for intermediate cave exploration. Every piece meets strict safety standards, ensuring stability and protection when navigating narrow cave passages and rocky terrain.',
      equipmentItems: const [
        'Heavy-duty climbing harness',
        'Dynamic rappel rope',
        'Quick-release carabiners',
        'Padded climbing leggings',
        'Sturdy climbing crop top',
        'Waist-mounted gear belt',
      ],
    ),
    HomeShare(
      id: 'summit_victory',
      title: 'Summit Victory Gear',
      author: 'Kai Torres',
      location: 'Glacial summit',
      image: A.assets_affie_11,
      tag: 'Equipment',
      likes: 205,
      date: 'Feb 20, 2026',
      about:
          'This gear carried me to the summit of a glacial peak—lightweight, durable, and built to withstand extreme cold. The bright pack cuts through the white landscape, making it easy to spot in whiteout conditions.',
      equipmentItems: const [
        'High-visibility technical backpack',
        'Windproof expedition jacket',
        'Insulated mountaineering pants',
        'Waterproof gloves',
        'Crampon-compatible boots',
      ],
    ),
    HomeShare(
      id: 'alpine_expedition',
      title: 'Alpine Expedition Kit',
      author: 'Ethan Cole & Clara Reed',
      location: 'Alpine traverse',
      image: A.assets_affie_12,
      tag: 'Equipment',
      likes: 187,
      date: 'Feb 21, 2026',
      about:
          'Our alpine expedition gear is optimized for multi-day glacial treks. Every item is chosen for warmth, durability, and weight efficiency—critical when moving through snow and ice for hours on end.',
      equipmentItems: const [
        'Down-filled expedition parka',
        'Waterproof mountaineering pants',
        'Trekking poles with snow baskets',
        'Insulated gaiters',
        'Multi-day backpack',
      ],
    ),
    HomeShare(
      id: 'ice_climbing_setup',
      title: 'Ice Climbing Setup',
      author: 'Stella Hart',
      location: 'Ice climbing',
      image: A.assets_affie_13,
      tag: 'Equipment',
      likes: 187,
      date: 'Feb 23, 2026',
      about:
          'This ice climbing kit is designed for precision and safety on frozen rock faces. The crampons and ice axe provide secure footing, while the harness keeps me anchored during steep ascents.',
      equipmentItems: const [
        'Technical ice axe',
        'Adjustable climbing crampons',
        'Full-body climbing harness',
        'Quick-dry performance leggings',
        'Thermal base layer',
      ],
    ),
  ];

  static const List<HomeQuickAction> quickActions = [
    HomeQuickAction(
      id: 'ai',
      title: 'AI',
      subtitle: 'Equipment Check',
      icon: 'ai',
    ),
    HomeQuickAction(
      id: 'discover',
      title: 'Discover',
      subtitle: 'Share Caves',
      icon: 'discover',
    ),
    HomeQuickAction(
      id: 'safe',
      title: 'Safe',
      subtitle: 'Exploration',
      icon: 'safe',
    ),
  ];

  static HomeShare explorersPick = HomeShare(
    id: 'retro_photo',
    title: 'Retro Photo Gear',
    author: 'Lila Moore',
    location: 'Cave photography',
    image: A.assets_affie_07,
    tag: 'Discovery',
    likes: 298,
    date: 'Feb 18, 2026',
    about:
        'My vintage film camera is my favorite companion for outdoor cave exploration. It captures the unique textures of rock formations and ice walls with unmatched warmth, perfect for documenting every adventure moment to share with the community.',
    equipmentItems: const [
      'Vintage 35mm film camera',
      'Woven crop sweater',
      'Plaid mini skirt',
      'Camera neck strap',
      'UV protection lens filter',
    ],
  );
}

class HomeCave {
  const HomeCave({
    required this.id,
    required this.title,
    required this.location,
    required this.image,
    required this.rating,
    required this.explorersCount,
    required this.difficulty,
    this.leftBadgeText,
    this.description,
    this.durationAndGroup,
    this.experienceHighlights = const [],
    this.requiredEquipment = const [],
  });

  final String id;
  final String title;
  final String location;
  final String image;
  final double rating;
  final int explorersCount;
  final String difficulty;
  final String? leftBadgeText;
  final String? description;
   final String? durationAndGroup;
  final List<String> experienceHighlights;
  final List<String> requiredEquipment;
}

class HomeShare {
  const HomeShare({
    required this.id,
    required this.title,
    required this.author,
    required this.location,
    required this.image,
    required this.tag,
    required this.likes,
    this.isVerified = false,
    this.date,
    this.about,
    this.equipmentItems = const [],
  });

  final String id;
  final String title;
  final String author;
  final String location;
  final String image;
  final String tag;
  final int likes;
  final bool isVerified;
  final String? date;
  final String? about;
  final List<String> equipmentItems;
}

class HomeQuickAction {
  const HomeQuickAction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final String icon;
}
