// This file provides no-op stubs for geolocator/geocoding on web so conditional imports work.
// It is only imported on web builds.

class Geolocator {
  static Future<bool> isLocationServiceEnabled() async => false;
  static Future<LocationPermission> checkPermission() async =>
      LocationPermission.denied;
  static Future<LocationPermission> requestPermission() async =>
      LocationPermission.denied;
  static Future<Position> getCurrentPosition({dynamic desiredAccuracy}) async =>
      Position();
}

enum LocationPermission { denied, deniedForever, whileInUse, always }

enum LocationAccuracy { high }

class Position {
  double get latitude => 0.0;
  double get longitude => 0.0;
}

class Placemark {
  String? get locality => null;
  String? get subAdministrativeArea => null;
  String? get country => null;
}

Future<List<Placemark>> placemarkFromCoordinates(
  double lat,
  double lng,
) async => <Placemark>[];
