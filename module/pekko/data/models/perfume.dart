import 'perfume_record.dart';

/// Perfume model
class Perfume {
  final String id;
  final String name;
  final String brand;
  final String? imageUrl;
  final PerfumeNote primaryNote;
  final List<PerfumeNote> notes;
  final String? description;
  final DateTime createdAt;

  Perfume({
    required this.id,
    required this.name,
    required this.brand,
    this.imageUrl,
    required this.primaryNote,
    required this.notes,
    this.description,
    required this.createdAt,
  });

  factory Perfume.fromJson(Map<String, dynamic> json) {
    return Perfume(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      imageUrl: json['imageUrl'] as String?,
      primaryNote: PerfumeNote.values.firstWhere(
        (e) => e.name == json['primaryNote'],
        orElse: () => PerfumeNote.floral,
      ),
      notes: (json['notes'] as List<dynamic>?)
              ?.map((e) => PerfumeNote.values.firstWhere(
                    (n) => n.name == e,
                    orElse: () => PerfumeNote.floral,
                  ))
              .toList() ??
          [],
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'imageUrl': imageUrl,
      'primaryNote': primaryNote.name,
      'notes': notes.map((e) => e.name).toList(),
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get fullName => '$brand $name';
}
