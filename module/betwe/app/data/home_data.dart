import '../../../gen_a/A.dart';

// 详情内容
class CareDetailData {
  final String title;
  final String category;
  final String overview;
  final List<String> steps;
  final String proTips;

  const CareDetailData({
    required this.title,
    required this.category,
    required this.overview,
    required this.steps,
    required this.proTips,
  });
}

// 护理提醒卡片数据
class CareReminderData {
  final String image;
  final String title;
  final String subtitle;
  final double progress;
  final int detailIndex;

  const CareReminderData({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.detailIndex,
  });
}

// 护理灵感大卡片数据
class CareInspirationMainData {
  final String image;
  final String category;
  final String title;
  final String subtitle;
  final String categoryColor;
  final int detailIndex;

  const CareInspirationMainData({
    required this.image,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.categoryColor,
    required this.detailIndex,
  });
}

// 护理灵感小卡片数据
class CareInspirationSmallData {
  final String image;
  final String category;
  final String title;
  final String subtitle;
  final String duration;
  final String difficulty;
  final String difficultyColor;
  final String categoryColor;
  final int detailIndex;

  const CareInspirationSmallData({
    required this.image,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.difficulty,
    required this.difficultyColor,
    required this.categoryColor,
    required this.detailIndex,
  });
}

// 首页数据类
class HomeData {
  static final List<String> imageCycle = [
    A.assets_betwe_01,
    A.assets_betwe_02,
    A.assets_betwe_03,
    A.assets_betwe_04,
    A.assets_betwe_05,
    A.assets_betwe_06,
    A.assets_betwe_07,
    A.assets_betwe_08,
    A.assets_betwe_09,
    A.assets_betwe_10,
    A.assets_betwe_11,
  ];

