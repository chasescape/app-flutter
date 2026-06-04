import 'dart:convert';

/// Bead record status
enum BeadStatus {
  planned,
  inProgress,
  finished,
}

/// Image type for bead records
enum ImageType { finished, pattern }

/// Bead theme categories
enum BeadTheme {
  character,
  animal,
  food,
  holiday,
  gameIcon,
  pixelStyle,
  custom,
}

/// Bead record model
class BeadRecord {
  final String id;
  final String title;
  final BeadTheme theme;
  final BeadStatus status;
  final String? finishedImagePath;
  final String? patternImagePath;
  final int beadCount;
  final List<String> mainColors;
  final DateTime? finishedDate;
  final String? notes;
  final DateTime createdAt;

  BeadRecord({
    required this.id,
    required this.title,
    required this.theme,
    required this.status,
    this.finishedImagePath,
    this.patternImagePath,
    this.beadCount = 0,
    this.mainColors = const [],
    this.finishedDate,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  BeadRecord copyWith({
    String? id,
    String? title,
    BeadTheme? theme,
    BeadStatus? status,
    String? finishedImagePath,
    String? patternImagePath,
    int? beadCount,
    List<String>? mainColors,
    DateTime? finishedDate,
    String? notes,
    DateTime? createdAt,
  }) {
    return BeadRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      theme: theme ?? this.theme,
      status: status ?? this.status,
      finishedImagePath: finishedImagePath ?? this.finishedImagePath,
      patternImagePath: patternImagePath ?? this.patternImagePath,
      beadCount: beadCount ?? this.beadCount,
      mainColors: mainColors ?? this.mainColors,
      finishedDate: finishedDate ?? this.finishedDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'theme': theme.name,
      'status': status.name,
      'finishedImagePath': finishedImagePath,
      'patternImagePath': patternImagePath,
      'beadCount': beadCount,
      'mainColors': mainColors,
      'finishedDate': finishedDate?.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BeadRecord.fromJson(Map<String, dynamic> json) {
    return BeadRecord(
      id: json['id'] as String,
      title: json['title'] as String,
      theme: BeadTheme.values.firstWhere(
        (e) => e.name == json['theme'],
        orElse: () => BeadTheme.custom,
      ),
      status: BeadStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BeadStatus.planned,
      ),
      finishedImagePath: json['finishedImagePath'] as String?,
      patternImagePath: json['patternImagePath'] as String?,
      beadCount: json['beadCount'] as int? ?? 0,
      mainColors: List<String>.from(json['mainColors'] as List? ?? []),
      finishedDate: json['finishedDate'] != null
          ? DateTime.parse(json['finishedDate'] as String)
          : null,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  String get themeDisplayName {
    switch (theme) {
      case BeadTheme.character:
        return 'Character';
      case BeadTheme.animal:
        return 'Animal';
      case BeadTheme.food:
        return 'Food';
      case BeadTheme.holiday:
        return 'Holiday';
      case BeadTheme.gameIcon:
        return 'Game Icon';
      case BeadTheme.pixelStyle:
        return 'Pixel Style';
      case BeadTheme.custom:
        return 'Custom';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case BeadStatus.planned:
        return 'Planned';
      case BeadStatus.inProgress:
        return 'In Progress';
      case BeadStatus.finished:
        return 'Finished';
    }
  }

  bool get isFinished => status == BeadStatus.finished;
}
