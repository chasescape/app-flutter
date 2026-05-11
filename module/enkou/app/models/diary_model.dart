class DiaryModel {
  final String id;
  final String title;
  final String subtitle;
  final String distance;
  final String imagePath; // 改为单张图片
  final List<String> tags; // 添加标签
  final DateTime createdAt;
  final DateTime? updatedAt;

  DiaryModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.distance,
    required this.imagePath,
    required this.tags,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'distance': distance,
      'imagePath': imagePath,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory DiaryModel.fromJson(Map<String, dynamic> json) {
    return DiaryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      distance: json['distance'] as String,
      imagePath: json['imagePath'] as String,
      tags: List<String>.from(json['tags'] as List? ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  DiaryModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? distance,
    String? imagePath,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiaryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      distance: distance ?? this.distance,
      imagePath: imagePath ?? this.imagePath,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
