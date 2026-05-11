import 'package:intl/intl.dart';

/// Perfume usage record model
class PerfumeRecord {
  final String id;
  final String perfumeName;
  final String brand;
  final String? imageUrl;
  final PerfumeNote noteType;
  final UsageScene scene;
  final TimeOfDayType timeOfDay;
  final Season season;
  final int longevity; // hours
  final int moodRating; // 1-5 stars
  final String? notes;
  final String? outfit;
  final String? weather;
  final DateTime createdAt;
  final int? compliments;

  PerfumeRecord({
    required this.id,
    required this.perfumeName,
    required this.brand,
    this.imageUrl,
    required this.noteType,
    required this.scene,
    required this.timeOfDay,
    required this.season,
    required this.longevity,
    required this.moodRating,
    this.notes,
    this.outfit,
    this.weather,
    required this.createdAt,
    this.compliments,
  });

  factory PerfumeRecord.fromJson(Map<String, dynamic> json) {
    return PerfumeRecord(
      id: json['id'] as String,
      perfumeName: json['perfumeName'] as String,
      brand: json['brand'] as String,
      imageUrl: json['imageUrl'] as String?,
      noteType: PerfumeNote.values.firstWhere(
        (e) => e.name == json['noteType'],
        orElse: () => PerfumeNote.floral,
      ),
      scene: UsageScene.values.firstWhere(
        (e) => e.name == json['scene'],
        orElse: () => UsageScene.work,
      ),
      timeOfDay: TimeOfDayType.values.firstWhere(
        (e) => e.name == json['timeOfDay'],
        orElse: () => TimeOfDayType.morning,
      ),
      season: Season.values.firstWhere(
        (e) => e.name == json['season'],
        orElse: () => Season.spring,
      ),
      longevity: json['longevity'] as int,
      moodRating: json['moodRating'] as int,
      notes: json['notes'] as String?,
      outfit: json['outfit'] as String?,
      weather: json['weather'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      compliments: json['compliments'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'perfumeName': perfumeName,
      'brand': brand,
      'imageUrl': imageUrl,
      'noteType': noteType.name,
      'scene': scene.name,
      'timeOfDay': timeOfDay.name,
      'season': season.name,
      'longevity': longevity,
      'moodRating': moodRating,
      'notes': notes,
      'outfit': outfit,
      'weather': weather,
      'createdAt': createdAt.toIso8601String(),
      'compliments': compliments,
    };
  }

  PerfumeRecord copyWith({
    String? id,
    String? perfumeName,
    String? brand,
    String? imageUrl,
    PerfumeNote? noteType,
    UsageScene? scene,
    TimeOfDayType? timeOfDay,
    Season? season,
    int? longevity,
    int? moodRating,
    String? notes,
    String? outfit,
    String? weather,
    DateTime? createdAt,
    int? compliments,
  }) {
    return PerfumeRecord(
      id: id ?? this.id,
      perfumeName: perfumeName ?? this.perfumeName,
      brand: brand ?? this.brand,
      imageUrl: imageUrl ?? this.imageUrl,
      noteType: noteType ?? this.noteType,
      scene: scene ?? this.scene,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      season: season ?? this.season,
      longevity: longevity ?? this.longevity,
      moodRating: moodRating ?? this.moodRating,
      notes: notes ?? this.notes,
      outfit: outfit ?? this.outfit,
      weather: weather ?? this.weather,
      createdAt: createdAt ?? this.createdAt,
      compliments: compliments ?? this.compliments,
    );
  }

  String get formattedDate => DateFormat('MMM d, y').format(createdAt);
  String get formattedTime => DateFormat('HH:mm').format(createdAt);
}

/// Perfume note/family type
enum PerfumeNote {
  floral('Floral'),
  woody('Woody'),
  oriental('Oriental'),
  citrus('Citrus'),
  fresh('Fresh'),
  gourmand('Gourmand'),
  green('Green'),
  spicy('Spicy');

  final String displayName;
  const PerfumeNote(this.displayName);
}

/// Usage scene/occasion
enum UsageScene {
  work('Work'),
  date('Date'),
  casual('Casual'),
  party('Party'),
  sports('Sports'),
  formal('Formal'),
  relaxation('Relaxation');

  final String displayName;
  const UsageScene(this.displayName);
}

/// Time of day
enum TimeOfDayType {
  morning('Morning'),
  afternoon('Afternoon'),
  evening('Evening'),
  night('Night');

  final String displayName;
  const TimeOfDayType(this.displayName);
}

/// Season
enum Season {
  spring('Spring'),
  summer('Summer'),
  autumn('Autumn'),
  winter('Winter');

  final String displayName;
  const Season(this.displayName);
}
