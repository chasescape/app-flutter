import 'package:flutter/material.dart';

/// Simple, shared mock travel data used by multiple modules.
/// Later this can be replaced by real persistence (local DB / API).

class TravelPlaceData {
  const TravelPlaceData({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.latitude,
    required this.longitude,
    this.color,
  });

  final String id;
  final String name;
  final String subtitle;
  final double latitude;
  final double longitude;
  final Color? color;
}

/// Shared mock places: used by Guides, Calendar and other modules.
const List<TravelPlaceData> kMockTravelPlaces = [
  TravelPlaceData(
    id: 'place_sensoji',
    name: 'Senso-ji Temple',
    subtitle: 'Asakusa, Taito City, Tokyo',
    latitude: 35.714765,
    longitude: 139.796655,
  ),
  TravelPlaceData(
    id: 'place_tokyo_tower',
    name: 'Tokyo Tower',
    subtitle: 'Minato City, Tokyo',
    latitude: 35.65858,
    longitude: 139.745433,
  ),
  TravelPlaceData(
    id: 'place_shibuya_crossing',
    name: 'Shibuya Crossing',
    subtitle: 'Shibuya City, Tokyo',
    latitude: 35.6595,
    longitude: 139.7005,
  ),
  TravelPlaceData(
    id: 'place_shinjuku_gyoen',
    name: 'Shinjuku Gyoen',
    subtitle: 'Shinjuku City, Tokyo',
    latitude: 35.685176,
    longitude: 139.710052,
  ),
  TravelPlaceData(
    id: 'place_meiji_jingu',
    name: 'Meiji Jingu',
    subtitle: 'Harajuku, Shibuya City, Tokyo',
    latitude: 35.676397,
    longitude: 139.699325,
  ),
  TravelPlaceData(
    id: 'place_fushimi_inari',
    name: 'Fushimi Inari Taisha',
    subtitle: 'Fushimi Ward, Kyoto',
    latitude: 34.967146,
    longitude: 135.772671,
  ),
  TravelPlaceData(
    id: 'place_kiyomizu_dera',
    name: 'Kiyomizu-dera',
    subtitle: 'Higashiyama Ward, Kyoto',
    latitude: 34.994857,
    longitude: 135.785046,
  ),
  TravelPlaceData(
    id: 'place_osaka_castle',
    name: 'Osaka Castle',
    subtitle: 'Chuo Ward, Osaka',
    latitude: 34.687315,
    longitude: 135.525932,
  ),
];

