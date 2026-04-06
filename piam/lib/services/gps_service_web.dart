// Stub web pour GPSService : toutes les méthodes lèvent une exception ou retournent des valeurs vides.
// Placez ce fichier à côté de gps_service.dart

class GPSService {
  static Future<bool> requestPermission() async => false;
  static Future<GPSPosition> getLastPosition() async => GPSPosition();
}

class GPSPosition {
  double get latitude => 0.0;
  double get longitude => 0.0;
}