  static const List<CareDetailData> careDetails = [
    CareDetailData(
      title: 'Lace Garment Care',
      category: 'Care',
      overview:
          'Preserve the delicate texture and intricate patterns of lace garments to maintain their elegant appearance over time.',
      steps: [
        'Hand wash lace items in cool water with a mild detergent',
        'Avoid scrubbing or rubbing lace to prevent snags and tears',
        'Gently press out excess water instead of wringing',
        'Lay flat on a clean towel to air dry',
        'Store lace garments in acid-free tissue paper to prevent discoloration',
        'Iron on low heat with a pressing cloth to protect delicate threads',
      ],
      proTips:
          'Never use bleach on lace, as it will weaken fibers and cause yellowing. For heavily beaded or embroidered lace, consider professional dry cleaning to avoid damage.',
    ),
    CareDetailData(
      title: 'Floral Dress Storage',
      category: 'Storage',
      overview:
          'Keep printed and delicate dresses wrinkle-free and vibrant while maximizing closet space.',
      steps: [
        'Hang dresses on padded hangers to preserve neckline shape',
        'Fold lightweight dresses using the KonMari method for drawer storage',
        'Use garment bags to shield dresses from dust and sunlight',
        'Store printed dresses away from direct light to prevent fading',
        'Place cedar sachets in storage areas to repel moths',
        'Avoid overcrowding to keep fabric from creasing',
      ],
      proTips:
          'For floral prints with water-based inks, avoid storing near damp areas to prevent color bleeding. Use acid-free tissue paper between folded layers to protect delicate patterns.',
    ),
    CareDetailData(
      title: 'Maxi Dress Care',
      category: 'Washing',
      overview:
          'Maintain the flow and fit of long maxi dresses with gentle cleaning and proper handling.',
      steps: [
        'Check the care label for specific washing instructions',
        'Use a gentle cycle with cold water for machine-washable maxi dresses',
        'Turn dresses inside out before washing to protect the outer fabric',
        'Hang to dry on a clothesline or drying rack to avoid shrinkage',
        'Steam wrinkles instead of ironing to preserve the dress’s drape',
        'Spot treat stains immediately with a gentle stain remover',
      ],
      proTips:
          'For long hemlines, avoid dragging the dress on the ground while washing to prevent fraying. Use a mesh laundry bag for sheer maxi dresses to protect delicate fabric from snags in the washer.',
    ),
    CareDetailData(
      title: 'Layered Outfit Organization',
      category: 'Organization',
      overview:
          'Streamline your wardrobe by organizing layered outfits for easy access and daily styling.',
      steps: [
        'Group complete outfits together on hanging racks or in labeled bins',
        'Use dividers to separate tops, bottoms, and layering pieces',
        'Arrange outfits by season or occasion for quick selection',
        'Fold lightweight layers vertically in drawers to see all options',
        'Keep frequently worn outfits at the front of the closet',
        'Rotate seasonal layers to maintain a clutter-free space',
      ],
      proTips:
          'Label storage bins with outfit themes (e.g., "casual weekend" or "office wear") to speed up morning routines. Use slim hangers to maximize hanging space for layered pieces without overcrowding the closet.',
    ),
    CareDetailData(
      title: 'Chiffon Layering Care',
      category: 'Care',
      overview:
          'Learn to care for layered chiffon pieces to maintain their lightweight flow and elegant drape.',
      steps: [
        'Hand wash layered chiffon outfits separately to avoid friction damage',
        'Use cool water and a sulfate-free cleanser to preserve fabric softness',
        'Gently blot moisture with a towel instead of wringing or twisting',
        'Lay flat on a drying rack to preserve the layered silhouette',
        'Avoid hanging chiffon layers to prevent stretching of hemlines',
        'Steam clean instead of ironing to maintain delicate texture',
      ],
      proTips:
          'Avoid wearing sharp accessories with chiffon layers to prevent snags; always spot-test new detergents on hidden seams to avoid discoloration.',
    ),
    CareDetailData(
      title: 'Woven Closet Organization',
      category: 'Organization',
      overview:
          'Maximize closet space with woven storage solutions while keeping garments neat and accessible.',
      steps: [
        'Sort clothing by category (tops, bottoms, outerwear) before placing in woven bins',
        'Use stackable woven baskets for folded knitwear and loungewear',
        'Label woven containers with clear tags for quick identification of contents',
        'Hang lightweight items on slim hangers above woven storage bins',
        'Group seasonal pieces in separate woven containers to reduce clutter',
        'Leave 10% of basket space empty to prevent overpacking and fabric creasing',
      ],
      proTips:
          'Choose water-resistant woven bins for storing summer wear to protect against humidity; line baskets with breathable fabric to prevent snags on delicate garments.',
    ),
    CareDetailData(
      title: 'Winter Scarf Storage',
      category: 'Storage',
      overview:
          'Preserve the shape and softness of winter scarves while keeping your closet organized.',
      steps: [
        'Fold thick knit scarves in thirds and store in drawer dividers',
        'Hang lightweight silk scarves on hook hangers to avoid creases',
        'Roll cashmere scarves and place in breathable storage bags',
        'Use scarf organizers with loops to display and separate different styles',
        'Store scarves away from direct sunlight to prevent color fading',
        'Add cedar balls to scarf storage to repel moths and odors',
      ],
      proTips:
          'For bulky knit scarves, avoid overstuffing drawers to prevent flattening of the knit; lightly brush cashmere scarves with a cashmere comb before storage to maintain texture.',
    ),
    CareDetailData(
      title: 'Cozy Outerwear Care',
      category: 'Care',
      overview:
          'Maintain the warmth and condition of heavy outerwear like coats and oversized sweaters.',
      steps: [
        'Brush off loose dirt from outerwear before cleaning to avoid ground-in stains',
        'Air out heavy coats regularly to reduce odors and prevent mildew',
        'Hand wash knit outerwear in cool water with a wool-safe detergent',
        'Stuff coats with tissue paper while hanging to maintain shape and absorb moisture',
        'Avoid machine drying heavy outerwear to prevent shrinkage and fabric damage',
        'Store coats in garment bags with ventilation holes to allow air circulation',
      ],
      proTips:
          'Use a fabric steamer to refresh coats between cleanings instead of washing; for fur-trimmed outerwear, avoid storing in plastic bags to prevent matting of the fur.',
    ),
    CareDetailData(
      title: 'Tailored Suit Care',
      category: 'Care',
      overview:
          'Keep structured suits and knit layers looking polished and well-fitted for professional wear.',
      steps: [
        'Spot clean minor stains on suits with a damp cloth and mild detergent',
        'Hang suits on wide, padded hangers to preserve shoulder shape',
        'Steam suits on low heat to remove wrinkles without damaging fabric',
        'Hand wash knit sweaters in cool water with a wool-safe cleanser',
        'Lay knit layers flat to dry to prevent stretching',
        'Store suits in breathable garment bags to shield from dust and moths',
      ],
      proTips:
          'Avoid dry cleaning suits too frequently—over-cleaning can weaken fabric fibers. Brush suits gently after each wear to remove lint and maintain texture.',
    ),
    CareDetailData(
      title: 'Pastel Wardrobe Organization',
      category: 'Organization',
      overview:
          'Create a calm, cohesive closet by organizing soft pastel garments for easy styling and access.',
      steps: [
        'Sort pastel clothing by color family to maintain visual harmony',
        'Use woven baskets for folded loungewear and undergarments',
        'Hang lightweight tops and dresses on wooden hangers to prevent creasing',
        'Label storage baskets with pastel-colored tags for quick identification',
        'Arrange items by length (short to long) on hanging rods for a neat look',
        'Keep frequently worn pieces at the front of the closet for daily convenience',
      ],
      proTips:
          'Place small potted plants on closet shelves to absorb excess moisture and keep the space fresh. Avoid overcrowding pastel garments to prevent color transfer between delicate fabrics.',
    ),
    CareDetailData(
      title: 'Vintage Dress Storage',
      category: 'Storage',
      overview:
          'Preserve delicate vintage dresses and lace pieces while keeping your closet elegant and organized.',
      steps: [
        'Wrap vintage dresses in acid-free tissue paper to prevent discoloration',
        'Store lace and silk dresses in breathable garment bags with acid-free lining',
        'Hang vintage pieces on padded hangers to protect fragile necklines',
        'Use woven baskets for folded vintage linens and accessories',
        'Keep vintage garments away from direct sunlight to avoid fading',
        'Place cedar sachets in storage areas to repel moths and preserve fabric',
      ],
      proTips:
          'Avoid storing vintage dresses in plastic containers—trapped moisture can cause mildew and fabric decay. Check stored vintage pieces quarterly for signs of damage or discoloration.',
    ),
  ];

