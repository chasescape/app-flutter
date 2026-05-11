import 'package:intl/intl.dart';

class CheckInRecord {
  final String id;
  final DateTime checkInTime;
  final int streak;
  final String motivationalQuote;
  final CheckInStatus status;

  CheckInRecord({
    required this.id,
    required this.checkInTime,
    required this.streak,
    required this.motivationalQuote,
    required this.status,
  });

  factory CheckInRecord.fromJson(Map<String, dynamic> json) {
    return CheckInRecord(
      id: json['id'] as String,
      checkInTime: DateTime.parse(json['checkInTime'] as String),
      streak: json['streak'] as int,
      motivationalQuote: json['motivationalQuote'] as String,
      status: CheckInStatus.values.firstWhere(
        (e) => e.toString() == 'CheckInStatus.${json['status']}',
        orElse: () => CheckInStatus.onTime,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checkInTime': checkInTime.toIso8601String(),
      'streak': streak,
      'motivationalQuote': motivationalQuote,
      'status': status.toString().split('.').last,
    };
  }

  CheckInRecord copyWith({
    String? id,
    DateTime? checkInTime,
    int? streak,
    String? motivationalQuote,
    CheckInStatus? status,
  }) {
    return CheckInRecord(
      id: id ?? this.id,
      checkInTime: checkInTime ?? this.checkInTime,
      streak: streak ?? this.streak,
      motivationalQuote: motivationalQuote ?? this.motivationalQuote,
      status: status ?? this.status,
    );
  }

  String get formattedTime => DateFormat('HH:mm').format(checkInTime);
  String get formattedDate => DateFormat('MMM dd, yyyy').format(checkInTime);
}

enum CheckInStatus {
  earlyBird,
  onTime,
  lateNightOwl,
}

extension CheckInStatusExtension on CheckInStatus {
  String get displayName {
    switch (this) {
      case CheckInStatus.earlyBird:
        return 'Early Bird';
      case CheckInStatus.onTime:
        return 'On Time';
      case CheckInStatus.lateNightOwl:
        return 'Late Check-in';
    }
  }

  String get emoji {
    switch (this) {
      case CheckInStatus.earlyBird:
        return '🌅';
      case CheckInStatus.onTime:
        return '⏰';
      case CheckInStatus.lateNightOwl:
        return '🦉';
    }
  }
}
