import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    print('LocationService: Checking if location service is enabled');
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission status
  Future<LocationPermission> checkPermission() async {
    print('LocationService: Checking location permission');
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    print('LocationService: Requesting location permission');
    return await Geolocator.requestPermission();
  }

  /// Get current location with lat and long
  Future<LocationData?> getCurrentLocation() async {
    try {
      print('LocationService: Getting current location...');

      // Check if location service is enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('LocationService: Location services are disabled');
        throw LocationException('Location services are disabled. Please enable location in settings.');
      }

      // Check permission
      LocationPermission permission = await checkPermission();
      
      if (permission == LocationPermission.denied) {
        print('LocationService: Location permission denied, requesting...');
        permission = await requestPermission();
        
        if (permission == LocationPermission.denied) {
          print('LocationService: Location permission denied by user');
          throw LocationException('Location permission denied. Please allow location access.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('LocationService: Location permission permanently denied');
        throw LocationException('Location permission permanently denied. Please enable in app settings.');
      }

      // Get current position
      print('LocationService: Fetching GPS coordinates...');
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      print('LocationService: Location fetched - Lat: ${position.latitude}, Long: ${position.longitude}');

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: position.timestamp ?? DateTime.now(),
      );
    } on LocationException catch (e) {
      print('LocationService: LocationException - ${e.message}');
      rethrow;
    } catch (e) {
      print('LocationService: Error getting location - $e');
      throw LocationException('Failed to get location. Please try again.');
    }
  }

  /// Open app settings for permissions
  Future<bool> openAppSettings() async {
    print('LocationService: Opening app settings');
    return await Geolocator.openAppSettings();
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    print('LocationService: Opening location settings');
    return await Geolocator.openLocationSettings();
  }
}

/// Location data model
class LocationData {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'LocationData(lat: $latitude, long: $longitude, accuracy: $accuracy)';
  }
}

/// Custom location exception
class LocationException implements Exception {
  final String message;
  LocationException(this.message);

  @override
  String toString() => message;
}