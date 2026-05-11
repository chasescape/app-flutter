import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/services.dart';

class AppleMapsSearchResult {
  AppleMapsSearchResult({
    required this.name,
    required this.subtitle,
    required this.position,
  });

  final String name;
  final String subtitle;
  final LatLng position;

  factory AppleMapsSearchResult.fromMap(Map<dynamic, dynamic> map) {
    return AppleMapsSearchResult(
      name: (map['name'] ?? '') as String,
      subtitle: (map['subtitle'] ?? '') as String,
      position: LatLng(
        (map['lat'] as num).toDouble(),
        (map['lng'] as num).toDouble(),
      ),
    );
  }
}

class AppleMapsSearchService {
  static const MethodChannel _channel =
      MethodChannel('enkou.apple_maps/search');

  static Future<List<AppleMapsSearchResult>> searchPlaces(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final dynamic raw = await _channel.invokeMethod(
      'searchPlaces',
      <String, dynamic>{'query': trimmed},
    );

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => AppleMapsSearchResult.fromMap(e))
          .toList();
    }
    return [];
  }
}

