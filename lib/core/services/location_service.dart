import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position?> getCurrentLocation() async {
    LocationPermission permission;

    // Check permissions
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    // Get actual location
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    
  }

static Future<String?> getAddressFromCoordinates(double lat, double lng) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

    if (placemarks.isNotEmpty) {
      final p = placemarks.first;

      return "${p.locality ?? ''}, ${p.administrativeArea ?? ''}, ${p.country ?? ''}"
          .replaceAll(" ,", "")  // cleanup empty values
          .trim();
    }
  } catch (e) {
    print("Reverse Geocoding Error: $e");
  }

  return null;
}

}
