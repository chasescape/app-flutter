class CreatePrefill {
  final String? destination;
  final String? season;
  final String? time;
  final String? style;
  final String? landmark;
  final String? mood;
  final bool? localPeople;

  const CreatePrefill({
    this.destination,
    this.season,
    this.time,
    this.style,
    this.landmark,
    this.mood,
    this.localPeople,
  });

  factory CreatePrefill.fromJson(Map<String, dynamic> json) {
    return CreatePrefill(
      destination: _asNullableString(json['destination']),
      season: _asNullableString(json['season']),
      time: _asNullableString(json['time']),
      style: _asNullableString(json['style']),
      landmark: _asNullableString(json['landmark']),
      mood: _asNullableString(json['mood']),
      localPeople: _asNullableBool(json['local_people'] ?? json['localPeople']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'destination': destination,
      'season': season,
      'time': time,
      'style': style,
      'landmark': landmark,
      'mood': mood,
      'local_people': localPeople,
    };
  }

  static String? _asNullableString(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static bool? _asNullableBool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    final s = v.toString().trim().toLowerCase();
    if (s == 'true' || s == '1' || s == 'yes') return true;
    if (s == 'false' || s == '0' || s == 'no') return false;
    return null;
  }
}
