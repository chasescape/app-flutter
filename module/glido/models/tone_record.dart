class ToneRecord {
  final String id;
  final String presetName;
  final String sceneTag;
  final String mainMood;
  final String toolUsed;
  final DateTime lastUpdated;
  final String? beforeImagePath;
  final String? afterImagePath;
  final Map<String, dynamic> parameters;
  final String? detailNotes;

  ToneRecord({
    required this.id,
    required this.presetName,
    required this.sceneTag,
    required this.mainMood,
    required this.toolUsed,
    required this.lastUpdated,
    this.beforeImagePath,
    this.afterImagePath,
    required this.parameters,
    this.detailNotes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'presetName': presetName,
      'sceneTag': sceneTag,
      'mainMood': mainMood,
      'toolUsed': toolUsed,
      'lastUpdated': lastUpdated.toIso8601String(),
      'beforeImagePath': beforeImagePath,
      'afterImagePath': afterImagePath,
      'parameters': parameters,
      'detailNotes': detailNotes,
    };
  }

  factory ToneRecord.fromJson(Map<String, dynamic> json) {
    return ToneRecord(
      id: json['id'] as String,
      presetName: json['presetName'] as String,
      sceneTag: json['sceneTag'] as String,
      mainMood: json['mainMood'] as String,
      toolUsed: json['toolUsed'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      beforeImagePath: json['beforeImagePath'] as String?,
      afterImagePath: json['afterImagePath'] as String?,
      parameters: json['parameters'] as Map<String, dynamic>,
      detailNotes: json['detailNotes'] as String?,
    );
  }

  String getParameterSummary() {
    final buffer = StringBuffer();
    buffer.writeln('📸 $presetName');
    buffer.writeln('Scene: $sceneTag | Mood: $mainMood');
    buffer.writeln('Tool: $toolUsed');
    buffer.writeln();
    buffer.writeln('Parameters:');
    parameters.forEach((key, value) {
      buffer.writeln('  $key: $value');
    });
    if (detailNotes != null && detailNotes!.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Notes: $detailNotes');
    }
    return buffer.toString();
  }

  ToneRecord copyWith({
    String? id,
    String? presetName,
    String? sceneTag,
    String? mainMood,
    String? toolUsed,
    DateTime? lastUpdated,
    String? beforeImagePath,
    String? afterImagePath,
    Map<String, dynamic>? parameters,
    String? detailNotes,
  }) {
    return ToneRecord(
      id: id ?? this.id,
      presetName: presetName ?? this.presetName,
      sceneTag: sceneTag ?? this.sceneTag,
      mainMood: mainMood ?? this.mainMood,
      toolUsed: toolUsed ?? this.toolUsed,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      beforeImagePath: beforeImagePath ?? this.beforeImagePath,
      afterImagePath: afterImagePath ?? this.afterImagePath,
      parameters: parameters ?? this.parameters,
      detailNotes: detailNotes ?? this.detailNotes,
    );
  }
}
