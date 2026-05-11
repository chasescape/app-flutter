class EquipmentModel {
  final String id;
  final String equipmentName;
  final String date;
  final String status;
  final String riskLevel;
  final String image;
  final int coinsUsed;
  final int condition;
  final int safety;
  final String wearLevel;
  final String aiAnalysis;
  final String type;
  final List<String> issuesFound;
  final List<String> recommendations;

  EquipmentModel({
    required this.id,
    required this.equipmentName,
    required this.date,
    required this.status,
    required this.riskLevel,
    required this.image,
    required this.coinsUsed,
    required this.condition,
    required this.safety,
    required this.wearLevel,
    required this.aiAnalysis,
    required this.type,
    required this.issuesFound,
    required this.recommendations,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'equipmentName': equipmentName,
      'date': date,
      'status': status,
      'riskLevel': riskLevel,
      'image': image,
      'coinsUsed': coinsUsed,
      'condition': condition,
      'safety': safety,
      'wearLevel': wearLevel,
      'aiAnalysis': aiAnalysis,
      'type': type,
      'issuesFound': issuesFound,
      'recommendations': recommendations,
    };
  }

  factory EquipmentModel.fromMap(Map<String, dynamic> map) {
    return EquipmentModel(
      id: (map['id'] ?? '').toString(),
      equipmentName: (map['equipmentName'] ?? '').toString(),
      date: (map['date'] ?? '').toString(),
      status: (map['status'] ?? '').toString(),
      riskLevel: (map['riskLevel'] ?? '').toString(),
      image: (map['image'] ?? '').toString(),
      coinsUsed: map['coinsUsed'] is int
          ? map['coinsUsed'] as int
          : int.tryParse(map['coinsUsed']?.toString() ?? '0') ?? 0,
      condition: map['condition'] is int
          ? map['condition'] as int
          : int.tryParse(map['condition']?.toString() ?? '0') ?? 0,
      safety: map['safety'] is int
          ? map['safety'] as int
          : int.tryParse(map['safety']?.toString() ?? '0') ?? 0,
      wearLevel: (map['wearLevel'] ?? '').toString(),
      aiAnalysis: (map['aiAnalysis'] ?? '').toString(),
      type: (map['type'] ?? '').toString(),
      issuesFound: _parseStringList(map['issuesFound']),
      recommendations: _parseStringList(map['recommendations']),
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return <String>[];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    // 兼容用分号或逗号拼接的字符串
    final str = value.toString();
    if (str.isEmpty) return <String>[];
    final split = str.split(RegExp(r'[;,]'));
    return split.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }
}
