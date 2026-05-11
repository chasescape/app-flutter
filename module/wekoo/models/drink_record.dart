class DrinkRecord {
  final String id;
  final DateTime dateTime;
  final int amount;
  final String? note;

  DrinkRecord({
    required this.id,
    required this.dateTime,
    required this.amount,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'amount': amount,
      'note': note,
    };
  }

  factory DrinkRecord.fromJson(Map<String, dynamic> json) {
    return DrinkRecord(
      id: json['id'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      amount: json['amount'] as int,
      note: json['note'] as String?,
    );
  }

  DrinkRecord copyWith({
    String? id,
    DateTime? dateTime,
    int? amount,
    String? note,
  }) {
    return DrinkRecord(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      amount: amount ?? this.amount,
      note: note ?? this.note,
    );
  }
}
