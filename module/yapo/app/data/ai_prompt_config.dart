/// AI 图生图 Prompt 配置
/// 用于生成带贴纸的个性化旅行纪念册照片
class AIPromptConfig {
  /// 系统提示词 - 定义 AI 的角色和任务
  static const String systemPrompt = '''
You are a creative travel scrapbook designer AI specialized in adding decorative stickers and themed elements to travel photos.

Your primary task: Transform ordinary travel photos into beautiful scrapbook-style album pages by adding:
- Location-themed decorative stickers (landmarks, flags, cultural icons)
- Travel-themed elements (stamps, tickets, postcards, cameras, airplanes, compasses)
- Decorative borders and frames
- Date stamps and location tags
- Handwritten-style text overlays
- Vintage travel aesthetic elements

Design principles:
1. STICKERS ARE ESSENTIAL - Every photo must have multiple decorative stickers
2. Match sticker themes to the location (Paris → Eiffel Tower stickers, Tokyo → Cherry blossom stickers)
3. Create a scrapbook/journal aesthetic with layered elements
4. Keep the original photo as the focal point, stickers should enhance not overwhelm
5. Use warm, nostalgic color palettes
6. Add subtle paper textures and vintage effects
7. Make it look handcrafted and personal

Sticker placement guidelines:
- Corner decorations (stamps, badges)
- Edge embellishments (washi tape, borders)
- Floating elements around the photo (small icons, stars, hearts)
- Location markers and date stamps
- Travel-themed icons scattered tastefully
''';

  /// 图生图的具体参数配置
  static Map<String, dynamic> getImageGenerationParams({
    required String imageUrl,
    required String prompt,
  }) {
    return {
      'model': 'gpt-4o-2024-05-13',
      'prompt': '$systemPrompt\n\n$prompt',
      'image': imageUrl,
      'n': 1,
      'size': '1024x1024',
      'response_format': 'b64_json',
    };
  }

  /// 根据位置生成主题贴纸关键词
  static String getLocationTheme(String location) {
    final locationLower = location.toLowerCase();

    if (locationLower.contains('paris') || locationLower.contains('巴黎')) {
      return 'Eiffel Tower stickers, French flag, croissant icons, beret, "Bonjour" text, Arc de Triomphe, love heart, romantic Paris theme';
    } else if (locationLower.contains('tokyo') || locationLower.contains('东京')) {
      return 'Cherry blossom stickers, Mount Fuji icon, Japanese flag, sushi emoji, lantern, torii gate, kawaii elements, anime-style decorations';
    } else if (locationLower.contains('london') || locationLower.contains('伦敦')) {
      return 'Big Ben sticker, red telephone box, Union Jack flag, tea cup, double-decker bus, crown, British theme';
    } else if (locationLower.contains('new york') || locationLower.contains('纽约')) {
      return 'Statue of Liberty sticker, yellow taxi, skyscraper icons, "I ❤️ NY", hot dog, American flag, urban theme';
    } else if (locationLower.contains('rome') || locationLower.contains('罗马')) {
      return 'Colosseum sticker, Italian flag, pizza slice, pasta, Roman column, gladiator helmet, ancient Rome theme';
    } else if (locationLower.contains('barcelona') || locationLower.contains('巴塞罗那')) {
      return 'Sagrada Familia sticker, Spanish flag, Gaudi mosaic patterns, paella, flamenco dancer, Mediterranean theme';
    } else if (locationLower.contains('dubai') || locationLower.contains('迪拜')) {
      return 'Burj Khalifa sticker, camel icon, desert dunes, palm tree, gold coin, luxury theme, Arabian nights';
    } else if (locationLower.contains('sydney') || locationLower.contains('悉尼')) {
      return 'Opera House sticker, kangaroo, koala, surfboard, Australian flag, beach theme, "G\'day mate"';
    } else if (locationLower.contains('beijing') || locationLower.contains('北京')) {
      return 'Great Wall sticker, Chinese flag, panda, lantern, dragon, Forbidden City, traditional Chinese elements';
    } else if (locationLower.contains('egypt') || locationLower.contains('埃及')) {
      return 'Pyramid sticker, sphinx, pharaoh, camel, hieroglyphics, scarab, ancient Egypt theme';
    } else {
      return 'Generic travel stickers: airplane, camera, compass, world map, passport stamp, suitcase, postcard, ticket stub, adventure badge';
    }
  }

