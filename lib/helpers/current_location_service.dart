import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'get_location_with_nominatim.dart';

class CurrentLocationService {
  /// Get current user location with automatic permission handling
  /// Returns Position object with latitude and longitude or null if failed/denied
  static Future<Position?> getCurrentLocation({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration? timeout = const Duration(seconds: 15),
  }) async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        return null;
      }

      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();

      // Request permission if not granted
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return null;
        }
      }

      // Handle permanently denied permissions
      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        return null;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          timeLimit: timeout,
        ),
      );

      return position;
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  /// Get current location with location name using reverse geocoding
  /// Returns LocationResult object with position and formatted location name
  static Future<LocationResult?> getCurrentLocationWithName({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration? timeout = const Duration(seconds: 15),
    String language = 'en',
  }) async {
    try {
      // Get current position
      final position = await getCurrentLocation(
        accuracy: accuracy,
        timeout: timeout,
      );

      if (position == null) {
        return null;
      }

      // Get location name using reverse geocoding
      final locationName = await LocationService.getLocationName(
        latitude: position.latitude,
        longitude: position.longitude,
        language: language,
      );

      return LocationResult(
        position: position,
        locationName: locationName ?? 'Unknown Location',
      );
    } catch (e) {
      print('Error getting current location with name: $e');
      return null;
    }
  }

  /// Check if location permission is granted
  static Future<bool> hasLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Open app settings for manual permission granting
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings page
  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Get location permission status as a readable string
  static Future<String> getPermissionStatus() async {
    final permission = await Geolocator.checkPermission();
    switch (permission) {
      case LocationPermission.denied:
        return 'Permission denied';
      case LocationPermission.deniedForever:
        return 'Permission permanently denied';
      case LocationPermission.whileInUse:
        return 'Permission granted while in use';
      case LocationPermission.always:
        return 'Permission always granted';
      default:
        return 'Unknown permission status';
    }
  }

  /// Watch location changes (for real-time updates)
  static Stream<Position> watchPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10, // meters
    Duration interval = const Duration(seconds: 5),
  }) {
    final settings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
      timeLimit: interval,
    );

    return Geolocator.getPositionStream(locationSettings: settings);
  }
}

class LocationResult {
  final Position position;
  final String locationName;

  LocationResult({
    required this.position,
    required this.locationName,
  });

  double get latitude => position.latitude;
  double get longitude => position.longitude;
  double get accuracy => position.accuracy;
  DateTime get timestamp => position.timestamp;

  @override
  String toString() => '$locationName (${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)})';
}

// Alternative implementation using permission_handler package
class AlternativeLocationService {
  /// Get current location using permission_handler package
  /// More control over permission handling
  static Future<Position?> getCurrentLocationWithPermissionHandler({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration? timeout = const Duration(seconds: 15),
  }) async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        return null;
      }

      // Check permission using permission_handler
      var permission = await Permission.location.status;

      if (permission.isDenied) {
        // Request permission
        permission = await Permission.location.request();

        if (permission.isDenied) {
          print('Location permission denied');
          return null;
        }
      }

      if (permission.isPermanentlyDenied) {
        print('Location permission permanently denied. Please enable it in settings.');
        // You can show dialog to open settings
        // await openAppSettings();
        return null;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          timeLimit: timeout,
        )
      );

      return position;
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }
}
