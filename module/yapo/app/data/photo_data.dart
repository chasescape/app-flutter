import '../../../gen_a/A.dart';

/// 照片信息模型
class PhotoInfo {
  final String id;
  final String imagePath;
  final String title;
  final String location;
  final String date;
  final List<String> highlights;
  final String story;
  final String? time;
  final String? weather;
  final List<String>? tags;

  const PhotoInfo({
    required this.id,
    required this.imagePath,
    required this.title,
    required this.location,
    required this.date,
    required this.highlights,
    required this.story,
    this.time,
    this.weather,
    this.tags,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image': imagePath,
      'title': title,
      'location': location,
      'date': date,
      'highlights': highlights,
      'story': story,
      'time': time,
      'weather': weather,
      'tags': tags,
    };
  }
}

/// 预定义的照片数据
class PhotoDataSource {
  static final List<PhotoInfo> allPhotos = [
    PhotoInfo(
      id: '1',
      imagePath: A.assets_yapo_01_0,
      title: 'Sahara Adventure',
      location: 'Sahara Desert, Morocco',
      date: 'March 28, 2026',
      highlights: ['Warm Tones', 'Soft Focus', 'Vintage Filter'],
      story: 'The AI bathes the desert scene in warm, sun-kissed tones, adding a subtle vintage filter that evokes the timeless feel of a classic adventure photo. The background is softened with a gentle bokeh effect to keep focus on the camel and explorer, creating a sense of wanderlust and nostalgia.',
      time: '4:15 PM',
      weather: 'Sunny, 32°C',
      tags: ['#Desert', '#Camel', '#Adventure', '#Wanderlust', '#Sunset'],
    ),
    PhotoInfo(
      id: '2',
      imagePath: A.assets_yapo_02_0,
      title: 'European Manor',
      location: 'Tuscany, Italy',
      date: 'May 14, 2025',
      highlights: ['Pastel Gradient', 'Floral Accent', 'Storybook Frame'],
      story: 'The AI applies a soft pastel color gradient to the villa, enhancing the romantic, storybook feel of the European countryside. Delicate floral accents are subtly amplified around the manor, and a vintage-style border is added to give the image a timeless, scrapbook-like charm.',
      time: '10:30 AM',
      weather: 'Partly Cloudy, 18°C',
      tags: ['#Villa', '#Tuscany', '#Europe', '#Floral', '#History'],
    ),
    PhotoInfo(
      id: '3',
      imagePath: A.assets_yapo_03_0,
      title: 'Barcelona Journey',
      location: 'Barcelona, Spain',
      date: 'June 22, 2025',
      highlights: ['Sketch Overlay', 'Warm Golden Glow', 'Depth Enhancement'],
      story: 'The AI blends a delicate line-art sketch of the Sagrada Família into the background, adding an artistic layer that highlights the landmark\'s architectural details. A warm golden glow is cast over the scene to mirror the Spanish sunlight, while depth enhancement makes the subject stand out against the iconic cathedral.',
      time: '5:45 PM',
      weather: 'Clear Sky, 24°C',
      tags: ['#Barcelona', '#Gaudi', '#Cathedral', '#Travel', '#Art'],
    ),
    PhotoInfo(
      id: '4',
      imagePath: A.assets_yapo_04_0,
      title: 'Western Horseback',
      location: 'Wyoming, USA',
      date: 'July 10, 2025',
      highlights: ['Film Grain', 'Dynamic Contrast', 'Warm Sunset Hues'],
      story: 'The AI adds a subtle film grain texture to evoke the rugged, nostalgic feel of classic Western photography. Dynamic contrast is used to make the black horse and rider pop against the golden prairie, while warm sunset hues amplify the sense of adventure and freedom.',
      time: '7:15 PM',
      weather: 'Clear Sky, 21°C',
      tags: ['#Western', '#Horse', '#Prairie', '#Adventure', '#Sunset'],
    ),
    PhotoInfo(
      id: '5',
      imagePath: A.assets_yapo_05_0,
      title: 'Paris Memories',
      location: 'Paris, France',
      date: 'September 5, 2025',
      highlights: ['Golden Hour Warmth', 'Bokeh Lights', 'Dreamy Softness'],
      story: 'The AI cranks up the golden-hour warmth of the sunset, painting the Eiffel Tower in rich oranges and pinks. A soft bokeh effect is added to the city lights in the background, creating a dreamy, romantic atmosphere that captures the essence of Paris as the City of Light.',
      time: '6:30 PM',
      weather: 'Clear Sky, 16°C',
      tags: ['#Paris', '#EiffelTower', '#Romance', '#City', '#Sunset'],
    ),
    PhotoInfo(
      id: '6',
      imagePath: A.assets_yapo_06_0,
      title: 'Lake View Terrace',
      location: 'Lake Como, Italy',
      date: 'April 18, 2026',
      highlights: ['Scrapbook Overlays', 'Soft Pastels', 'Depth Layering'],
      story: 'The AI adds vintage travel-themed stickers like a suitcase, camera, and map to create a playful scrapbook aesthetic. Soft pastel tones enhance the tranquil lakeside setting, while depth layering makes the terrace feel immersive and cozy.',
      time: '9:20 AM',
      weather: 'Partly Cloudy, 16°C',
      tags: ['#Lake', '#Terrace', '#Italy', '#Tranquility', '#Scrapbook'],
    ),
    PhotoInfo(
      id: '7',
      imagePath: A.assets_yapo_07_0,
      title: 'Coastal Getaway',
      location: 'Mykonos, Greece',
      date: 'June 3, 2025',
      highlights: ['Vibrant Blues', 'Tropical Accents', 'Warm Highlights'],
      story: 'The AI amplifies the vivid blues of the Aegean Sea and sky, adding subtle tropical leaf overlays to enhance the vacation vibe. Warm golden highlights are applied to the sunlit terrace, making the scene feel bright and inviting.',
      time: '5:10 PM',
      weather: 'Sunny, 27°C',
      tags: ['#Coast', '#Greece', '#Vacation', '#Ocean', '#Terrace'],
    ),
    PhotoInfo(
      id: '8',
      imagePath: A.assets_yapo_08_0,
      title: 'Cappadocia Journey',
      location: 'Cappadocia, Turkey',
      date: 'August 15, 2025',
      highlights: ['Earthy Tones', 'Balloon Accents', 'Textured Borders'],
      story: 'The AI enriches the warm, earthy hues of the Cappadocia rock formations, adding a hot air balloon graphic to emphasize the region\'s iconic scenery. A textured, vintage-style border frames the image, giving it a timeless travel-postcard feel.',
      time: '10:00 AM',
      weather: 'Clear Sky, 22°C',
      tags: ['#Cappadocia', '#Turkey', '#Balloon', '#Rock', '#Journey'],
    ),
    PhotoInfo(
      id: '9',
      imagePath: A.assets_yapo_09_0,
      title: 'South Africa Adventure',
      location: 'Kruger National Park, South Africa',
      date: 'September 22, 2025',
      highlights: ['Safari Filter', 'Warm Earth Tones', 'Vintage Map Overlay'],
      story: 'The AI applies a warm, earthy safari filter to capture the rugged beauty of the African wilderness, adding a subtle vintage map graphic to reinforce the adventure theme. Soft focus on the background highlights the explorer and natural surroundings.',
      time: '4:30 PM',
      weather: 'Sunny, 29°C',
      tags: ['#Safari', '#Africa', '#Wilderness', '#Adventure', '#Nature'],
    ),
    PhotoInfo(
      id: '10',
      imagePath: A.assets_yapo_10_0,
      title: 'Desert Camel Journey',
      location: 'Wadi Rum, Jordan',
      date: 'October 8, 2025',
      highlights: ['Golden Sand Tones', 'Soft Glow', 'Curved Borders'],
      story: 'The AI enhances the golden warmth of the desert sands, adding a soft, sunlit glow to create a dreamlike atmosphere. A curved, retro-style border frames the scene, giving it a nostalgic, storybook quality that highlights the camel ride experience.',
      time: '3:45 PM',
      weather: 'Clear Sky, 34°C',
      tags: ['#Desert', '#Camel', '#Jordan', '#Adventure', '#Sand'],
    ),
    PhotoInfo(
      id: '11',
      imagePath: A.assets_yapo_11_0,
      title: 'Desert Falcon Odyssey',
      location: 'Wadi Rum, Jordan',
      date: 'March 12, 2026',
      highlights: ['Warm Sand Tones', 'Bold Contrast', 'Desert-Themed Overlays'],
      story: 'The AI deepens the golden hues of the desert sand, creating bold contrast between the subject, falcon, and backdrop. Subtle camel and palm tree graphics are added to reinforce the desert adventure theme, with a retro text overlay that evokes a classic explorer vibe.',
      time: '2:15 PM',
      weather: 'Sunny, 35°C',
      tags: ['#Desert', '#Falcon', '#Jordan', '#Adventure', '#Wild'],
    ),
    PhotoInfo(
      id: '12',
      imagePath: A.assets_yapo_12_0,
      title: 'Yacht Adventure',
      location: 'French Riviera, France',
      date: 'July 28, 2025',
      highlights: ['Vibrant Ocean Blues', 'Nautical Accents', 'Sunny Highlights'],
      story: 'The AI intensifies the deep blues of the Mediterranean Sea and sky, adding nautical elements like anchors and wave graphics to enhance the luxury yacht vibe. Bright, sunny highlights are applied to the deck and harbor, making the scene feel crisp and vibrant.',
      time: '4:45 PM',
      weather: 'Clear Sky, 26°C',
      tags: ['#Yacht', '#Riviera', '#France', '#Luxury', '#Ocean'],
    ),
    PhotoInfo(
      id: '13',
      imagePath: A.assets_yapo_13_0,
      title: 'European Courtyard Journey',
      location: 'Tuscany, Italy',
      date: 'May 6, 2025',
      highlights: ['Vintage Map Overlay', 'Soft Warm Tones', 'Architectural Accents'],
      story: 'The AI overlays a faded vintage map border to evoke a sense of timeless travel, while enhancing the warm, earthy tones of the stone courtyard. Delicate line-art details of the fountain and architecture are added to highlight the classic European charm.',
      time: '11:00 AM',
      weather: 'Partly Cloudy, 19°C',
      tags: ['#Courtyard', '#Italy', '#Europe', '#History', '#Fountain'],
    ),
    PhotoInfo(
      id: '14',
      imagePath: A.assets_yapo_14_0,
      title: 'Lake Como Journey',
      location: 'Lake Como, Italy',
      date: 'June 19, 2025',
      highlights: ['Vivid Greens & Blues', 'Luminous Glow', 'Scenic Depth'],
      story: 'The AI amplifies the vibrant greens of the gardens and deep blues of the lake, adding a soft luminous glow to the villa and shoreline to enhance the sense of elegance. Scenic depth is boosted to make the layered landscape feel immersive and luxurious.',
      time: '5:30 PM',
      weather: 'Clear Sky, 23°C',
      tags: ['#LakeComo', '#Italy', '#Villa', '#Nature', '#Elegance'],
    ),
    PhotoInfo(
      id: '15',
      imagePath: A.assets_yapo_15_0,
      title: 'Urban Street View',
      location: 'Tokyo, Japan',
      date: 'August 3, 2025',
      highlights: ['Retro Film Grain', 'Urban Contrast', 'Polaroid Overlays'],
      story: 'The AI applies a subtle retro film grain texture to capture the cool, modern edge of city streets, with a polaroid camera graphic overlay to emphasize the "capture the moment" theme. Bold contrast makes the subject stand out against the sleek urban backdrop.',
      time: '3:20 PM',
      weather: 'Partly Cloudy, 25°C',
      tags: ['#Tokyo', '#Street', '#Urban', '#City', '#Vibe'],
    ),
  ];

  /// 获取精选照片（前6张）
  static List<PhotoInfo> get featuredPhotos =>
      allPhotos.skip(6).take(8).toList();

  /// 获取 All Memories 网格显示的照片（只显示前6张）
  static List<PhotoInfo> get gridPhotos => allPhotos.take(6).toList();

  /// 获取编辑推荐照片（取第13张 - Machu Picchu）
  static PhotoInfo get spotlightPhoto => allPhotos[14];  // 索引12 = 第13张（Machu Picchu）

  /// 根据ID获取照片
  static PhotoInfo? getPhotoById(String id) {
    try {
      return allPhotos.firstWhere((photo) => photo.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 获取所有照片的Map格式（用于兼容现有代码）
  static List<Map<String, dynamic>> get allPhotosMap =>
      allPhotos.map((photo) => photo.toMap()).toList();

  /// 获取 All Memories 网格照片的Map格式（只显示前6张）
  static List<Map<String, dynamic>> get gridPhotosMap =>
      gridPhotos.map((photo) => photo.toMap()).toList();

  /// 获取精选照片的Map格式
  static List<Map<String, dynamic>> get featuredPhotosMap =>
      featuredPhotos.map((photo) => photo.toMap()).toList();
}
