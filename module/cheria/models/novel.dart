import 'package:syncfusion_flutter_charts/charts.dart';

/// Novel Status Enum
enum NovelStatus {
  toRead('To Read'),
  reading('Reading'),
  finished('Finished'),
  paused('Paused'),
  dropped('Dropped');

  final String label;
  const NovelStatus(this.label);

  static NovelStatus fromString(String value) {
    return NovelStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NovelStatus.toRead,
    );
  }
}

/// Novel Genre Enum
enum NovelGenre {
  fantasy('Fantasy'),
  romance('Romance'),
  scifi('Sci-Fi'),
  mystery('Mystery'),
  horror('Horror'),
  thriller('Thriller'),
  literary('Literary'),
  historical('Historical'),
  other('Other');

  final String label;
  const NovelGenre(this.label);

  static NovelGenre fromString(String value) {
    return NovelGenre.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NovelGenre.other,
    );
  }
}

/// Character Model
class Character {
  final String id;
  final String name;
  final String? role;
  final String? notes;
  final DateTime createdAt;

  Character({
    required this.id,
    required this.name,
    this.role,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Character copyWith({
    String? id,
    String? name,
    String? role,
    String? notes,
    DateTime? createdAt,
  }) {
    return Character(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Novel Model
class Novel {
  final String id;
  final String title;
  final String author;
  final NovelGenre genre;
  final NovelStatus status;
  final List<Character> characters;
  final String? coverImagePath;
  final String? plotSummary;
  final DateTime? startDate;
  final DateTime? finishDate;
  final int? readingMinutes; // Estimated reading time in minutes
  final DateTime createdAt;
  final DateTime updatedAt;

  Novel({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.status,
    List<Character>? characters,
    this.coverImagePath,
    this.plotSummary,
    this.startDate,
    this.finishDate,
    this.readingMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : characters = characters ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Getters for display
  String get genreLabel => genre.label;
  String get statusLabel => status.label;
  bool get isFinished => status == NovelStatus.finished;
  bool get isReading => status == NovelStatus.reading;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'genre': genre.name,
      'status': status.name,
      'characters': characters.map((c) => c.toJson()).toList(),
      'coverImagePath': coverImagePath,
      'plotSummary': plotSummary,
      'startDate': startDate?.toIso8601String(),
      'finishDate': finishDate?.toIso8601String(),
      'readingMinutes': readingMinutes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Novel.fromJson(Map<String, dynamic> json) {
    return Novel(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      genre: NovelGenre.fromString(json['genre'] as String? ?? 'other'),
      status: NovelStatus.fromString(json['status'] as String? ?? 'toRead'),
      characters: (json['characters'] as List<dynamic>?)
              ?.map((c) => Character.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      coverImagePath: json['coverImagePath'] as String?,
      plotSummary: json['plotSummary'] as String?,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      finishDate: json['finishDate'] != null
          ? DateTime.parse(json['finishDate'] as String)
          : null,
      readingMinutes: json['readingMinutes'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Novel copyWith({
    String? id,
    String? title,
    String? author,
    NovelGenre? genre,
    NovelStatus? status,
    List<Character>? characters,
    String? coverImagePath,
    String? plotSummary,
    DateTime? startDate,
    DateTime? finishDate,
    int? readingMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Novel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      status: status ?? this.status,
      characters: characters ?? this.characters,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      plotSummary: plotSummary ?? this.plotSummary,
      startDate: startDate ?? this.startDate,
      finishDate: finishDate ?? this.finishDate,
      readingMinutes: readingMinutes ?? this.readingMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Reading Statistics Data
class ReadingStats {
  final int totalBooks;
  final int finishedBooks;
  final int readingBooks;
  final int totalReadingMinutes;
  final int currentMonthBooks;
  final int currentYearBooks;
  final List<MonthlyData> monthlyData;

  const ReadingStats({
    required this.totalBooks,
    required this.finishedBooks,
    required this.readingBooks,
    required this.totalReadingMinutes,
    required this.currentMonthBooks,
    required this.currentYearBooks,
    required this.monthlyData,
  });

  // Getters for display
  int get totalReadingHours => (totalReadingMinutes / 60).floor();
  String get totalReadingTimeDisplay {
    final hours = totalReadingMinutes ~/ 60;
    final minutes = totalReadingMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  Map<String, dynamic> toJson() {
    return {
      'totalBooks': totalBooks,
      'finishedBooks': finishedBooks,
      'readingBooks': readingBooks,
      'totalReadingMinutes': totalReadingMinutes,
      'currentMonthBooks': currentMonthBooks,
      'currentYearBooks': currentYearBooks,
      'monthlyData': monthlyData.map((d) => d.toJson()).toList(),
    };
  }

  factory ReadingStats.fromJson(Map<String, dynamic> json) {
    return ReadingStats(
      totalBooks: json['totalBooks'] as int? ?? 0,
      finishedBooks: json['finishedBooks'] as int? ?? 0,
      readingBooks: json['readingBooks'] as int? ?? 0,
      totalReadingMinutes: json['totalReadingMinutes'] as int? ?? 0,
      currentMonthBooks: json['currentMonthBooks'] as int? ?? 0,
      currentYearBooks: json['currentYearBooks'] as int? ?? 0,
      monthlyData: (json['monthlyData'] as List<dynamic>?)
              ?.map((d) => MonthlyData.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Monthly Data for Charts
class MonthlyData {
  final String month;
  final int booksRead;
  final int minutesRead;

  const MonthlyData({
    required this.month,
    required this.booksRead,
    required this.minutesRead,
  });

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'booksRead': booksRead,
      'minutesRead': minutesRead,
    };
  }

  factory MonthlyData.fromJson(Map<String, dynamic> json) {
    return MonthlyData(
      month: json['month'] as String,
      booksRead: json['booksRead'] as int? ?? 0,
      minutesRead: json['minutesRead'] as int? ?? 0,
    );
  }

  // Convert to chart data point
  ChartData toChartData() {
    return ChartData(month, booksRead.toDouble());
  }
}

/// Achievement Model
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    this.unlockedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
    );
  }
}

/// Chart Data Point for Syncfusion Charts
class ChartData {
  final String category;
  final double value;

  const ChartData(this.category, this.value);
}