  // 护理提醒卡片数据
  static List<CareReminderData> careReminders = [
    CareReminderData(
      image: imageCycle[0],
      title: 'Lace Garment Care',
      subtitle:
          'Preserve the delicate texture and intricate patterns of lace garments to maintain their elegant appearance over time.',
      progress: 0.75,
      detailIndex: 0,
    ),
    CareReminderData(
      image: imageCycle[1],
      title: 'Floral Dress Storage',
      subtitle:
          'Keep printed and delicate dresses wrinkle-free and vibrant while maximizing closet space.',
      progress: 0.3,
      detailIndex: 1,
    ),
    CareReminderData(
      image: imageCycle[2],
      title: 'Maxi Dress Care',
      subtitle:
          'Maintain the flow and fit of long maxi dresses with gentle cleaning and proper handling.',
      progress: 0.9,
      detailIndex: 2,
    ),
    CareReminderData(
      image: imageCycle[3],
      title: 'Layered Outfit Organization',
      subtitle:
          'Streamline your wardrobe by organizing layered outfits for easy access and daily styling.',
      progress: 0.6,
      detailIndex: 3,
    ),
    CareReminderData(
      image: imageCycle[4],
      title: 'Chiffon Layering Care',
      subtitle:
          'Learn to care for layered chiffon pieces to maintain their lightweight flow and elegant drape.',
      progress: 0.4,
      detailIndex: 4,
    ),
    CareReminderData(
      image: imageCycle[5],
      title: 'Woven Closet Organization',
      subtitle:
          'Maximize closet space with woven storage solutions while keeping garments neat and accessible.',
      progress: 0.55,
      detailIndex: 5,
    ),
    CareReminderData(
      image: imageCycle[6],
      title: 'Winter Scarf Storage',
      subtitle:
          'Preserve the shape and softness of winter scarves while keeping your closet organized.',
      progress: 0.2,
      detailIndex: 6,
    ),
    CareReminderData(
      image: imageCycle[7],
      title: 'Cozy Outerwear Care',
      subtitle:
          'Maintain the warmth and condition of heavy outerwear like coats and oversized sweaters.',
      progress: 0.45,
      detailIndex: 7,
    ),
    CareReminderData(
      image: imageCycle[8],
      title: 'Tailored Suit Care',
      subtitle:
          'Keep structured suits and knit layers looking polished and well-fitted for professional wear.',
      progress: 0.68,
      detailIndex: 8,
    ),
    CareReminderData(
      image: imageCycle[9],
      title: 'Pastel Wardrobe Organization',
      subtitle:
          'Create a calm, cohesive closet by organizing soft pastel garments for easy styling and access.',
      progress: 0.35,
      detailIndex: 9,
    ),
    CareReminderData(
      image: imageCycle[10],
      title: 'Vintage Dress Storage',
      subtitle:
          'Preserve delicate vintage dresses and lace pieces while keeping your closet elegant and organized.',
      progress: 0.8,
      detailIndex: 10,
    ),
  ];