  /// 生成增强版 Prompt（包含位置主题贴纸）
  static String generateEnhancedPrompt({
    required String location,
    required String date,
    required String description,
  }) {
    final theme = getLocationTheme(location);

    return '''
Create a beautiful travel scrapbook album page by adding decorative stickers and themed elements to this photo.

📍 LOCATION: $location
📅 DATE: $date
💭 MEMORY: $description

🎨 STICKER THEME PACK: $theme

DESIGN INSTRUCTIONS:

1. ADD LOCATION-THEMED STICKERS:
   - Main landmark sticker (e.g., Eiffel Tower for Paris)
   - Cultural icon stickers (flags, food, symbols)
   - 3-5 themed decorative stickers around the photo

2. ADD TRAVEL STICKERS:
   - Airplane or travel mode icon
   - Camera or photography element
   - Compass or map marker
   - Passport stamp or visa sticker
   - Suitcase or luggage tag

3. ADD DECORATIVE ELEMENTS:
   - Vintage postage stamps in corners
   - Washi tape or decorative borders
   - Date stamp badge
   - Location pin or tag
   - Small doodles (stars, hearts, arrows)

4. STYLE REQUIREMENTS:
   - Scrapbook/journal aesthetic
   - Vintage travel poster vibes
   - Warm, nostalgic color palette
   - Paper texture overlays
   - Handcrafted, personal feel
   - Stickers should look like they were carefully placed by hand

5. LAYOUT:
   - Keep original photo as the main focus (70% of space)
   - Stickers around edges and corners (30% of space)
   - Layered, collage-style composition
   - Some stickers can slightly overlap the photo edge
   - Create visual balance and harmony

OUTPUT: A complete travel album page that looks like a beautifully crafted scrapbook spread, with the photo enhanced by themed stickers and decorative elements. The result should evoke nostalgia and wanderlust, perfect for a personal travel journal or memory book.

IMPORTANT: The stickers and decorations are ESSENTIAL - this is not just photo editing, it's creating a scrapbook masterpiece!
''';
  }

  /// 生成 Story 描述的 Prompt
  /// 用于生成描述 AI 对图片做了什么处理的文字
  static String generateStoryPrompt({
    required String location,
    required String date,
    String? userDescription,
  }) {
    return '''
You are a creative travel photo editor AI. You have just enhanced a travel photo by adding decorative stickers, vintage filters, and scrapbook-style elements.

Write a brief, elegant description (2-3 sentences, around 50-80 words) explaining what artistic enhancements were applied to the photo. Focus on:

1. Color grading and filters (e.g., "warm, sun-kissed tones", "vintage filter", "nostalgic color palette")
2. Visual effects (e.g., "subtle bokeh effect", "softened background", "paper texture overlays")
3. Decorative elements (e.g., "themed stickers", "handcrafted borders", "vintage travel elements")
4. Overall aesthetic (e.g., "scrapbook masterpiece", "timeless adventure photo", "wanderlust and nostalgia")

Location: $location
Date: $date
${userDescription != null && userDescription.isNotEmpty ? 'User Memory: $userDescription' : ''}

Write in English, in a poetic and descriptive style. Start with "The AI" and describe what was done to enhance the photo. Make it sound professional and artistic.

Example style:
"The AI bathes the desert scene in warm, sun-kissed tones, adding a subtle vintage filter that evokes the timeless feel of a classic adventure photo. The background is softened with a gentle bokeh effect to keep focus on the camel and explorer, creating a sense of wanderlust and nostalgia."

Now write a similar description for this photo:
''';
  }

}
