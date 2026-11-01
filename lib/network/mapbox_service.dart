import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../utils/app_common.dart';

/// Service for Mapbox geocoding operations
class MapboxService {
  /// Get the Mapbox access token from app configuration
  static String get accessToken => appConfigs.value.mapboxKey;

  /// Check if Mapbox is enabled
  static bool get isEnabled =>
      appConfigs.value.enableMapbox && appConfigs.value.mapboxKey.isNotEmpty;

  /// Reverse geocode: Convert coordinates to address
  /// Uses Mapbox Geocoding API to get address from lat/lng
  static Future<String> reverseGeocode(
      double latitude, double longitude) async {
    if (!isEnabled) {
      throw Exception(
          'Mapbox is not enabled. Please configure it from admin panel.');
    }

    try {
      final url = Uri.parse(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$longitude,$latitude.json'
        '?access_token=$accessToken'
        '&types=address,place,locality,neighborhood'
        '&limit=1',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final features = data['features'] as List?;

        if (features != null && features.isNotEmpty) {
          return features.first['place_name'] as String? ?? '';
        }
        return '';
      } else {
        log('Mapbox geocoding error: ${response.statusCode}');
        throw Exception('Failed to get address from Mapbox');
      }
    } catch (e) {
      log('Mapbox reverseGeocode error: $e');
      rethrow;
    }
  }

  /// Forward geocode: Search for addresses/places
  /// Returns list of places matching the search query
  static Future<List<MapboxPlace>> searchPlaces(String query) async {
    if (!isEnabled) {
      throw Exception(
          'Mapbox is not enabled. Please configure it from admin panel.');
    }

    if (query.isEmpty) return [];

    try {
      final url = Uri.parse(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/${Uri.encodeComponent(query)}.json'
        '?access_token=$accessToken'
        '&types=address,place,locality,neighborhood,poi'
        '&limit=5',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final features = data['features'] as List?;

        if (features != null) {
          return features
              .map((f) => MapboxPlace.fromJson(f as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        log('Mapbox search error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Mapbox searchPlaces error: $e');
      return [];
    }
  }
}

/// Model for Mapbox place result
class MapboxPlace {
  final String placeName;
  final double latitude;
  final double longitude;
  final String? address;

  MapboxPlace({
    required this.placeName,
    required this.latitude,
    required this.longitude,
    this.address,
  });

  factory MapboxPlace.fromJson(Map<String, dynamic> json) {
    final center = json['center'] as List?;
    return MapboxPlace(
      placeName: json['place_name'] as String? ?? '',
      longitude: center?[0]?.toDouble() ?? 0.0,
      latitude: center?[1]?.toDouble() ?? 0.0,
      address: json['place_name'] as String?,
    );
  }
}
