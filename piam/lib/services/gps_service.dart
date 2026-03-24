import 'package:geolocator/geolocator.dart';

class GPSService {
  static Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  static Future<Position> getLastPosition() async {
    if (!await requestPermission()) {
      throw Exception('Permission GPS non accordée');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }
}