  // 护理灵感主卡片数据
  static CareInspirationMainData careInspirationMain = CareInspirationMainData(
    image: imageCycle[0],
    category: 'Care',
    title: 'Lace Garment Care',
    subtitle:
        'Preserve the delicate texture and intricate patterns of lace garments to maintain their elegant appearance over time.',
    categoryColor: '#FF6B9D',
    detailIndex: 0,
  );

  // 护理灵感小卡片数据
  static List<CareInspirationSmallData> careInspirationSmall = [
    CareInspirationSmallData(
      image: imageCycle[1],
      category: 'Storage',
      title: 'Floral Dress Storage',
      subtitle:
          'Keep printed and delicate dresses wrinkle-free and vibrant while maximizing closet space.',
      duration: '—',
      difficulty: 'Easy',
      difficultyColor: '#FF6B9D',
      categoryColor: '#9C27B0',
      detailIndex: 1,
    ),
    CareInspirationSmallData(
      image: imageCycle[2],
      category: 'Washing',
      title: 'Maxi Dress Care',
      subtitle:
          'Maintain the flow and fit of long maxi dresses with gentle cleaning and proper handling.',
      duration: '—',
      difficulty: 'Easy',
      difficultyColor: '#FF6B9D',
      categoryColor: '#4FC3F7',
      detailIndex: 2,
    ),
    CareInspirationSmallData(
      image: imageCycle[3],
      category: 'Organization',
      title: 'Layered Outfit Organization',
      subtitle:
          'Streamline your wardrobe by organizing layered outfits for easy access and daily styling.',
      duration: '—',
      difficulty: 'Easy',
      difficultyColor: '#FF6B9D',
      categoryColor: '#66BB6A',
      detailIndex: 3,
    ),
    CareInspirationSmallData(
      image: imageCycle[4],
      category: 'Care',
      title: 'Chiffon Layering Care',
      subtitle:
          'Learn to care for layered chiffon pieces to maintain their lightweight flow and elegant drape.',
      duration: '—',
      difficulty: 'Easy',
      difficultyColor: '#FF6B9D',
      categoryColor: '#FF6B9D',
      detailIndex: 4,
    ),
    CareInspirationSmallData(
      image: imageCycle[5],
      category: 'Organization',
      title: 'Woven Closet Organization',
      subtitle:
          'Maximize closet space with woven storage solutions while keeping garments neat and accessible.',
      duration: '—',
      difficulty: 'Easy',
      difficultyColor: '#FF6B9D',
      categoryColor: '#66BB6A',
      detailIndex: 5,
    ),
    CareInspirationSmallData(
      image: imageCycle[6],
      category: 'Storage',
      title: 'Winter Scarf Storage',
      subtitle:
          'Preserve the shape and softness of winter scarves while keeping your closet organized.',
      duration: '—',
      difficulty: 'Easy',
      difficultyColor: '#FF6B9D',
      categoryColor: '#9C27B0',
      detailIndex: 6,
    ),
    CareInspirationSmallData(
      image: imageCycle[7],
      category: 'Care',
      title: 'Cozy Outerwear Care',
      subtitle:
          'Maintain the warmth and condition of heavy outerwear like coats and oversized sweaters.',
      duration: '—',
      difficulty: 'Easy',
      difficultyColor: '#FF6B9D',
      categoryColor: '#FF6B9D',
      detailIndex: 7,
    ),
    CareInspirationSmallData(
      image: imageCycle[8],
      category: 'Care',
      title: 'Tailored Suit Care',
      subtitle:
          'Keep structured suits and knit layers looking polished and well-fitted for professional wear.',
      duration: '—',
      difficulty: 'Easy',
      difficultyColor: '#FF6B9D',
      categoryColor: '#FF6B9D',
      detailIndex: 8,
    ),
    CareInspirationSmallData(
      image: imageCycle[9],
      category: 'Organization',
      title: 'Pastel Wardrobe Organization',
      subtitle:
          'Create a calm, cohesive closet by organizing soft pastel garments for easy styling and access.',
      duration: '—',
      difficulty: 'Easy',
      difficultyColor: '#FF6B9D',
      categoryColor: '#66BB6A',
      detailIndex: 9,
    ),
    CareInspirationSmallData(
      image: imageCycle[10],
      category: 'Storage',
      title: 'Vintage Dress Storage',
      subtitle:
          'Preserve delicate vintage dresses and lace pieces while keeping your closet elegant and organized.',
      duration: '—',
      difficulty: 'Easy',
      difficultyColor: '#FF6B9D',
      categoryColor: '#9C27B0',
      detailIndex: 10,
    ),
  ];
}
