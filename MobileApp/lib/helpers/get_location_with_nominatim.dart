import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationService {
  static const String _nominatimBaseUrl = 'https://nominatim.openstreetmap.org';

  /// Get location name from latitude and longitude using Nominatim reverse geocoding
  /// Returns a formatted location string like "City, Country" or null if failed
  static Future<String?> getLocationName({
    required double latitude,
    required double longitude,
    String language = 'en',
  }) async {
    try {
      final uri = Uri.parse(
        '$_nominatimBaseUrl/reverse'
            '?lat=$latitude'
            '&lon=$longitude'
            '&format=json'
            '&accept-language=$language'
            '&zoom=10'
            '&addressdetails=1',
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'Flutter Weather App', // Required by Nominatim
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return _formatLocationName(data);
      } else {
        print('Nominatim API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting location name: $e');
      return null;
    }
  }

  /// Get detailed location information from latitude and longitude
  /// Returns a LocationInfo object with detailed address components
  static Future<LocationInfo?> getDetailedLocation({
    required double latitude,
    required double longitude,
    String language = 'en',
  }) async {
    try {
      final uri = Uri.parse(
        '$_nominatimBaseUrl/reverse'
            '?lat=$latitude'
            '&lon=$longitude'
            '&format=json'
            '&accept-language=$language'
            '&zoom=18'
            '&addressdetails=1',
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'Flutter Weather App',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return LocationInfo.fromJson(data);
      } else {
        print('Nominatim API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting detailed location: $e');
      return null;
    }
  }

  /// Private method to format location name from Nominatim response
  static String _formatLocationName(Map<String, dynamic> data) {
    final address = data['address'] as Map<String, dynamic>?;

    if (address == null) {
      return data['display_name'] ?? 'Unknown Location';
    }

    // Priority order for location components
    final city = address['city'] ??
        address['town'] ??
        address['village'] ??
        address['hamlet'] ??
        address['municipality'];

    final state = address['state'] ??
        address['province'] ??
        address['region'];

    final country = address['country'];

    // Build location string
    List<String> parts = [];

    if (city != null) {
      parts.add(city);
    }

    if (state != null && state != city) {
      parts.add(state);
    }

    if (country != null) {
      parts.add(country);
    }

    return parts.isNotEmpty ? parts.join(', ') : 'Unknown Location';
  }
}

class LocationInfo {
  final String displayName;
  final String? city;
  final String? state;
  final String? country;
  final String? countryCode;
  final String? postcode;
  final String? road;
  final String? neighbourhood;
  final double latitude;
  final double longitude;

  LocationInfo({
    required this.displayName,
    this.city,
    this.state,
    this.country,
    this.countryCode,
    this.postcode,
    this.road,
    this.neighbourhood,
    required this.latitude,
    required this.longitude,
  });

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;

    return LocationInfo(
      displayName: json['display_name'] ?? 'Unknown Location',
      city: address?['city'] ??
          address?['town'] ??
          address?['village'] ??
          address?['hamlet'] ??
          address?['municipality'],
      state: address?['state'] ??
          address?['province'] ??
          address?['region'],
      country: address?['country'],
      countryCode: address?['country_code'],
      postcode: address?['postcode'],
      road: address?['road'],
      neighbourhood: address?['neighbourhood'] ?? address?['suburb'],
      latitude: double.tryParse(json['lat']?.toString() ?? '0') ?? 0,
      longitude: double.tryParse(json['lon']?.toString() ?? '0') ?? 0,
    );
  }

  /// Get a short formatted location string
  String get shortName {
    List<String> parts = [];

    if (city != null) {
      parts.add(city!);
    }

    if (country != null) {
      parts.add(country!);
    }

    return parts.isNotEmpty ? parts.join(', ') : displayName;
  }

  /// Get a medium formatted location string
  String get mediumName {
    List<String> parts = [];

    if (city != null) {
      parts.add(city!);
    }

    if (state != null && state != city) {
      parts.add(state!);
    }

    if (country != null) {
      parts.add(country!);
    }

    return parts.isNotEmpty ? parts.join(', ') : displayName;
  }

  @override
  String toString() => mediumName;
}