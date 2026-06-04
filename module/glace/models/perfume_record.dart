class PerfumeRecord {
  final String id;
  final String brandName;
  final String perfumeName;
  final String scentFamily;
  final String occasion;
  final String? mood;
  final int rating;
  final String? note;
  final String? photoPath;
  final DateTime createdAt;

  const PerfumeRecord({
    required this.id,
    required this.brandName,
    required this.perfumeName,
    required this.scentFamily,
    required this.occasion,
    this.mood,
    required this.rating,
    this.note,
    this.photoPath,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'brandName': brandName,
        'perfumeName': perfumeName,
        'scentFamily': scentFamily,
        'occasion': occasion,
        'mood': mood,
        'rating': rating,
        'note': note,
        'photoPath': photoPath,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PerfumeRecord.fromJson(Map<String, dynamic> json) => PerfumeRecord(
        id: json['id'] as String,
        brandName: json['brandName'] as String,
        perfumeName: json['perfumeName'] as String,
        scentFamily: json['scentFamily'] as String,
        occasion: json['occasion'] as String,
        mood: json['mood'] as String?,
        rating: json['rating'] as int,
        note: json['note'] as String?,
        photoPath: json['photoPath'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class ScentConstants {
  static const List<String> scentFamilies = [
    'Floral',
    'Woody',
    'Fresh',
    'Oriental',
    'Citrus',
    'Gourmand',
    'Aquatic',
  ];

  static const List<String> occasions = [
    'Date',
    'Work',
    'Casual',
    'Party',
    'Gym',
    'Outdoor',
    'Bedtime',
  ];

  static const List<String> moods = [
    'Confident',
    'Relaxed',
    'Romantic',
    'Energetic',
    'Cozy',
  ];
}
