import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paech/gen_a/A.dart';

import '../../components/explore_card/explore_card.dart';
import '../../components/home_skeleton.dart';
import '../nav/nav_logic.dart';
import 'home_logic.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final HomeLogic logic;
  late final AnimationController _animationController;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  static const int _kHomeTabIndex = 0;
  bool _hasPlayedEntrance = false;

  @override
  void initState() {
    super.initState();
    logic = Get.put(HomeLogic());
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.85, curve: Curves.easeOut),
      ),
    );
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.85, curve: Curves.easeOut),
      ),
    );
    // 仅首次切到本 Tab 时播放入场渐入动画
    final navLogic = Get.find<NavLogic>();
    ever(navLogic.tabIndex, (int index) {
      if (!mounted || index != _kHomeTabIndex || _hasPlayedEntrance) return;
      _hasPlayedEntrance = true;
      _animationController.reset();
      _animationController.forward();
    });
    if (navLogic.tabIndex.value == _kHomeTabIndex) {
      _hasPlayedEntrance = true;
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) _animationController.forward();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        children: [
          FadeTransition(
            opacity: _contentFade,
            child: SlideTransition(
              position: _contentSlide,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Paech',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2D2A26),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Discover care tips and styling inspiration',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF8D857C),
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => Get.toNamed('/history'),
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD0B08E),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Image.asset(
                              A.assets_paech_ic_history,
                              width: 20,
                              height: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                ],
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              // 显示骨架屏或实际内容
              if (logic.isLoading.value) {
                return FadeTransition(
                  opacity: _contentFade,
                  child: SlideTransition(
                    position: _contentSlide,
                    child: const HomeSkeleton(),
                  ),
                );
              }

              return FadeTransition(
                opacity: _contentFade,
                child: SlideTransition(
                  position: _contentSlide,
                  child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Featured Care Tips
                      Text(
                        'Featured Care Tips',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          color: const Color(0xFF4A3C2E),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => Get.toNamed(
                          '/details',
                          arguments: {
                            'imagePath': A.assets_paech_01,
                            'title': 'Steampunk Outfit Care',
                            'description':
                                'This detailed steampunk ensemble features delicate fabrics and hardware. Proper care will keep its unique details intact and ensure it stays in great condition for events and adventures.',
                            'tips': [
                              {
                                'title': 'Care Instructions',
                                'subtitle':
                                    'Keep your steampunk outfit in top condition',
                                'instruction1':
                                    'Spot clean leather and metal hardware with a damp cloth to avoid damage',
                                'instruction2':
                                    'Hand wash lace and cotton components separately in cold water',
                                'instruction3':
                                    'Air dry away from direct sunlight to prevent fading of fabric and rust on metal parts',
                                'instruction4':
                                    'Store with acid-free tissue paper to protect lace and keep structured pieces from creasing',
                                'instruction5':
                                    'Polish metal buckles and gears gently with a soft cloth to maintain shine',
                              },
                              {
                                'title': 'Styling Suggestions',
                                'subtitle':
                                    'Maintain delicate fabrics and hardware with care',
                                'instruction1':
                                    'Pair with lace-up boots and fingerless gloves for an authentic steampunk vibe',
                                'instruction2':
                                    'Add a vintage pocket watch or goggles as statement accessories',
                                'instruction3':
                                    'Layer with a tailored waistcoat over the blouse for extra structure',
                                'instruction4':
                                    'Complete the look with a wide-brimmed hat and a small leather satchel',
                              },
                            ],
                          },
                        ),
                        child: _FeaturedCard(
                          title: 'Steampunk Outfit Care',
                          subtitle:
                              'Delicate steampunk fabrics; proper care keeps details intact for events.',
                          imagePath: A.assets_paech_01,
                        ),
                      ),
                      //Quick Tips
                      const SizedBox(height: 22),
                      Text(
                        'Quick Tips',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF8B7968),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Get.toNamed(
                                '/details',
                                arguments: {
                                  'imagePath': A.assets_paech_03,
                                  'title': 'Pirate Costume Care',
                                  'description':
                                      'This swashbuckling pirate costume blends rugged fabrics and decorative details. With proper maintenance, it will stay ready for your next voyage or themed event.',
                                  'tips': [
                                    {
                                      'title': 'Care Instructions',
                                      'subtitle':
                                          'Keep your pirate outfit in top shape',
                                      'instruction1':
                                          'Machine wash cotton and linen fabrics on a gentle cycle in cold water',
                                      'instruction2':
                                          'Hand wash or spot clean velvet and faux leather accents',
                                      'instruction3':
                                          'Air dry to prevent shrinkage and preserve the shape of hats and belts',
                                      'instruction4':
                                          'Brush dust off tricorn hats and fabric sashes regularly',
                                    },
                                    {
                                      'title': 'Styling Suggestions',
                                      'subtitle':
                                          'Create a bold, authentic pirate look',
                                      'instruction1':
                                          'Add a pair of knee-high leather boots and a faux sword for full pirate flair',
                                      'instruction2':
                                          'Tie a patterned scarf around the neck or waist for extra texture',
                                      'instruction3':
                                          'Layer with a loose, billowy shirt under the corset for an authentic silhouette',
                                      'instruction4':
                                          'Complete the look with dramatic eye makeup and a bold red lip',
                                    },
                                  ],
                                },
                              ),
                              child: _QuickTipCard(
                                title: 'Pirate Costume Care',
                                subtitle:
                                    'This swashbuckling pirate costume blends rugged fabrics and decorative details. With proper maintenance, it will stay ready for your next voyage or themed event.',
                                imagePath: A.assets_paech_03,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Get.toNamed(
                                '/details',
                                arguments: {
                                  'imagePath': A.assets_paech_04,
                                  'title': 'Utility Dress Style',
                                  'description':
                                      'This versatile utility dress balances practicality and chic design. It’s perfect for everyday wear and can be dressed up or down with ease.',
                                  'tips': [
                                    {
                                      'title': 'Care Instructions',
                                      'subtitle':
                                          'Keep your pirate outfit in top shape',
                                      'instruction1':
                                          'Machine wash on a gentle cycle with like colors',
                                      'instruction2':
                                          'Tumble dry on low or air dry to maintain the fabric’s structure',
                                      'instruction3':
                                          'Iron on medium heat to smooth out creases in the cotton blend fabric',
                                      'instruction4':
                                          'Spot clean stains promptly to avoid setting',
                                    },
                                    {
                                      'title': 'Styling Suggestions',
                                      'subtitle':
                                          'Keep your pirate outfit in top shape',
                                      'instruction1':
                                          'Pair with white sneakers and a crossbody bag for a casual daytime look',
                                      'instruction2':
                                          'Dress it up with block heels and gold jewelry for brunch or a date',
                                      'instruction3':
                                          'Layer with a cropped denim jacket or knit cardigan for cooler weather',
                                      'instruction4':
                                          'Add a wide fabric belt to cinch the waist and enhance the silhouette',
                                    },
                                  ],
                                },
                              ),
                              child: _QuickTipCard(
                                title: 'Utility Dress Style',
                                subtitle:
                                    'This versatile utility dress balances practicality and chic design. It’s perfect for everyday wear and can be dressed up or down with ease.',
                                imagePath: A.assets_paech_04,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Get.toNamed(
                                '/details',
                                arguments: {
                                  'imagePath': A.assets_paech_05,
                                  'title': 'Western Vest Care',
                                  'description':
                                      'This classic western-style leather vest is a rugged, timeless piece. Proper care will keep the leather supple and maintain its vintage-inspired look.',
                                  'tips': [
                                    {
                                      'title': 'Care Instructions',
                                      'subtitle':
                                          'Maintain leather for a rugged, timeless look',
                                      'instruction1':
                                          'Clean leather with a specialized cleaner and conditioner',
                                      'instruction2':
                                          'Wipe dust and dirt regularly with a soft, dry cloth',
                                      'instruction3':
                                          'Avoid direct sunlight and moisture to prevent cracking or fading',
                                      'instruction4':
                                          'Store on a wide, padded hanger to preserve shape',
                                      'instruction5':
                                          'Use a leather protectant spray to guard against stains and water',
                                    },
                                    {
                                      'title': 'Styling Suggestions',
                                      'subtitle':
                                          'Create an authentic western vibe',
                                      'instruction1':
                                          'Wear over a white or striped button-down shirt for a classic look',
                                      'instruction2':
                                          'Pair with jeans, cowboy boots, and a bandana for rancher style',
                                      'instruction3':
                                          'Add a leather belt with a large buckle and aviator sunglasses',
                                      'instruction4':
                                          'Layer with a denim jacket over the vest for warmth and texture',
                                    },
                                  ],
                                },
                              ),
                              child: _QuickTipCard(
                                title: 'Western Vest Care',
                                subtitle:
                                    'This classic western-style leather vest is a rugged, timeless piece. Proper care will keep the leather supple and maintain its vintage-inspired look.',
                                imagePath: A.assets_paech_05,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),
                      Text(
                        'Popular Styles',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          color: const Color(0xFF4A3C2E),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => Get.toNamed(
                          '/details',
                          arguments: {
                            'imagePath': A.assets_paech_02,
                            'title': 'Vintage Gown Care',
                            'description':
                                'This romantic, ethereal vintage gown is crafted from delicate tulle and lace. Gentle care is essential to preserve its soft, dreamy appearance for special occasions.',
                            'tips': [
                              {
                                'title': 'Care Instructions',
                                'subtitle':
                                    'Keep the gown delicate and flawless',
                                'instruction1':
                                    'Dry clean only to protect intricate lace and tulle fabric',
                                'instruction2':
                                    'Store flat in a breathable garment bag to avoid stretching or snagging',
                                'instruction3':
                                    'Spot treat small stains with a mild, pH-neutral detergent',
                                'instruction4':
                                    'Avoid hanging for long periods to prevent shoulder dents and fabric distortion',
                                'instruction5':
                                    'Steam lightly on low heat to remove wrinkles, keeping the iron at a safe distance',
                              },
                              {
                                'title': 'Styling Suggestions',
                                'subtitle':
                                    'Accessorize and style for ethereal elegance',
                                'instruction1':
                                    'Accessorize with a pearl hairpin and drop earrings for a timeless bridal look',
                                'instruction2':
                                    'Pair with strappy satin heels and a small beaded clutch',
                                'instruction3':
                                    'Layer with a cropped lace bolero for cooler evenings',
                                'instruction4':
                                    'Keep makeup soft and dewy to complement the gown’s romantic aesthetic',
                              },
                            ],
                          },
                        ),
                        child: _PopularStylesCard(
                          title: 'Vintage Gown Care',
                          subtitle:
                              'Ethereal vintage gown with soft, dreamy fabrics',
                          imagePath: A.assets_paech_02,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Quick Tips',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF8B7968),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Get.toNamed(
                                '/details',
                                arguments: {
                                  'imagePath': A.assets_paech_06,
                                  'title': 'Trench Coat Care',
                                  'description':
                                      'This classic trench coat is a timeless outerwear staple, designed to be both functional and stylish. Proper care will preserve its water-resistant finish and sharp silhouette for years.',
                                  'tips': [
                                    {
                                      'title': 'Care Instructions',
                                      'subtitle':
                                          'Keep your trench coat sharp and weather-resistant',
                                      'instruction1':
                                          'Spot clean with a damp cloth and mild detergent for small stains',
                                      'instruction2':
                                          'Machine wash on a gentle cycle in cold water, or dry clean for optimal results',
                                      'instruction3':
                                          'Tumble dry on low or air dry to avoid shrinking the cotton blend fabric',
                                      'instruction4':
                                          'Iron on medium heat to maintain crisp lapels and a tailored look',
                                      'instruction5':
                                          'Reapply a water-repellent spray annually to keep it weather-resistant',
                                    },
                                    {
                                      'title': 'Styling Suggestions',
                                      'subtitle':
                                          'Style for polished and sophisticated looks',
                                      'instruction1':
                                          'Layer over a tailored suit for a polished office-to-evening look',
                                      'instruction2':
                                          'Pair with a turtleneck and slim-fit jeans for a casual yet sophisticated outfit',
                                      'instruction3':
                                          'Add a leather belt to cinch the waist and define your silhouette',
                                      'instruction4':
                                          'Complete the look with Chelsea boots and a structured leather briefcase',
                                    },
                                  ],
                                },
                              ),
                              child: _QuickTipCard(
                                title: 'Trench Coat Care',
                                subtitle:
                                    'This classic trench coat is a timeless outerwear staple, designed to be both functional and stylish. Proper care will preserve its water-resistant finish and sharp silhouette for years.',
                                imagePath: A.assets_paech_06,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Get.toNamed(
                                '/details',
                                arguments: {
                                  'imagePath': A.assets_paech_07,
                                  'title': 'Casual Chore Coat',
                                  'description':
                                      'This relaxed chore coat is a versatile layering piece for everyday wear. Its durable cotton fabric and easy style make it perfect for weekends and casual outings.',
                                  'tips': [
                                    {
                                      'title': 'Care Instructions',
                                      'subtitle':
                                          'Keep your chore coat clean and well-shaped',
                                      'instruction1':
                                          'Machine wash on a regular cycle with like colors',
                                      'instruction2':
                                          'Tumble dry on medium or air dry to prevent fading',
                                      'instruction3':
                                          'Iron on low heat to smooth out wrinkles, or embrace a lived-in look',
                                      'instruction4':
                                          'Spot treat stains promptly to avoid setting into the fabric',
                                      'instruction5':
                                          'Store on a hanger or fold neatly to maintain shape',
                                    },
                                    {
                                      'title': 'Styling Suggestions',
                                      'subtitle':
                                          'Create effortless, casual outfits',
                                      'instruction1':
                                          'Layer over a striped tee and pair with wide-leg trousers for a retro-inspired look',
                                      'instruction2':
                                          'Wear with a plain white shirt and chinos for a clean, minimalist outfit',
                                      'instruction3':
                                          'Add white sneakers and a crossbody bag for a laid-back weekend vibe',
                                      'instruction4':
                                          'Roll up the cuffs to show off a pair of statement socks',
                                    },
                                  ],
                                },
                              ),
                              child: _QuickTipCard(
                                title: 'Casual Chore Coat',
                                subtitle:
                                    'This relaxed chore coat is a versatile layering piece for everyday wear. Its durable cotton fabric and easy style make it perfect for weekends and casual outings.',
                                imagePath: A.assets_paech_07,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Get.toNamed(
                                '/details',
                                arguments: {
                                  'imagePath': A.assets_paech_08,
                                  'title': 'Leather Blazer Care',
                                  'description':
                                      'This sleek leather blazer elevates any outfit with its bold texture and sharp tailoring. With proper maintenance, it will develop a rich patina and last for decades.',
                                  'tips': [
                                    {
                                      'title': 'Care Instructions',
                                      'subtitle':
                                          'Maintain your leather blazer for lasting style',
                                      'instruction1':
                                          'Clean with a specialized leather cleaner and conditioner every 3–6 months',
                                      'instruction2':
                                          'Wipe away spills immediately with a soft, dry cloth to prevent stains',
                                      'instruction3':
                                          'Avoid prolonged exposure to sunlight and heat to prevent cracking or fading',
                                      'instruction4':
                                          'Store on a padded hanger in a breathable garment bag',
                                      'instruction5':
                                          'Use a leather protectant spray to guard against water damage',
                                    },
                                    {
                                      'title': 'Styling Suggestions',
                                      'subtitle':
                                          'Style for modern and sophisticated looks',
                                      'instruction1':
                                          'Wear over a crisp white shirt and tailored trousers for a modern office look',
                                      'instruction2':
                                          'Pair with a black turtleneck and jeans for a ruggedly sophisticated evening outfit',
                                      'instruction3':
                                          'Add a silk pocket square and leather loafers for a polished finish',
                                      'instruction4':
                                          'Layer over a knit sweater for extra warmth during cooler months',
                                    },
                                  ],
                                },
                              ),
                              child: _QuickTipCard(
                                title: 'Leather Blazer Care',
                                subtitle:
                                    'This sleek leather blazer elevates any outfit with its bold texture and sharp tailoring. With proper maintenance, it will develop a rich patina and last for decades.',
                                imagePath: A.assets_paech_08,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        "Editor's Pick",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          color: const Color(0xFF4A3C2E),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => Get.toNamed(
                          '/details',
                          arguments: {
                            'imagePath': A.assets_paech_09,
                            'title': 'Shearling-Lined Jacket',
                            'description':
                                'This rugged shearling-lined jacket combines warmth and durability, making it ideal for cold weather. Its heavy-duty construction and plush interior require gentle care to stay in top condition.',
                            'tips': [
                              {
                                'title': 'Care Instructions',
                                'subtitle':
                                    'Keep your shearling jacket soft and durable',
                                'instruction1':
                                    'Dry clean only to protect the shearling lining and leather exterior',
                                'instruction2':
                                    'Brush the shearling gently with a soft-bristled brush to maintain its fluffiness',
                                'instruction3':
                                    'Spot clean leather with a damp cloth and mild leather soap',
                                'instruction4':
                                    'Store in a cool, dry place away from direct sunlight to prevent fading',
                                'instruction5':
                                    'Avoid hanging for long periods; lay flat to preserve the shearling shape',
                              },
                              {
                                'title': 'Styling Suggestions',
                                'subtitle':
                                    'Create cozy and rugged winter looks',
                                'instruction1':
                                    'Pair with a chunky knit sweater and dark jeans for a cozy winter look',
                                'instruction2':
                                    'Wear with work boots and a beanie for a rugged, outdoor-ready outfit',
                                'instruction3':
                                    'Layer over a flannel shirt for extra warmth and texture',
                                'instruction4':
                                    'Add a scarf and leather gloves to complete the cold-weather ensemble',
                              },
                            ],
                          },
                        ),
                        child: _EditorsPickCard(
                          title: 'Shearling-Lined Jacket',
                          subtitle:
                              "This rugged shearling-lined jacket combines warmth and durability, making it ideal for cold weather. Its heavy-duty construction and plush interior require gentle care to stay in top condition.",
                          imagePath: A.assets_paech_09,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Explore More',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          color: const Color(0xFF4A3C2E),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ExploreCardGrid(
                        items: [
                          ExploreCardItem(
                            title: 'Romantic Midi Dress',
                            subtitle:
                                'This flowy, feminine midi dress is crafted from lightweight fabric with delicate detailing. It’s perfect for garden parties, weddings, and warm-weather occasions.',
                            imagePath: A.assets_paech_10,
                          ),
                          ExploreCardItem(
                            title: 'Casual Cargo Style',
                            subtitle:
                                'This relaxed, functional outfit pairs a soft sweatshirt with durable cargo pants, perfect for comfortable everyday wear while staying on-trend.',
                            imagePath: A.assets_paech_11,
                          ),
                          ExploreCardItem(
                            title: 'Shearling-Lined Bomber',
                            subtitle:
                                'This rugged shearling-lined bomber jacket is built for warmth and style, combining a weathered leather exterior with a plush, insulating interior.',
                            imagePath: A.assets_paech_12,
                          ),
                          ExploreCardItem(
                            title: 'Minimalist Knitwear',
                            subtitle:
                                'This sleek black knit sweater is a wardrobe essential, offering timeless style and versatile layering potential for both casual and polished looks.',
                            imagePath: A.assets_paech_13,
                          ),
                        ],
                        onItemTap: (index) {
                          final items = [
                            {
                              'imagePath': A.assets_paech_10,
                              'title': 'Romantic Midi Dress',
                              'description':
                                  'This flowy, feminine midi dress is crafted from lightweight fabric with delicate detailing. It’s perfect for garden parties, weddings, and warm-weather occasions.',
                              'tips': [
                                {
                                  'title': 'Care Instructions',
                                  'subtitle':
                                      'Keep your dress delicate and pristine',
                                  'instruction1':
                                      'Hand wash in cold water with a mild detergent, or dry clean for best results',
                                  'instruction2':
                                      'Air dry flat to avoid stretching the delicate fabric',
                                  'instruction3':
                                      'Steam lightly on low heat to remove wrinkles, avoiding direct contact with lace',
                                  'instruction4':
                                      'Store in a breathable garment bag to prevent snags and dust buildup',
                                  'instruction5':
                                      'Spot treat stains immediately with a gentle stain remover',
                                },
                                {
                                  'title': 'Styling Suggestions',
                                  'subtitle':
                                      'Create romantic and versatile looks',
                                  'instruction1':
                                      'Pair with strappy block heels and a woven basket bag for a garden party look',
                                  'instruction2':
                                      'Add a cropped denim jacket and white sneakers for a casual daytime outfit',
                                  'instruction3':
                                      'Accessorize with dainty gold jewelry and a hair clip for a romantic finish',
                                  'instruction4':
                                      'Layer with a sheer blouse underneath for extra coverage on cooler days',
                                },
                              ],
                            },
                            {
                              'imagePath': A.assets_paech_11,
                              'title': 'Casual Cargo Style',
                              'description':
                                  'This relaxed, functional outfit pairs a soft sweatshirt with durable cargo pants, perfect for comfortable everyday wear while staying on-trend.',
                              'tips': [
                                {
                                  'title': 'Care Instructions',
                                  'subtitle':
                                      'Keep your outfit clean and functional',
                                  'instruction1':
                                      'Machine wash sweatshirt on a gentle cycle in cold water to preserve fabric softness',
                                  'instruction2':
                                      'Wash cargo pants separately to avoid color bleeding from hardware',
                                  'instruction3':
                                      'Tumble dry on low or air dry to prevent shrinking',
                                  'instruction4':
                                      'Iron sweatshirt on low heat if needed; avoid ironing over printed logos',
                                  'instruction5':
                                      'Store folded to maintain the shape of cargo pockets',
                                },
                                {
                                  'title': 'Styling Suggestions',
                                  'subtitle':
                                      'Casual and comfortable everyday looks',
                                  'instruction1':
                                      'Pair with white sneakers and a crossbody bag for a laid-back weekend look',
                                  'instruction2':
                                      'Layer with a lightweight windbreaker for cooler days',
                                  'instruction3':
                                      'Roll up cargo pant cuffs to show off statement socks',
                                  'instruction4':
                                      'Add a baseball cap for a sporty, casual finish',
                                },
                              ],
                            },
                            {
                              'imagePath': A.assets_paech_12,
                              'title': 'Shearling-Lined Bomber',
                              'description':
                                  'This rugged shearling-lined bomber jacket is built for warmth and style, combining a weathered leather exterior with a plush, insulating interior.',
                              'tips': [
                                {
                                  'title': 'Care Instructions',
                                  'subtitle':
                                      'Maintain warmth and preserve leather quality',
                                  'instruction1':
                                      'Dry clean only to protect the shearling lining and leather shell',
                                  'instruction2':
                                      'Brush shearling gently with a soft-bristled brush to keep it fluffy',
                                  'instruction3':
                                      'Wipe leather with a damp cloth and mild leather cleaner for spot cleaning',
                                  'instruction4':
                                      'Store flat in a cool, dry place to avoid crushing the shearling',
                                  'instruction5':
                                      'Avoid exposure to direct sunlight to prevent fading and cracking',
                                },
                                {
                                  'title': 'Styling Suggestions',
                                  'subtitle':
                                      'Create rugged and cozy winter outfits',
                                  'instruction1':
                                      'Layer over a chunky knit sweater and cargo pants for a rugged winter look',
                                  'instruction2':
                                      'Pair with work boots and a wool beanie for outdoor adventures',
                                  'instruction3':
                                      'Add a scarf and leather gloves for extra warmth',
                                  'instruction4':
                                      'Wear with slim-fit jeans for a balanced silhouette',
                                },
                              ],
                            },
                            {
                              'imagePath': A.assets_paech_13,
                              'title': 'Minimalist Knitwear',
                              'description':
                                  'This sleek black knit sweater is a wardrobe essential, offering timeless style and versatile layering potential for both casual and polished looks.',
                              'tips': [
                                {
                                  'title': 'Care Instructions',
                                  'subtitle':
                                      'Keep your knitwear neat and well-shaped',
                                  'instruction1':
                                      'Hand wash in cold water with a mild wool detergent, or dry clean',
                                  'instruction2':
                                      'Lay flat to dry to avoid stretching and maintain shape',
                                  'instruction3':
                                      'Steam lightly to remove wrinkles; avoid ironing directly on the knit',
                                  'instruction4':
                                      'Fold and store in a drawer to prevent hanger bumps',
                                  'instruction5':
                                      'Use a lint roller regularly to keep the surface clean',
                                },
                                {
                                  'title': 'Styling Suggestions',
                                  'subtitle':
                                      'Versatile looks for casual and polished outfits',
                                  'instruction1':
                                      'Tuck into tailored trousers and add loafers for a minimalist office look',
                                  'instruction2':
                                      'Pair with wide-leg jeans and sneakers for a casual weekend outfit',
                                  'instruction3':
                                      'Layer under a blazer for added warmth and texture',
                                  'instruction4':
                                      'Accessorize with a leather belt and gold watch for a polished finish',
                                },
                              ],
                            },
                          ];

                          if (index >= 0 && index < items.length) {
                            Get.toNamed(
                              '/details',
                              arguments: items[index],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });

  final String title;
  final String subtitle;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              imagePath,
              width: 128,
              height: 160,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2A26),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8D857C),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PopularStylesCard extends StatelessWidget {
  const _PopularStylesCard({
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });

  final String title;
  final String subtitle;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              imagePath,
              width: 125,
              height: 160,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2D2A26),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF8D857C),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickTipCard extends StatelessWidget {
  const _QuickTipCard({
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });

  final String title;
  final String subtitle;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            imagePath,
            height: 130,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2D2A26),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF8D857C),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorsPickCard extends StatelessWidget {
  const _EditorsPickCard({
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });

  final String title;
  final String subtitle;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 560,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0xFFE4E0DA),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0xCC000000),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    subtitle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
